import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/glucose_measurement.dart';
import '../../../../core/theme/theme.dart';
import '../providers/glucose_provider.dart';

/// Pantalla dedicada para el registro de mediciones de glucosa y evaluación de umbrales
class AddMeasurementScreen extends StatefulWidget {
  const AddMeasurementScreen({super.key});

  @override
  State<AddMeasurementScreen> createState() => _AddMeasurementScreenState();
}

class _AddMeasurementScreenState extends State<AddMeasurementScreen> {
  final TextEditingController _glucoseController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Opciones de contexto clínico requeridas
  final List<String> _contextOptions = [
    'En ayunas',
    'Post-desayuno',
    'Antes de comer',
    'Post-almuerzo',
    'Antes de cenar',
    'Post-cena',
    'Antes de dormir',
    'Madrugada',
  ];

  late String _selectedContext;

  @override
  void initState() {
    super.initState();
    _selectedContext = _contextOptions[0]; // Por defecto 'En ayunas'
  }

  @override
  void dispose() {
    _glucoseController.dispose();
    super.dispose();
  }

  /// Función que evalúa el umbral (> 140 mg/dL) y dispara el modal estricto de Antigravity
  Future<void> _processMeasurementSubmission() async {
    if (!_formKey.currentState!.validate()) return;

    final double? glucoseValue = double.tryParse(_glucoseController.text.trim());
    if (glucoseValue == null) return;

    // LÓGICA ESTRICTA: Evalúa si supera los 140 mg/dL
    if (glucoseValue > 140.0) {
      final bool? proceed = await _showHighGlucoseAlertModal(glucoseValue);
      // Si el usuario canceló en el modal, no continuamos con el guardado
      if (proceed != true) return;
    }

    // Creación de la entidad final para Firebase / Estado local
    final newMeasurement = GlucoseMeasurement.create(
      value: glucoseValue,
      context: _selectedContext,
      isHigh: glucoseValue > 140.0,
      timestamp: DateTime.now(),
    );

    if (mounted) {
      context.read<GlucoseProvider>().addMeasurement(newMeasurement);
      Navigator.of(context).pop(newMeasurement);
    }
  }

  /// Estructura exacta e inquebrantable del Modal de Alerta de Antigravity
  Future<bool?> _showHighGlucoseAlertModal(double value) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.surfaceCard, // #0A0A0A
          surfaceTintColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // borderRadius de 24px
            side: const BorderSide(color: AppColors.border, width: 1.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Ícono centrado dentro de un círculo tenue
                // width: 64, height: 64, margin: '0 auto 20px', borderRadius: '50%'
                Container(
                  width: 64,
                  height: 64,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.alertMagenta.withValues(alpha: 0.12),
                    border: Border.all(
                      color: AppColors.alertMagenta.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.warning_amber_rounded,
                      size: 34,
                      color: AppColors.alertMagenta,
                    ),
                  ),
                ),

                // Título descriptivo centrado
                const Text(
                  'Alerta: Glucosa Elevada',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),

                // Descripción centrada
                Text(
                  'El valor ingresado (${value.toStringAsFixed(0)} mg/dL) supera el umbral límite de 140 mg/dL.\n\n¿Deseas confirmar y registrar esta medición de todos modos?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),

                // Fila de Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Botón Cancelar: TextButton solo texto, sin fondo, sin recuadro, fontWeight bold
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: const RoundedRectangleBorder(side: BorderSide.none),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),

                    // Botón Acción: Fondo Magenta (#FF007F), borderRadius de 16px, padding de 12px, texto blanco en bold
                    ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.alertMagenta, // #FF007F
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // padding de 12px
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16), // borderRadius de 16px
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold, // texto blanco en bold
                          fontSize: 14,
                          letterSpacing: 0.2,
                        ),
                      ),
                      child: const Text('Registrar de todos modos'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureBlack,
      appBar: AppBar(
        title: const Text('Registrar Glucosa'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado de la tarjeta principal
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryCyan.withValues(alpha: 0.12),
                              ),
                              child: const Icon(
                                Icons.water_drop_rounded,
                                color: AppColors.primaryCyan,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nivel de Glucosa',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Ingresa tu lectura en mg/dL',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Input numérico grande y estilizado
                        TextFormField(
                          controller: _glucoseController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: '110',
                            hintStyle: TextStyle(
                              color: AppColors.textMuted.withValues(alpha: 0.4),
                            ),
                            suffixText: 'mg/dL',
                            suffixStyle: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            filled: true,
                            fillColor: AppColors.pureBlack,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppColors.primaryCyan, width: 1.8),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppColors.alertMagenta, width: 1.5),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppColors.alertMagenta, width: 2.0),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Por favor ingresa un valor de glucosa';
                            }
                            final parsed = double.tryParse(val.trim());
                            if (parsed == null || parsed <= 0) {
                              return 'Ingresa un valor numérico válido';
                            }
                            if (parsed > 600) {
                              return 'El valor supera el rango medible (>600 mg/dL)';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Selector de Contexto (Dropdown)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MOMENTO DE LA MEDICIÓN',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // DropdownButtonFormField estéticamente adaptado al tema Pure Dark
                        DropdownButtonFormField<String>(
                          initialValue: _selectedContext,
                          dropdownColor: AppColors.surfaceElevated,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryCyan),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.pureBlack,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.primaryCyan),
                            ),
                          ),
                          items: _contextOptions.map((opt) {
                            return DropdownMenuItem<String>(
                              value: opt,
                              child: Text(opt),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedContext = val;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Botón principal de Guardar / Evaluar
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _processMeasurementSubmission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryCyan,
                      foregroundColor: AppColors.pureBlack,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    child: const Text('GUARDAR MEDICIÓN'),
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
