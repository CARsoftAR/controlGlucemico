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
}
