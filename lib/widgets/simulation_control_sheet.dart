import 'dart:async';
import 'package:flutter/material.dart';
import '../models/telemetry.dart';
import '../services/telemetry_service.dart';

void showSimulationSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => const SimulationControlSheet(),
  );
}

class SimulationControlSheet extends StatefulWidget {
  const SimulationControlSheet({super.key});

  @override
  State<SimulationControlSheet> createState() => _SimulationControlSheetState();
}

class _SimulationControlSheetState extends State<SimulationControlSheet> {
  String? _loadingScenario;
  List<ElderSummary> _elders = [];

  StreamSubscription<bool>? _connSub;

  @override
  void initState() {
    super.initState();
    _loadElders();
    _connSub = TelemetryService.instance.connectionStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _connSub?.cancel();
    super.dispose();
  }

  Future<void> _loadElders() async {
    await TelemetryService.instance.ensureAuthenticated();
    final list = await TelemetryService.instance.getElders();
    if (mounted) {
      setState(() => _elders = list);
    }
    if (!TelemetryService.instance.isConnected && list.isNotEmpty) {
      await TelemetryService.instance.connectWebSocket(list.first.id);
      if (mounted) setState(() {});
    }
  }

  Future<void> _trigger(String scenario, String label) async {
    setState(() => _loadingScenario = scenario);
    await TelemetryService.instance.ensureAuthenticated();
    final ok = await TelemetryService.instance.triggerScenario(scenario);
    if (!mounted) return;
    setState(() => _loadingScenario = null);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Skenario "$label" berhasil dipicu! Menunggu respon engine...'
            : 'Gagal memicu skenario. Pastikan backend aktif.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  void _editBackendHost(BuildContext context) {
    final controller = TextEditingController(text: TelemetryService.instance.host);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Host Backend', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gunakan 127.0.0.1:8000 untuk USB/adb reverse atau Desktop, 192.168.1.10:8000 untuk Wi-Fi, atau 10.0.2.2:8000 untuk Emulator.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Host:Port',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ActionChip(
                  label: const Text('127.0.0.1:8000', style: TextStyle(fontSize: 11)),
                  onPressed: () => controller.text = '127.0.0.1:8000',
                ),
                ActionChip(
                  label: const Text('192.168.1.10:8000', style: TextStyle(fontSize: 11)),
                  onPressed: () => controller.text = '192.168.1.10:8000',
                ),
                ActionChip(
                  label: const Text('10.0.2.2:8000', style: TextStyle(fontSize: 11)),
                  onPressed: () => controller.text = '10.0.2.2:8000',
                ),
              ],
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final found = await TelemetryService.instance.probeWorkingHost();
              await _loadElders();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(found != null
                        ? 'Backend aktif ditemukan di: $found'
                        : 'Tidak dapat menemukan backend aktif otomatis.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Deteksi Otomatis'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newHost = controller.text.trim();
              if (newHost.isNotEmpty) {
                await TelemetryService.instance.setHost(newHost);
                await _loadElders();
                if (mounted) setState(() {});
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Simpan & Reconnect'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeElder = TelemetryService.instance.activeElder;
    final isConnected = TelemetryService.instance.isConnected;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        6,
        22,
        MediaQuery.viewInsetsOf(context).bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F5F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.tune_rounded, color: Color(0xFF176E9E)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pusat Kontrol Simulasi',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF123D4F),
                      ),
                    ),
                    Text(
                      'Picukan kejadian darurat untuk uji respon aplikasi',
                      style: TextStyle(fontSize: 12, color: Color(0xFF627B84)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: (isConnected ? const Color(0xFF35A66F) : Colors.orange)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: isConnected ? const Color(0xFF35A66F) : Colors.orange,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isConnected ? 'Live WS' : 'Offline',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color:
                            isConnected ? const Color(0xFF35A66F) : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Elder Selector
          if (_elders.isNotEmpty) ...[
            const Text(
              'Lansia Target:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _elders.map((elder) {
                  final isSelected = elder.id == activeElder?.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Text(elder.name),
                      avatar: Icon(
                        Icons.elderly_rounded,
                        size: 18,
                        color: isSelected ? Colors.white : const Color(0xFF176E9E),
                      ),
                      selectedColor: const Color(0xFF176E9E),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF123D4F),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      onSelected: (val) {
                        if (val) {
                          TelemetryService.instance.loadInitialData(elder.id);
                          TelemetryService.instance.connectWebSocket(elder.id);
                          setState(() {});
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          const Text(
            'PILIH SKENARIO PENGUJIAN:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: Color(0xFF627B84),
            ),
          ),
          const SizedBox(height: 12),

          // Quick Scenario Buttons Grid
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ScenarioCard(
                title: 'Normal / Reset',
                subtitle: 'Kembali ke kondisi normal',
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xFF35A66F),
                loading: _loadingScenario == 'normal',
                onTap: () => _trigger('normal', 'Normal'),
              ),
              _ScenarioCard(
                title: 'Jatuh (Fall)',
                subtitle: 'Spike 3.4g -> diam -> Auto-SOS',
                icon: Icons.personal_injury_rounded,
                color: const Color(0xFFE95858),
                highlight: true,
                loading: _loadingScenario == 'fall',
                onTap: () => _trigger('fall', 'Jatuh (Auto-SOS)'),
              ),
              _ScenarioCard(
                title: 'Takikardia',
                subtitle: 'Detak jantung naik > 130 bpm',
                icon: Icons.monitor_heart_rounded,
                color: const Color(0xFFE95858),
                loading: _loadingScenario == 'tachycardia',
                onTap: () => _trigger('tachycardia', 'Takikardia'),
              ),
              _ScenarioCard(
                title: 'Bradikardia',
                subtitle: 'Detak jantung turun < 40 bpm',
                icon: Icons.heart_broken_rounded,
                color: const Color(0xFFF5A524),
                loading: _loadingScenario == 'bradycardia',
                onTap: () => _trigger('bradycardia', 'Bradikardia'),
              ),
              _ScenarioCard(
                title: 'Hipoksia',
                subtitle: 'Saturasi SpO2 turun ke 87%',
                icon: Icons.air_rounded,
                color: const Color(0xFFF5A524),
                loading: _loadingScenario == 'hypoxia',
                onTap: () => _trigger('hypoxia', 'Hipoksia'),
              ),
              _ScenarioCard(
                title: 'Demam Tinggi',
                subtitle: 'Suhu tubuh naik ke 38.6°C',
                icon: Icons.thermostat_rounded,
                color: const Color(0xFFF5A524),
                loading: _loadingScenario == 'fever',
                onTap: () => _trigger('fever', 'Demam Tinggi'),
              ),
              _ScenarioCard(
                title: 'Keluar Zona (Wander)',
                subtitle: 'GPS keluar batas aman 150m',
                icon: Icons.navigation_rounded,
                color: const Color(0xFF176E9E),
                loading: _loadingScenario == 'wander',
                onTap: () => _trigger('wander', 'Keluar Zona Aman'),
              ),
              _ScenarioCard(
                title: 'Hipertensi',
                subtitle: 'Tensi melonjak ke 192/124',
                icon: Icons.speed_rounded,
                color: const Color(0xFFE95858),
                loading: _loadingScenario == 'hypertensive',
                onTap: () => _trigger('hypertensive', 'Lonjakan Hipertensi'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Center(
            child: InkWell(
              onTap: () => _editBackendHost(context),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Backend: ${TelemetryService.instance.baseUrl}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF627B84),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit_rounded, size: 12, color: Color(0xFF627B84)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool highlight;
  final bool loading;
  final VoidCallback onTap;

  const _ScenarioCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.highlight = false,
    this.loading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.sizeOf(context).width - 54) / 2;
    return SizedBox(
      width: width,
      child: Material(
        color: highlight ? color.withValues(alpha: 0.1) : const Color(0xFFF7FBFC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: highlight ? color : const Color(0xFFE2EDF0),
            width: highlight ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: loading ? null : onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 22),
                    const Spacer(),
                    if (loading)
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: color,
                        ),
                      )
                    else if (highlight)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'SOS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: highlight ? color : const Color(0xFF123D4F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF627B84),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
