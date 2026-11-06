import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/glucose_measurement.dart';
import '../../../../core/theme/theme.dart';
import '../../../measurements/presentation/providers/glucose_provider.dart';

/// Gráfico de tendencia de glucosa para los últimos 7 días con estética Light Glassmorphism
/// y contención estricta antidesbordamiento (ClipRRect + SizedBox fijo)
class GlucoseChartWidget extends StatelessWidget {
  const GlucoseChartWidget({super.key});

  static const List<String> _dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  @override
  Widget build(BuildContext context) {
    final glucoseProvider = context.watch<GlucoseProvider>();
    final allMeasurements = glucoseProvider.measurements;

    // Filtrar y ordenar mediciones de los últimos 7 días con datos disponibles
    final now = DateTime.now();
    final sevenDaysAgo = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));

    List<GlucoseMeasurement> recentMeasurements = allMeasurements
        .where((m) => m.timestamp.isAfter(sevenDaysAgo) || m.timestamp.isAtSameMomentAs(sevenDaysAgo))
        .toList();

    // Si los últimos 7 días calendario no tienen registros, tomar la última ventana de 7 días con mediciones registradas
    if (recentMeasurements.isEmpty && allMeasurements.isNotEmpty) {
      final latest = allMeasurements.map((m) => m.timestamp).reduce((a, b) => a.isAfter(b) ? a : b);
      final rangeStart = DateTime(latest.year, latest.month, latest.day).subtract(const Duration(days: 6));
      final rangeEnd = DateTime(latest.year, latest.month, latest.day).add(const Duration(days: 1));
      recentMeasurements = allMeasurements
          .where((m) => (m.timestamp.isAfter(rangeStart) || m.timestamp.isAtSameMomentAs(rangeStart)) && m.timestamp.isBefore(rangeEnd))
          .toList();
    }
    recentMeasurements.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return GlassContainer(
      padding: const EdgeInsets.all(18.0),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera del gráfico con textos oscuros de alto contraste
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryCyan.withValues(alpha: 0.25)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryCyan.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
          const SizedBox(height: 18),

          // Contenedor del gráfico LineChart con altura controlada, recorte estricto y fondo blanco translúcido
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 190,
              width: double.infinity,
              padding: const EdgeInsets.only(right: 14, left: 4, top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.55), // Vidrio blanco translúcido
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.2),
              ),
              child: recentMeasurements.isEmpty
                  ? _buildEmptyState()
                  : _buildLineChart(recentMeasurements),
            ),
          ),
          const SizedBox(height: 14),

          // Leyenda de puntos
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendIndicator(AppColors.primaryCyan, 8, 'Normal (≤ 140 mg/dL)'),
              const SizedBox(width: 20),
              _buildLegendIndicator(AppColors.alertMagenta, 12, 'Elevada (> 140 mg/dL)'),
            ],
          ),
        ],
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
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
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

    // Agrupar índices por fecha para renderizar el texto del día una única vez por fecha
    final Map<String, List<int>> indicesByDate = {};
    for (int i = 0; i < measurements.length; i++) {
      final m = measurements[i];
      final x = i.toDouble();
      spots.add(FlSpot(x, m.value));

      final dateKey =
          '${m.timestamp.year}-${m.timestamp.month.toString().padLeft(2, '0')}-${m.timestamp.day.toString().padLeft(2, '0')}';
      indicesByDate.putIfAbsent(dateKey, () => []).add(i);
    }

    // Para cada fecha única, asignar la etiqueta del día solo al índice medio (una sola vez por día)
    indicesByDate.forEach((dateKey, indices) {
      final midIndex = indices[indices.length ~/ 2];
      final m = measurements[midIndex];
      final dayName = _dayNames[m.timestamp.weekday - 1];
      dateLabels[midIndex.toDouble()] = dayName;
    });

    // 1. Fix del Eje Y: cálculo dinámico del valor máximo + margen de 40 unidades
    final double maxDataValue = measurements.isEmpty
        ? 180.0
        : measurements.map((m) => m.value).reduce((a, b) => a > b ? a : b);
    final double maxY = (maxDataValue + 40).toDouble();

    final double minDataValue = measurements.isEmpty
        ? 70.0
        : measurements.map((m) => m.value).reduce((a, b) => a < b ? a : b);
    final double minY = (minDataValue - 20 < 40.0) ? 40.0 : (minDataValue - 20).toDouble();

    final double maxX = (measurements.length - 1).toDouble() > 0
        ? (measurements.length - 1).toDouble()
        : 1.0;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        minX: 0,
        maxX: maxX,

        // Contención estricta: recorta cualquier punto o curva que supere los límites del gráfico
        clipData: const FlClipData.all(),

        // Rejilla interna sutil y elegante sin desbordar
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 40,
          getDrawingHorizontalLine: (value) => FlLine(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),

        // Configuración de bordes
        borderData: FlBorderData(show: false),

        // Configuración de Ejes con márgenes y tamaños controlados
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          // EJE Y: Valores de glucosa
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

          // EJE X: Días en el eje X (renderizado una única vez por fecha)
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final int index = value.round();
                if ((value - index).abs() > 0.05) {
                  return const SizedBox.shrink();
                }

                final label = dateLabels[index.toDouble()];
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
            color: AppColors.primaryCyan, // Cyan brillante
            barWidth: 3.0,
            isStrokeCapRound: true,

            // PUNTOS DE DATOS (DOTS):
            // - Menor o igual a 140 mg/dl: Cyan
            // - Mayor a 140 mg/dl: Magenta (#FF007F)
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final bool isHigh = spot.y > 140.0;
                final Color dotColor = isHigh ? AppColors.alertMagenta : AppColors.primaryCyan;
                final double radius = isHigh ? 5.0 : 3.5;

                return FlDotCirclePainter(
                  radius: radius,
                  color: dotColor,
                  strokeWidth: isHigh ? 2.5 : 2.0,
                  strokeColor: Colors.white,
                );
              },
            ),

            // Sombra/Gradiente translúcido inferior
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

        // Tooltip interactivo con estilo translúcido esmerilado blanco
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.white.withValues(alpha: 0.95),
            tooltipBorder: BorderSide(color: Colors.white.withValues(alpha: 0.90)),
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
