import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta de marca de Raíz Capital.
///
/// Valores copiados EXACTOS de css/style.css (:root) de la web,
/// para que mobile y web luzcan idénticos.
class ColoresApp {
  static const Color azulNoche = Color(0xFF12263F); // --navy
  static const Color azulNocheClaro = Color(0xFF1D3A5F); // --navy-light
  static const Color vino = Color(0xFF8C2F39); // --wine
  static const Color vinoClaro = Color(0xFFA8434E); // --wine-light
  static const Color dorado = Color(0xFFB08D57); // --gold
  static const Color crema = Color(0xFFFAF8F4); // --cream (fondo)
  static const Color tarjeta = Color(0xFFFFFFFF); // --card
  static const Color tinta = Color(0xFF1A1A1A); // --ink (texto principal)
  static const Color textoApagado = Color(0xFF6B7280); // --muted
  static const Color borde = Color(0xFFE7E2D9); // --border
  static const Color error = Color(0xFFD64545);
}

/// Tema global de la app. Se aplica una sola vez en main.dart.
///
/// Radio de bordes de 4px en todo (botones, inputs, tarjetas), igual
/// que --radius: 4px en la web — nada de esquinas muy redondeadas.
class TemaApp {
  static const double radio = 4.0;

  static ThemeData get tema {
    final temaDeTexto = TextTheme(
      // Fraunces: para títulos (h1, h2, h3 en la web usan --navy)
      displayLarge: GoogleFonts.fraunces(
        fontSize: 34,
        fontWeight: FontWeight.w600,
        color: ColoresApp.azulNoche,
        height: 1.1,
      ),
      headlineSmall: GoogleFonts.fraunces(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: ColoresApp.azulNoche,
        height: 1.1,
      ),
      // Inter: cuerpo de texto (la web usa --ink para texto normal,
      // --muted para texto secundario como precios de zona, ubicaciones, etc.)
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: ColoresApp.tinta,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: ColoresApp.textoApagado,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      // Equivalente al ".eyebrow" de la web: mayúsculas, vino, letras separadas.
      labelSmall: GoogleFonts.inter(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: ColoresApp.vino,
        letterSpacing: 1.5,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: ColoresApp.crema,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ColoresApp.azulNoche,
        primary: ColoresApp.azulNoche, // .btn-primary es navy, no vino
        secondary: ColoresApp.vino, // acento: focus, hover, whatsapp
        tertiary: ColoresApp.dorado,
        surface: ColoresApp.crema,
        error: ColoresApp.error,
      ),
      textTheme: temaDeTexto,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColoresApp.tarjeta,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radio),
          borderSide: const BorderSide(color: ColoresApp.borde),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radio),
          borderSide: const BorderSide(color: ColoresApp.borde),
        ),
        // La web resalta el foco del input con --wine, no con --navy.
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radio),
          borderSide: const BorderSide(color: ColoresApp.vino, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radio),
          borderSide: const BorderSide(color: ColoresApp.error),
        ),
        labelStyle: GoogleFonts.inter(color: ColoresApp.textoApagado),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          // .btn-primary de la web: fondo navy, texto blanco.
          backgroundColor: ColoresApp.azulNoche,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radio),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          // Los links/acentos de la web usan --wine (hover del nav, focus, etc.)
          foregroundColor: ColoresApp.vino,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: ColoresApp.tarjeta,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radio),
          side: const BorderSide(color: ColoresApp.borde),
        ),
      ),
    );
  }
}
