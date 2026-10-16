import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/telemetry.dart';

class TelemetryService {
  static final TelemetryService instance = TelemetryService._();
  TelemetryService._() {
    _initDefaultHost();
  }

  void _initDefaultHost() {
    // Default to 127.0.0.1:8000 which works on Desktop, Web, and Android with adb reverse
    _host = '127.0.0.1:8000';
    initHostFromPrefs();
  }

  Future<void> initHostFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedHost = prefs.getString('sim_backend_host') ?? prefs.getString('custom_host');
      if (savedHost != null && savedHost.trim().isNotEmpty) {
        _host = savedHost.trim();
      }
    } catch (_) {}
  }

  String _host = '127.0.0.1:8000';
  String get host => _host;
  set host(String value) {
    setHost(value);
  }

  Future<void> setHost(String value) async {
    final sanitized = value
        .trim()
        .replaceAll('http://', '')
        .replaceAll('https://', '')
        .replaceAll('ws://', '')
        .replaceAll('wss://', '');
    _host = sanitized;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sim_backend_host', _host);
    } catch (_) {}
    if (isConnected && _activeElderId != null) {
      connectWebSocket(_activeElderId!);
    }
  }

  /// Checks if a given host responds 200 OK to /health within 1.2 seconds.
  Future<bool> checkHealth([String? targetHost]) async {
    final target = targetHost ?? _host;
    try {
      final res = await http
          .get(Uri.parse('http://$target/health'))
          .timeout(const Duration(milliseconds: 1500));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Probes multiple common endpoints (adb reverse, LAN IP, emulator) and switches to the first responding host.
  Future<String?> probeWorkingHost() async {
    if (await checkHealth(_host)) {
      return _host;
    }

    final candidates = [
      '127.0.0.1:8000',
      '192.168.1.10:8000',
      '10.0.2.2:8000',
    ];

    for (final c in candidates) {
      if (c == _host) continue;
      if (await checkHealth(c)) {
        debugPrint('Auto-discovered active simulation backend at: $c');
        await setHost(c);
        return c;
      }
    }
    return null;
  }

  String get baseUrl => 'http://$_host';
  String get wsBaseUrl => 'ws://$_host';

  String? _token;
  String? get token => _token;

  String? _activeElderId;
  String? get activeElderId => _activeElderId;

  ElderSummary? _activeElder;
  ElderSummary? get activeElder => _activeElder;

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  bool _shouldReconnect = false;
  bool _connecting = false;

  final _vitalsController = StreamController<VitalsData>.broadcast();
  final _alertsController = StreamController<AlertItem>.broadcast();
  final _locationController = StreamController<LocationData>.broadcast();
  final _measurementController = StreamController<MeasurementData>.broadcast();
  final _scenarioController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  Stream<VitalsData> get vitalsStream => _vitalsController.stream;
  Stream<AlertItem> get alertsStream => _alertsController.stream;
  Stream<LocationData> get locationStream => _locationController.stream;
  Stream<MeasurementData> get measurementStream => _measurementController.stream;
  Stream<Map<String, dynamic>> get scenarioStream => _scenarioController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;

  bool get isConnected => _channel != null;

  VitalsData latestVitals = VitalsData.initial();
  LocationData latestLocation = LocationData.initial();
  MeasurementData? latestBp;
  MeasurementData? latestGlucose;
  final List<AlertItem> currentAlerts = [];

  Future<void> initSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    final savedHost = prefs.getString('sim_backend_host') ?? prefs.getString('custom_host');
    if (savedHost != null && savedHost.isNotEmpty) {
      _host = savedHost;
    }
    await probeWorkingHost();
  }

  /// Ensures user is authenticated; auto-logs in with demo caregiver credentials if needed.
  Future<bool> ensureAuthenticated() async {
    if (_token != null && _token!.isNotEmpty) return true;
    return await login('caregiver@demo.id', 'demo1234');
  }

  Future<bool> login(String email, String password) async {
    // Probe working host first if current host doesn't respond
    if (!await checkHealth(_host)) {
      await probeWorkingHost();
    }

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _token = data['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        return true;
      }
    } catch (e) {
      debugPrint('Login failed on $baseUrl: $e. Probing candidate hosts...');
    }

    // Try probing other candidate hosts on error
    final fallbackHost = await probeWorkingHost();
    if (fallbackHost != null && fallbackHost != _host) {
      try {
        final res = await http.post(
          Uri.parse('$baseUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        ).timeout(const Duration(seconds: 4));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          _token = data['access_token'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', _token!);
          return true;
        }
      } catch (_) {}
    }

    return false;
  }

  Future<void> logout() async {
    disconnectWebSocket();
    _token = null;
    _activeElderId = null;
    _activeElder = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<List<ElderSummary>> getElders() async {
    if (_token == null) return [];
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/elders'),
        headers: {'Authorization': 'Bearer $_token'},
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        final elders = list.map((e) => ElderSummary.fromJson(e)).toList();
        if (elders.isNotEmpty) {
          _activeElder = elders.first;
          _activeElderId = elders.first.id;
        }
        return elders;
      }
    } catch (e) {
      debugPrint('Error getting elders: $e');
    }
    return [];
  }

  Future<void> loadInitialData(String elderId) async {
    _activeElderId = elderId;
    if (_token == null) return;

    try {
      // 1. Fetch latest vitals
      final vitalsRes = await http.get(
        Uri.parse('$baseUrl/elders/$elderId/vitals/latest'),
        headers: {'Authorization': 'Bearer $_token'},
      ).timeout(const Duration(seconds: 4));

      if (vitalsRes.statusCode == 200) {
        final data = jsonDecode(vitalsRes.body);
        if (data['vitals'] != null) {
          latestVitals = VitalsData.fromJson(data['vitals']);
          _vitalsController.add(latestVitals);
        }
        if (data['bp'] != null) {
          latestBp = MeasurementData(
            kind: 'bp',
            value1: (data['bp']['systolic'] as num).toDouble(),
            value2: (data['bp']['diastolic'] as num).toDouble(),
            ts: DateTime.tryParse(data['bp']['ts'] ?? '') ?? DateTime.now(),
          );
          _measurementController.add(latestBp!);
        }
      }

      // 2. Fetch latest alerts
      final alertsRes = await http.get(
        Uri.parse('$baseUrl/elders/$elderId/alerts?limit=20'),
        headers: {'Authorization': 'Bearer $_token'},
      ).timeout(const Duration(seconds: 4));

      if (alertsRes.statusCode == 200) {
        final list = jsonDecode(alertsRes.body) as List<dynamic>;
        currentAlerts.clear();
        for (var item in list) {
          currentAlerts.add(AlertItem.fromJson(item));
        }
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    }
  }

  Future<void> connectWebSocket(String elderId) async {
    if (_connecting) return;
    _connecting = true;
    _shouldReconnect = true;
    _activeElderId = elderId;

    if (_token == null || _token!.isEmpty) {
      final ok = await ensureAuthenticated();
      if (!ok) {
        _connecting = false;
        _connectionController.add(false);
        return;
      }
    }

    disconnectWebSocket(internal: true);

    try {
      final wsUrl = '$wsBaseUrl/ws/$elderId?token=$_token';
      debugPrint('Connecting to WebSocket: $wsUrl');
      final uri = Uri.parse(wsUrl);
      _channel = WebSocketChannel.connect(uri);
      _connectionController.add(true);

      _sub = _channel!.stream.listen(
        (raw) {
          _connecting = false;
          try {
            final msg = jsonDecode(raw);
            final type = msg['type'];

            if (type == 'ping') {
              _channel?.sink.add(jsonEncode({'type': 'pong'}));
            } else if (type == 'vitals') {
              final vitals = VitalsData.fromJson(msg['data']);
              latestVitals = vitals;
              _vitalsController.add(vitals);
            } else if (type == 'alert') {
              final alert = AlertItem.fromJson(msg['data']);
              currentAlerts.insert(0, alert);
              _alertsController.add(alert);
            } else if (type == 'location') {
              final loc = LocationData.fromJson(msg['data']);
              latestLocation = loc;
              _locationController.add(loc);
            } else if (type == 'measurement') {
              final m = MeasurementData.fromJson(msg['data']);
              if (m.kind == 'bp') latestBp = m;
              if (m.kind == 'glucose') latestGlucose = m;
              _measurementController.add(m);
            } else if (type == 'scenario') {
              _scenarioController.add(Map<String, dynamic>.from(msg['data']));
            }
          } catch (e) {
            debugPrint('Error parsing WS message: $e');
          }
        },
        onError: (err) {
          debugPrint('WS error: $err');
          _onDisconnect();
        },
        onDone: () {
          debugPrint('WS closed');
          _onDisconnect();
        },
      );
    } catch (e) {
      debugPrint('WS connect exception: $e');
      _onDisconnect();
    }
  }

  void _onDisconnect() {
    _connecting = false;
    _channel = null;
    _connectionController.add(false);
    if (_shouldReconnect && _activeElderId != null) {
      Future.delayed(const Duration(seconds: 3), () {
        if (_shouldReconnect && _activeElderId != null) {
          connectWebSocket(_activeElderId!);
        }
      });
    }
  }

  void disconnectWebSocket({bool internal = false}) {
    if (!internal) _shouldReconnect = false;
    _sub?.cancel();
    _channel?.sink.close();
    _channel = null;
    _connectionController.add(false);
  }

  Future<bool> triggerScenario(String scenario, {int duration = 30}) async {
    final elderId = _activeElderId;
    if (elderId == null || _token == null) return false;

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/sim/$elderId/trigger'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'scenario': scenario,
          'duration_s': duration,
        }),
      ).timeout(const Duration(seconds: 5));

      return res.statusCode == 200;
    } catch (e) {
      debugPrint('Error triggering scenario: $e');
      return false;
    }
  }

  // --- Random Simulation Controller ---
  bool randomSimEnabled = false;
  Timer? _randomSimTimer;
  String? lastRandomScenario;

  static const List<String> availableScenarios = [
    'fall',
    'tachycardia',
    'bradycardia',
    'hypoxia',
    'fever',
    'wander',
    'hypertensive',
    'hypoglycemia',
  ];

  void setRandomSimulationEnabled(bool enabled) {
    randomSimEnabled = enabled;
    _randomSimTimer?.cancel();
    _randomSimTimer = null;

    if (enabled) {
      _scheduleNextRandomEvent();
    } else {
      triggerScenario('normal');
    }
  }

  void _scheduleNextRandomEvent() {
    if (!randomSimEnabled) return;
    // Delay randomly between 20 and 35 seconds
    final delaySeconds = 20 + Random().nextInt(16);
    _randomSimTimer = Timer(Duration(seconds: delaySeconds), () async {
      if (!randomSimEnabled) return;
      await triggerRandomScenario();
      _scheduleNextRandomEvent();
    });
  }

  Future<String?> triggerRandomScenario() async {
    final pool = List<String>.from(availableScenarios);
    pool.shuffle();
    final chosen = pool.first;
    lastRandomScenario = chosen;
    await triggerScenario(chosen);
    return chosen;
  }

  void acknowledgeAlertLocally(String alertId) {
    final idx = currentAlerts.indexWhere((a) => a.id == alertId);
    if (idx != -1) {
      currentAlerts[idx].acknowledged = true;
      _alertsController.add(currentAlerts[idx]);
    }
  }

  Future<bool> acknowledgeAlert(String alertId) async {
    acknowledgeAlertLocally(alertId);
    if (_token == null) return false;
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/alerts/$alertId/ack'),
        headers: {'Authorization': 'Bearer $_token'},
      ).timeout(const Duration(seconds: 4));

      return res.statusCode == 200;
    } catch (e) {
      debugPrint('Error acknowledging alert on server: $e');
    }
    return false;
  }

  Future<bool> sendSos({String? note}) async {
    final elderId = _activeElderId;
    if (elderId == null || _token == null) return false;
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/elders/$elderId/sos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(note != null ? {'note': note} : {}),
      ).timeout(const Duration(seconds: 5));

      return res.statusCode == 200;
    } catch (e) {
      debugPrint('Error sending SOS: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> generateSmartReport({int days = 7}) async {
    final elderId = _activeElderId;
    if (elderId == null || _token == null) return null;
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/elders/$elderId/reports/generate?days=$days'),
        headers: {'Authorization': 'Bearer $_token'},
      ).timeout(const Duration(seconds: 20));

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('Error generating report: $e');
    }
    return null;
  }
}
