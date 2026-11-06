import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/models/doctor.dart';
import '../../../../core/models/glucose_measurement.dart';

/// Proveedor de estado para la gestión de contactos médicos y envío de reportes vía WhatsApp
class DoctorProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper;
  List<Doctor> _doctors = [];
  bool _isLoading = false;

  DoctorProvider({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  List<Doctor> get doctors => List.unmodifiable(_doctors);
  bool get isLoading => _isLoading;

  /// Carga inicial de médicos desde SQLite
  Future<void> loadDoctors() async {
    _isLoading = true;
    notifyListeners();

    try {
      final loaded = await _dbHelper.getAllDoctors();
      if (loaded.isEmpty) {
        // Semilla inicial amigable para que el usuario cuente con un ejemplo funcional de inmediato
        final defaultDoctor = Doctor(
          id: 'doc_default_1',
          name: 'Dr. Alejandro Rossi',
          specialty: 'Diabetología y Nutrición',
          whatsapp: '+54 9 11 4567-8901',
        );
        await _dbHelper.insertDoctor(defaultDoctor);
        _doctors = [defaultDoctor];
      } else {
        _doctors = loaded;
      }
    } catch (_) {
      _doctors = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Agrega un nuevo médico y persiste en SQLite
  Future<void> addDoctor(Doctor doctor) async {
    await _dbHelper.insertDoctor(doctor);
    _doctors = [..._doctors, doctor]..sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  /// Actualiza un médico existente
  Future<void> updateDoctor(Doctor doctor) async {
    await _dbHelper.updateDoctor(doctor);
    final index = _doctors.indexWhere((d) => d.id == doctor.id);
    if (index != -1) {
      _doctors[index] = doctor;
      _doctors.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
    }
  }

  /// Elimina un médico de la lista y de SQLite
  Future<void> deleteDoctor(String id) async {
    await _dbHelper.deleteDoctor(id);
    _doctors.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  /// Abre WhatsApp con el enlace oficial https://wa.me/[NUMERO]?text=[MENSAJE]
  Future<bool> sendReportViaWhatsApp({
    required Doctor doctor,
    required List<GlucoseMeasurement> measurements,
  }) async {
    final cleanPhone = doctor.cleanWhatsAppNumber;
    if (cleanPhone.isEmpty) return false;

    // Métricas para el resumen clínico
    final total = measurements.length;
    final avg = total == 0
        ? 0.0
        : measurements.fold<double>(0.0, (s, m) => s + m.value) / total;
    final inRange = measurements.where((m) => m.value >= 70 && m.value <= 140).length;
    final inRangePct = total == 0 ? 0 : ((inRange / total) * 100).round();
    final last = measurements.isNotEmpty ? measurements.first : null;

    final String lastStr = last != null
        ? '${last.value.toStringAsFixed(0)} mg/dL (${last.timestamp.day.toString().padLeft(2, '0')}/${last.timestamp.month.toString().padLeft(2, '0')} ${last.timestamp.hour.toString().padLeft(2, '0')}:${last.timestamp.minute.toString().padLeft(2, '0')})'
        : 'Sin registros';

    final message = '''
Hola ${doctor.name}, le comparto mi reporte de control glucémico actualizado (Gluco Control):

📊 RESUMEN CLÍNICO:
• Total de registros: $total mediciones
• Promedio general: ${avg.toStringAsFixed(0)} mg/dL
• Tiempo en rango objetivo (70-140 mg/dL): $inRangePct%
• Última medición: $lastStr

📄 Se adjunta el archivo del reporte completo en formato PDF para su evaluación clínica.

¡Muchas gracias!
''';

    final encodedText = Uri.encodeComponent(message.trim());
    final urlString = 'https://wa.me/$cleanPhone?text=$encodedText';
    final uri = Uri.parse(urlString);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      return launched;
    } catch (_) {
      return false;
    }
  }
}

