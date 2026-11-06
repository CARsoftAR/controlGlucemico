import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/doctor.dart';
import '../../../../core/models/glucose_measurement.dart';
import '../../../../core/services/pdf_export_service.dart';
import '../providers/doctor_provider.dart';
import '../screens/doctors_screen.dart';

/// Modal BottomSheet limpio y elegante para seleccionar el médico de destino y enviar el reporte por WhatsApp
class SendReportModal extends StatelessWidget {
  final List<GlucoseMeasurement> measurements;

  const SendReportModal({super.key, required this.measurements});

  static const Color bgColor = Color(0xFFF7F4EE);
  static const Color cardColor = Colors.white;
  static const Color borderColor = Color(0xFFE8E2D8);
  static const Color textDark = Color(0xFF2D3748);
  static const Color textGray = Color(0xFF718096);
  static const Color pastelBlue = Color(0xFF7EBCE6);
  static const Color pastelGreen = Color(0xFFA8D5BA);
  static const Color whatsappGreen = Color(0xFF25D366);

  static Future<void> show(BuildContext context, {required List<GlucoseMeasurement> measurements}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SendReportModal(measurements: measurements),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctorProvider = context.watch<DoctorProvider>();
    final doctors = doctorProvider.doctors;

    return Container(
      decoration: const BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 14,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Píldora de arrastre superior
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
          const SizedBox(height: 18),

          // Encabezado
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: pastelGreen.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF2C7A7B), size: 24),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enviar Reporte Médico',
                      style: TextStyle(
                        color: textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '¿A qué médico deseas enviar el reporte?',
                      style: TextStyle(
                        color: textGray,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: textGray),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Resumen rápido de lo que se enviará
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: pastelBlue, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Se enviará el resumen de ${measurements.length} mediciones y el enlace del reporte a través de WhatsApp.',
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Lista de médicos disponibles
          if (doctors.isEmpty)
            _buildEmptyDoctors(context)
          else ...[
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: doctors.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, index) {
                  final doctor = doctors[index];
                  return _buildDoctorTile(context, doctor);
                },
              ),
            ),
            const SizedBox(height: 14),
            // Botón para gestionar o agregar más médicos
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DoctorsScreen()),
                  );
                },
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18, color: Color(0xFF2C7A7B)),
                label: const Text(
                  'Gestionar lista de médicos',
                  style: TextStyle(
                    color: Color(0xFF2C7A7B),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyDoctors(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          const Icon(Icons.person_search_rounded, size: 38, color: textGray),
          const SizedBox(height: 8),
          const Text(
            'No tienes médicos registrados',
            style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            'Agrega al menos un especialista con su número de WhatsApp para enviarle tus reportes.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textGray, fontSize: 12),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DoctorsScreen()),
                );
              },
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: const Text(
                'Agregar Médico Ahora',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: pastelBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorTile(BuildContext context, Doctor doctor) {
    return InkWell(
      onTap: () async {
        Navigator.of(context).pop();
        await PdfExportService.generateAndShareFromList(
          context: context,
          measurements: measurements,
          doctor: doctor,
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Iniciales del médico
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: pastelBlue.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                _getInitials(doctor.name),
                style: const TextStyle(
                  color: Color(0xFF2B6CB0),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Nombre y especialidad
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (doctor.specialty != null && doctor.specialty!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      doctor.specialty!,
                      style: const TextStyle(
                        color: textGray,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 12, color: textGray),
                      const SizedBox(width: 4),
                      Text(
                        doctor.whatsapp,
                        style: const TextStyle(
                          color: textGray,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Botón de PDF y WhatsApp
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8EE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF22543D), size: 16),
                  SizedBox(width: 6),
                  Text(
                    'PDF',
                    style: TextStyle(
                      color: Color(0xFF22543D),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

