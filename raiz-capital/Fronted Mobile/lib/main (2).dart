import 'package:flutter/material.dart';
import 'pantalla_catalogo.dart';
import 'tema_app.dart';

void main() {
  runApp(const AplicacionRaizCapital());
}

class AplicacionRaizCapital extends StatelessWidget {
  const AplicacionRaizCapital({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Raíz Capital',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.tema,
      // El catálogo es la puerta de entrada: cualquier visitante puede
      // ver propiedades sin cuenta. El login se alcanza desde ahí
      // (ícono de perfil), no es la pantalla inicial.
      home: const PantallaCatalogo(),
    );
  }
}
