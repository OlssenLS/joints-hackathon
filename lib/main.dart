import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'creative_home.dart';
import 'models/telemetry.dart';
import 'services/telemetry_service.dart';
import 'widgets/emergency_alert_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TelemetryService.instance.initSession();
  runApp(const LanSiapApp());
}

abstract final class C {
  static const primary = Color(0xFF176E9E),
      dark = Color(0xFF174C65),
      deep = Color(0xFF123D4F),
      sky = Color(0xFFE6F5F8),
      blue = Color(0xFF7CC3D1),
      bg = Color(0xFFF7FBFC),
      ink = Color(0xFF123D4F),
      muted = Color(0xFF627B84),
      green = Color(0xFF35A66F),
      amber = Color(0xFFF5A524),
      red = Color(0xFFE95858);
}

class LanSiapApp extends StatelessWidget {
  const LanSiapApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'LanSIAP',
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'PlusJakartaSans',
      scaffoldBackgroundColor: C.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: C.primary,
        primary: C.primary,
        surface: Colors.white,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 31,
          fontWeight: FontWeight.w800,
          color: C.deep,
          height: 1.13,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: C.deep,
        ),
        titleLarge: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: C.ink,
        ),
        bodyLarge: TextStyle(fontSize: 15, color: C.ink, height: 1.45),
        bodyMedium: TextStyle(fontSize: 13, color: C.muted, height: 1.45),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F7F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: C.primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    ),
    home: const Splash(),
  );
}

class Frame extends StatelessWidget {
  const Frame({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFFE5F4F9),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: child,
      ),
    ),
  );
}

class Brand extends StatelessWidget {
  const Brand({super.key, this.light = false, this.small = false});
  final bool light, small;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: small ? 38 : 52,
        height: small ? 38 : 52,
        decoration: BoxDecoration(
          color: light ? Colors.white.withValues(alpha: .18) : C.primary,
          borderRadius: BorderRadius.circular(small ? 13 : 18),
        ),
        child: const Icon(Icons.favorite_rounded, color: Colors.white),
      ),
      const SizedBox(width: 10),
      Text.rich(
        TextSpan(
          style: TextStyle(
            fontSize: small ? 21 : 30,
            fontWeight: FontWeight.w800,
            color: light ? Colors.white : C.deep,
            letterSpacing: -.8,
          ),
          children: [
            const TextSpan(text: 'Lan'),
            TextSpan(
              text: 'SIAP',
              style: TextStyle(color: light ? Colors.white : C.primary),
            ),
          ],
        ),
      ),
    ],
  );
}

Route<T> fade<T>(Widget page) => PageRouteBuilder<T>(
  pageBuilder: (context, animation, secondaryAnimation) => page,
  transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
    child: child,
  ),
);
String dayGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 11) return 'Selamat pagi';
  if (hour < 15) return 'Selamat siang';
  if (hour < 18) return 'Selamat sore';
  return 'Selamat malam';
}

String todayLabel() {
  final now = DateTime.now();
  const weekdays = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year} • ${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}';
}

