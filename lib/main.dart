import 'dart:async';
import 'package:flutter/material.dart';
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

class Reports extends StatelessWidget {
  const Reports({super.key});
  @override
  Widget build(BuildContext context) => SubPage(
    'Laporan Kesehatan',
    ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Ringkasan Januari',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
        ),
        const Text('Insight otomatis dari data kesehatan Nenek Yenti.'),
        const SizedBox(height: 19),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [C.dark, C.primary]),
            borderRadius: BorderRadius.circular(23),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_awesome, color: Colors.white),
              SizedBox(height: 12),
              Text(
                'Kondisi secara umum stabil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Kepatuhan obat meningkat 8% dan tekanan darah berada pada rentang aman selama 6 hari terakhir.',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 17),
        const Row(
          children: [
            Expanded(child: Stat('96%', 'Kepatuhan obat', Icons.medication)),
            SizedBox(width: 12),
            Expanded(
              child: Stat('128/78', 'Rata-rata tensi', Icons.monitor_heart),
            ),
          ],
        ),
        const SizedBox(height: 17),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tren tekanan darah',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 125,
                  child: CustomPaint(painter: Trend(), size: Size.infinite),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
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

  @override
  Widget build(BuildContext context) {
    final liveAlerts = TelemetryService.instance.currentAlerts;

    return SubPage(
      'Pusat Peringatan',
      liveAlerts.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: C.green,
                      size: 56,
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Semua Terkendali',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Belum ada anomali atau peringatan darurat terdeteksi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: C.muted),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: liveAlerts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final a = liveAlerts[i];
                final isCritical = a.isCritical || a.isFall || a.isSos;
                final color = isCritical
                    ? C.red
                    : (a.severity == 'warning' ? C.amber : C.primary);

                return Card(
                  child: ListTile(
                    onTap: () {
                      if (!a.acknowledged) {
                        showEmergencyDialog(context, a);
                      }
                    },
                    contentPadding: const EdgeInsets.all(14),
                    leading: CircleAvatar(
                      backgroundColor: color.withValues(alpha: .12),
                      child: Icon(
                        a.acknowledged
                            ? Icons.check
                            : (a.isFall
                                ? Icons.personal_injury_rounded
                                : (a.isSos
                                    ? Icons.sos_rounded
                                    : Icons.warning_amber_rounded)),
                        color: a.acknowledged ? C.green : color,
                      ),
                    ),
                    title: Text(
                      a.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        decoration:
                            a.acknowledged ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(a.message),
                        const SizedBox(height: 4),
                        Text(
                          'Pukul ${a.ts.hour.toString().padLeft(2, '0')}.${a.ts.minute.toString().padLeft(2, '0')} • ${a.source.toUpperCase()}',
                          style: const TextStyle(fontSize: 11, color: C.muted),
                        ),
                      ],
                    ),
                    trailing: Pill(
                      a.acknowledged
                          ? 'Selesai'
                          : (isCritical ? 'Darurat' : 'Cek'),
                      a.acknowledged ? C.green : color,
                    ),
                  ),
                );
              },
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
