import 'dart:async';
import 'package:flutter/material.dart';
import 'models/telemetry.dart';
import 'services/telemetry_service.dart';

/// Home experience for the caregiver demo. Actions are supplied by the shell.
class CreativeHome extends StatefulWidget {
  const CreativeHome({
    super.key,
    required this.onSchedule,
    required this.onMonitor,
    required this.onDocuments,
    required this.onReports,
    required this.onFamily,
    required this.onAlerts,
  });

  final VoidCallback onSchedule;
  final VoidCallback onMonitor;
  final VoidCallback onDocuments;
  final VoidCallback onReports;
  final VoidCallback onFamily;
  final VoidCallback onAlerts;

  @override
  State<CreativeHome> createState() => _CreativeHomeState();
}

class _CreativeHomeState extends State<CreativeHome> {
  bool medicineTaken = false;
  StreamSubscription<AlertItem>? _alertsSub;

  @override
  void initState() {
    super.initState();
    _alertsSub = TelemetryService.instance.alertsStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _alertsSub?.cancel();
    super.dispose();
  }

  static const ink = Color(0xFF123D4F);
  static const blue = Color(0xFF176E9E);
  static const pale = Color(0xFFE6F5F8);
  static const apricot = Color(0xFFFFD7B2);
  static const coral = Color(0xFFEA795C);

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  String get today {
    final now = DateTime.now();
    const days = [
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
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  void toggleMedicine() {
    setState(() => medicineTaken = !medicineTaken);
    final elderName = TelemetryService.instance.activeElder?.name ?? 'Pak Budi';
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            medicineTaken
                ? 'Obat pagi tercatat. Terima kasih sudah menjaga $elderName.'
                : 'Konfirmasi obat pagi dibatalkan.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final unackCount = TelemetryService.instance.currentAlerts
        .where((a) => !a.acknowledged)
        .length;

    return ColoredBox(
      color: const Color(0xFFF7FBFC),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 46, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              today.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                letterSpacing: 1.8,
                                fontWeight: FontWeight.w800,
                                color: blue,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '$greeting, Pendamping',
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -.6,
                                color: ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Semantics(
                        label: 'Pusat peringatan',
                        button: true,
                        child: IconButton.filledTonal(
                          onPressed: widget.onAlerts,
                          style: IconButton.styleFrom(
                            backgroundColor: pale,
                            foregroundColor: blue,
                            minimumSize: const Size(48, 48),
                          ),
                          icon: unackCount > 0
                              ? Badge(
                                  label: Text('$unackCount'),
                                  child: const Icon(
                                      Icons.notifications_none_rounded),
                                )
                              : const Icon(Icons.notifications_none_rounded),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 23),
                  _HeroCard(onTap: widget.onMonitor),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Hari ini, satu langkah lagi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: ink,
                          ),
                        ),
                      ),
                      Text(
                        '${medicineTaken ? 3 : 2}/3',
                        style: const TextStyle(
                          color: blue,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      minHeight: 9,
                      value: medicineTaken ? 1 : 2 / 3,
                      backgroundColor: pale,
                      valueColor: const AlwaysStoppedAnimation(blue),
                    ),
                  ),
                  const SizedBox(height: 17),
                  _MedicineCard(done: medicineTaken, onTap: toggleMedicine),
                  const SizedBox(height: 29),
                  const Text(
                    'Semua yang kamu butuhkan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 13),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final gap = 12.0;
                      final width = (constraints.maxWidth - gap) / 2;
                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: [
                          _ActionTile(
                            width: width,
                            title: 'Jadwal',
                            caption: 'Lihat agenda',
                            icon: Icons.calendar_today_rounded,
                            color: const Color(0xFFDCEEF5),
                            onTap: widget.onSchedule,
                          ),
                          _ActionTile(
                            width: width,
                            title: 'Dokumen',
                            caption: 'Berkas Nenek',
                            icon: Icons.folder_open_rounded,
                            color: const Color(0xFFFFEBD8),
                            onTap: widget.onDocuments,
                          ),
                          _ActionTile(
                            width: width,
                            title: 'Keluarga',
                            caption: 'Rawat bersama',
                            icon: Icons.diversity_3_rounded,
                            color: const Color(0xFFE7F1E1),
                            onTap: widget.onFamily,
                          ),
                          _ActionTile(
                            width: width,
                            title: 'Laporan',
                            caption: 'Lihat tren',
                            icon: Icons.auto_graph_rounded,
                            color: const Color(0xFFFCE6E2),
                            onTap: widget.onReports,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 29),
                  const Text(
                    'Kabar terbaru',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 13),
                  _NewsCard(onTap: widget.onMonitor),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final elder = TelemetryService.instance.activeElder;
    final elderName = elder?.name ?? 'Pak Budi';
    final hasWarning = TelemetryService.instance.currentAlerts.any(
        (a) => !a.acknowledged && (a.isCritical || a.isFall || a.severity == 'warning'));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          height: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE6F6F8), Color(0xFFB4E0E8)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -35,
                top: -70,
                child: Container(
                  width: 210,
                  height: 210,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x66FFFFFF),
                  ),
                ),
              ),
              Positioned(
                right: -16,
                bottom: -27,
                width: 218,
                height: 238,
                child: Image.asset(
                  'assets/images/care_family_editorial.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .88),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              color: hasWarning
                                  ? const Color(0xFFE95858)
                                  : const Color(0xFF52AD87),
                              size: 8,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              hasWarning ? 'PERLU PERIKSA' : 'KONDISI STABIL',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                                color: hasWarning
                                    ? const Color(0xFFC0392B)
                                    : const Color(0xFF296B54),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 180,
                        child: Text(
                          '$elderName\n${hasWarning ? 'butuh dicek.' : 'baik hari ini.'}',
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            letterSpacing: -.6,
                            color: Color(0xFF123D4F),
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Lihat ringkasan  ↗',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF176E9E),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  const _MedicineCard({required this.done, required this.onTap});
  final bool done;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final elderName = TelemetryService.instance.activeElder?.name ?? 'Pak Budi';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: done ? const Color(0xFFA8DDC2) : const Color(0xFFE2EDF0),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 53,
                height: 53,
                decoration: BoxDecoration(
                  color: done
                      ? const Color(0xFFE5F6EC)
                      : _CreativeHomeState.apricot,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  done ? Icons.check_rounded : Icons.medication_rounded,
                  color: done
                      ? const Color(0xFF2B925D)
                      : _CreativeHomeState.coral,
                  size: 27,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      done ? 'Obat pagi selesai' : 'Obat pagi $elderName',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _CreativeHomeState.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Amlodipine 5 mg · 08.00',
                      style: TextStyle(fontSize: 11, color: Color(0xFF68818A)),
                    ),
                  ],
                ),
              ),
              Icon(
                done ? Icons.undo_rounded : Icons.arrow_forward_rounded,
                color: _CreativeHomeState.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.width,
    required this.title,
    required this.caption,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final double width;
  final String title, caption;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Material(
      color: color,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: _CreativeHomeState.blue, size: 29),
              const SizedBox(height: 17),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _CreativeHomeState.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                caption,
                style: const TextStyle(fontSize: 11, color: Color(0xFF52717C)),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFF153F50),
    borderRadius: BorderRadius.circular(22),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: const Padding(
        padding: EdgeInsets.all(19),
        child: Row(
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: Color(0xFF2D7184),
              child: Icon(Icons.monitor_heart_rounded, color: Colors.white),
            ),
            SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SecondBand tersambung',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Tanda vital Nenek siap dilihat',
                    style: TextStyle(color: Color(0xFFB8D9DF), fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.north_east_rounded, color: Colors.white),
          ],
        ),
      ),
    ),
  );
}
