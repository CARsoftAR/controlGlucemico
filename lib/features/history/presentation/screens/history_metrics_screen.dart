import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/glucose_measurement.dart';
import '../../../measurements/presentation/providers/glucose_provider.dart';

enum HistoryFilter { day, week, custom }

/// Pantalla de Historial y Métricas (Gluco Control - Flat Design & Colores Pastel)
/// Incluye selector de filtros ("Día", "Semana", "Intervalo personalizado"),
/// registros agrupados por fecha y tarjeta inferior de resumen con gráfico circular.
class HistoryMetricsScreen extends StatefulWidget {
  const HistoryMetricsScreen({super.key});

  @override
  State<HistoryMetricsScreen> createState() => _HistoryMetricsScreenState();
}

class _HistoryMetricsScreenState extends State<HistoryMetricsScreen> {
  HistoryFilter _selectedFilter = HistoryFilter.week;
  DateTimeRange? _customDateRange;

  // Paleta de colores pastel & Flat Design estricto
  static const Color bgColor = Color(0xFFFAF8F5); // Fondo crema / blanco hueso suave
  static const Color cardColor = Colors.white; // Tarjetas planas blancas
  static const Color borderColor = Color(0xFFE8EEF3); // Bordes tenues limpios
  static const Color textDark = Color(0xFF1E293B); // Títulos oscuros
  static const Color textGray = Color(0xFF64748B); // Textos secundarios
  static const Color textMuted = Color(0xFF94A3B8); // Etiquetas

