import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/glucose_measurement.dart';
import '../../core/theme/theme.dart';
import '../history/presentation/screens/history_metrics_screen.dart';
import '../measurements/presentation/providers/glucose_provider.dart';
import '../measurements/presentation/screens/add_measurement_screen.dart';
import '../settings/presentation/screens/settings_screen.dart';
import 'presentation/widgets/glucose_chart_widget.dart';

/// Pantalla principal de Monitoreo y Dashboard de Glucosa
/// Estructura limpia y enfocada en métricas resumidas, gráfico interactivo y acceso al historial completo
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

  /// Navega a la pantalla de historial y métricas
  void _navigateToHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HistoryMetricsScreen(),
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

    return Container(
      // Fondo con Degradé Lineal suave y limpio
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildMinimalistAppBar(context),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Tarjetas de métricas principales con efecto Glassmorphism
                _buildMetricsOverview(lastMeasurement, averageGlucose, inRangePercentage),
                const SizedBox(height: 20),

                // 2. Gráfico interactivo de tendencia con recorte estricto antidesbordamiento
                const GlucoseChartWidget(),
                const SizedBox(height: 24),

                // 3. Tarjeta de Acceso Directo al Historial y Métricas Completo (Dashboard limpio)
                _buildHistoryAccessCard(context, measurements.length),
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
      ),
    );
  }

  /// AppBar translúcida con accesos directos rápidos
  PreferredSizeWidget _buildMinimalistAppBar(BuildContext context) {
    return AppBar(
      titleSpacing: 16,
      backgroundColor: Colors.transparent,
      elevation: 0,
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
                  color: AppColors.primaryCyan.withValues(alpha: 0.7),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
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
        // Acceso directo a Historial y Métricas
        IconButton(
          tooltip: 'Historial y Métricas',
          onPressed: () => _navigateToHistory(context),
          icon: const Icon(
            Icons.analytics_outlined,
            color: AppColors.primaryCyan,
            size: 24,
          ),
        ),
        // Recordatorios y Alarmas
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

  /// Tarjetas de métricas rápidas con efecto Glassmorphism (BackdropFilter + Borde 1.5px)
  Widget _buildMetricsOverview(
      GlucoseMeasurement? last, double averageGlucose, int inRangePercentage) {
    return Row(
      children: [
        // Tarjeta: Último Registro (Glassmorphism)
        Expanded(
          child: GlassContainer(
            padding: const EdgeInsets.all(16.0),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ÚLTIMO REGISTRO',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 8),
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
                        fontSize: 28,
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
        const SizedBox(width: 12),

        // Tarjeta: Promedio Diario (Glassmorphism)
        Expanded(
          child: GlassContainer(
            padding: const EdgeInsets.all(16.0),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PROMEDIO DIARIO',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      averageGlucose.toStringAsFixed(0),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
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
                  style: const TextStyle(
                    color: AppColors.successGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Tarjeta de acceso directo al Historial y Métricas completas
  Widget _buildHistoryAccessCard(BuildContext context, int totalCount) {
    return InkWell(
      onTap: () => _navigateToHistory(context),
      borderRadius: BorderRadius.circular(20),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryCyan.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.history_edu_rounded,
                    color: AppColors.primaryCyan,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Historial y Métricas',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$totalCount registros almacenados',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.primaryCyan,
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: Color(0x1F0F172A), height: 1),
            const SizedBox(height: 12),
            const Text(
              'Consulta registros agrupados por fecha, distribuciones porcentuales en rango glucémico y filtros avanzados por día, semana o intervalo personalizado.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryCyan.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tune_rounded, size: 14, color: AppColors.primaryCyan),
                      SizedBox(width: 6),
                      Text(
                        'Filtros día / semana',
                        style: TextStyle(
                          color: AppColors.primaryCyan,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pie_chart_outline_rounded, size: 14, color: AppColors.successGreen),
                      SizedBox(width: 6),
                      Text(
                        'Gráfico circular',
                        style: TextStyle(
                          color: AppColors.successGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
