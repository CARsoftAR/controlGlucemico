import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/doctor.dart';
import '../../../../core/services/pdf_export_service.dart';
import '../../../measurements/presentation/providers/glucose_provider.dart';
import '../providers/doctor_provider.dart';
import '../widgets/send_report_modal.dart';

/// Pantalla "Mis Médicos" para la gestión de contactos médicos y envío de reportes
/// Diseñada con estética Flat Design, fondo crema/blanco hueso y tonos pasteles
class DoctorsScreen extends StatelessWidget {
  const DoctorsScreen({super.key});

  static const Color bgColor = Color(0xFFF7F4EE); // Blanco hueso / crema suave
  static const Color cardColor = Colors.white;
  static const Color borderColor = Color(0xFFE8E2D8);
  static const Color textDark = Color(0xFF2D3748);
  static const Color textGray = Color(0xFF718096);
  static const Color textMuted = Color(0xFFA0AEC0);

  static const Color pastelBlue = Color(0xFF7EBCE6);
  static const Color pastelGreen = Color(0xFFA8D5BA);
  static const Color pastelCoral = Color(0xFFFFB5A7);
  static const Color pastelAmber = Color(0xFFF6D186);

  @override
  Widget build(BuildContext context) {
    final doctorProvider = context.watch<DoctorProvider>();
    final doctors = doctorProvider.doctors;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Mis Médicos',
          style: TextStyle(
            color: textDark,
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Agregar Médico',
            icon: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF2C7A7B)),
            onPressed: () => _showDoctorFormDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: doctors.isEmpty
            ? _buildEmptyState(context)
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                children: [
                  // Banner descriptivo superior
                  _buildHeaderBanner(context),
                  const SizedBox(height: 14),

                  // Botón pastilla destacado: Generar Reporte PDF
                  _buildGeneratePdfPillButton(context),
                  const SizedBox(height: 18),

                  // Conteo de especialistas registrados
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Especialistas Vinculados',
                        style: TextStyle(
                          color: textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        '${doctors.length} ${doctors.length == 1 ? "contacto" : "contactos"}',
                        style: const TextStyle(
                          color: textGray,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Lista de tarjetas de médicos
                  ...doctors.map((doctor) => _buildDoctorCard(context, doctor)),
                  const SizedBox(height: 80),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDoctorFormDialog(context),
        backgroundColor: pastelBlue,
        elevation: 2,
        icon: const Icon(Icons.add, color: Colors.white, size: 22),
        label: const Text(
          'Nuevo Médico',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: pastelGreen.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.health_and_safety_rounded, color: Color(0xFF2C7A7B), size: 26),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comparte con tu Equipo Médico',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Configura a tus especialistas para enviarles tus reportes y estadísticas con un solo toque vía WhatsApp.',
                  style: TextStyle(
                    color: textGray,
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: pastelBlue.withValues(alpha: 0.2),
                ),
                child: const Icon(Icons.person_add_alt_rounded, size: 32, color: pastelBlue),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sin médicos vinculados',
                style: TextStyle(
                  color: textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Agrega a tu diabetólogo, nutricionista o médico de cabecera para enviarle tus resúmenes glucémicos directamente.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textGray,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () => _showDoctorFormDialog(context),
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  label: const Text(
                    'Agregar Primer Médico',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pastelBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Doctor doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar con iniciales
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: pastelBlue.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _getInitials(doctor.name),
                  style: const TextStyle(
                    color: Color(0xFF2B6CB0),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Información del médico
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (doctor.specialty != null && doctor.specialty!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0EBE3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          doctor.specialty!,
                          style: const TextStyle(
                            color: textDark,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: Color(0xFF25D366)),
                        const SizedBox(width: 5),
                        Text(
                          doctor.whatsapp,
                          style: const TextStyle(
                            color: textGray,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Menú de opciones rápidas (editar / eliminar)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: textMuted, size: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showDoctorFormDialog(context, doctor: doctor);
                  } else if (value == 'delete') {
                    _showDeleteConfirmationDialog(context, doctor);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18, color: textDark),
                        SizedBox(width: 8),
                        Text('Editar datos', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFE53E3E)),
                        SizedBox(width: 8),
                        Text('Eliminar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFE53E3E))),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: borderColor, height: 1),
          const SizedBox(height: 10),

          // Botón de acción para generar y compartir reporte PDF
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: () {
                final glucoseProvider = context.read<GlucoseProvider>();
                PdfExportService.generateAndShareFromList(
                  context: context,
                  measurements: glucoseProvider.measurements,
                  doctor: doctor,
                );
              },
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 17, color: Colors.white),
              label: Text(
                'Generar y Enviar PDF a ${doctor.name.split(' ').first}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: pastelBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratePdfPillButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: pastelCoral, // Color coral suave acordado de la paleta
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: pastelCoral.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            final glucoseProvider = context.read<GlucoseProvider>();
            SendReportModal.show(
              context,
              measurements: glucoseProvider.measurements,
            );
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Generar Reporte PDF',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDoctorFormDialog(BuildContext context, {Doctor? doctor}) {
    final isEditing = doctor != null;
    final nameController = TextEditingController(text: doctor?.name ?? '');
    final specialtyController = TextEditingController(text: doctor?.specialty ?? '');
    final whatsappController = TextEditingController(text: doctor?.whatsapp ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            top: 16,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  isEditing ? 'Editar Contacto Médico' : 'Nuevo Contacto Médico',
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ingresa los datos para sincronizar y enviar reportes automáticos.',
                  style: TextStyle(color: textGray, fontSize: 12),
                ),
                const SizedBox(height: 18),

                // Campo: Nombre
                _buildFormField(
                  controller: nameController,
                  label: 'NOMBRE DEL MÉDICO *',
                  hint: 'Ej: Dr. Alejandro Rossi',
                  icon: Icons.person_outline_rounded,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Por favor ingresa el nombre del médico';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Campo: Especialidad (Opcional)
                _buildFormField(
                  controller: specialtyController,
                  label: 'ESPECIALIDAD (OPCIONAL)',
                  hint: 'Ej: Diabetología, Nutrición, Endocrinología',
                  icon: Icons.medical_services_outlined,
                ),
                const SizedBox(height: 14),

                // Campo: WhatsApp
                _buildFormField(
                  controller: whatsappController,
                  label: 'NÚMERO DE WHATSAPP *',
                  hint: 'Ej: +54 9 11 4567-8901 (con código de país)',
                  icon: Icons.chat_bubble_outline_rounded,
                  keyboardType: TextInputType.phone,
                  helperText: 'Importante: incluye el prefijo internacional (ej. +54, +34, +52)',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Por favor ingresa el número de WhatsApp';
                    }
                    final digitsOnly = val.replaceAll(RegExp(r'[^0-9]'), '');
                    if (digitsOnly.length < 8) {
                      return 'Ingresa un número válido con código de país';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22),

                // Botón Guardar
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;

                      final provider = context.read<DoctorProvider>();
                      final id = isEditing ? doctor.id : 'doc_${DateTime.now().millisecondsSinceEpoch}';

                      final updatedDoctor = Doctor(
                        id: id,
                        name: nameController.text.trim(),
                        specialty: specialtyController.text.trim().isEmpty
                            ? null
                            : specialtyController.text.trim(),
                        whatsapp: whatsappController.text.trim(),
                      );

                      if (isEditing) {
                        await provider.updateDoctor(updatedDoctor);
                      } else {
                        await provider.addDoctor(updatedDoctor);
                      }

                      if (bottomSheetContext.mounted) {
                        Navigator.of(bottomSheetContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEditing
                                  ? 'Médico actualizado exitosamente'
                                  : 'Médico registrado con éxito',
                            ),
                            backgroundColor: const Color(0xFF2C7A7B),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pastelBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      isEditing ? 'Guardar Cambios' : 'Registrar Médico',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? helperText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textGray,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
            color: textDark,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: textMuted, fontSize: 13),
            prefixIcon: Icon(icon, color: pastelBlue, size: 20),
            filled: true,
            fillColor: cardColor,
            helperText: helperText,
            helperStyle: const TextStyle(color: textGray, fontSize: 11),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: pastelBlue, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE53E3E)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE53E3E), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Doctor doctor) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '¿Eliminar médico?',
          style: TextStyle(color: textDark, fontWeight: FontWeight.w800, fontSize: 17),
        ),
        content: Text(
          'Se eliminará a ${doctor.name} de tu lista de contactos. Esta acción no se puede deshacer.',
          style: const TextStyle(color: textGray, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: textGray, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await context.read<DoctorProvider>().deleteDoctor(doctor.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${doctor.name} fue eliminado.'),
                    backgroundColor: textDark,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'Dr';
    if (parts.length == 1) return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