  static const Color pastelBlue = Color(0xFF7BAED4); // Acento celeste pastel
  static const Color pastelCoral = Color(0xFFE89A8C); // Alertas / Elevada
  static const Color pastelGreen = Color(0xFF81C784); // Normal / En rango
  static const Color pastelAmber = Color(0xFFF6BD60); // Hipoglucemia / Baja

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _customDateRange = DateTimeRange(
      start: now.subtract(const Duration(days: 14)),
      end: now,
    );
  }

  Future<void> _selectCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: _customDateRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 7)),
            end: now,
          ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: pastelBlue,
              onPrimary: Colors.white,
              surface: cardColor,
              onSurface: textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customDateRange = picked;
        _selectedFilter = HistoryFilter.custom;
      });
    }
  }

  List<GlucoseMeasurement> _filterMeasurements(List<GlucoseMeasurement> all) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    switch (_selectedFilter) {
      case HistoryFilter.day:
        return all.where((m) {
          return (m.timestamp.isAfter(todayStart) || m.timestamp.isAtSameMomentAs(todayStart)) &&
              m.timestamp.isBefore(todayEnd);
        }).toList();

      case HistoryFilter.week:
        final weekStart = todayStart.subtract(const Duration(days: 6));
        return all.where((m) {
          return m.timestamp.isAfter(weekStart) || m.timestamp.isAtSameMomentAs(weekStart);
        }).toList();

      case HistoryFilter.custom:
        if (_customDateRange == null) return all;
        final start = DateTime(
          _customDateRange!.start.year,
          _customDateRange!.start.month,
          _customDateRange!.start.day,
        );
        final end = DateTime(
          _customDateRange!.end.year,
          _customDateRange!.end.month,
          _customDateRange!.end.day,
        ).add(const Duration(days: 1));
        return all.where((m) {
          return (m.timestamp.isAfter(start) || m.timestamp.isAtSameMomentAs(start)) &&
              m.timestamp.isBefore(end);
        }).toList();
    }
  }

  /// Agrupa las mediciones por fecha cronológica (año, mes, día)
  Map<DateTime, List<GlucoseMeasurement>> _groupByDate(List<GlucoseMeasurement> items) {
    final Map<DateTime, List<GlucoseMeasurement>> grouped = {};

    for (final item in items) {
      final dateKey = DateTime(item.timestamp.year, item.timestamp.month, item.timestamp.day);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(item);
    }

    // Ordenar fechas descendentes (la más reciente primero)
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final Map<DateTime, List<GlucoseMeasurement>> sortedGrouped = {};
    for (final k in sortedKeys) {
      // Ordenar mediciones de cada día descendentes por hora
      grouped[k]!.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      sortedGrouped[k] = grouped[k]!;
    }

    return sortedGrouped;
  }

  @override
  Widget build(BuildContext context) {
    final glucoseProvider = context.watch<GlucoseProvider>();
    final allMeasurements = glucoseProvider.measurements;
    final filtered = _filterMeasurements(allMeasurements);
    final grouped = _groupByDate(filtered);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Historial y Métricas',
          style: TextStyle(
            color: textDark,
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Selector de Filtros ("Día", "Semana", "Intervalo personalizado")
              _buildFilterSelector(),
              const SizedBox(height: 16),

              // Rango de fechas seleccionado cuando es personalizado
              if (_selectedFilter == HistoryFilter.custom && _customDateRange != null) ...[
                _buildCustomRangeBanner(),
                const SizedBox(height: 16),
              ],

              // 2. Métricas del periodo filtrado
              _buildFilteredPeriodMetrics(filtered),
              const SizedBox(height: 24),

              // 3. Tarjeta de Resumen con Gráfico Circular (PieChart de Porcentaje en Rango)
              _buildCircularSummaryCard(filtered),
              const SizedBox(height: 28),

              // 4. Encabezado de la lista
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Registros Agrupados',
                    style: TextStyle(
                      color: textDark,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    '${filtered.length} mediciones',
                    style: const TextStyle(
                      color: textGray,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 5. Lista de registros agrupados por fecha
              if (filtered.isEmpty)
                _buildEmptyState()
              else
                ...grouped.entries.map((entry) => _buildDateGroup(entry.key, entry.value)),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Selector de filtros con diseño plano
  Widget _buildFilterSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBE3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildFilterTab('Día', HistoryFilter.day),
          _buildFilterTab('Semana', HistoryFilter.week),
          _buildFilterTab('Intervalo', HistoryFilter.custom, onCustomTap: _selectCustomRange),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, HistoryFilter filter, {VoidCallback? onCustomTap}) {
    final bool isSelected = _selectedFilter == filter;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (filter == HistoryFilter.custom) {
            if (onCustomTap != null) onCustomTap();
          } else {
            setState(() {
              _selectedFilter = filter;
            });
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? cardColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? textDark : textGray,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomRangeBanner() {
    final startStr = DateFormat('dd MMM yyyy').format(_customDateRange!.start);
    final endStr = DateFormat('dd MMM yyyy').format(_customDateRange!.end);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.date_range_rounded, color: pastelBlue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$startStr - $endStr',
              style: const TextStyle(
                color: textDark,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          InkWell(
            onTap: _selectCustomRange,
            child: const Text(
              'Cambiar',
              style: TextStyle(
                color: pastelBlue,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tarjetas de métricas rápidas del periodo seleccionado
  Widget _buildFilteredPeriodMetrics(List<GlucoseMeasurement> items) {
    final double avg = items.isEmpty
        ? 0.0
        : items.fold<double>(0.0, (sum, m) => sum + m.value) / items.length;

    final inRangeCount = items.where((m) => m.value >= 70 && m.value <= 140).length;
    final int inRangePct = items.isEmpty ? 0 : ((inRangeCount / items.length) * 100).round();

    return Row(
      children: [
        _buildMetricItem('PROMEDIO', avg.toStringAsFixed(0), 'mg/dL', pastelBlue),
        const SizedBox(width: 12),
        _buildMetricItem('EN RANGO', '$inRangePct%', 'Normal', pastelGreen),
        const SizedBox(width: 12),
        _buildMetricItem('TOTAL', '${items.length}', 'registros', textDark),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value, String unit, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: accent,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              unit,
              style: const TextStyle(
                color: textGray,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tarjeta de Resumen con Gráfico Circular (PieChart Donut)
  Widget _buildCircularSummaryCard(List<GlucoseMeasurement> items) {
    final int total = items.length;
    final int inRange = items.where((m) => m.value >= 70 && m.value <= 140).length;
    final int high = items.where((m) => m.value > 140).length;
    final int low = items.where((m) => m.value < 70).length;

    final int inRangePct = total == 0 ? 0 : ((inRange / total) * 100).round();
    final int highPct = total == 0 ? 0 : ((high / total) * 100).round();
    final int lowPct = total == 0 ? 0 : ((low / total) * 100).round();

    final List<PieChartSectionData> sections = [];
    if (total == 0) {
      sections.add(
        PieChartSectionData(
          color: const Color(0xFFE2E8F0),
          value: 100,
          showTitle: false,
          radius: 20,
        ),
      );
    } else {
      if (inRange > 0) {
        sections.add(
          PieChartSectionData(
            color: pastelBlue,
            value: inRange.toDouble(),
            title: '$inRangePct%',
            showTitle: false,
            radius: 22,
          ),
        );
      }
      if (high > 0) {
        sections.add(
          PieChartSectionData(
            color: pastelCoral,
            value: high.toDouble(),
            title: '$highPct%',
            showTitle: false,
            radius: 22,
          ),
        );
      }
      if (low > 0) {
        sections.add(
          PieChartSectionData(
            color: pastelAmber,
            value: low.toDouble(),
            title: '$lowPct%',
            showTitle: false,
            radius: 22,
          ),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen de Rango Glucémico',
            style: TextStyle(
              color: textDark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Distribución porcentual en el período seleccionado',
            style: TextStyle(
              color: textGray,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),

          // Gráfico Donut y Leyenda
          Row(
            children: [
              // Donut con porcentaje centrado
              SizedBox(
                width: 130,
                height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 44,
                        sections: sections,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          total > 0 ? '$inRangePct%' : '--',
                          style: const TextStyle(
                            color: textDark,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'En Rango',
                          style: TextStyle(
                            color: textGray,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Leyenda detallada
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendRow('En Rango (≤ 140)', inRange, inRangePct, pastelBlue),
                    const SizedBox(height: 10),
                    _buildLegendRow('Elevada (> 140)', high, highPct, pastelCoral),
                    const SizedBox(height: 10),
                    _buildLegendRow('Baja (< 70)', low, lowPct, pastelAmber),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(String title, int count, int pct, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: textDark,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          '$count ($pct%)',
          style: const TextStyle(
            color: textGray,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Agrupación de tarjetas por fecha
  Widget _buildDateGroup(DateTime date, List<GlucoseMeasurement> items) {
    final dateLabel = _formatGroupDate(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado del día
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateLabel,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              Text(
                '${items.length} ${items.length == 1 ? "registro" : "registros"}',
                style: const TextStyle(
                  color: textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Lista de tarjetas individuales para este día
        ...items.map((m) => _buildMeasurementCard(m)),
        const SizedBox(height: 12),
      ],
    );
  }

  /// Tarjeta de registro individual con diseño plano, etiqueta de estado y color pastel
  Widget _buildMeasurementCard(GlucoseMeasurement item) {
    final bool isHigh = item.value > 140.0;
    final bool isLow = item.value < 70.0;

    final Color statusColor = isHigh
        ? pastelCoral
        : isLow
            ? pastelAmber
            : pastelGreen;

    final String statusLabel = isHigh
        ? 'Elevada'
        : isLow
            ? 'Baja'
            : 'Normal';

    final timeStr = DateFormat('HH:mm').format(item.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // Punto indicador pastel
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),

          // Contexto, hora y notas
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.context,
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$timeStr hrs',
                        style: const TextStyle(
                          color: textGray,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (item.notes != null && item.notes!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.medication_outlined,
                        size: 13,
                        color: pastelBlue,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.notes!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: textGray,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Valor y estado
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    item.value.toStringAsFixed(0),
                    style: TextStyle(
                      color: isHigh ? pastelCoral : textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Text(
                    'mg/dL',
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: const Column(
        children: [
          Icon(Icons.event_note_outlined, size: 40, color: textMuted),
          SizedBox(height: 12),
          Text(
            'Sin registros en este período',
            style: TextStyle(
              color: textDark,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Prueba seleccionando otro rango en el filtro superior.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textGray,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatGroupDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    const weekdays = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];

    final dayStr = '${date.day} de ${months[date.month - 1]} ${date.year}';

    if (date.isAtSameMomentAs(today)) {
      return 'Hoy • $dayStr';
    } else if (date.isAtSameMomentAs(yesterday)) {
      return 'Ayer • $dayStr';
    } else {
      return '${weekdays[date.weekday - 1]} • $dayStr';
    }
  }
}
