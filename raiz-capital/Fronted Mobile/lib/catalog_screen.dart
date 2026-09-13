import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'app_theme.dart';

/// Pantalla de catálogo (RF04 - Filtros de búsqueda / caso de uso
/// "Buscar propiedad"). Es la pantalla de entrada de la app: cualquier
/// visitante puede ver propiedades y contactar por WhatsApp sin
/// necesidad de iniciar sesión (según el documento de validación de
/// requerimientos, el registro/login no es necesario para compradores).
///
/// El ícono de perfil en la esquina superior derecha lleva al login,
/// que ahora es una pantalla secundaria y opcional — solo la usa quien
/// necesita entrar como administrador para gestionar el inventario.
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: Text('Raíz Capital', style: textTheme.headlineSmall),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.navy),
            tooltip: 'Iniciar sesión',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Encuentra tu próxima propiedad', style: textTheme.displayLarge),
            const SizedBox(height: 20),

            // TODO: reemplazar por los filtros reales (zona, precio,
            // tipo de operación) consumiendo el mismo endpoint que la web.
            _FilterBarPlaceholder(),

            const SizedBox(height: 24),
            Text('Propiedades destacadas', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),

            // aqui va la conexion con el backend Java
            // Endpoint esperado: GET /api/propiedades  (con filtros como query params)
            // Por ahora se muestra una lista vacía de ejemplo.
            Expanded(
              child: Center(
                child: Text(
                  'Aún no hay propiedades cargadas.\n(esto se llenará con la respuesta de la API)',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBarPlaceholder extends StatelessWidget {
  const _FilterBarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _FilterChipPlaceholder(label: 'Tipo de propiedad')),
        const SizedBox(width: 10),
        Expanded(child: _FilterChipPlaceholder(label: 'Operación')),
        const SizedBox(width: 10),
        Expanded(child: _FilterChipPlaceholder(label: 'Zona')),
      ],
    );
  }
}

class _FilterChipPlaceholder extends StatelessWidget {
  const _FilterChipPlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E0D8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
