import 'package:flutter/material.dart';
import 'catalog_screen.dart';
import 'app_theme.dart';

void main() {
  runApp(const RaizCapitalApp());
}

class RaizCapitalApp extends StatelessWidget {
  const RaizCapitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Raíz Capital',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      // El catálogo es la puerta de entrada: cualquier visitante puede
      // ver propiedades sin cuenta. El login se alcanza desde ahí
      // (ícono de perfil), no es la pantalla inicial.
      home: const CatalogScreen(),
    );
  }
}