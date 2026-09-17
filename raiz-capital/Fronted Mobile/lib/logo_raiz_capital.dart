import 'package:flutter/material.dart';

/// Logo de Raíz Capital, reutilizable en cualquier pantalla
/// (AppBar del catálogo, encabezado del login, etc.).
class LogoRaizCapital extends StatelessWidget {
  const LogoRaizCapital({super.key, this.altura = 40});

  /// Altura de la imagen; el ancho se ajusta solo (fit: contain).
  final double altura;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logoSinFondo.JPG',
      height: altura,
      fit: BoxFit.contain,
    );
  }
}
