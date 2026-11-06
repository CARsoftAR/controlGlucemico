import 'package:flutter/foundation.dart';
import '../../../../core/data/historical_data.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/models/glucose_measurement.dart';
import '../../../../core/notifications/notification_service.dart';

/// Gestor de estado reactivo para mediciones de glucosa y persistencia
class GlucoseProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper;
  final NotificationService _notificationService;

  // Inyección estricta de la base de datos real oficial (sin mocks dinámicos de DateTime.now)
  List<GlucoseMeasurement> _measurements = HistoricalData.getMeasurements();
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

  /// Porcentaje en rango objetivo (70 - 140 mg/dL según umbral clínico)
  int get inRangePercentage {
    if (_measurements.isEmpty) return 100;
    final inRangeCount =
        _measurements.where((m) => m.value >= 70 && m.value <= 140).length;
    return ((inRangeCount / _measurements.length) * 100).round();
  }

  /// 1. Carga inicial de todas las mediciones desde la base de datos SQLite
  Future<void> loadMeasurements() async {
    _isLoading = true;
    notifyListeners();

    try {
      final loadedData = await _dbHelper.getAllMeasurements();
      final realSeed = HistoricalData.getMeasurements();

      // Si la base de datos ya tiene al menos todos los registros reales oficiales, los usamos.
      // Si está vacía, contiene mocks antiguos o le faltan registros nuevos, sincronizamos la base completa.
      final bool hasOnlyOldSeeds = loadedData.isNotEmpty &&
          loadedData.every((m) => m.id.startsWith('seed_'));

      if (loadedData.isNotEmpty && !hasOnlyOldSeeds && loadedData.length >= realSeed.length) {
        _measurements = loadedData;
      } else {
        await _dbHelper.clearAllMeasurements();
        for (final m in realSeed) {
          await _dbHelper.insertMeasurement(m);
        }
        _measurements = realSeed;
      }
    } catch (_) {
      // Fallback seguro asegurando siempre los datos históricos reales en memoria
      if (_measurements.isEmpty) {
        _measurements = HistoricalData.getMeasurements();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 2. Guarda una nueva medición en la base de datos y actualiza reactivamente la UI
  Future<void> addMeasurement(GlucoseMeasurement measurement) async {
    _measurements.insert(0, measurement);
    notifyListeners();

    if (measurement.value > 180.0) {
      _notificationService.showHighGlucoseAlert(measurement.value);
    }

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

  /// Carga masiva forzada de los registros históricos reales del paciente en SQLite y actualiza reactivamente la UI
  Future<void> loadHistoricalData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _dbHelper.clearAllMeasurements();
      final realSeed = HistoricalData.getMeasurements();
      for (final m in realSeed) {
        await _dbHelper.insertMeasurement(m);
      }
      _measurements = realSeed;
    } catch (_) {
      _measurements = HistoricalData.getMeasurements();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
