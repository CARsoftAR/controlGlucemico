import '../models/glucose_measurement.dart';

/// Base de datos estática oficial con las mediciones reales completas del usuario
class HistoricalData {
  HistoricalData._();

  static const List<Map<String, dynamic>> medicionesDePrueba = [
    {"fecha": "2026-09-02", "hora": "21:00", "valor": 212, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u + Apidra 6u", "estado": "alto"},
    {"fecha": "2026-09-03", "hora": "14:30", "valor": 145, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "", "estado": "precaucion"},
    {"fecha": "2026-09-03", "hora": "22:45", "valor": 242, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "6u Apidra", "estado": "alto"},
    {"fecha": "2026-09-04", "hora": "22:00", "valor": 222, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u + Apidra 6u", "estado": "alto"},
    {"fecha": "2026-09-05", "hora": "09:20", "valor": 204, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u + Apidra", "estado": "alto"},
    {"fecha": "2026-09-05", "hora": "14:20", "valor": 155, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "", "estado": "precaucion"},
    {"fecha": "2026-09-05", "hora": "22:30", "valor": 231, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u + 6 Apidra", "estado": "alto"},
    {"fecha": "2026-09-06", "hora": "08:20", "valor": 209, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u + 6 Apidra", "estado": "alto"},
    {"fecha": "2026-09-06", "hora": "13:45", "valor": 157, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "6u Apidra", "estado": "precaucion"},
    {"fecha": "2026-09-06", "hora": "20:43", "valor": 224, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "6u Apidra", "estado": "alto"},
    {"fecha": "2026-09-07", "hora": "13:30", "valor": 213, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "6u Apidra", "estado": "alto"},
    {"fecha": "2026-09-07", "hora": "20:30", "valor": 235, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u + 6 Apidra", "estado": "alto"},
    {"fecha": "2026-09-08", "hora": "09:00", "valor": 168, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u + Apidra 6", "estado": "precaucion"},
    {"fecha": "2026-09-08", "hora": "14:10", "valor": 138, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "", "estado": "normal"},
    {"fecha": "2026-09-08", "hora": "22:00", "valor": 190, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u", "estado": "alto"},
    {"fecha": "2026-09-09", "hora": "08:30", "valor": 155, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u", "estado": "precaucion"},
    {"fecha": "2026-09-09", "hora": "21:30", "valor": 265, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u + 6 Apidra", "estado": "alto"},
    {"fecha": "2026-09-10", "hora": "08:30", "valor": 231, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u + 6 Apidra", "estado": "alto"},
    {"fecha": "2026-09-10", "hora": "13:30", "valor": 176, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "6u Apidra", "estado": "precaucion"},
    {"fecha": "2026-09-10", "hora": "22:30", "valor": 209, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u + 6 Apidra", "estado": "alto"},
    {"fecha": "2026-09-11", "hora": "09:15", "valor": 195, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u + 6 Apidra", "estado": "alto"},
    {"fecha": "2026-09-11", "hora": "13:00", "valor": 155, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "", "estado": "precaucion"},
    {"fecha": "2026-09-11", "hora": "22:00", "valor": 203, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u + Apidra 6u", "estado": "alto"},
    {"fecha": "2026-09-12", "hora": "08:00", "valor": 195, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "", "estado": "alto"},
    {"fecha": "2026-09-12", "hora": "15:00", "valor": 204, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "6u Apidra", "estado": "alto"},
    {"fecha": "2026-09-12", "hora": "22:15", "valor": 188, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "", "estado": "alto"},
    {"fecha": "2026-09-13", "hora": "09:30", "valor": 145, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "", "estado": "precaucion"},
    {"fecha": "2026-09-13", "hora": "14:05", "valor": 201, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "6 Apidra", "estado": "alto"},
    {"fecha": "2026-09-14", "hora": "11:00", "valor": 198, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u", "estado": "alto"},
    {"fecha": "2026-09-14", "hora": "23:00", "valor": 135, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "", "estado": "normal"},
    {"fecha": "2026-09-15", "hora": "09:05", "valor": 234, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u", "estado": "alto"},
    {"fecha": "2026-09-15", "hora": "22:45", "valor": 195, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "", "estado": "alto"},
    {"fecha": "2026-09-22", "hora": "10:35", "valor": 215, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "no me puse insulina", "estado": "alto"},
    {"fecha": "2026-09-23", "hora": "10:43", "valor": 146, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u + Apidra 6", "estado": "precaucion"},
    {"fecha": "2026-09-23", "hora": "13:35", "valor": 172, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "", "estado": "precaucion"},
    {"fecha": "2026-09-23", "hora": "16:35", "valor": 151, "unidad": "mg/dl", "etiqueta": "A/M", "notas": "", "estado": "precaucion"},
    {"fecha": "2026-09-26", "hora": "08:40", "valor": 190, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u", "estado": "alto"},
    {"fecha": "2026-09-28", "hora": "21:30", "valor": 173, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u", "estado": "precaucion"},
    {"fecha": "2026-09-29", "hora": "08:20", "valor": 193, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u", "estado": "alto"},
    {"fecha": "2026-09-29", "hora": "13:00", "valor": 148, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "", "estado": "precaucion"},
    {"fecha": "2026-09-29", "hora": "22:00", "valor": 158, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u", "estado": "precaucion"},
    {"fecha": "2026-09-30", "hora": "09:02", "valor": 180, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "", "estado": "alto"},
    {"fecha": "2026-09-30", "hora": "17:05", "valor": 165, "unidad": "mg/dl", "etiqueta": "A/M", "notas": "", "estado": "precaucion"},
    {"fecha": "2026-09-30", "hora": "22:55", "valor": 146, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u", "estado": "precaucion"},
    {"fecha": "2026-10-01", "hora": "10:00", "valor": 148, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "", "estado": "precaucion"},
    {"fecha": "2026-10-01", "hora": "15:00", "valor": 212, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "", "estado": "alto"},
    {"fecha": "2026-10-02", "hora": "08:45", "valor": 168, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "", "estado": "precaucion"},
    {"fecha": "2026-10-02", "hora": "22:42", "valor": 185, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u", "estado": "alto"},
    {"fecha": "2026-10-03", "hora": "00:14", "valor": 251, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u + 8u Apidra", "estado": "alto"},
    {"fecha": "2026-10-03", "hora": "07:15", "valor": 172, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u", "estado": "precaucion"},
    {"fecha": "2026-10-04", "hora": "08:00", "valor": 208, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u + 6u Apidra", "estado": "alto"},
    {"fecha": "2026-10-04", "hora": "15:21", "valor": 154, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "", "estado": "precaucion"},
    {"fecha": "2026-10-04", "hora": "22:10", "valor": 164, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u", "estado": "precaucion"},
    {"fecha": "2026-10-05", "hora": "07:15", "valor": 196, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u", "estado": "alto"},
    {"fecha": "2026-10-07", "hora": "09:25", "valor": 183, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "", "estado": "alto"},
    {"fecha": "2026-10-07", "hora": "15:36", "valor": 172, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "", "estado": "precaucion"},
    {"fecha": "2026-10-08", "hora": "14:36", "valor": 243, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "4u Apidra", "estado": "alto"},
    {"fecha": "2026-10-08", "hora": "22:05", "valor": 308, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u + 10u Apidra", "estado": "alto"},
    {"fecha": "2026-10-09", "hora": "08:45", "valor": 251, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "", "estado": "alto"},
    {"fecha": "2026-10-09", "hora": "21:30", "valor": 166, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u", "estado": "precaucion"},
    {"fecha": "2026-10-09", "hora": "23:00", "valor": 172, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "", "estado": "precaucion"},
    {"fecha": "2026-10-10", "hora": "06:51", "valor": 189, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u", "estado": "alto"},
    {"fecha": "2026-10-10", "hora": "15:35", "valor": 146, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "", "estado": "precaucion"},
    {"fecha": "2026-10-11", "hora": "09:35", "valor": 195, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u", "estado": "alto"},
    {"fecha": "2026-10-11", "hora": "21:45", "valor": 187, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u", "estado": "alto"},
    {"fecha": "2026-10-12", "hora": "09:00", "valor": 210, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u", "estado": "alto"},
    {"fecha": "2026-10-12", "hora": "12:30", "valor": 220, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "", "estado": "alto"},
    {"fecha": "2026-10-12", "hora": "22:10", "valor": 167, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u", "estado": "precaucion"},
    {"fecha": "2026-10-13", "hora": "08:00", "valor": 176, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u", "estado": "precaucion"},
    {"fecha": "2026-10-13", "hora": "15:25", "valor": 147, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "", "estado": "precaucion"},
    {"fecha": "2026-10-13", "hora": "21:45", "valor": 228, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u + 6u Apidra", "estado": "alto"},
    {"fecha": "2026-10-14", "hora": "09:10", "valor": 156, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u", "estado": "precaucion"},
    {"fecha": "2026-10-14", "hora": "17:00", "valor": 142, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "", "estado": "precaucion"},
    {"fecha": "2026-10-15", "hora": "21:30", "valor": 150, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u", "estado": "precaucion"},
    {"fecha": "2026-10-16", "hora": "08:15", "valor": 177, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u", "estado": "precaucion"},
    {"fecha": "2026-10-16", "hora": "23:00", "valor": 190, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u", "estado": "alto"},
    {"fecha": "2026-10-17", "hora": "09:15", "valor": 176, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u", "estado": "precaucion"},
    {"fecha": "2026-10-17", "hora": "15:30", "valor": 117, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "", "estado": "normal"},
    {"fecha": "2026-10-17", "hora": "19:00", "valor": 234, "unidad": "mg/dl", "etiqueta": "A/M", "notas": "", "estado": "alto"},
    {"fecha": "2026-10-18", "hora": "10:05", "valor": 236, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "", "estado": "alto"},
    {"fecha": "2026-10-18", "hora": "23:20", "valor": 270, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u", "estado": "alto"},
    {"fecha": "2026-10-19", "hora": "09:05", "valor": 189, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u", "estado": "alto"},
    {"fecha": "2026-10-19", "hora": "12:46", "valor": 218, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "8u Apidra", "estado": "alto"},
    {"fecha": "2026-10-19", "hora": "21:30", "valor": 230, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u", "estado": "alto"},
    {"fecha": "2026-10-20", "hora": "06:10", "valor": 196, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "Analisis", "estado": "alto"},
    {"fecha": "2026-10-20", "hora": "10:00", "valor": 223, "unidad": "mg/dl", "etiqueta": "", "notas": "", "estado": "alto"},
    {"fecha": "2026-10-20", "hora": "22:45", "valor": 203, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u + 6 Apidra", "estado": "alto"},
    {"fecha": "2026-10-21", "hora": "09:03", "valor": 217, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14 + 8 Apidra", "estado": "alto"},
    {"fecha": "2026-10-21", "hora": "14:00", "valor": 169, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "", "estado": "precaucion"},
    {"fecha": "2026-10-21", "hora": "18:25", "valor": 272, "unidad": "mg/dl", "etiqueta": "A/M", "notas": "8u Apidra", "estado": "alto"},
    {"fecha": "2026-10-21", "hora": "21:05", "valor": 183, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u", "estado": "alto"},
    {"fecha": "2026-10-22", "hora": "09:20", "valor": 225, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u + 6 Apidra", "estado": "alto"},
    {"fecha": "2026-10-22", "hora": "23:00", "valor": 258, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u + 6 Apidra", "estado": "alto"},
    {"fecha": "2026-10-23", "hora": "09:03", "valor": 174, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u", "estado": "precaucion"},
    {"fecha": "2026-10-23", "hora": "22:30", "valor": 162, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u", "estado": "precaucion"},
    {"fecha": "2026-10-24", "hora": "07:55", "valor": 183, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u", "estado": "alto"},
    {"fecha": "2026-10-24", "hora": "12:41", "valor": 192, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "6u Apidra", "estado": "alto"},
    {"fecha": "2026-10-24", "hora": "21:00", "valor": 187, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u", "estado": "alto"},
    {"fecha": "2026-10-25", "hora": "10:00", "valor": 137, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u + 6 Apidra", "estado": "normal"},
    {"fecha": "2026-10-25", "hora": "13:45", "valor": 135, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "", "estado": "normal"},
    {"fecha": "2026-10-25", "hora": "21:50", "valor": 261, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u + 8 Apidra", "estado": "alto"},
    {"fecha": "2026-10-26", "hora": "08:45", "valor": 184, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14", "estado": "alto"},
    {"fecha": "2026-10-26", "hora": "13:15", "valor": 218, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "", "estado": "alto"},
    {"fecha": "2026-10-26", "hora": "21:30", "valor": 197, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "14u NHP + 6 Apidra", "estado": "alto"},
    {"fecha": "2026-10-27", "hora": "08:55", "valor": 183, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14 + 4 Apidra", "estado": "alto"},
    {"fecha": "2026-10-27", "hora": "14:02", "valor": 145, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "", "estado": "precaucion"},
    {"fecha": "2026-10-27", "hora": "23:10", "valor": 190, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u + 4 Apidra", "estado": "alto"},
    {"fecha": "2026-10-28", "hora": "06:30", "valor": 195, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14 + 4 Apidra", "estado": "alto"},
    {"fecha": "2026-10-28", "hora": "13:24", "valor": 189, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "", "estado": "alto"},
    {"fecha": "2026-10-28", "hora": "21:30", "valor": 161, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u + 4 Apidra", "estado": "precaucion"},
    {"fecha": "2026-10-29", "hora": "09:15", "valor": 145, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u", "estado": "precaucion"},
    {"fecha": "2026-10-29", "hora": "22:00", "valor": 187, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u", "estado": "alto"},
    {"fecha": "2026-10-30", "hora": "13:30", "valor": 273, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "NHP 14u + 8 Apidra", "estado": "alto"},
    {"fecha": "2026-10-30", "hora": "22:04", "valor": 246, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u + 8 Apidra", "estado": "alto"},
    {"fecha": "2026-10-31", "hora": "09:05", "valor": 166, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u + 4 Apidra", "estado": "precaucion"},
    {"fecha": "2026-10-31", "hora": "16:15", "valor": 231, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "", "estado": "alto"},
    {"fecha": "2026-11-01", "hora": "11:09", "valor": 166, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u", "estado": "precaucion"},
    {"fecha": "2026-11-01", "hora": "16:45", "valor": 162, "unidad": "mg/dl", "etiqueta": "A/M", "notas": "", "estado": "precaucion"},
    {"fecha": "2026-11-01", "hora": "23:19", "valor": 138, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u", "estado": "normal"},
    {"fecha": "2026-11-02", "hora": "06:28", "valor": 247, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u + 6 Apidra", "estado": "alto"},
    {"fecha": "2026-11-02", "hora": "15:11", "valor": 206, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "6 Apidra", "estado": "alto"},
    {"fecha": "2026-11-02", "hora": "20:50", "valor": 234, "unidad": "mg/dl", "etiqueta": "A/C", "notas": "NHP 14u + 8u Apidra", "estado": "alto"},
    {"fecha": "2026-11-03", "hora": "08:30", "valor": 232, "unidad": "mg/dl", "etiqueta": "A/D", "notas": "NHP 14u", "estado": "alto"},
    {"fecha": "2026-11-03", "hora": "14:50", "valor": 226, "unidad": "mg/dl", "etiqueta": "A/A", "notas": "+ 6 Apidra", "estado": "alto"},
    {"fecha": "2026-11-03", "hora": "17:54", "valor": 208, "unidad": "mg/dl", "etiqueta": "A/M", "notas": "6 u Apidra", "estado": "alto"}
  ];

  /// Parsea y devuelve la lista completa de mediciones ordenadas cronológicamente (más recientes primero)
  static List<GlucoseMeasurement> getMeasurements() {
    final List<GlucoseMeasurement> list = [];
    for (int i = 0; i < medicionesDePrueba.length; i++) {
      final item = medicionesDePrueba[i];
      final fecha = item['fecha'] as String;
      final hora = item['hora'] as String;
      final val = (item['valor'] as num).toDouble();
      final etiqueta = item['etiqueta'] as String;
      final rawNotes = item['notas'] as String?;
      final notes = (rawNotes != null && rawNotes.trim().isNotEmpty) ? rawNotes.trim() : null;

      final dateParts = fecha.split('-');
      final timeParts = hora.split(':');
      final dt = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      list.add(
        GlucoseMeasurement(
          id: 'hist_${fecha}_${hora.replaceAll(":", "")}_$i',
          value: val,
          timestamp: dt,
          context: mapEtiquetaToContext(etiqueta),
          isHigh: val > 140.0,
          notes: notes,
        ),
      );
    }
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  static String mapEtiquetaToContext(String etiqueta) {
    switch (etiqueta) {
      case 'A/D':
        return 'En ayunas (A/D)';
      case 'A/A':
        return 'Antes de comer (A/A)';
      case 'A/C':
        return 'Antes de cenar (A/C)';
      case 'A/M':
        return 'Merienda (A/M)';
      default:
        return etiqueta.isEmpty ? 'Control' : etiqueta;
    }
  }
}
