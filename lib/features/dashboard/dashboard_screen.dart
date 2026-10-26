import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/models/glucose_measurement.dart';
import '../../core/theme/theme.dart';
import '../measurements/presentation/providers/glucose_provider.dart';
import '../measurements/presentation/screens/add_measurement_screen.dart';
import '../settings/presentation/screens/settings_screen.dart';
import 'presentation/widgets/glucose_chart_widget.dart';

/// Pantalla principal de Monitoreo y Dashboard de Glucosa
/// Reactiva, integrada con fl_chart (GlucoseChartWidget) y GlucoseProvider
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  /// Navega a la pantalla de registro de medición
  Future<void> _handleRegisterMeasurement(BuildContext context) async {
    await Navigator.of(context).push<GlucoseMeasurement>(
      MaterialPageRoute(
        builder: (context) => const AddMeasurementScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Consumo reactivo del gestor de estado GlucoseProvider
    final glucoseProvider = context.watch<GlucoseProvider>();
    final measurements = glucoseProvider.measurements;
    final lastMeasurement = glucoseProvider.lastMeasurement;
    final double averageGlucose = glucoseProvider.averageGlucose;
    final int inRangePercentage = glucoseProvider.inRangePercentage;

    return Scaffold(
      backgroundColor: AppColors.pureBlack,
      appBar: _buildMinimalistAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner con métricas principales conectadas a Provider
              _buildMetricsOverview(lastMeasurement, averageGlucose, inRangePercentage),
              const SizedBox(height: 20),

              // SPRINT 4: Gráfico interactivo y minimalista de los últimos 7 días con fl_chart
              const GlucoseChartWidget(),
              const SizedBox(height: 24),

              // Encabezado de la lista reactiva
              _buildRecentMeasurementsHeader(measurements.length),
              const SizedBox(height: 12),

              // Historial reciente usando ListView.builder con franja de acento lateral
              _buildMeasurementsList(measurements, glucoseProvider.isLoading),
              const SizedBox(height: 80), // Margen inferior para el FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _handleRegisterMeasurement(context),
        tooltip: 'Registrar Medición',
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  /// AppBar minimalista con tipografía pura e indicadores sutiles
  PreferredSizeWidget _buildMinimalistAppBar(BuildContext context) {
    return AppBar(
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryCyan,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryCyan.withValues(alpha: 0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GLUCO CONTROL',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'Monitoreo Continuo Diario',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Recordatorios y Alarmas',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.primaryCyan,
            size: 24,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Tarjetas de métricas rápidas (Promedio, En Rango, Último Registro)
  Widget _buildMetricsOverview(
      GlucoseMeasurement? last, double averageGlucose, int inRangePercentage) {
    return Row(
      children: [
        // Último Registro
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ÚLTIMO REGISTRO',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        last != null ? last.value.toStringAsFixed(0) : '--',
                        style: TextStyle(
                          color: (last != null && last.isHigh)
                              ? AppColors.alertMagenta
                              : AppColors.primaryCyan,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'mg/dL',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    last != null ? last.context : 'Sin datos',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Promedio
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PROMEDIO DIARIO',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        averageGlucose.toStringAsFixed(0),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'mg/dL',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'En Rango: $inRangePercentage%',
                    style: const TextStyle(color: AppColors.successGreen, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentMeasurementsHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Registros de Hoy',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '$count mediciones',
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Historial reciente usando ListView.builder con franja de acento lateral
  Widget _buildMeasurementsList(List<GlucoseMeasurement> measurements, bool isLoading) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(
          color: AppColors.primaryCyan,
          strokeWidth: 2.5,
        ),
      );
    }

    if (measurements.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: const Text(
          'Aún no hay mediciones guardadas.\nToca "+" para registrar tu primera lectura.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: measurements.length,
      itemBuilder: (context, index) {
        final item = measurements[index];
        final bool isHigh = item.isHigh;
        final Color accentColor = isHigh ? AppColors.alertMagenta : AppColors.primaryCyan;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard, // #0A0A0A
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border, // #1A1A1A
              width: 1.0,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ACENTO LATERAL VISUAL: Franja Cyan (#00F0FF) o Magenta (#FF007F)
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: accentColor,
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),

                // Contenido del registro
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        // Ícono de estado en círculo tenue
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accentColor.withValues(alpha: 0.12),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.3),
                              width: 1.0,
                            ),
                          ),
                          child: Icon(
                            isHigh ? Icons.arrow_upward_rounded : Icons.check_rounded,
                            color: accentColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Contexto y hora
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.context,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _formatDateTime(item.timestamp),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Valor numérico de glucosa
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  item.value.toStringAsFixed(0),
                                  style: TextStyle(
                                    color: isHigh ? AppColors.alertMagenta : AppColors.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                const Text(
                                  'mg/dL',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.statusLabel,
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dt) {
    return DateFormat("dd/MM/yyyy - HH:mm 'hrs'").format(dt);
  }
}