class Splash extends StatefulWidget {
  const Splash({super.key});
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late final AnimationController animation;
  @override
  void initState() {
    super.initState();
    animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) Navigator.pushReplacement(context, fade(const Onboarding()));
    });
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Frame(
    child: Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [C.blue, C.primary, C.dark],
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: Tween(begin: .8, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Brand(light: true),
                SizedBox(height: 14),
                Text(
                  'Keluarga tenang, lansia tersayang.',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class Onboarding extends StatelessWidget {
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) => Frame(
    child: Scaffold(
      backgroundColor: const Color(0xFFF7FBFC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Brand(small: true),
                    const SizedBox(height: 24),
                    Container(
                      height: constraints.maxHeight < 650 ? 260 : 335,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F3F5),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -55,
                            right: -65,
                            child: Container(
                              width: 210,
                              height: 210,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFE1BF),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/care_family_editorial.png',
                              fit: BoxFit.contain,
                              alignment: Alignment.bottomCenter,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Kabar baik untuk\nyang tersayang.',
                      style: TextStyle(
                        color: Color(0xFF123D4F),
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.2,
                        height: 1.12,
                      ),
                    ),
                    const SizedBox(height: 13),
                    const Text(
                      'LanSIAP membantu keluarga mengatur obat, membaca kondisi kesehatan, dan tetap terhubung dengan lansia setiap hari.',
                      style: TextStyle(
                        color: Color(0xFF627B84),
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 23),
                    const Wrap(
                      spacing: 9,
                      runSpacing: 9,
                      children: [
                        Chip(
                          label: Text('Jadwal obat'),
                          avatar: Icon(Icons.medication_rounded, size: 18),
                        ),
                        Chip(
                          label: Text('Pantau kesehatan'),
                          avatar: Icon(Icons.monitor_heart_rounded, size: 18),
                        ),
                        Chip(
                          label: Text('Keluarga dekat'),
                          avatar: Icon(Icons.favorite_rounded, size: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        fade(const Access()),
                      ),
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Mulai dengan LanSIAP'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class Access extends StatefulWidget {
  const Access({super.key});
  @override
  State<Access> createState() => _AccessState();
}

class _AccessState extends State<Access> {
  final email = TextEditingController(text: 'caregiver@demo.id'),
      pass = TextEditingController(text: 'demo1234');
  bool hidden = true;
  bool loading = false;
  bool backendOnline = false;

  @override
  void initState() {
    super.initState();
    _checkServer();
  }

  Future<void> _checkServer() async {
    final ok = await TelemetryService.instance.checkHealth();
    if (mounted) setState(() => backendOnline = ok);
    if (!ok) {
      final found = await TelemetryService.instance.probeWorkingHost();
      if (mounted && found != null) {
        setState(() => backendOnline = true);
      }
    }
  }

  void _editHostDialog(BuildContext context) {
    final controller = TextEditingController(text: TelemetryService.instance.host);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Koneksi Server Simulation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih alamat backend simulation engine sesuai konfigurasi Anda:',
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
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final found = await TelemetryService.instance.probeWorkingHost();
              await _checkServer();
              if (context.mounted) {
                msg(context, found != null ? 'Terhubung ke $found' : 'Backend belum terdeteksi aktif.');
              }
            },
            child: const Text('Deteksi Otomatis'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newHost = controller.text.trim();
              if (newHost.isNotEmpty) {
                await TelemetryService.instance.setHost(newHost);
                await _checkServer();
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Simpan & Cek'),
          ),
        ],
      ),
    );
  }

  Future<void> login() async {
    if (email.text.isEmpty || pass.text.isEmpty) {
      msg(context, 'Lengkapi email dan kata sandi dulu.');
      return;
    }

    setState(() => loading = true);
    final ok = await TelemetryService.instance.login(
      email.text.trim(),
      pass.text.trim(),
    );

    if (ok) {
      final elders = await TelemetryService.instance.getElders();
      if (elders.isNotEmpty) {
        await TelemetryService.instance.loadInitialData(elders.first.id);
        TelemetryService.instance.connectWebSocket(elders.first.id);
      }
    } else {
      if (mounted) {
        msg(context, 'Masuk mode offline demo (backend belum aktif).');
      }
    }

    if (mounted) {
      setState(() => loading = false);
      Navigator.pushReplacement(context, fade(const Shell()));
    }
  }

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Frame(
    child: Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(26, 30, 26, 28),
          children: [
            const Brand(),
            const SizedBox(height: 44),
            Text(
              'Selamat datang kembali!',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 9),
            const Text(
              'Masuk sebagai pendamping untuk melanjutkan perawatan keluarga.',
            ),
            const SizedBox(height: 28),
            TextField(
              controller: email,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: pass,
              obscureText: hidden,
              onSubmitted: (_) => login(),
              decoration: InputDecoration(
                labelText: 'Kata sandi',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => hidden = !hidden),
                  icon: Icon(
                    hidden
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () =>
                    msg(context, 'Tautan pemulihan dikirim ke email demo.'),
                child: const Text('Lupa kata sandi?'),
              ),
            ),
            Center(
              child: InkWell(
                onTap: () => _editHostDialog(context),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: (backendOnline ? const Color(0xFF35A66F) : Colors.orange)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: (backendOnline ? const Color(0xFF35A66F) : Colors.orange)
                          .withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: backendOnline ? const Color(0xFF35A66F) : Colors.orange,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        backendOnline
                            ? 'Server: ${TelemetryService.instance.host} (Online)'
                            : 'Server: ${TelemetryService.instance.host} (Offline - Ubah)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: backendOnline
                              ? const Color(0xFF296B54)
                              : const Color(0xFFB45309),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.tune_rounded, size: 12, color: Color(0xFF627B84)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: loading ? null : login,
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Masuk sebagai Pendamping'),
            ),
            const SizedBox(height: 13),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              onPressed: () => Navigator.push(context, fade(const Elder())),
              icon: const Icon(Icons.elderly_rounded),
              label: const Text('Masuk sebagai Lansia'),
            ),
            const SizedBox(height: 15),
            TextButton.icon(
              onPressed: () => joinSheet(context),
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Gabung keluarga via QR / ID'),
            ),
          ],
        ),
      ),
    ),
  );
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int index = 0;
  StreamSubscription<AlertItem>? _alertSub;

  @override
  void initState() {
    super.initState();
    _alertSub = TelemetryService.instance.alertsStream.listen((alert) {
      if (!mounted) return;
      showEmergencyDialog(context, alert);
    });
  }

  @override
  void dispose() {
    _alertSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      CreativeHome(
        onSchedule: () => setState(() => index = 1),
        onMonitor: () => setState(() => index = 2),
        onDocuments: () => Navigator.push(context, fade(const Documents())),
        onReports: () => Navigator.push(context, fade(const Reports())),
        onFamily: () => familySheet(context),
        onAlerts: () => Navigator.push(context, fade(const Alerts())),
      ),
      const Schedule(),
      const Monitor(),
      const Profile(),
    ];
    return Frame(
      child: Scaffold(
        body: IndexedStack(index: index, children: pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          height: 72,
          backgroundColor: Colors.white,
          indicatorColor: C.sky,
          onDestinationSelected: (v) => setState(() => index = v),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded),
              label: 'Jadwal',
            ),
            NavigationDestination(
              icon: Icon(Icons.monitor_heart_outlined),
              selectedIcon: Icon(Icons.monitor_heart_rounded),
              label: 'Monitor',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}


class Section extends StatelessWidget {
  const Section(this.title, {super.key, this.action});
  final String title;
  final String? action;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      if (action != null)
        Text(
          action!,
          style: const TextStyle(
            color: C.primary,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
    ],
  );
}

class Pill extends StatelessWidget {
  const Pill(this.text, this.color, {super.key});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
    ),
  );
}

class Schedule extends StatefulWidget {
  const Schedule({super.key});
  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  int selected = 0;
  final List<(String, String, String, Color)> tasks = [
    ('08.00', 'Amlodipine 5 mg', 'Obat pagi', C.green),
    ('10.30', 'Cek tekanan darah', 'Pemeriksaan rutin', C.amber),
    ('15.00', 'Jalan santai 20 menit', 'Aktivitas', C.primary),
  ];
  final completed = <int>{};

  Future<void> addNewTask() async {
    final controller = TextEditingController();
    TimeOfDay time = TimeOfDay.now();
    final result = await showModalBottomSheet<(String, String)?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) => StatefulBuilder(
        builder: (sheet, refresh) => Padding(
          padding: EdgeInsets.fromLTRB(
            22,
            4,
            22,
            MediaQuery.viewInsetsOf(sheet).bottom + 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tambah kegiatan',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nama kegiatan',
                  prefixIcon: Icon(Icons.edit_calendar_rounded),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: sheet,
                    initialTime: time,
                  );
                  if (picked != null) refresh(() => time = picked);
                },
                icon: const Icon(Icons.schedule_rounded),
                label: Text(
                  'Pukul ${time.hour.toString().padLeft(2, '0')}.${time.minute.toString().padLeft(2, '0')}',
                ),
              ),
              const SizedBox(height: 15),
              FilledButton(
                onPressed: () {
                  final title = controller.text.trim();
                  if (title.isEmpty) return;
                  Navigator.pop(sheet, (
                    '${time.hour.toString().padLeft(2, '0')}.${time.minute.toString().padLeft(2, '0')}',
                    title,
                  ));
                },
                child: const Text('Simpan kegiatan'),
              ),
            ],
          ),
        ),
      ),
    );
    controller.dispose();
    if (result == null || !mounted) return;
    setState(() {
      tasks.add((result.$1, result.$2, 'Kegiatan keluarga', C.primary));
      tasks.sort((a, b) => a.$1.compareTo(b.$1));
      completed.clear();
    });
  }

  Future<void> openTask(int index) async {
    final task = tasks[index];
    final didComplete = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 6, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.event_available_rounded,
              color: C.primary,
              size: 36,
            ),
            const SizedBox(height: 10),
            Text(
              task.$2,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text('${task.$1} · Nenek Yenti'),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => Navigator.pop(sheet, true),
              icon: Icon(
                completed.contains(index)
                    ? Icons.undo_rounded
                    : Icons.check_rounded,
              ),
              label: Text(
                completed.contains(index)
                    ? 'Batalkan selesai'
                    : 'Tandai selesai',
              ),
            ),
          ],
        ),
      ),
    );
    if (didComplete == true && mounted) {
      setState(
        () => completed.contains(index)
            ? completed.remove(index)
            : completed.add(index),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    const days = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addNewTask,
        backgroundColor: C.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah tugas'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 46, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [C.dark, C.primary]),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(34),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${months[now.month - 1]} ${now.year}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'Jadwal perawatan Nenek Yenti',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: List.generate(7, (i) {
                      final active = i == selected;
                      final date = now.add(Duration(days: i));
                      return Expanded(
                        child: InkWell(
                          onTap: () => setState(() => selected = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: active ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  days[date.weekday - 1],
                                  style: TextStyle(
                                    color: active ? C.primary : Colors.white70,
                                    fontSize: 9,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    color: active ? C.deep : Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
            sliver: SliverList.separated(
              itemCount: tasks.length + 1,
              separatorBuilder: (context, index) => const SizedBox(height: 13),
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Section(
                    selected == 0
                        ? 'Agenda hari ini'
                        : 'Agenda ${now.add(Duration(days: selected)).day} ${months[now.add(Duration(days: selected)).month - 1]}',
                    action: '${tasks.length} aktivitas',
                  );
                }
                final t = tasks[i - 1];
                return Card(
                  child: ListTile(
                    onTap: () => openTask(i - 1),
                    contentPadding: const EdgeInsets.all(16),
                    leading: Text(
                      t.$1,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    title: Text(
                      t.$2,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        decoration: completed.contains(i - 1)
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Text(t.$3),
                    trailing: Icon(
                      completed.contains(i - 1)
                          ? Icons.check_circle_rounded
                          : Icons.circle,
                      color: completed.contains(i - 1) ? C.green : t.$4,
                      size: completed.contains(i - 1) ? 24 : 13,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Monitor extends StatefulWidget {
  const Monitor({super.key});
  @override
  State<Monitor> createState() => _MonitorState();
}

class _MonitorState extends State<Monitor> {
  bool live = true;
  StreamSubscription<VitalsData>? _vitalsSub;
  StreamSubscription<MeasurementData>? _measSub;
  StreamSubscription<bool>? _connSub;
  VitalsData vitals = TelemetryService.instance.latestVitals;
  MeasurementData? bp = TelemetryService.instance.latestBp;

  @override
  void initState() {
    super.initState();
    live = TelemetryService.instance.isConnected;
    _vitalsSub = TelemetryService.instance.vitalsStream.listen((data) {
      if (mounted) setState(() => vitals = data);
    });
    _measSub = TelemetryService.instance.measurementStream.listen((data) {
      if (mounted && data.kind == 'bp') setState(() => bp = data);
    });
    _connSub = TelemetryService.instance.connectionStream.listen((status) {
      if (mounted) setState(() => live = status);
    });

    if (!TelemetryService.instance.isConnected) {
      _autoConnect();
    }
  }

  Future<void> _autoConnect() async {
    await TelemetryService.instance.ensureAuthenticated();
    final activeId = TelemetryService.instance.activeElderId;
    if (activeId != null) {
      await TelemetryService.instance.connectWebSocket(activeId);
    } else {
      final elders = await TelemetryService.instance.getElders();
      if (elders.isNotEmpty) {
        await TelemetryService.instance.loadInitialData(elders.first.id);
        await TelemetryService.instance.connectWebSocket(elders.first.id);
      }
    }
  }

  @override
  void dispose() {
    _vitalsSub?.cancel();
    _measSub?.cancel();
    _connSub?.cancel();
    super.dispose();
  }

  void toggleLive(bool value) async {
    setState(() => live = value);
    if (value) {
      await _autoConnect();
    } else {
      TelemetryService.instance.disconnectWebSocket();
    }
  }

  @override
  Widget build(BuildContext context) {
    final elder = TelemetryService.instance.activeElder;
    final elderName = elder?.name ?? 'Pak Budi';
    final hasWarning =
        vitals.isTachycardia || vitals.isBradycardia || vitals.isHypoxia || vitals.isFever;
    final unackAlerts =
        TelemetryService.instance.currentAlerts.where((a) => !a.acknowledged).length;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(22, 48, 22, 31),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [C.dark, C.primary, C.blue]),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(38)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Halo, Pendamping 👋',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      live
                          ? 'Streaming live dari Simulation Engine'
                          : 'Pemantauan langsung dijeda',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Switch(
                value: live,
                onChanged: toggleLive,
                activeThumbColor: Colors.white,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Section('Tanda-Tanda Vital', action: 'Riwayat'),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 27,
                            backgroundColor: C.sky,
                            child: Icon(Icons.elderly_rounded, color: C.primary),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TTV $elderName',
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  live
                                      ? 'Pembaruan real-time (3s)'
                                      : 'Terakhir: ${vitals.ts.hour.toString().padLeft(2, '0')}.${vitals.ts.minute.toString().padLeft(2, '0')}',
                                ),
                              ],
                            ),
                          ),
                          Pill(
                            hasWarning ? 'Perlu Dicek' : 'Stabil',
                            hasWarning ? C.red : C.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Vital(
                              Icons.bloodtype,
                              'Tekanan Darah',
                              bp != null
                                  ? '${bp!.value1.toInt()}/${bp!.value2?.toInt() ?? 80}'
                                  : '128/78',
                              'mmHg',
                              C.red,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Vital(
                              Icons.favorite,
                              'Detak Jantung',
                              '${vitals.hr.toInt()}',
                              'bpm',
                              (vitals.isTachycardia || vitals.isBradycardia)
                                  ? C.red
                                  : C.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Vital(
                              Icons.air,
                              'Saturasi Oksigen',
                              '${vitals.spo2.toInt()}',
                              '%',
                              vitals.isHypoxia ? C.red : C.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Vital(
                              Icons.thermostat,
                              'Suhu Kulit',
                              vitals.temp.toStringAsFixed(1),
                              '°C',
                              vitals.isFever ? C.red : C.amber,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Vital(
                              Icons.directions_walk,
                              'Aktivitas',
                              vitals.activityLabel,
                              '(${vitals.steps} langkah)',
                              C.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Vital(
                              Icons.speed_rounded,
                              'Akselerometer',
                              vitals.accelMag.toStringAsFixed(2),
                              'g',
                              vitals.accelMag > 2.5 ? C.red : C.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ActionCard(
                      Icons.location_on,
                      'Lokasi Live',
                      'Rumah • aman',
                      C.primary,
                      () => locationSheet(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ActionCard(
                      Icons.warning_amber,
                      'Pusat Alert',
                      unackAlerts > 0
                          ? '$unackAlerts peringatan aktif'
                          : 'Kondisi aman',
                      unackAlerts > 0 ? C.red : C.green,
                      () => Navigator.push(context, fade(const Alerts())),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 23),
              const Section('Perangkat Terhubung'),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: const CircleAvatar(
                    backgroundColor: C.sky,
                    child: Icon(Icons.watch, color: C.primary),
                  ),
                  title: const Text(
                    'Simulation Engine (SecondBand)',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    live
                        ? 'Tersambung • Sinkron tiap 3 detik'
                        : 'Terputus • Ketuk toggle untuk live',
                  ),
                  trailing: Icon(
                    live ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                    color: live ? C.green : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class Vital extends StatelessWidget {
  const Vital(
    this.icon,
    this.label,
    this.value,
    this.unit,
    this.color, {
    super.key,
  });
  final IconData icon;
  final String label, value, unit;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .09),
      borderRadius: BorderRadius.circular(17),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(fontSize: 10)),
        FittedBox(
          child: Text(
            '$value $unit',
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    ),
  );
}

class ActionCard extends StatelessWidget {
  const ActionCard(
    this.icon,
    this.title,
    this.sub,
    this.color,
    this.tap, {
    super.key,
  });
  final IconData icon;
  final String title, sub;
  final Color color;
  final VoidCallback tap;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: tap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: .12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(sub, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    ),
  );
}

class Profile extends StatefulWidget {
  const Profile({super.key});
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int selected = 0;
  @override
  Widget build(BuildContext context) => ListView(
    padding: EdgeInsets.zero,
    children: [
      Container(
        height: 205,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFFFC37B), C.blue, C.dark]),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 42,
              right: 18,
              child: IconButton.filled(
                style: IconButton.styleFrom(backgroundColor: Colors.white24),
                onPressed: () =>
                    msg(context, 'Pengaturan profil siap digunakan.'),
                icon: const Icon(Icons.settings, color: Colors.white),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Transform.translate(
                offset: const Offset(0, 37),
                child: const CircleAvatar(
                  radius: 53,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: C.sky,
                    child: Icon(Icons.person, color: C.primary, size: 50),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 47),
      const Text(
        'Dinda Pramesti',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
      ),
      const Text('@dindap • Bandung', textAlign: TextAlign.center),
      const SizedBox(height: 19),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('Profil Saya')),
            ButtonSegment(value: 1, label: Text('Nenek Yenti')),
          ],
          selected: {selected},
          showSelectedIcon: false,
          onSelectionChanged: (v) => setState(() => selected = v.first),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Stat(
                    selected == 0 ? '12' : '8',
                    selected == 0 ? 'Tugas selesai' : 'Obat aktif',
                    Icons.task_alt,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Stat(
                    selected == 0 ? '96%' : 'Stabil',
                    selected == 0 ? 'Kepatuhan' : 'Kondisi',
                    Icons.favorite,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 17),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: TelemetryService.instance.randomSimEnabled
                      ? C.primary
                      : const Color(0xFFE2EDF0),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: TelemetryService.instance.randomSimEnabled
                                ? C.primary.withValues(alpha: 0.12)
                                : const Color(0xFFF0F4F6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            color: TelemetryService.instance.randomSimEnabled
                                ? C.primary
                                : Colors.grey,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Simulasi Kejadian Darurat',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                TelemetryService.instance.randomSimEnabled
                                    ? 'Acak otomatis aktif (tiap 20-35s)'
                                    : 'Simulasi dinonaktifkan',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: TelemetryService.instance.randomSimEnabled
                                      ? C.primary
                                      : const Color(0xFF627B84),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: TelemetryService.instance.randomSimEnabled,
                          activeThumbColor: C.primary,
                          onChanged: (val) {
                            setState(() {
                              TelemetryService.instance.setRandomSimulationEnabled(val);
                            });
                          },
                        ),
                      ],
                    ),
                    if (TelemetryService.instance.randomSimEnabled) ...[
                      const Divider(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                          onPressed: () async {
                            await TelemetryService.instance.triggerRandomScenario();
                            if (mounted) setState(() {});
                          },
                          icon: const Icon(Icons.bolt_rounded, size: 18),
                          label: const Text(
                            'Picu Acak Sekarang',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Menu(
              'Laporan Kesehatan',
              Icons.description_outlined,
              () => Navigator.push(context, fade(const Reports())),
            ),
            Menu(
              'Dokumen Medis',
              Icons.folder_open,
              () => Navigator.push(context, fade(const Documents())),
            ),
            Menu(
              'Kelola Keluarga',
              Icons.group_add,
              () => familySheet(context),
            ),
            Menu(
              'Pratinjau Mode Lansia',
              Icons.elderly,
              () => Navigator.push(context, fade(const Elder())),
            ),
            Menu(
              'Keluar',
              Icons.logout,
              () => Navigator.pushAndRemoveUntil(
                context,
                fade(const Access()),
                (_) => false,
              ),
              color: C.red,
            ),
          ],
        ),
      ),
    ],
  );
}

class Stat extends StatelessWidget {
  const Stat(this.value, this.label, this.icon, {super.key});
  final String value, label;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: C.primary),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    ),
  );
}

class Menu extends StatelessWidget {
  const Menu(this.title, this.icon, this.tap, {super.key, this.color = C.ink});
  final String title;
  final IconData icon;
  final VoidCallback tap;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Card(
      child: ListTile(
        onTap: tap,
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w700, color: color),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    ),
  );
}

class Elder extends StatefulWidget {
  const Elder({super.key});
  @override
  State<Elder> createState() => _ElderState();
}

class _ElderState extends State<Elder> {
  bool taken = false;
  @override
  Widget build(BuildContext context) => Frame(
    child: Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            Row(
              children: [
                const Expanded(child: Brand(small: true)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              '${dayGreeting()},\n${TelemetryService.instance.activeElder?.name ?? 'Pak Budi'} 👋',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: C.deep,
              ),
            ),
            Text(todayLabel()),
            const SizedBox(height: 25),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: taken ? const Color(0xFFE6F7ED) : C.sky,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    taken ? Icons.check_circle : Icons.medication,
                    color: taken ? C.green : C.primary,
                    size: 40,
                  ),
                  const SizedBox(height: 13),
                  Text(
                    taken ? 'Obat sudah diminum' : 'Waktunya minum obat',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'Amlodipine 5 mg • 1 tablet\nSesudah sarapan',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () => setState(() => taken = !taken),
                    icon: Icon(taken ? Icons.undo : Icons.check),
                    label: Text(taken ? 'Batalkan' : 'Saya Sudah Minum'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElderButton(
              Icons.calendar_month,
              'Jadwal Saya',
              '3 kegiatan hari ini',
              C.primary,
              () => msg(context, 'Obat, cek tensi, dan jalan santai.'),
            ),
            const SizedBox(height: 12),
            ElderButton(
              Icons.call,
              'Telepon Keluarga',
              'Hubungi Pendamping',
              C.green,
              () => callDialog(context, false),
            ),
            const SizedBox(height: 12),
            ElderButton(
              Icons.sos,
              'Bantuan Darurat',
              'Tekan jika butuh bantuan',
              C.red,
              () async {
                await TelemetryService.instance
                    .sendSos(note: 'SOS manual dipicu oleh Lansia');
                if (context.mounted) callDialog(context, true);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class ElderButton extends StatelessWidget {
  const ElderButton(
    this.icon,
    this.title,
    this.sub,
    this.color,
    this.tap, {
    super.key,
  });
  final IconData icon;
  final String title, sub;
  final Color color;
  final VoidCallback tap;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: tap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 27,
              backgroundColor: color.withValues(alpha: .12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(sub),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    ),
  );
}

class SubPage extends StatelessWidget {
  const SubPage(this.title, this.child, {super.key, this.action});
  final String title;
  final Widget child;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Frame(
    child: Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: C.bg,
        surfaceTintColor: Colors.transparent,
        actions: action == null ? null : [action!],
      ),
      body: child,
    ),
  );
}

class Documents extends StatelessWidget {
  const Documents({super.key});
  @override
  Widget build(BuildContext context) {
    final docs = [
      'Hasil Lab Januari.pdf',
      'Resep Dokter.pdf',
      'Kartu BPJS.jpg',
      'Riwayat Tekanan Darah.pdf',
    ];
    return SubPage(
      'Dokumen Medis',
      ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: docs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 11),
        itemBuilder: (_, i) => Card(
          child: ListTile(
            onTap: () => msg(context, '${docs[i]} dibuka.'),
            contentPadding: const EdgeInsets.all(14),
            leading: CircleAvatar(
              backgroundColor: C.sky,
              child: Icon(
                i == 2 ? Icons.image : Icons.picture_as_pdf,
                color: C.primary,
              ),
            ),
            title: Text(
              docs[i],
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text('${1 + i * 2} Jan 2026 • ${240 + i * 115} KB'),
            trailing: const Icon(Icons.more_vert),
          ),
        ),
      ),
      action: IconButton(
        onPressed: () =>
            msg(context, 'Pilih berkas dari perangkat untuk diunggah.'),
        icon: const Icon(Icons.upload_file),
      ),
    );
  }
}

class Reports extends StatefulWidget {
  const Reports({super.key});
  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  bool _isLoading = false;
  bool _isInitialLoading = true;
  int _selectedDays = 7;
  Map<String, dynamic>? _currentReport;
  List<Map<String, dynamic>> _historyReports = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final list = await TelemetryService.instance.fetchReports();
    if (!mounted) return;
    setState(() {
      _historyReports = list;
    });

    if (list.isNotEmpty) {
      final latestId = list.first['id'] as String;
      final detail = await TelemetryService.instance.getReportDetail(latestId);
      if (mounted) {
        setState(() {
          _currentReport = detail;
          _isInitialLoading = false;
        });
      }
    } else {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _generateReport() async {
    setState(() => _isLoading = true);
    final report = await TelemetryService.instance.generateSmartReport(days: _selectedDays);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (report != null) {
        _currentReport = report;
      }
    });

    // Refresh history
    final list = await TelemetryService.instance.fetchReports();
    if (mounted) {
      setState(() => _historyReports = list);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(report != null
                  ? 'Laporan AI $_selectedDays hari berhasil digenerate!'
                  : 'Gagal membuat laporan AI. Silakan coba lagi.'),
            ],
          ),
          backgroundColor: report != null ? C.green : C.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  String _cleanRepetitiveReportText(String? raw) {
    if (raw == null || raw.isEmpty) return 'Laporan belum tersedia.';
    final lines = raw.split('\n');
    final cleaned = <String>[];
    final seen = <String>{};

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        cleaned.add('');
        continue;
      }
      final norm = trimmed.replaceAll(RegExp(r'^[\d\.\-\+\*\s]+'), '').toLowerCase();
      final key = norm.length > 30 ? norm.substring(0, 30) : norm;
      if (key.length >= 15 && seen.contains(key)) {
        continue;
      }
      if (key.length >= 15) {
        seen.add(key);
      }
      cleaned.add(line);
    }

    while (cleaned.isNotEmpty) {
      final last = cleaned.last.trim();
      if (last.isEmpty) {
        cleaned.removeLast();
        continue;
      }
      if (RegExp(r'^(\d+[\.\)]|[\-\*\+]|#+)\s*$').hasMatch(last)) {
        cleaned.removeLast();
        continue;
      }
      if (!last.endsWith('.') &&
          !last.endsWith('!') &&
          !last.endsWith('?') &&
          !last.endsWith('*') &&
          !last.endsWith(':') &&
          !last.endsWith(')')) {
        cleaned.removeLast();
        continue;
      }
      break;
    }

    return cleaned.join('\n').trim();
  }

  void _copyToClipboard(String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.copy_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Teks laporan disalin! Siap dikirim ke WhatsApp dokter/keluarga.'),
          ],
        ),
        backgroundColor: C.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showDownloadDialog(BuildContext context, String reportId) {
    final url = TelemetryService.instance.getReportDownloadUrl(reportId);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: C.sky,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: C.primary, size: 24),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Unduh Lembar Medis Resmi',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    Text('Format dokumen siap cetak / PDF standar klinik',
                        style: TextStyle(fontSize: 12, color: C.muted)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link_rounded, color: C.muted, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      url,
                      style: const TextStyle(fontSize: 11, color: C.ink, fontFamily: 'monospace'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Clipboard.setData(ClipboardData(text: url));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tautan dokumen PDF/Cetak berhasil disalin!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Salin Tautan', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: C.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _copyToClipboard(_cleanRepetitiveReportText(_currentReport?['content_md']));
                    },
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text('Bagikan Teks', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showHistorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Riwayat Laporan Kesehatan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            if (_historyReports.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('Belum ada riwayat laporan.', style: TextStyle(color: C.muted)),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _historyReports.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final item = _historyReports[i];
                    final rId = item['id'] as String;
                    final isCurrent = _currentReport?['id'] == rId;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: isCurrent ? C.primary : const Color(0xFFF1F5F9),
                        child: Icon(
                          Icons.description_outlined,
                          color: isCurrent ? Colors.white : C.muted,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        'Laporan ${item['created_at']?.toString().substring(0, 10) ?? ''}',
                        style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                          color: isCurrent ? C.primary : C.ink,
                        ),
                      ),
                      subtitle: Text(
                        'Metode: ${item['generated_by']?.toString().toUpperCase() ?? 'AI'}',
                        style: const TextStyle(fontSize: 11, color: C.muted),
                      ),
                      trailing: isCurrent
                          ? const Pill('Aktif', C.green)
                          : const Icon(Icons.chevron_right, size: 18),
                      onTap: () async {
                        Navigator.pop(ctx);
                        final detail = await TelemetryService.instance.getReportDetail(rId);
                        if (mounted && detail != null) {
                          setState(() => _currentReport = detail);
                        }
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _currentReport?['stats_json'] as Map<String, dynamic>?;
    final contentMd = _currentReport?['content_md'] as String?;
    final reportId = _currentReport?['id'] as String?;
    final generatedBy = _currentReport?['generated_by'] as String? ?? 'LLM';

    final hrStats = stats?['heart_rate'] as Map<String, dynamic>?;
    final bpStats = stats?['blood_pressure'] as Map<String, dynamic>?;
    final medStats = stats?['medication'] as Map<String, dynamic>?;
    final spo2Stats = stats?['spo2'] as Map<String, dynamic>?;

    final hrAvg = hrStats?['avg']?.toString() ?? '74';
    final bpAvg = bpStats?['avg']?.toString() ?? '132/84';
    final medAdh = medStats?['adherence_pct']?.toString() ?? '92';
    final spo2Avg = spo2Stats?['avg']?.toString() ?? '97';

    return SubPage(
      'Laporan Kesehatan AI',
      _isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Top Generator Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F4C68), Color(0xFF1E7EAB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: C.primary.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'Groq LLaMA / Qwen AI Engine',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_historyReports.isNotEmpty)
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _showHistorySheet(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.history_rounded, color: Colors.white70, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_historyReports.length} Laporan',
                                      style: const TextStyle(color: Colors.white, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Ringkasan Cerdas Klinis',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'AI mengagregasi ribuan data telemetri, ritme jantung, tekanan darah, dan obat untuk menghasilkan laporan siap dokter.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      // Day selector
                      Row(
                        children: [
                          _buildDayChip(7, '7 Hari Terakhir'),
                          const SizedBox(width: 8),
                          _buildDayChip(14, '14 Hari Terakhir'),
                          const SizedBox(width: 8),
                          _buildDayChip(30, '30 Hari'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: C.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _isLoading ? null : _generateReport,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: C.primary),
                                )
                              : const Icon(Icons.bolt_rounded, size: 20),
                          label: Text(
                            _isLoading ? 'Groq AI Menganalisis Data...' : 'Generate Laporan AI Baru',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (_currentReport != null) ...[
                  // Report Document Action Bar
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () => _copyToClipboard(_cleanRepetitiveReportText(contentMd)),
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          label: const Text('Salin Teks', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: C.primary,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () {
                            if (reportId != null) {
                              _showDownloadDialog(context, reportId);
                            }
                          },
                          icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                          label: const Text('Unduh Dokumen', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 4 Biometrics Matrix Cards
                  Row(
                    children: [
                      Expanded(child: Stat('$hrAvg bpm', 'Detak Jantung Rata-rata', Icons.favorite_rounded)),
                      const SizedBox(width: 10),
                      Expanded(child: Stat('$bpAvg mmHg', 'Tensi Darah', Icons.speed_rounded)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: Stat('$medAdh%', 'Kepatuhan Obat', Icons.medication_rounded)),
                      const SizedBox(width: 10),
                      Expanded(child: Stat('$spo2Avg%', 'Oksigen SpO2', Icons.air_rounded)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Full Narrative AI Report Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: C.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.analytics_outlined, color: C.primary, size: 18),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'Analisis Naratif Hasil AI',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                ),
                              ),
                              Pill('Metode: ${generatedBy.toUpperCase()}', C.green),
                            ],
                          ),
                          const Divider(height: 24),
                          Text(
                            _cleanRepetitiveReportText(contentMd),
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.6,
                              color: Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFFEF3C7)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline_rounded, color: Color(0xFF92400E), size: 16),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Laporan otomatis berbasis telemetri IoT & AI. Gunakan sebagai bahan konsultasi dengan dokter.',
                                    style: TextStyle(fontSize: 11, color: Color(0xFF92400E), fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.description_outlined, color: C.muted, size: 48),
                          SizedBox(height: 12),
                          Text(
                            'Belum Ada Laporan Terbuat',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tekan tombol di atas untuk menganalisis data kesehatan Nenek Yenti dengan AI.',
                            style: TextStyle(color: C.muted, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
      action: _currentReport != null
          ? IconButton(
              tooltip: 'Riwayat Laporan',
              onPressed: () => _showHistorySheet(context),
              icon: const Icon(Icons.history_rounded),
            )
          : null,
    );
  }

  Widget _buildDayChip(int days, String label) {
    final selected = _selectedDays == days;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => setState(() => _selectedDays = days),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? C.primary : Colors.white,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class Trend extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final g = Paint()..color = const Color(0xFFE5EEF1);
    for (var i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(0, i * s.height / 3),
        Offset(s.width, i * s.height / 3),
        g,
      );
    }
    final p = Path()
      ..moveTo(0, s.height * .6)
      ..cubicTo(
        s.width * .25,
        s.height * .2,
        s.width * .38,
        s.height * .8,
        s.width * .55,
        s.height * .4,
      )
      ..cubicTo(
        s.width * .72,
        s.height * .1,
        s.width * .82,
        s.height * .55,
        s.width,
        s.height * .25,
      );
    canvas.drawPath(
      p,
      Paint()
        ..color = C.primary
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class Alerts extends StatefulWidget {
  const Alerts({super.key});
  @override
  State<Alerts> createState() => _AlertsState();
}

class _AlertsState extends State<Alerts> {
  StreamSubscription<AlertItem>? _alertSub;
  int _selectedFilter = 0; // 0: Semua, 1: Perlu Ditangani, 2: Selesai
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _alertSub = TelemetryService.instance.alertsStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _alertSub?.cancel();
    super.dispose();
  }

  Future<void> _confirmAcknowledgeAll(int count) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.done_all_rounded, color: C.primary, size: 24),
            SizedBox(width: 10),
            Text('Tangani Semua?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          'Tandai seluruh $count peringatan aktif sebagai telah ditangani dan selesai?',
          style: const TextStyle(fontSize: 14, color: C.dark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal', style: TextStyle(color: C.muted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: C.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Ya, Selesaikan',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isProcessing = true);
      final handled = await TelemetryService.instance.acknowledgeAllAlerts();
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text('$handled peringatan berhasil ditandai selesai.'),
            ],
          ),
          backgroundColor: C.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final liveAlerts = TelemetryService.instance.currentAlerts;
    final unhandledAlerts = liveAlerts.where((a) => !a.acknowledged).toList();
    final handledAlerts = liveAlerts.where((a) => a.acknowledged).toList();

    final List<AlertItem> displayList;
    if (_selectedFilter == 1) {
      displayList = unhandledAlerts;
    } else if (_selectedFilter == 2) {
      displayList = handledAlerts;
    } else {
      displayList = liveAlerts;
    }

    final hasUnhandled = unhandledAlerts.isNotEmpty;

    return SubPage(
      'Pusat Peringatan',
      Column(
        children: [
          // Header summary banner
          if (liveAlerts.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: hasUnhandled
                      ? const Color(0xFFFFF7ED)
                      : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasUnhandled
                        ? C.amber.withValues(alpha: 0.3)
                        : C.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: hasUnhandled
                            ? C.amber.withValues(alpha: 0.15)
                            : C.green.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        hasUnhandled
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_rounded,
                        color: hasUnhandled ? const Color(0xFFB45309) : C.green,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasUnhandled
                                ? '${unhandledAlerts.length} Peringatan Butuh Penanganan'
                                : 'Semua Kondisi Terkendali',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: hasUnhandled
                                  ? const Color(0xFF9A3412)
                                  : const Color(0xFF166534),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasUnhandled
                                ? 'Ketuk "Tangani" pada kartu atau selesaikan sekaligus.'
                                : '${handledAlerts.length} riwayat peringatan telah diselesaikan.',
                            style: TextStyle(
                              fontSize: 11,
                              color: hasUnhandled
                                  ? const Color(0xFFC2410C)
                                  : const Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasUnhandled) ...[
                      const SizedBox(width: 8),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFB45309),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: _isProcessing
                            ? null
                            : () => _confirmAcknowledgeAll(
                                unhandledAlerts.length),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.done_all_rounded, size: 14),
                            SizedBox(width: 4),
                            Text('Selesaikan',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Filter Pills Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildFilterChip(0, 'Semua (${liveAlerts.length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                      1, 'Perlu Ditangani (${unhandledAlerts.length})',
                      badgeColor: hasUnhandled ? C.red : null),
                  const SizedBox(width: 8),
                  _buildFilterChip(2, 'Selesai (${handledAlerts.length})'),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Expanded(
            child: displayList.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _selectedFilter == 1
                                ? Icons.verified_user_rounded
                                : Icons.check_circle_outline_rounded,
                            color: C.green,
                            size: 56,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _selectedFilter == 1
                                ? 'Tidak Ada Peringatan Aktif'
                                : (_selectedFilter == 2
                                    ? 'Belum Ada yang Selesai'
                                    : 'Semua Terkendali'),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _selectedFilter == 1
                                ? 'Semua peringatan telah ditangani dengan baik.'
                                : (_selectedFilter == 2
                                    ? 'Peringatan yang ditangani akan muncul di sini.'
                                    : 'Belum ada anomali atau peringatan darurat terdeteksi.'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: C.muted),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: displayList.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final a = displayList[i];
                      final isCritical = a.isCritical || a.isFall || a.isSos;
                      final color = isCritical
                          ? C.red
                          : (a.severity == 'warning' ? C.amber : C.primary);

                      return Card(
                        elevation: a.acknowledged ? 0 : 1,
                        color: a.acknowledged
                            ? const Color(0xFFFAFBFB)
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: a.acknowledged
                                ? const Color(0xFFE5ECED)
                                : color.withValues(alpha: 0.35),
                            width: a.acknowledged ? 1 : 1.5,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            showEmergencyDialog(context, a);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: a.acknowledged
                                      ? C.green.withValues(alpha: .12)
                                      : color.withValues(alpha: .12),
                                  child: Icon(
                                    a.acknowledged
                                        ? Icons.check_circle_rounded
                                        : (a.isFall
                                            ? Icons.personal_injury_rounded
                                            : (a.isSos
                                                ? Icons.sos_rounded
                                                : Icons.warning_amber_rounded)),
                                    color: a.acknowledged ? C.green : color,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              a.title,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                                color: a.acknowledged
                                                    ? C.muted
                                                    : C.ink,
                                                decoration: a.acknowledged
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Pill(
                                            isCritical
                                                ? 'Darurat'
                                                : 'Peringatan',
                                            a.acknowledged ? C.muted : color,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        a.message,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: a.acknowledged
                                              ? const Color(0xFF8A9EA5)
                                              : const Color(0xFF425A63),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Pukul ${a.ts.hour.toString().padLeft(2, '0')}.${a.ts.minute.toString().padLeft(2, '0')} • ${a.source.toUpperCase()}',
                                            style: const TextStyle(
                                                fontSize: 11, color: C.muted),
                                          ),
                                          if (!a.acknowledged)
                                            FilledButton.tonalIcon(
                                              style: FilledButton.styleFrom(
                                                backgroundColor: isCritical
                                                    ? C.red.withValues(
                                                        alpha: 0.12)
                                                    : C.amber.withValues(
                                                        alpha: 0.16),
                                                foregroundColor: isCritical
                                                    ? C.red
                                                    : const Color(0xFFB45309),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              onPressed: () async {
                                                await TelemetryService.instance
                                                    .acknowledgeAlert(a.id);
                                                if (mounted) setState(() {});
                                              },
                                              icon: const Icon(
                                                  Icons.check_rounded,
                                                  size: 14),
                                              label: const Text(
                                                'Tangani',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            )
                                          else
                                            const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.done_all_rounded,
                                                    size: 14, color: C.green),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Selesai',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: C.green,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      action: hasUnhandled
          ? TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: C.primary,
                backgroundColor: C.primary.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
              onPressed: () => _confirmAcknowledgeAll(
                  unhandledAlerts.length),
              icon: const Icon(Icons.done_all_rounded, size: 16),
              label: Text(
                'Tangani (${unhandledAlerts.length})',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 12),
              ),
            )
          : null,
    );
  }

  Widget _buildFilterChip(int index, String label, {Color? badgeColor}) {
    final selected = _selectedFilter == index;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => setState(() => _selectedFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? C.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? C.primary : const Color(0xFFD6E2E6),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected
                ? Colors.white
                : (badgeColor ?? const Color(0xFF4A646E)),
          ),
        ),
      ),
    );
  }
}


class Search extends SearchDelegate<String> {
  final data = [
    'Jadwal minum obat',
    'Hasil Lab Januari.pdf',
    'Laporan kesehatan',
    'Nenek Yenti',
    'Lokasi langsung',
    'Pusat peringatan',
  ];
  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear)),
  ];
  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    onPressed: () => close(context, ''),
    icon: const Icon(Icons.arrow_back),
  );
  @override
  Widget buildResults(BuildContext context) => results(context);
  @override
  Widget buildSuggestions(BuildContext context) => results(context);
  Widget results(BuildContext context) {
    final r = data
        .where((x) => x.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: r.length,
      itemBuilder: (_, i) => ListTile(
        leading: const Icon(Icons.search),
        title: Text(r[i]),
        onTap: () => close(context, r[i]),
      ),
    );
  }
}

void msg(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
}

void joinSheet(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (sheet) => Padding(
    padding: EdgeInsets.fromLTRB(
      24,
      8,
      24,
      MediaQuery.viewInsetsOf(sheet).bottom + 28,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gabung Keluarga',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const Text('Pindai QR atau masukkan ID keluarga.'),
        const SizedBox(height: 18),
        Center(
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: C.deep,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.qr_code_2, color: Colors.white, size: 95),
          ),
        ),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(labelText: 'ID keluarga'),
          controller: null,
        ),
        const SizedBox(height: 13),
        FilledButton(
          onPressed: () {
            Navigator.pop(sheet);
            msg(context, 'Berhasil terhubung dengan Keluarga Yenti.');
          },
          child: const Text('Hubungkan'),
        ),
      ],
    ),
  ),
);
void familySheet(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  builder: (sheet) => Padding(
    padding: const EdgeInsets.fromLTRB(22, 6, 22, 28),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tim Keluarga',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const ListTile(
          leading: CircleAvatar(backgroundColor: C.sky, child: Text('D')),
          title: Text('Dinda Pramesti'),
          subtitle: Text('Admin • Pendamping utama'),
          trailing: Pill('Aktif', C.green),
        ),
        const ListTile(
          leading: CircleAvatar(child: Text('A')),
          title: Text('Andi Gunawan'),
          subtitle: Text('Anggota keluarga'),
        ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: () => msg(context, 'Tautan undangan disalin.'),
          icon: const Icon(Icons.person_add),
          label: const Text('Undang anggota'),
        ),
      ],
    ),
  ),
);
void locationSheet(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  builder: (sheet) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lokasi Langsung',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 13),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: C.sky,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Center(
            child: CircleAvatar(
              radius: 30,
              backgroundColor: C.primary,
              child: Icon(Icons.elderly_woman, color: Colors.white),
            ),
          ),
        ),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.home, color: C.primary),
          title: Text(
            'Rumah Nenek Yenti',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text('Jl. Sukajadi No. 28, Bandung'),
          trailing: Pill('Zona aman', C.green),
        ),
      ],
    ),
  ),
);
void callDialog(BuildContext context, bool sos) => showDialog<void>(
  context: context,
  builder: (dialog) => AlertDialog(
    icon: Icon(
      sos ? Icons.sos : Icons.call,
      color: sos ? C.red : C.green,
      size: 40,
    ),
    title: Text(sos ? 'Hubungi bantuan darurat?' : 'Telepon Dinda?'),
    content: Text(
      sos
          ? 'Lokasi dan data kesehatan terakhir juga akan dikirim ke keluarga.'
          : 'Panggilan akan dimulai ke pendamping utama.',
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(dialog),
        child: const Text('Batal'),
      ),
      FilledButton(
        onPressed: () {
          Navigator.pop(dialog);
          msg(
            context,
            sos ? 'Bantuan darurat sedang dihubungi.' : 'Memanggil Dinda...',
          );
        },
        child: Text(sos ? 'Kirim SOS' : 'Telepon'),
      ),
    ],
  ),
);
