import 'package:flutter/material.dart';

/// Logo de Raíz Capital reutilizable en cualquier pantalla

class LogoRaizCapital extends StatelessWidget {
  const LogoRaizCapital({super.key, this.altura = 40});

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
