import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/models/user_profile.dart';

/// Proveedor de estado para persistir los datos personales del paciente mediante SharedPreferences
class ProfileProvider extends ChangeNotifier {
  static const String _keyFullName = 'patient_full_name';
  static const String _keyPhone = 'patient_phone';

  UserProfile _profile = const UserProfile();
  bool _isLoading = true;

  UserProfile get profile => _profile;
  String get fullName => _profile.fullName;
  String get phone => _profile.phone;
  bool get isLoading => _isLoading;
  bool get hasName => _profile.fullName.trim().isNotEmpty;

  /// Carga inicial de datos desde SharedPreferences
  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_keyFullName) ?? '';
      final phone = prefs.getString(_keyPhone) ?? '';
      _profile = UserProfile(fullName: name, phone: phone);
    } catch (_) {
      _profile = const UserProfile();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Guarda y persiste los datos del paciente localmente
  Future<void> saveProfile({
    required String fullName,
    required String phone,
  }) async {
    _profile = UserProfile(
      fullName: fullName.trim(),
      phone: phone.trim(),
    );
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyFullName, _profile.fullName);
      await prefs.setString(_keyPhone, _profile.phone);
    } catch (_) {}
  }
}

