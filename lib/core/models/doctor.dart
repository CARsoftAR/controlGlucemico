/// Modelo de datos para contactos médicos asociados al paciente
class Doctor {
  final String id;
  final String name;
  final String? specialty;
  final String whatsapp;

  const Doctor({
    required this.id,
    required this.name,
    this.specialty,
    required this.whatsapp,
  });

  /// Limpia y normaliza el número de WhatsApp a solo dígitos numéricos para la URL wa.me
  String get cleanWhatsAppNumber {
    return whatsapp.replaceAll(RegExp(r'[^0-9]'), '');
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'whatsapp': whatsapp,
    };
  }

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id'] as String,
      name: map['name'] as String,
      specialty: map['specialty'] as String?,
      whatsapp: map['whatsapp'] as String,
    );
  }

  Doctor copyWith({
    String? id,
    String? name,
    String? specialty,
    String? whatsapp,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      whatsapp: whatsapp ?? this.whatsapp,
    );
  }
}

