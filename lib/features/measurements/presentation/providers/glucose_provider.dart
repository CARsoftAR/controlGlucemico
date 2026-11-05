import 'package:flutter/foundation.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/models/glucose_measurement.dart';
import '../../../../core/notifications/notification_service.dart';

/// Gestor de estado reactivo para mediciones de glucosa y persistencia
class GlucoseProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper;
  final NotificationService _notificationService;

  List<GlucoseMeasurement> _measurements = [];
  bool _isLoading = false;

  GlucoseProvider({
    DatabaseHelper? dbHelper,
    NotificationService? notificationService,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _notificationService =
            notificationService ?? NotificationService.instance;

  // Getters reactivos
  List<GlucoseMeasurement> get measurements => List.unmodifiable(_measurements);
  bool get isLoading => _isLoading;

  /// Última medición registrada
  GlucoseMeasurement? get lastMeasurement =>
      _measurements.isNotEmpty ? _measurements.first : null;

  /// Promedio general de glucosa
  double get averageGlucose {
    if (_measurements.isEmpty) return 0.0;
    final total = _measurements.fold<double>(0.0, (sum, m) => sum + m.value);
    return total / _measurements.length;
  }

  /// Porcentaje en rango objetivo (70 - 180 mg/dL)
  int get inRangePercentage {
    if (_measurements.isEmpty) return 100;
    final inRangeCount =
        _measurements.where((m) => m.value >= 70 && m.value <= 180).length;
    return ((inRangeCount / _measurements.length) * 100).round();
  }

  /// 1. Carga inicial de todas las mediciones desde la base de datos SQLite
  Future<void> loadMeasurements() async {
    _isLoading = true;
    notifyListeners();

    try {
      final loadedData = await _dbHelper.getAllMeasurements();

      if (loadedData.isNotEmpty) {
        _measurements = loadedData;
      } else {
        // Datos iniciales de demostración si la base de datos está vacía en primer inicio
        final initialSeed = [
          GlucoseMeasurement(
            id: 'seed_1',
            value: 104.0,
            timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
            context: 'Post-desayuno',
            isHigh: false,
          ),
          GlucoseMeasurement(
            id: 'seed_2',
            value: 165.0,
            timestamp: DateTime.now().subtract(const Duration(hours: 4)),
            context: 'Post-almuerzo',
            isHigh: true,
          ),
          GlucoseMeasurement(
            id: 'seed_3',
            value: 92.0,
            timestamp: DateTime.now().subtract(const Duration(hours: 8)),
            context: 'En ayunas',
            isHigh: false,
          ),
        ];

        for (final m in initialSeed) {
          await _dbHelper.insertMeasurement(m);
        }
        _measurements = initialSeed;
      }
    } catch (_) {
      // Manejo de contingencia sin romper el flujo UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 2. Guarda una nueva medición en la base de datos y actualiza reactivamente la UI
  Future<void> addMeasurement(GlucoseMeasurement measurement) async {
    // Actualización inmediata en memoria para respuesta instantánea en la UI
    _measurements.insert(0, measurement);
    notifyListeners();

    // SPRINT 5: Si el valor es peligroso (> 180 mg/dL), dispara showHighGlucoseAlert()
    if (measurement.value > 180.0) {
      _notificationService.showHighGlucoseAlert(measurement.value);
    }

    // Persistencia asíncrona en la base de datos SQLite
    try {
      await _dbHelper.insertMeasurement(measurement);
    } catch (_) {}
  }

  /// Elimina una medición y actualiza la lista
  Future<void> deleteMeasurement(String id) async {
    _measurements.removeWhere((m) => m.id == id);
    notifyListeners();

    try {
      await _dbHelper.deleteMeasurement(id);
    } catch (_) {}
  }

  /// Borra todos los registros físicos de la base de datos local y limpia la lista reactiva en memoria
  Future<void> clearAllData() async {
    _measurements.clear();
    notifyListeners();

    try {
      await _dbHelper.clearAllMeasurements();
    } catch (_) {}
  }

  /// Carga masiva de los registros históricos del paciente en SQLite y actualiza reactivamente la UI
  Future<void> loadHistoricalData() async {
    _isLoading = true;
    notifyListeners();

    final historicalRaw = <Map<String, dynamic>>[
      {'dt': DateTime(2026, 9, 11, 13, 0), 'val': 155.0, 'ctx': 'Antes de comer', 'notes': null},
      {'dt': DateTime(2026, 9, 11, 21, 0), 'val': 203.0, 'ctx': 'Antes de dormir', 'notes': 'NHP 14u + Apidra 6u'},
      {'dt': DateTime(2026, 9, 12, 8, 0), 'val': 195.0, 'ctx': 'En ayunas', 'notes': null},
      {'dt': DateTime(2026, 9, 12, 15, 0), 'val': 204.0, 'ctx': 'Antes de comer', 'notes': '6u Apidra'},
      {'dt': DateTime(2026, 9, 12, 22, 15), 'val': 188.0, 'ctx': 'Antes de dormir', 'notes': null},
      {'dt': DateTime(2026, 9, 13, 9, 30), 'val': 145.0, 'ctx': 'En ayunas', 'notes': null},
      {'dt': DateTime(2026, 9, 13, 14, 5), 'val': 201.0, 'ctx': 'Antes de comer', 'notes': '8u Apidra'},
      {'dt': DateTime(2026, 9, 14, 11, 0), 'val': 198.0, 'ctx': 'En ayunas', 'notes': 'NHP 14u'},
      {'dt': DateTime(2026, 9, 14, 23, 20), 'val': 135.0, 'ctx': 'Antes de dormir', 'notes': null},
      {'dt': DateTime(2026, 9, 22, 10, 35), 'val': 215.0, 'ctx': 'En ayunas', 'notes': 'No me puse insulina'},
      {'dt': DateTime(2026, 9, 23, 10, 43), 'val': 146.0, 'ctx': 'En ayunas', 'notes': 'NHP 14u + Apidra 6'},
      {'dt': DateTime(2026, 9, 26, 8, 40), 'val': 190.0, 'ctx': 'En ayunas', 'notes': 'NHP 14u'},
      {'dt': DateTime(2026, 9, 28, 21, 30), 'val': 173.0, 'ctx': 'Antes de dormir', 'notes': 'NHP 14u'},
      {'dt': DateTime(2026, 9, 29, 8, 20), 'val': 193.0, 'ctx': 'En ayunas', 'notes': 'NHP 14u'},
      {'dt': DateTime(2026, 10, 19, 12, 46), 'val': 218.0, 'ctx': 'Antes de comer', 'notes': '8u Apidra'},
      {'dt': DateTime(2026, 10, 20, 6, 10), 'val': 196.0, 'ctx': 'En ayunas', 'notes': 'Analisis + urocultivo'},
      {'dt': DateTime(2026, 10, 20, 22, 45), 'val': 203.0, 'ctx': 'Antes de dormir', 'notes': 'NHP 14u + 6 Apidra'},
      {'dt': DateTime(2026, 10, 26, 21, 30), 'val': 197.0, 'ctx': 'Antes de dormir', 'notes': '14u NHP + 6 Apidra'},
      {'dt': DateTime(2026, 10, 27, 8, 55), 'val': 183.0, 'ctx': 'En ayunas', 'notes': 'NHP 14 + 4 Apidra'},
      {'dt': DateTime(2026, 10, 30, 13, 30), 'val': 273.0, 'ctx': 'Antes de comer', 'notes': 'NHP 14u + 8 Apidra'},
      {'dt': DateTime(2026, 11, 2, 6, 28), 'val': 247.0, 'ctx': 'En ayunas', 'notes': 'NHP 14u + 6 Apidra'},
      {'dt': DateTime(2026, 11, 3, 20, 50), 'val': 234.0, 'ctx': 'Antes de dormir', 'notes': 'NHP 14u + 8 Apidra'},
    ];

    try {
      final List<GlucoseMeasurement> seededItems = [];
      for (int i = 0; i < historicalRaw.length; i++) {
        final item = historicalRaw[i];
        final dt = item['dt'] as DateTime;
        final val = (item['val'] as num).toDouble();
        final ctx = item['ctx'] as String;
        final notes = item['notes'] as String?;

        final measurement = GlucoseMeasurement(
          id: 'hist_${dt.millisecondsSinceEpoch}_$i',
          value: val,
          timestamp: dt,
          context: ctx,
          isHigh: val > 140.0, // Cálculo automático: isHigh si value > 140
          notes: notes,
        );

        seededItems.add(measurement);
        await _dbHelper.insertMeasurement(measurement);
      }

      final allData = await _dbHelper.getAllMeasurements();
      _measurements = allData.isNotEmpty ? allData : seededItems;
      _measurements.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
