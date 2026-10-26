import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/glucose_measurement.dart';
import '../../../../core/theme/theme.dart';

/// Modal interactivo para el registro rápido de una medición de glucosa
/// Cumple estrictamente con el componente de Modal de Antigravity (Regla 4).
class AddMeasurementModal {
  AddMeasurementModal._();

  static Future<GlucoseMeasurement?> show(BuildContext context) async {
    final TextEditingController valueController = TextEditingController();
    String selectedContext = 'En ayunas';
    final List<String> contextOptions = [
      'En ayunas',
      'Antes de comer',
      'Postprandial (2h)',
      'Antes de dormir',
      'Madrugada',
    ];

    return showDialog<GlucoseMeasurement>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final double? enteredVal = double.tryParse(valueController.text);
            final bool isAlarm = enteredVal != null &&
                (enteredVal > GlucoseMeasurement.defaultHighThreshold ||
                    enteredVal < GlucoseMeasurement.defaultLowThreshold);

            final Color accentColor =
                isAlarm ? AppColors.alertMagenta : AppColors.primaryCyan;

            return Dialog(
              backgroundColor: AppColors.surfaceCard,
              surfaceTintColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: AppColors.border, width: 1.0),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ícono centrado dentro de un círculo tenue
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor.withValues(alpha: 0.12),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.water_drop_outlined,
                          size: 36,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Título centrado
                      const Text(
                        'Nueva Medición',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Descripción centrada
                      const Text(
                        'Ingresa el valor de glucosa capilar medido en tu glucómetro.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Campo de texto para el valor
                      TextField(
                        controller: valueController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        autofocus: true,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                        decoration: InputDecoration(
                          hintText: '110',
                          hintStyle: TextStyle(
                            color: AppColors.textMuted.withValues(alpha: 0.5),
                          ),
                          suffixText: 'mg/dL',
                          suffixStyle: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          filled: true,
                          fillColor: AppColors.pureBlack,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: accentColor, width: 1.5),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),

                      // Selector de contexto/momento del día
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'MOMENTO DE MEDICIÓN',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: contextOptions.map((opt) {
                          final bool isSelected = opt == selectedContext;
                          return ChoiceChip(
                            label: Text(
                              opt,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.pureBlack
                                    : AppColors.textSecondary,
                                fontWeight:
                                    isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.primaryCyan,
                            backgroundColor: AppColors.surfaceElevated,
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primaryCyan
                                  : AppColors.border,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onSelected: (val) {
                              if (val) {
                                setState(() {
                                  selectedContext = opt;
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 28),

                      // Fila de acciones (Regla 4)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Botón Cancelar: TextButton solo texto, sin fondo ni recuadro, negrita
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 12),

                          // Botón Acción: Fondo Cyan (o Magenta) con borderRadius de 16px, padding de 12px, texto blanco en negrita
                          ElevatedButton(
                            onPressed: () {
                              final val = double.tryParse(valueController.text);
                              if (val == null || val <= 0) return;

                              final measurement = GlucoseMeasurement.create(
                                value: val,
                                context: selectedContext,
                              );

                              Navigator.of(context).pop(measurement);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.3,
                              ),
                            ),
                            child: const Text('Guardar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
