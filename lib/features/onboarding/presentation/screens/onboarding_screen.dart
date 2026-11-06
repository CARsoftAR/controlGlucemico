import 'package:flutter/material.dart';
import '../../../dashboard/dashboard_screen.dart';

/// Pantalla de Onboarding en Flutter (Flat Design & Colores Pastel)
/// Implementa un carrusel interactivo con PageView de 5 pasos ordenados
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Paleta de colores Pastel & Flat Design estricto
  static const Color bgColor = Color(0xFFFAF8F5); // Crema / Blanco hueso suave
  static const Color pastelBlue = Color(0xFF7BAED4); // Celeste pastel mate
  static const Color pastelCoral = Color(0xFFE89A8C); // Coral / Rosa pastel mate
  static const Color textDark = Color(0xFF1E293B); // Título oscuro moderno
  static const Color textGray = Color(0xFF64748B); // Subtítulo gris suave
  static const Color textCategory = Color(0xFF8A9AAB); // Etiqueta superior
  static const Color indicatorInactive = Color(0xFFD6E2ED); // Puntos inactivos

  // Flujo ordenado de 5 pantallas según especificación exacta de las referencias
  final List<_OnboardingStepData> _steps = const [
    _OnboardingStepData(
      category: 'BIENVENIDA',
      title: 'Control de Glucosa\nInteligente',
      description:
          'Lleva el registro diario de tus mediciones de manera rápida, ordenada y segura en la palma de tu mano.',
      type: _StepType.waterDrop,
      buttonText: 'Siguiente',
    ),
    _OnboardingStepData(
      category: 'TENDENCIAS',
      title: 'Visualiza tus\nTendencias',
      description:
          'Analiza el comportamiento de tu glucosa en los últimos 7 días con gráficos limpios y detecta picos a tiempo.',
      type: _StepType.trendChart,
      buttonText: 'Siguiente',
    ),
    _OnboardingStepData(
      category: 'ALERTAS',
      title: 'Nunca olvides una\nmedición',
      description:
          'Configura recordatorios recurrentes para cada momento clave del día y recibe avisos inmediatos ante valores críticos.',
      type: _StepType.bellAlert,
      buttonText: 'Siguiente',
    ),
    _OnboardingStepData(
      category: 'REPORTE MÉDICO',
      title: 'Comparte con tu\nMédico',
      description:
          'Envía tus reportes y estadísticas detalladas directamente por WhatsApp a tu especialista en segundos.',
      type: _StepType.medicalReport,
      buttonText: 'Siguiente',
      buttonColor: pastelBlue,
    ),
    _OnboardingStepData(
      category: 'RESUMEN',
      title: 'Todo listo para empezar',
      description:
          'Registra tus valores en segundos, añade notas sobre tus dosis de insulina y mantén todo preparado para compartir con tu médico.',
      type: _StepType.clipboardCheck,
      buttonText: 'Comenzar Ahora',
      buttonColor: pastelCoral,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const DashboardScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = _currentPage == _steps.length - 1;
    final currentStep = _steps[_currentPage];
    final Color buttonColor = currentStep.buttonColor ?? (isLastPage ? pastelCoral : pastelBlue);
    final String buttonText = currentStep.buttonText ?? (isLastPage ? 'Comenzar Ahora' : 'Siguiente');

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Header: Icono de gota + Gluco Control
            _buildAppHeader(),

            // PageView con los 5 pasos
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _steps.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPageItem(_steps[index]);
                },
              ),
            ),

            // Indicadores de puntos horizontales dinámicos (5 puntos exactos)
            _buildPageIndicators(),
            const SizedBox(height: 28),

            // Botón de acción inferior plano y redondeado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    elevation: 0, // Flat Design estricto
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                  child: Text(buttonText),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Header de la aplicación con la marca Gluco Control
  Widget _buildAppHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomPaint(
            size: const Size(20, 24),
            painter: _SmallDropPainter(color: pastelBlue),
          ),
          const SizedBox(width: 8),
          const Text(
            'Gluco Control',
            style: TextStyle(
              color: textDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye cada página del carrusel Onboarding
  Widget _buildPageItem(_OnboardingStepData step) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Etiqueta superior de sección (mayúsculas espaciadas)
          Text(
            step.category,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textCategory,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.5,
            ),
          ),
          const SizedBox(height: 32),

          // Ilustración vectorial plana personalizada
          SizedBox(
            height: 180,
            width: double.infinity,
            child: Center(
              child: _buildIllustration(step.type),
            ),
          ),
          const SizedBox(height: 36),

          // Título principal en estilo oscuro limpio
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textDark,
              fontSize: 27,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 14),

          // Subtítulo en gris suave
          Text(
            step.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textGray,
              fontSize: 14.5,
              fontWeight: FontWeight.w400,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  /// Indicadores de puntos dinámicos (5 puntos) con píldora para el activo
  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_steps.length, (index) {
        final bool isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8,
          width: isActive ? 24 : 8,
          decoration: BoxDecoration(
            color: isActive ? pastelBlue : indicatorInactive,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  /// Renderiza la ilustración plana correspondiente según el paso
  Widget _buildIllustration(_StepType type) {
    switch (type) {
      case _StepType.waterDrop:
        return CustomPaint(
          size: const Size(140, 160),
          painter: _WaterDropIllustrationPainter(
            dropColor: pastelBlue,
            innerColor: Colors.white,
          ),
        );
      case _StepType.trendChart:
        return CustomPaint(
          size: const Size(220, 140),
          painter: _TrendChartIllustrationPainter(
            lineColor: pastelBlue,
            dotColor: Colors.white,
            fillColor: pastelBlue.withValues(alpha: 0.22),
          ),
        );
      case _StepType.bellAlert:
        return CustomPaint(
          size: const Size(170, 140),
          painter: _BellAlertIllustrationPainter(
            bellColor: pastelBlue,
            waveColor: pastelBlue.withValues(alpha: 0.55),
          ),
        );
      case _StepType.medicalReport:
        return CustomPaint(
          size: const Size(160, 160),
          painter: _MedicalReportIllustrationPainter(
            primaryColor: pastelBlue,
          ),
        );
      case _StepType.clipboardCheck:
        return CustomPaint(
          size: const Size(150, 160),
          painter: _ClipboardCheckIllustrationPainter(
            boardColor: pastelBlue,
            paperColor: Colors.white,
            badgeColor: pastelCoral,
          ),
        );
    }
  }
}

enum _StepType {
  waterDrop,
  trendChart,
  bellAlert,
  medicalReport,
  clipboardCheck,
}

class _OnboardingStepData {
  final String category;
  final String title;
  final String description;
  final _StepType type;
  final String? buttonText;
  final Color? buttonColor;

  const _OnboardingStepData({
    required this.category,
    required this.title,
    required this.description,
    required this.type,
    this.buttonText,
    this.buttonColor,
  });
}

// ---------------------------------------------------------------------------
// ILUSTRACIONES VECTORIALES FLAT DESIGN EN COLORES PASTEL
// ---------------------------------------------------------------------------

/// Pequeña gota para el header
class _SmallDropPainter extends CustomPainter {
  final Color color;
  const _SmallDropPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.cubicTo(
      size.width,
      size.height * 0.55,
      size.width,
      size.height,
      size.width / 2,
      size.height,
    );
    path.cubicTo(
      0,
      size.height,
      0,
      size.height * 0.55,
      size.width / 2,
      0,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Ilustración 1: Gota de Glucosa con electrocardiograma y hoja de salud blanca
class _WaterDropIllustrationPainter extends CustomPainter {
  final Color dropColor;
  final Color innerColor;

  const _WaterDropIllustrationPainter({
    required this.dropColor,
    required this.innerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dropPaint = Paint()
      ..color = dropColor
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // 1. Trazado de la gota plana
    final dropPath = Path();
    dropPath.moveTo(w / 2, 0);
    dropPath.cubicTo(w * 0.98, h * 0.50, w * 0.98, h, w / 2, h);
    dropPath.cubicTo(w * 0.02, h, w * 0.02, h * 0.50, w / 2, 0);
    dropPath.close();

    canvas.drawPath(dropPath, dropPaint);

    // 2. Línea de ECG blanca
    final linePaint = Paint()
      ..color = innerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final ecgPath = Path();
    final centerY = h * 0.56;
    ecgPath.moveTo(w * 0.22, centerY);
    ecgPath.lineTo(w * 0.38, centerY);
    ecgPath.lineTo(w * 0.43, centerY + 12);
    ecgPath.lineTo(w * 0.50, centerY - 28);
    ecgPath.lineTo(w * 0.57, centerY + 24);
    ecgPath.lineTo(w * 0.63, centerY);
    ecgPath.lineTo(w * 0.72, centerY);

    canvas.drawPath(ecgPath, linePaint);

    // 3. Hoja estilizada en blanco junto al pulso
    final leafPaint = Paint()
      ..color = innerColor
      ..style = PaintingStyle.fill;

    final leafPath = Path();
    leafPath.moveTo(w * 0.54, centerY - 4);
    leafPath.cubicTo(w * 0.54, centerY - 24, w * 0.68, centerY - 32, w * 0.76, centerY - 32);
    leafPath.cubicTo(w * 0.76, centerY - 14, w * 0.66, centerY - 4, w * 0.54, centerY - 4);
    leafPath.close();

    canvas.drawPath(leafPath, leafPaint);

    // Nervadura de la hoja
    final veinPaint = Paint()
      ..color = dropColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(w * 0.55, centerY - 4),
      Offset(w * 0.73, centerY - 28),
      veinPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Ilustración 2: Gráfico de Tendencias fluido y minimalista (sin ejes rígidos)
class _TrendChartIllustrationPainter extends CustomPainter {
  final Color lineColor;
  final Color dotColor;
  final Color fillColor;

  const _TrendChartIllustrationPainter({
    required this.lineColor,
    required this.dotColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final points = [
      Offset(w * 0.05, h * 0.76),
      Offset(w * 0.24, h * 0.58),
      Offset(w * 0.42, h * 0.64),
      Offset(w * 0.60, h * 0.32),
      Offset(w * 0.78, h * 0.48),
      Offset(w * 0.95, h * 0.16),
    ];

    // Trazado de la curva continua
    final curvePath = Path();
    curvePath.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      curvePath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    // Área rellena degradada inferior
    final areaPath = Path.from(curvePath);
    areaPath.lineTo(points.last.dx, h * 0.95);
    areaPath.lineTo(points.first.dx, h * 0.95);
    areaPath.close();

    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        fillColor,
        fillColor.withValues(alpha: 0.0),
      ],
    );

    final areaPaint = Paint()
      ..shader = fillGradient.createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawPath(areaPath, areaPaint);

    // Línea de contorno principal
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(curvePath, linePaint);

    // Puntos circulares claros con borde pastel
    final dotFillPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8;

    for (final pt in points) {
      canvas.drawCircle(pt, 5.0, dotFillPaint);
      canvas.drawCircle(pt, 5.0, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Ilustración 3: Campana de Notificaciones con Ondas Suaves
class _BellAlertIllustrationPainter extends CustomPainter {
  final Color bellColor;
  final Color waveColor;

  const _BellAlertIllustrationPainter({
    required this.bellColor,
    required this.waveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // 1. Ondas de sonido laterales (arcos concéntricos suaves)
    final wavePaint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Onda izquierda interior
    final leftInner = Path()
      ..addArc(
        Rect.fromCircle(center: Offset(center.dx - 18, center.dy), radius: 46),
        2.4,
        1.45,
      );
    canvas.drawPath(leftInner, wavePaint);

    // Onda derecha interior
    final rightInner = Path()
      ..addArc(
        Rect.fromCircle(center: Offset(center.dx + 18, center.dy), radius: 46),
        -0.72,
        1.45,
      );
    canvas.drawPath(rightInner, wavePaint);

    // 2. Campana plana principal
    final bellPaint = Paint()
      ..color = bellColor
      ..style = PaintingStyle.fill;

    // Aro superior
    canvas.drawCircle(Offset(center.dx, center.dy - 44), 6, bellPaint);

    // Cuerpo de la campana
    final bellPath = Path();
    bellPath.moveTo(center.dx - 9, center.dy - 38);
    bellPath.cubicTo(center.dx - 30, center.dy - 20, center.dx - 34, center.dy + 8, center.dx - 44, center.dy + 20);
    bellPath.cubicTo(center.dx - 46, center.dy + 24, center.dx - 40, center.dy + 26, center.dx - 32, center.dy + 26);
    bellPath.lineTo(center.dx + 32, center.dy + 26);
    bellPath.cubicTo(center.dx + 40, center.dy + 26, center.dx + 46, center.dy + 24, center.dx + 44, center.dy + 20);
    bellPath.cubicTo(center.dx + 34, center.dy + 8, center.dx + 30, center.dy - 20, center.dx + 9, center.dy - 38);
    bellPath.close();

    canvas.drawPath(bellPath, bellPaint);

    // Badajo / esfera inferior
    canvas.drawCircle(Offset(center.dx, center.dy + 32), 8, bellPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Ilustración 4: Burbuja de chat con documento PDF y reporte médico
class _MedicalReportIllustrationPainter extends CustomPainter {
  final Color primaryColor;

  const _MedicalReportIllustrationPainter({
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2 - 4);

    // 1. Burbuja de chat exterior en celeste pastel
    final bubblePath = Path();
    const radius = 62.0;
    final bubbleCenter = Offset(center.dx, center.dy);

    // Círculo principal
    bubblePath.addOval(Rect.fromCircle(center: bubbleCenter, radius: radius));

    // Cola de la burbuja hacia abajo-izquierda
    final tailPath = Path();
    tailPath.moveTo(bubbleCenter.dx - 34, bubbleCenter.dy + 46);
    tailPath.lineTo(bubbleCenter.dx - 52, bubbleCenter.dy + 66);
    tailPath.lineTo(bubbleCenter.dx - 18, bubbleCenter.dy + 58);
    tailPath.close();

    // Fondo suave blanco de la burbuja
    final bubbleFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(bubblePath, bubbleFill);
    canvas.drawPath(tailPath, bubbleFill);

    // Borde de la burbuja en celeste pastel grueso
    final bubbleBorder = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final combinedBubble = Path.combine(PathOperation.union, bubblePath, tailPath);
    canvas.drawPath(combinedBubble, bubbleBorder);

    // 2. Documento con esquina doblada
    final docLeft = bubbleCenter.dx - 26;
    final docTop = bubbleCenter.dy - 38;
    const docWidth = 52.0;
    const docHeight = 56.0;

    final docPath = Path();
    const foldSize = 12.0;
    docPath.moveTo(docLeft + 6, docTop);
    docPath.lineTo(docLeft + docWidth - foldSize, docTop);
    docPath.lineTo(docLeft + docWidth, docTop + foldSize);
    docPath.lineTo(docLeft + docWidth, docTop + docHeight - 6);
    docPath.cubicTo(docLeft + docWidth, docTop + docHeight, docLeft + docWidth - 6, docTop + docHeight, docLeft + docWidth - 6, docTop + docHeight);
    docPath.lineTo(docLeft + 6, docTop + docHeight);
    docPath.cubicTo(docLeft, docTop + docHeight, docLeft, docTop + docHeight - 6, docLeft, docTop + docHeight - 6);
    docPath.lineTo(docLeft, docTop + 6);
    docPath.cubicTo(docLeft, docTop, docLeft + 6, docTop, docLeft + 6, docTop);
    docPath.close();

    final docPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(docPath, docPaint);

    // Pliegue de la esquina
    final foldPath = Path();
    foldPath.moveTo(docLeft + docWidth - foldSize, docTop);
    foldPath.lineTo(docLeft + docWidth - foldSize, docTop + foldSize);
    foldPath.lineTo(docLeft + docWidth, docTop + foldSize);
    canvas.drawPath(foldPath, docPaint);

    // 3. Etiqueta / Pill 'PDF'
    final pdfRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(docLeft + 8, docTop + 10, 36, 15),
      const Radius.circular(4),
    );
    final pdfPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(pdfRect, pdfPaint);

    // Texto 'PDF' dentro de la etiqueta
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'PDF',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(docLeft + 8 + (36 - textPainter.width) / 2, docTop + 10 + (15 - textPainter.height) / 2),
    );

    // Líneas del documento
    final linePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(docLeft + 10, docTop + 33), Offset(docLeft + docWidth - 10, docTop + 33), linePaint);
    canvas.drawLine(Offset(docLeft + 10, docTop + 42), Offset(docLeft + docWidth - 16, docTop + 42), linePaint);

    // 4. Texto 'Report' y Checkmark abajo del documento
    final reportPainter = TextPainter(
      text: TextSpan(
        text: 'Report ',
        style: TextStyle(
          color: primaryColor,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final reportX = bubbleCenter.dx - (reportPainter.width + 12) / 2;
    final reportY = bubbleCenter.dy + 24;
    reportPainter.paint(canvas, Offset(reportX, reportY));

    // Checkmark azul
    final checkPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final checkX = reportX + reportPainter.width + 1;
    final checkY = reportY + 6;
    final checkPath = Path();
    checkPath.moveTo(checkX, checkY);
    checkPath.lineTo(checkX + 3.5, checkY + 4);
    checkPath.lineTo(checkX + 9, checkY - 4);
    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Ilustración 5: Portapapeles con hoja de datos y badge coral con checkmark
class _ClipboardCheckIllustrationPainter extends CustomPainter {
  final Color boardColor;
  final Color paperColor;
  final Color badgeColor;

  const _ClipboardCheckIllustrationPainter({
    required this.boardColor,
    required this.paperColor,
    required this.badgeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // 1. Tablero base pastel
    final boardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx - 8, center.dy - 4), width: 90, height: 118),
      const Radius.circular(14),
    );
    final boardPaint = Paint()
      ..color = boardColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(boardRect, boardPaint);

    // Clip superior del tablero
    final clipRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx - 8, center.dy - 60), width: 32, height: 12),
      const Radius.circular(6),
    );
    final clipPaint = Paint()
      ..color = boardColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(clipRect, clipPaint);

    // 2. Hoja blanca interior
    final paperRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx - 8, center.dy), width: 72, height: 96),
      const Radius.circular(8),
    );
    final paperPaint = Paint()
      ..color = paperColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(paperRect, paperPaint);

    // Líneas de texto simuladas en la hoja
    final linePaint = Paint()
      ..color = boardColor.withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(center.dx - 32, center.dy - 32), Offset(center.dx + 4, center.dy - 32), linePaint);
    canvas.drawLine(Offset(center.dx - 32, center.dy - 20), Offset(center.dx + 16, center.dy - 20), linePaint);
    canvas.drawLine(Offset(center.dx - 32, center.dy - 8), Offset(center.dx + 16, center.dy - 8), linePaint);
    canvas.drawLine(Offset(center.dx - 32, center.dy + 4), Offset(center.dx + 8, center.dy + 4), linePaint);
    canvas.drawLine(Offset(center.dx - 32, center.dy + 16), Offset(center.dx - 4, center.dy + 16), linePaint);

    // 3. Badge circular en tono coral pastel con checkmark
    final badgeCenter = Offset(center.dx + 30, center.dy + 28);
    final badgePaint = Paint()
      ..color = badgeColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(badgeCenter, 22, badgePaint);

    // Checkmark blanco
    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final checkPath = Path();
    checkPath.moveTo(badgeCenter.dx - 8, badgeCenter.dy - 1);
    checkPath.lineTo(badgeCenter.dx - 2, badgeCenter.dy + 6);
    checkPath.lineTo(badgeCenter.dx + 8, badgeCenter.dy - 6);

    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
