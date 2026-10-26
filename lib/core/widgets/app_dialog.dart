import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Tipo de modal para variar estilos visuales de acento
enum DialogType { normal, alert }

/// Modal estándar del sistema con reglas estrictas de Antigravity:
/// - Dialog con bordes de 24px y fondo #0A0A0A
/// - Ícono centrado dentro de un círculo tenue
/// - Título y descripción centrados
/// - Botón Cancelar: TextButton solo texto, sin fondo ni recuadro, negrita
/// - Botón Acción: Fondo Cyan (o Magenta para alertas) con borderRadius de 16px, padding de 12px, texto blanco en negrita
class AppDialog extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String cancelText;
  final String actionText;
  final VoidCallback onAction;
  final VoidCallback? onCancel;
  final DialogType dialogType;
  final Widget? customContent;

  const AppDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.cancelText = 'Cancelar',
    required this.actionText,
    required this.onAction,
    this.onCancel,
    this.dialogType = DialogType.normal,
    this.customContent,
  });

  /// Método estático utilitario para invocar el diálogo fácilmente
  static Future<T?> show<T>({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    String cancelText = 'Cancelar',
    required String actionText,
    required VoidCallback onAction,
    VoidCallback? onCancel,
    DialogType dialogType = DialogType.normal,
    Widget? customContent,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => AppDialog(
        icon: icon,
        title: title,
        description: description,
        cancelText: cancelText,
        actionText: actionText,
        onAction: onAction,
        onCancel: onCancel,
        dialogType: dialogType,
        customContent: customContent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAlert = dialogType == DialogType.alert;
    final Color accentColor = isAlert ? AppColors.alertMagenta : AppColors.primaryCyan;

    return Dialog(
      backgroundColor: AppColors.surfaceCard,
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
            // Ícono centrado dentro de un círculo tenue
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.12),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                size: 34,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 20),

            // Título centrado
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),

            // Descripción centrada
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.45,
              ),
            ),

            if (customContent != null) ...[
              const SizedBox(height: 16),
              customContent!,
            ],

            const SizedBox(height: 28),

            // Fila de botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Botón Cancelar: TextButton solo texto, sin fondo ni recuadro, negrita
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onCancel != null) onCancel!();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  child: Text(cancelText),
                ),
                const SizedBox(width: 12),

                // Botón Acción: Fondo Cyan (o Magenta) con borderRadius de 16px, padding de 12px, texto blanco en negrita
                ElevatedButton(
                  onPressed: () {
                    onAction();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.3,
                    ),
                  ),
                  child: Text(actionText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
