import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta de marca de Raíz Capital.
///
/// NOTA: estos valores son una aproximación al navy/vino/dor ado usado
/// en la web (css/style.css). Si tienes los hex exactos de las
/// variables :root de esa hoja de estilos, reemplázalos aquí para
/// que mobile y web luzcan idénticos.
class AppColors {
  static const Color navy = Color(0xFF152238); // fondo principal / textos fuertes
  static const Color navyLight = Color(0xFF243352); // superficies sobre navy
  static const Color wine = Color(0xFF6E1E30); // acento primario (botones, links activos)
  static const Color gold = Color(0xFFC9A24B); // acento secundario (detalles, iconos)
  static const Color cream = Color(0xFFF7F4EE); // fondo claro / tarjetas
  static const Color textMuted = Color(0xFF8892A6); // texto secundario sobre navy
  static const Color error = Color(0xFFD64545);
}

/// Tema global de la app. Se aplica una sola vez en main.dart.
class AppTheme {
  static ThemeData get theme {
    final baseTextTheme = TextTheme(
      // Fraunces: para títulos y momentos de marca (logo, encabezados grandes)
      displayLarge: GoogleFonts.fraunces(
        fontSize: 34,
        fontWeight: FontWeight.w600,
        color: AppColors.navy,
        height: 1.15,
      ),
      headlineSmall: GoogleFonts.fraunces(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.navy,
      ),
      // Inter: para todo el texto de interfaz (labels, inputs, botones, cuerpo)
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: AppColors.navy,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textMuted,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.wine,
        primary: AppColors.wine,
        secondary: AppColors.gold,
        surface: AppColors.cream,
        error: AppColors.error,
      ),
      textTheme: baseTextTheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E0D8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E0D8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.wine, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: GoogleFonts.inter(color: AppColors.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.wine,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.wine,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
