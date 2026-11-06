/// Modelo para los datos personales del paciente (sin login)
class UserProfile {
  final String fullName;
  final String phone;

  const UserProfile({
    this.fullName = '',
    this.phone = '',
  });

  bool get isEmpty => fullName.trim().isEmpty && phone.trim().isEmpty;
  bool get isNotEmpty => !isEmpty;

  UserProfile copyWith({
    String? fullName,
    String? phone,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
    );
  }
}

