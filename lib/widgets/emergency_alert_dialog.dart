import 'package:flutter/material.dart';
import '../models/telemetry.dart';
import '../services/telemetry_service.dart';

bool _isEmergencyDialogOpen = false;

void showEmergencyDialog(BuildContext context, AlertItem alert) {
  if (_isEmergencyDialogOpen) return;
  _isEmergencyDialogOpen = true;
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => EmergencyAlertDialog(alert: alert),
  ).then((_) {
    _isEmergencyDialogOpen = false;
  });
}

class EmergencyAlertDialog extends StatefulWidget {
  final AlertItem alert;
  const EmergencyAlertDialog({super.key, required this.alert});

  @override
  State<EmergencyAlertDialog> createState() => _EmergencyAlertDialogState();
}

class _EmergencyAlertDialogState extends State<EmergencyAlertDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alert = widget.alert;
    final isCritical = alert.isCritical || alert.isFall || alert.isSos;
    final primaryColor =
        isCritical ? const Color(0xFFE95858) : const Color(0xFFF5A524);
    final elder = TelemetryService.instance.activeElder;
    final elderName = elder?.name ?? 'Lansia Tersayang';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.15),
                  border: Border.all(color: primaryColor, width: 2.5),
                ),
                child: Icon(
                  alert.isFall
                      ? Icons.personal_injury_rounded
                      : alert.isSos
                      ? Icons.sos_rounded
                      : Icons.warning_rounded,
                  color: primaryColor,
                  size: 42,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isCritical ? 'PERINGATAN KRITIS' : 'PERINGATAN KESEHATAN',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              alert.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF123D4F),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Terdeteksi pada $elderName',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF627B84),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FBFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2EDF0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF123D4F),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 14, color: Color(0xFF627B84)),
                      const SizedBox(width: 5),
                      Text(
                        'Pukul ${alert.ts.hour.toString().padLeft(2, '0')}.${alert.ts.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF627B84),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: Color(0xFF176E9E)),
                      const SizedBox(width: 4),
                      const Text(
                        'Radius Rumah',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF176E9E),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    icon: const Icon(Icons.call),
                    label: const Text('Hubungi'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryColor,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () {
                      // Acknowledge locally and remotely, dismiss immediately
                      alert.acknowledged = true;
                      TelemetryService.instance.acknowledgeAlert(alert.id);
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: const Text('Tangani (Ack)'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
