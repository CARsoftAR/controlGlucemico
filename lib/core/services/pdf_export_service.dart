import 'dart:io';
import 'package:flutter/material.dart' as m;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';
import '../models/doctor.dart';
import '../models/glucose_measurement.dart';

/// Servicio especializado para la generación y compartición de reportes clínicos en PDF
class PdfExportService {
  PdfExportService._();

  static const MethodChannel _whatsappChannel =
      MethodChannel('com.controlglucemico/whatsapp_share');

  /// Genera y comparte el PDF directamente a partir de la lista de mediciones actualmente filtrada
  /// Copia automáticamente el texto personalizado al portapapeles y abre el menú nativo de Share
  static Future<File?> generateAndShareFromList({
    required m.BuildContext context,
    required List<GlucoseMeasurement> measurements,
    Doctor? doctor,
  }) async {
    if (measurements.isEmpty) {
      m.ScaffoldMessenger.of(context).showSnackBar(
        const m.SnackBar(
          content: m.Text('No hay registros en el período seleccionado para exportar.'),
          backgroundColor: m.Color(0xFFE53E3E),
          behavior: m.SnackBarBehavior.floating,
        ),
      );
      return null;
    }

    // Obtener nombre del paciente desde ProfileProvider si está configurado
    String patientName = '';
    try {
      patientName = context.read<ProfileProvider>().fullName.trim();
    } catch (_) {}

    // Orden cronológico para el reporte (más reciente primero)
    final sortedList = List<GlucoseMeasurement>.from(measurements)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Determinar rango de fechas representativo del conjunto filtrado
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    final earliest = sortedList.last.timestamp;
    final latest = sortedList.first.timestamp;

    final String rangeStr = (earliest.year == latest.year &&
            earliest.month == latest.month &&
            earliest.day == latest.day)
        ? dateFormat.format(earliest)
        : '${dateFormat.format(earliest)} al ${dateFormat.format(latest)}';

    // Métricas del conjunto
    final total = sortedList.length;
    final avg = total > 0 ? sortedList.fold<double>(0.0, (s, item) => s + item.value) / total : 0.0;
    final maxVal = total > 0 ? sortedList.map((item) => item.value).reduce((a, b) => a > b ? a : b) : 0.0;
    final minVal = total > 0 ? sortedList.map((item) => item.value).reduce((a, b) => a < b ? a : b) : 0.0;
    final inRangeCount = sortedList.where((item) => item.value >= 70 && item.value <= 140).length;
    final inRangePct = total > 0 ? ((inRangeCount / total) * 100).round() : 0;

    // Paleta de colores PDF
    const primaryColor = PdfColor.fromInt(0xFF2C7A7B);
    const darkTextColor = PdfColor.fromInt(0xFF2D3748);
    const grayTextColor = PdfColor.fromInt(0xFF718096);
    const headerBgColor = PdfColor.fromInt(0xFFE2E8F0);
    const zebraRowColor = PdfColor.fromInt(0xFFF8FAFC);
    const alertColor = PdfColor.fromInt(0xFFE53E3E);
    const normalColor = PdfColor.fromInt(0xFF38A169);

    final pdf = pw.Document(
      title: 'Reporte Glucémico - Gluco Control',
      author: 'Gluco Control App',
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 36),
        header: (ctx) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 12),
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: headerBgColor, width: 1.5)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'GLUCO CONTROL',
                      style: pw.TextStyle(
                        color: primaryColor,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Reporte Glucémico del Paciente',
                      style: pw.TextStyle(
                        color: darkTextColor,
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (patientName.isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Paciente: $patientName',
                        style: pw.TextStyle(
                          color: primaryColor,
                          fontSize: 10.5,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Período: $rangeStr',
                      style: const pw.TextStyle(
                        color: darkTextColor,
                        fontSize: 10,
                      ),
                    ),
                    if (doctor != null) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Destinatario: ${doctor.name}',
                        style: pw.TextStyle(
                          color: primaryColor,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
        footer: (ctx) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(top: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(color: headerBgColor, width: 1)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Generado por Gluco Control • Documento Informativo de Monitoreo',
                  style: const pw.TextStyle(color: grayTextColor, fontSize: 8),
                ),
                pw.Text(
                  'Página ${ctx.pageNumber} de ${ctx.pagesCount}',
                  style: const pw.TextStyle(color: grayTextColor, fontSize: 8),
                ),
              ],
            ),
          );
        },
        build: (ctx) => [
          pw.SizedBox(height: 12),

          // 1. Resumen Estadístico
          pw.Row(
            children: [
              _buildStatCard(
                title: 'PROMEDIO',
                value: total > 0 ? '${avg.toStringAsFixed(0)} mg/dL' : '--',
                subtitle: 'Glucosa media',
                color: primaryColor,
              ),
              pw.SizedBox(width: 8),
              _buildStatCard(
                title: 'VALOR MÁXIMO',
                value: total > 0 ? '${maxVal.toStringAsFixed(0)} mg/dL' : '--',
                subtitle: 'Pico más alto',
                color: alertColor,
              ),
              pw.SizedBox(width: 8),
              _buildStatCard(
                title: 'VALOR MÍNIMO',
                value: total > 0 ? '${minVal.toStringAsFixed(0)} mg/dL' : '--',
                subtitle: 'Lectura más baja',
                color: normalColor,
              ),
              pw.SizedBox(width: 8),
              _buildStatCard(
                title: 'EN RANGO (70-140)',
                value: total > 0 ? '$inRangePct%' : '--',
                subtitle: '$inRangeCount de $total tomas',
                color: primaryColor,
              ),
            ],
          ),
          pw.SizedBox(height: 18),

          // Título de la tabla
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Registro Detallado de Mediciones',
                style: pw.TextStyle(
                  color: darkTextColor,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                '$total registros',
                style: const pw.TextStyle(
                  color: grayTextColor,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),

          // 2. Tabla de Datos Limpia con Zebra Striping
          pw.Table(
            border: pw.TableBorder.all(
              color: headerBgColor,
              width: 0.6,
            ),
            columnWidths: const {
              0: pw.FlexColumnWidth(2.2), // Fecha
              1: pw.FlexColumnWidth(1.6), // Hora
              2: pw.FlexColumnWidth(2.4), // Valor
              3: pw.FlexColumnWidth(3.0), // Etiqueta
              4: pw.FlexColumnWidth(4.8), // Notas / Insulina
            },
            children: [
              // Encabezado
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: headerBgColor),
                children: [
                  _buildTableHeaderCell('Fecha'),
                  _buildTableHeaderCell('Hora'),
                  _buildTableHeaderCell('Valor (mg/dL)'),
                  _buildTableHeaderCell('Etiqueta / Momento'),
                  _buildTableHeaderCell('Notas / Insulina'),
                ],
              ),
              // Filas
              ...sortedList.asMap().entries.map((entry) {
                final index = entry.key;
                final mItem = entry.value;
                final isEven = index % 2 == 0;
                final isElevated = mItem.value > 140.0;

                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: isEven ? PdfColors.white : zebraRowColor,
                  ),
                  children: [
                    _buildTableCell(dateFormat.format(mItem.timestamp)),
                    _buildTableCell(timeFormat.format(mItem.timestamp)),
                    _buildTableCell(
                      '${mItem.value.toStringAsFixed(0)} mg/dL',
                      textColor: isElevated ? alertColor : normalColor,
                      isBold: isElevated,
                    ),
                    _buildTableCell(_extractEtiqueta(mItem.context)),
                    _buildTableCell(mItem.notes != null && mItem.notes!.isNotEmpty ? mItem.notes! : '-'),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );

    // Guardado en directorio temporal
    final outputDir = await getTemporaryDirectory();
    final startTag = DateFormat('yyyyMMdd').format(earliest);
    final endTag = DateFormat('yyyyMMdd').format(latest);
    final fileName = 'Reporte_Glucemia_${startTag}_$endTag.pdf';
    final filePath = '${outputDir.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Generar mensaje personalizado según el requerimiento exacto
    final String doctorPrefix = doctor != null
        ? (doctor.name.startsWith('Dr') ? doctor.name : 'Dr. ${doctor.name}')
        : 'Doctor';

    final String mensaje = patientName.isNotEmpty
        ? 'Hola $doctorPrefix, soy $patientName. Le adjunto mi reporte glucémico generado desde Gluco Control para su revisión.'
        : 'Hola $doctorPrefix, le adjunto mi reporte glucémico generado desde Gluco Control para su revisión.';

    // Copiar automáticamente al portapapeles
    try {
      await Clipboard.setData(ClipboardData(text: mensaje));
    } catch (_) {}

    // Notificación flotante informativa
    if (context.mounted) {
      m.ScaffoldMessenger.of(context).showSnackBar(
        const m.SnackBar(
          content: m.Row(
            children: [
              m.Icon(m.Icons.content_paste_rounded, color: m.Colors.white, size: 20),
              m.SizedBox(width: 10),
              m.Expanded(
                child: m.Text(
                  'Mensaje copiado al portapapeles. Pégalo directamente al adjuntar en WhatsApp.',
                  style: m.TextStyle(fontWeight: m.FontWeight.w600, fontSize: 12),
                ),
              ),
            ],
          ),
          backgroundColor: m.Color(0xFF2C7A7B),
          behavior: m.SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );
    }

    // Envío directo a WhatsApp si se seleccionó un médico con número (Bypass del Share Sheet)
    final cleanPhone = doctor?.cleanWhatsAppNumber ?? '';

    if (cleanPhone.isNotEmpty) {
      bool sentDirectly = false;

      // Intent nativo en Android con FileProvider (content:// URI Parcelable + FLAG_GRANT_READ_URI_PERMISSION + JID)
      if (Platform.isAndroid) {
        try {
          final res = await _whatsappChannel.invokeMethod<bool>(
            'sharePdfToWhatsApp',
            <String, dynamic>{
              'filePath': file.path,
              'phone': cleanPhone,
              'text': mensaje,
            },
          );
          if (res == true) {
            sentDirectly = true;
          }
        } catch (_) {}
      }

      // Fallback a share_plus únicamente si no se pudo abrir WhatsApp directamente
      if (!sentDirectly) {
        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'application/pdf', name: fileName)],
          text: mensaje,
          subject: 'Reporte Glucémico - Gluco Control',
        );
      }
    } else {
      // Si es un reporte general sin médico específico, abrir el menú de compartir estándar
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf', name: fileName)],
        text: mensaje,
        subject: 'Reporte Glucémico - Gluco Control',
      );
    }

    return file;
  }

  static pw.Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required PdfColor color,
  }) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          border: pw.Border.all(color: const PdfColor.fromInt(0xFFE2E8F0), width: 0.8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: const pw.TextStyle(
                color: PdfColor.fromInt(0xFF718096),
                fontSize: 7.5,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              value,
              style: pw.TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              subtitle,
              style: const pw.TextStyle(
                color: PdfColor.fromInt(0xFFA0AEC0),
                fontSize: 7.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildTableHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: const PdfColor.fromInt(0xFF2D3748),
          fontSize: 8.5,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    PdfColor textColor = const PdfColor.fromInt(0xFF2D3748),
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: textColor,
          fontSize: 8.5,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static String _extractEtiqueta(String context) {
    if (context.isEmpty) return 'Control';
    return context;
  }
}
