import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Paleta de colores "Light Glassmorphism" con acentos médicos vibrantes
class AppColors {
  AppColors._();

  // Fondos Degradé Claros (Blanco puro a perla celeste y gris platino sutil)
  static const Color bgLightPearl = Color(0xFFF0F4F8);
  static const Color bgLightSoft = Color(0xFFF8FAFC);
  static const Color bgLightWhite = Color(0xFFFFFFFF);

  // Degradé de Fondo Principal de la App (Suave, claro y limpio)
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEBF1F6), // Perla celeste suave
      Color(0xFFF3F7FA), // Hielo luminoso
      Color(0xFFFFFFFF), // Blanco puro
    ],
    stops: [0.0, 0.45, 1.0],
  );

  // Superficies Glassmorphism Real (Blanco translúcido con desenfoque)
  static Color glassSurface = Colors.white.withValues(alpha: 0.70);
  static Color glassSurfaceInput = Colors.white.withValues(alpha: 0.85);
  static Color glassBorder = Colors.white.withValues(alpha: 0.80);
  static const double glassBlur = 12.0;

  // Compatibilidad de superficies para temas previos
  static Color surfaceCard = Colors.white.withValues(alpha: 0.75);
  static const Color surfaceElevated = Colors.white;
  static const Color border = Color(0x260F172A); // Borde tenue oscuro para divisores
  static const Color borderHighlight = Color(0x400F172A);
  static const Color pureBlack = Color(0xFFF0F4F8); // Fondo claro neutro en lugar de negro

  // Colores de Acento y Estado Funcionales
  static const Color primaryCyan = Color(0xFF0098A6); // Cyan brillante con alto contraste sobre claro
  static const Color cyanAccentGlow = Color(0xFF00F0FF); // Cyan puro para resplandor y puntos
  static const Color alertMagenta = Color(0xFFFF007F); // Magenta para alertas críticas
  static const Color successGreen = Color(0xFF10B981); // Verde salud
  static const Color warningOrange = Color(0xFFF59E0B);

  // Tipografía y Neutros de Alto Contraste (Gris muy oscuro / Negro suave)
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900 - Alta legibilidad
  static const Color textSecondary = Color(0xFF475569); // Slate 600 - Claridad intermedia
  static const Color textMuted = Color(0xFF64748B); // Slate 500 - Textos secundarios y etiquetas
}

/// Widget contenedor reutilizable para el efecto Glassmorphism real en fondo claro
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final Border? border;
  final double blurSigma;
  final List<BoxShadow>? boxShadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.border,
    this.blurSigma = AppColors.glassBlur,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(20.0);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        // Sombra difusa elegante para que las tarjetas de cristal floten sobre el fondo degradado
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 18,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.6),
            blurRadius: 0,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color ?? AppColors.glassSurface,
              borderRadius: effectiveRadius,
              border: border ??
                  Border.all(
                    color: AppColors.glassBorder,
                    width: 1.5,
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Definición del tema Light Glassmorphism
class AppTheme {
  AppTheme._();

  static ThemeData get pureDark => lightTheme;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLightPearl,
      primaryColor: AppColors.primaryCyan,

      // ColorScheme Claro
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryCyan,
        onPrimary: Colors.white,
        error: AppColors.alertMagenta,
        onError: Colors.white,
        surface: AppColors.surfaceElevated,
        onSurface: AppColors.textPrimary,
        outline: AppColors.glassBorder,
      ),

      // AppBar Minimalista translúcida
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),

      // CardTheme Glassmorphism translúcido claro
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.75),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.80),
            width: 1.5,
          ),
        ),
      ),

      // FloatingActionButton Cyan brillante
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryCyan,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: CircleBorder(),
      ),

      // Dialog Theme con bordes redondeados y cristal claro
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.94),
        surfaceTintColor: Colors.transparent,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.90),
            width: 1.5,
          ),
        ),
      ),

      // TextButton Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),

      // Estilo de texto general en tonos oscuros de alto contraste
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.0,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
        labelSmall: TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
