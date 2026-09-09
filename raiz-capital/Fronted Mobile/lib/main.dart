import 'package:flutter/material.dart';
import 'login_screen.dart';
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
      home: const LoginScreen(),
    );
  }
}
