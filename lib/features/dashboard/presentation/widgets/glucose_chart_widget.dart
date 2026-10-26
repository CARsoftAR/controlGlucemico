import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/glucose_measurement.dart';
import '../../../../core/theme/theme.dart';
import '../../../measurements/presentation/providers/glucose_provider.dart';

/// Gráfico minimalista de tendencia de glucosa para los últimos 7 días
/// Cumple estrictamente con las reglas de diseño "Pure Dark"
class GlucoseChartWidget extends StatelessWidget {
  const GlucoseChartWidget({super.key});

  static const List<String> _dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  @override
  Widget build(BuildContext context) {
    final glucoseProvider = context.watch<GlucoseProvider>();
    final allMeasurements = glucoseProvider.measurements;

    // Filtrar y ordenar mediciones de los últimos 7 días (cronológico ascendente para el eje X)
    final now = DateTime.now();
    final sevenDaysAgo = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));

    final recentMeasurements = allMeasurements
        .where((m) => m.timestamp.isAfter(sevenDaysAgo) || m.timestamp.isAtSameMomentAs(sevenDaysAgo))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera del gráfico
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tendencia Últimos 7 Días',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Umbral de alerta: 140 mg/dL',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryCyan,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '7 Días',
                        style: TextStyle(
                          color: AppColors.primaryCyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Contenedor del gráfico LineChart
            Container(
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.only(right: 12, left: 0, top: 10, bottom: 6),
              decoration: BoxDecoration(
                color: AppColors.pureBlack, // Fondo negro puro
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
              ),
              child: recentMeasurements.isEmpty
                  ? _buildEmptyState()
                  : _buildLineChart(recentMeasurements),
            ),
            const SizedBox(height: 14),

            // Leyenda de puntos
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendIndicator(AppColors.primaryCyan, 8, 'Normal (<= 140 mg/dL)'),
                const SizedBox(width: 20),
                _buildLegendIndicator(AppColors.alertMagenta, 12, 'Elevada (> 140 mg/dL)'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendIndicator(Color color, double size, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'Sin mediciones en los últimos 7 días',
        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
      ),
    );
  }

  Widget _buildLineChart(List<GlucoseMeasurement> measurements) {
    final spots = <FlSpot>[];
    final dateLabels = <double, String>{};

    for (int i = 0; i < measurements.length; i++) {
      final m = measurements[i];
      final x = i.toDouble();
      spots.add(FlSpot(x, m.value));
      // Etiqueta del día de la semana
      final dayName = _dayNames[m.timestamp.weekday - 1];
      dateLabels[x] = dayName;
    }

    final double minY = 60.0;
    final double maxY = 220.0;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        minX: 0,
        maxX: (measurements.length - 1).toDouble() > 0
            ? (measurements.length - 1).toDouble()
            : 1.0,

        // Ocultar líneas interiores de la cuadrícula
        gridData: const FlGridData(
          show: false,
        ),

        // Configuración de bordes
        borderData: FlBorderData(
          show: false,
        ),

        // Configuración de Ejes
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          // EJE Y: Valores de glucosa con estilo tenue
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              interval: 40,
              getTitlesWidget: (value, meta) {
                if (value == minY || value == maxY) {
                  return const SizedBox.shrink();
                }
                return Text(
                  value.toInt().toString(),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),

          // EJE X: Días en el eje X
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final label = dateLabels[value];
                if (label == null) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Barra de línea principal del gráfico
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColors.primaryCyan, // Cyan (#00F0FF)
            barWidth: 3.0, // Grosor de 3px
            isStrokeCapRound: true,

            // PUNTOS DE DATOS (DOTS):
            // - Menor o igual a 140 mg/dl: Cyan
            // - Mayor a 140 mg/dl: Magenta (#FF007F) resaltado fuertemente y más grande
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final bool isHigh = spot.y > 140.0;
                final Color dotColor = isHigh ? AppColors.alertMagenta : AppColors.primaryCyan;
                final double radius = isHigh ? 5.5 : 3.5;

                return FlDotCirclePainter(
                  radius: radius,
                  color: dotColor,
                  strokeWidth: isHigh ? 2.5 : 1.5,
                  strokeColor: isHigh ? Colors.white : AppColors.pureBlack,
                );
              },
            ),

            // Sombra/Gradiente sutil inferior
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryCyan.withValues(alpha: 0.20),
                  AppColors.primaryCyan.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],

        // Tooltip táctil
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.surfaceElevated,
            tooltipBorder: const BorderSide(color: AppColors.border),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final isHigh = spot.y > 140.0;
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(0)} mg/dL\n',
                  TextStyle(
                    color: isHigh ? AppColors.alertMagenta : AppColors.primaryCyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: isHigh ? 'Elevada (>140)' : 'Normal',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
