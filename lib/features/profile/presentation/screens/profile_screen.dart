import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

/// Pantalla "Mi Perfil" / "Datos Personales" para identificar al paciente en reportes y mensajes
/// Estética Flat Design, fondo crema/blanco hueso y colores pasteles
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const Color bgColor = Color(0xFFF7F4EE); // Blanco hueso / crema suave
  static const Color cardColor = Colors.white;
  static const Color borderColor = Color(0xFFE8E2D8);
  static const Color textDark = Color(0xFF2D3748);
  static const Color textGray = Color(0xFF718096);
  static const Color textMuted = Color(0xFFA0AEC0);
  static const Color pastelBlue = Color(0xFF7EBCE6);
  static const Color pastelGreen = Color(0xFFA8D5BA);
  static const Color pastelCoral = Color(0xFFFFB5A7);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final profileProvider = context.read<ProfileProvider>();
    _nameController = TextEditingController(text: profileProvider.fullName);
    _phoneController = TextEditingController(text: profileProvider.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final profileProvider = context.read<ProfileProvider>();
    await profileProvider.saveProfile(
      fullName: _nameController.text,
      phone: _phoneController.text,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                'Datos de perfil guardados correctamente',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
          backgroundColor: Color(0xFF2C7A7B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileScreen.bgColor,
      appBar: AppBar(
        backgroundColor: ProfileScreen.bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: ProfileScreen.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            color: ProfileScreen.textDark,
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner informativo superior
                _buildInfoBanner(),
                const SizedBox(height: 20),

                // Tarjeta del formulario
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ProfileScreen.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: ProfileScreen.borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Campo: Nombre Completo
                      _buildFieldHeader('NOMBRE COMPLETO *', 'Tu nombre se incluirá en el reporte PDF y en los mensajes a tus médicos.'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(
                          color: ProfileScreen.textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: _buildInputDecoration(
                          hint: 'Ej: Juan Pérez',
                          icon: Icons.person_outline_rounded,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Por favor ingresa tu nombre completo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 22),

                      // Campo: Teléfono
                      _buildFieldHeader('TELÉFONO DE CONTACTO', 'Número personal de referencia.'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(
                          color: ProfileScreen.textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: _buildInputDecoration(
                          hint: 'Ej: +54 9 11 2345-6789',
                          icon: Icons.phone_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Botón Guardar en tono celeste pastel
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _saveProfile,
                    icon: const Icon(Icons.save_rounded, color: Colors.white, size: 20),
                    label: const Text(
                      'Guardar Datos Personales',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ProfileScreen.pastelBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ProfileScreen.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ProfileScreen.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ProfileScreen.pastelGreen.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.badge_outlined, color: Color(0xFF2C7A7B), size: 26),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Datos para tus Reportes Médicos',
                  style: TextStyle(
                    color: ProfileScreen.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'No necesitas cuenta ni contraseña. Tus datos se guardan solo en tu dispositivo para firmar tus reportes y mensajes de WhatsApp.',
                  style: TextStyle(
                    color: ProfileScreen.textGray,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: ProfileScreen.textGray,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            color: ProfileScreen.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: ProfileScreen.textMuted, fontSize: 13),
      prefixIcon: Icon(icon, color: ProfileScreen.pastelBlue, size: 20),
      filled: true,
      fillColor: const Color(0xFFFAF8F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ProfileScreen.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ProfileScreen.pastelBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE53E3E)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE53E3E), width: 1.5),
      ),
    );
  }
}

