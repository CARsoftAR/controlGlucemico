/// Modelo de dominio para representar una medición de glucosa en sangre.
/// Preparado para integración bidireccional con Firebase Firestore.
class GlucoseMeasurement {
  final String id;
  final double value; // Valor de glucosa en mg/dL
  final DateTime timestamp;
  final String context; // Ej: "En ayunas", "Postprandial", "Antes de dormir", etc.
  final bool isHigh;

  /// Umbral clínico estándar para considerar hiperglucemia si no se especifica
  static const double defaultHighThreshold = 180.0;
  static const double defaultLowThreshold = 70.0;

  const GlucoseMeasurement({
    required this.id,
    required this.value,
    required this.timestamp,
    required this.context,
    required this.isHigh,
  });

  /// Factory constructor con cálculo automático de [isHigh] si no se provee
  factory GlucoseMeasurement.create({
    String? id,
    required double value,
    DateTime? timestamp,
    String? context,
    bool? isHigh,
  }) {
    return GlucoseMeasurement(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      value: value,
      timestamp: timestamp ?? DateTime.now(),
      context: context ?? 'General',
      isHigh: isHigh ?? (value > defaultHighThreshold),
    );
  }

  /// Serialización a Map compatible con Firestore / JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
      'timestampMillis': timestamp.millisecondsSinceEpoch,
      'context': context,
      'isHigh': isHigh,
    };
  }

  /// Deserialización desde Map (compatible con Firestore DocumentSnapshot data,
  /// DateTime, ISO-8601 String, int milliseconds o Firestore Timestamp object)
  factory GlucoseMeasurement.fromMap(Map<String, dynamic> map, [String? docId]) {
    final dynamic rawTimestamp = map['timestamp'] ?? map['timestampMillis'];
    DateTime parsedTimestamp = DateTime.now();

    if (rawTimestamp != null) {
      if (rawTimestamp is DateTime) {
        parsedTimestamp = rawTimestamp;
      } else if (rawTimestamp is int) {
        parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(rawTimestamp);
      } else if (rawTimestamp is String) {
        parsedTimestamp = DateTime.tryParse(rawTimestamp) ?? DateTime.now();
      } else {
        // Soporte para objetos Timestamp de cloud_firestore mediante duck typing
        try {
          final dynamic dynObj = rawTimestamp;
          parsedTimestamp = dynObj.toDate() as DateTime;
        } catch (_) {
          parsedTimestamp = DateTime.now();
        }
      }
    }

    final double parsedValue = (map['value'] is num)
        ? (map['value'] as num).toDouble()
        : double.tryParse(map['value']?.toString() ?? '0.0') ?? 0.0;

    final bool parsedIsHigh = (map['isHigh'] is bool)
        ? (map['isHigh'] as bool)
        : (parsedValue > defaultHighThreshold);

    return GlucoseMeasurement(
      id: docId ?? map['id']?.toString() ?? '',
      value: parsedValue,
      timestamp: parsedTimestamp,
      context: map['context']?.toString() ?? 'General',
      isHigh: parsedIsHigh,
    );
  }

  /// Clona la entidad con propiedades modificadas
  GlucoseMeasurement copyWith({
    String? id,
    double? value,
    DateTime? timestamp,
    String? context,
    bool? isHigh,
  }) {
    return GlucoseMeasurement(
      id: id ?? this.id,
      value: value ?? this.value,
      timestamp: timestamp ?? this.timestamp,
      context: context ?? this.context,
      isHigh: isHigh ?? this.isHigh,
    );
  }

  /// Clasificación de estado de glucemia para UI
  String get statusLabel {
    if (value < defaultLowThreshold) return 'Baja (Hipoglucemia)';
    if (isHigh || value > defaultHighThreshold) return 'Alta (Hiperglucemia)';
    return 'Normal';
  }

  @override
  String toString() {
    return 'GlucoseMeasurement(id: $id, value: $value mg/dL, timestamp: $timestamp, context: $context, isHigh: $isHigh)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GlucoseMeasurement &&
        other.id == id &&
        other.value == value &&
        other.timestamp == timestamp &&
        other.context == context &&
        other.isHigh == isHigh;
  }

  @override
  int get hashCode {
    return Object.hash(id, value, timestamp, context, isHigh);
  }
}
