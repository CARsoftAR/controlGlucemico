import 'package:flutter/material.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/theme/theme.dart';

/// Pantalla de configuración para la gestión de recordatorios y alarmas locales
/// Respeta estrictamente la estética Pure Dark con interruptores en Cyan (#00F0FF)
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Estados locales de los recordatorios diarios
  bool _remindFasting = true; // 08:00 hrs
  bool _remindLunch = true; // 13:00 hrs
  bool _remindBedtime = false; // 22:00 hrs

  @override
  void initState() {
    super.initState();
    _applyActiveReminders();
  }

  void _applyActiveReminders() {
    if (_remindFasting) {
      NotificationService.instance.scheduleDailyReminder(8, 0, 'En ayunas', id: 101);
    }
    if (_remindLunch) {
      NotificationService.instance.scheduleDailyReminder(13, 0, 'Antes de comer', id: 102);
    }
    if (_remindBedtime) {
      NotificationService.instance.scheduleDailyReminder(22, 0, 'Antes de dormir', id: 103);
    }
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: AppColors.primaryCyan, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureBlack,
      appBar: AppBar(
        title: const Text('Ajustes y Recordatorios'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          children: [
            // Sección: Alarmas recurrentes diarias
            _buildSectionHeader('RECORDATORIOS DIARIOS RECURRENTES'),
            const SizedBox(height: 8),

            Card(
              child: Column(
                children: [
                  _buildReminderTile(
                    title: 'Control en Ayunas',
                    time: '08:00 AM',
                    subtitle: 'Medición matutina basal al despertar',
                    value: _remindFasting,
                    onChanged: (val) {
                      setState(() => _remindFasting = val);
                      if (val) {
                        NotificationService.instance.scheduleDailyReminder(8, 0, 'En ayunas', id: 101);
                        _showFeedback('Recordatorio de ayunas programado a las 08:00 AM');
                      } else {
                        NotificationService.instance.cancelReminder(101);
                        _showFeedback('Recordatorio de ayunas desactivado');
                      }
                    },
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  _buildReminderTile(
                    title: 'Control Pre-Almuerzo',
                    time: '01:00 PM',
                    subtitle: 'Medición previa a la comida principal',
                    value: _remindLunch,
                    onChanged: (val) {
                      setState(() => _remindLunch = val);
                      if (val) {
                        NotificationService.instance.scheduleDailyReminder(13, 0, 'Antes de comer', id: 102);
                        _showFeedback('Recordatorio de almuerzo programado a la 01:00 PM');
                      } else {
                        NotificationService.instance.cancelReminder(102);
                        _showFeedback('Recordatorio de almuerzo desactivado');
                      }
                    },
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  _buildReminderTile(
                    title: 'Antes de Dormir',
                    time: '10:00 PM',
                    subtitle: 'Prevención de episodios nocturnos de hipoglucemia',
                    value: _remindBedtime,
                    onChanged: (val) {
                      setState(() => _remindBedtime = val);
                      if (val) {
                        NotificationService.instance.scheduleDailyReminder(22, 0, 'Antes de dormir', id: 103);
                        _showFeedback('Recordatorio nocturno programado a las 10:00 PM');
                      } else {
                        NotificationService.instance.cancelReminder(103);
                        _showFeedback('Recordatorio nocturno desactivado');
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sección: Notificaciones de emergencia
            _buildSectionHeader('ALERTAS DE EMERGENCIA Y UMBRALES'),
            const SizedBox(height: 8),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.alertMagenta.withValues(alpha: 0.12),
                          ),
                          child: const Icon(Icons.health_and_safety_rounded, color: AppColors.alertMagenta, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hiperglucemia Crítica',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Disparo automático al registrar > 180 mg/dL',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Cuando registres un valor de glucosa que supere el límite crítico de 180 mg/dL, el sistema emitirá de forma autónoma una notificación prioritaria de alta urgencia.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Botón para probar la notificación crítica inmediata
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await NotificationService.instance.showHighGlucoseAlert(215.0);
                          _showFeedback('Alerta de prueba emitida (>180 mg/dL)');
                        },
                        icon: const Icon(Icons.notification_important_rounded, color: AppColors.alertMagenta, size: 20),
                        label: const Text(
                          'Probar Notificación Crítica',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.alertMagenta, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor: AppColors.alertMagenta.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildReminderTile({
    required String title,
    required String time,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      activeThumbColor: AppColors.primaryCyan, // Switchers en Cyan según requerimiento
      activeTrackColor: AppColors.primaryCyan.withValues(alpha: 0.3),
      inactiveThumbColor: AppColors.textSecondary,
      inactiveTrackColor: AppColors.surfaceElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      title: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              time,
              style: const TextStyle(
                color: AppColors.primaryCyan,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
