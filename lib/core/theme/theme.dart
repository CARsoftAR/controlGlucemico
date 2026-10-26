import 'package:flutter/material.dart';

/// Paleta de colores "Pure Dark" con acentos Cyber-Medical
class AppColors {
  AppColors._();

  // Fondos y Superficies
  static const Color pureBlack = Color(0xFF000000);
  static const Color surfaceCard = Color(0xFF0A0A0A);
  static const Color surfaceElevated = Color(0xFF141414);
  static const Color border = Color(0xFF1A1A1A);
  static const Color borderHighlight = Color(0xFF2A2A2A);

  // Colores de Acento y Estado
  static const Color primaryCyan = Color(0xFF00F0FF);
  static const Color alertMagenta = Color(0xFFFF007F);
  static const Color successGreen = Color(0xFF00E676);
  static const Color warningOrange = Color(0xFFFF9100);

  // Tipografía y Neutros
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color textMuted = Color(0xFF666666);
}

/// Definición del tema Pure Dark
class AppTheme {
  AppTheme._();

  static ThemeData get pureDark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.pureBlack,
      primaryColor: AppColors.primaryCyan,
      
      // ColorScheme moderno
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryCyan,
        onPrimary: AppColors.pureBlack,
        error: AppColors.alertMagenta,
        onError: AppColors.textPrimary,
        surface: AppColors.surfaceCard,
        onSurface: AppColors.textPrimary,
        outline: AppColors.border,
      ),

      // AppBar Minimalista
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.pureBlack,
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

      // CardTheme: #0A0A0A sin elevación con borde #1A1A1A
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: AppColors.border,
            width: 1.0,
          ),
        ),
      ),

      // FloatingActionButton Cyan
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryCyan,
        foregroundColor: AppColors.pureBlack,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Dialog Theme con bordes de 24px
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceCard,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(
            color: AppColors.border,
            width: 1.0,
          ),
        ),
      ),

      // TextButton Theme (Cancelar: sin borde ni fondo, texto blanco/muted negrita)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),

      // Estilo de texto general
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
