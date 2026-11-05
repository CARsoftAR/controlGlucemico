import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/theme/theme.dart';
import '../../../measurements/presentation/providers/glucose_provider.dart';

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
            const SizedBox(height: 24),

            // Sección: Gestión de datos
            _buildSectionHeader('GESTIÓN DE DATOS'),
            const SizedBox(height: 8),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.cloud_download_outlined,
                      color: AppColors.primaryCyan,
                    ),
                    title: const Text(
                      'Cargar historial histórico (Seed)',
                      style: TextStyle(
                        color: AppColors.primaryCyan,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Popular la base de datos con los 22 registros de mediciones e insulina',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primaryCyan,
                      size: 20,
                    ),
                    onTap: () async {
                      final provider = Provider.of<GlucoseProvider>(context, listen: false);
                      await provider.loadHistoricalData();
                      if (context.mounted) {
                        _showFeedback('Historial de 22 registros cargado con éxito');
                      }
                    },
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.alertMagenta,
                    ),
                    title: const Text(
                      'Borrar todos los registros',
                      style: TextStyle(
                        color: AppColors.alertMagenta,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Eliminar permanentemente todo el historial de mediciones',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.alertMagenta,
                      size: 20,
                    ),
                    onTap: () => _showClearDataConfirmationDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showClearDataConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF0A0A0A),
          surfaceTintColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.border, width: 1.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Ícono de advertencia/papelera centrado dentro de un círculo tenue (width 64, height 64, margin bottom 20px)
                Container(
                  width: 64,
                  height: 64,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF007F).withValues(alpha: 0.12),
                    border: Border.all(
                      color: const Color(0xFFFF007F).withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFFF007F),
                    size: 32,
                  ),
                ),

                // Título centrado
                const Text(
                  '¿Eliminar todo el historial?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),

                // Descripción centrada
                const Text(
                  'Esta acción no se puede deshacer. Se eliminarán permanentemente todas las mediciones registradas en el dispositivo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 28),

                // Fila de botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Botón Cancelar: TextButton solo texto, sin fondo ni recuadro, color texto gris/blanco, fontWeight bold
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          side: BorderSide.none,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),

                    // Botón Acción (Eliminar): Fondo Magenta (#FF007F), borderRadius de 16px, padding de 12px, color texto blanco, fontWeight bold
                    ElevatedButton(
                      onPressed: () async {
                        final provider = Provider.of<GlucoseProvider>(context, listen: false);
                        await provider.clearAllData();
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                        if (context.mounted) {
                          _showFeedback('Todos los registros han sido eliminados');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF007F),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
