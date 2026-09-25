import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'logo_raiz_capital.dart';
import 'pantalla_inicio_sesion.dart';
import 'tema_app.dart';

/// Pantalla de catálogo — puerta de entrada de la app 
/// Cualquier visitante puede ver esto sin cuenta.
/// El ícono de perfil lleva al login, que es secundario y opcional.
/// Estructura calcada del index.html de la web

class PantallaCatalogo extends StatelessWidget {
  const PantallaCatalogo({super.key});

  @override
  Widget build(BuildContext context) {
    final temaDeTexto = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColoresApp.crema,
        elevation: 0,
        titleSpacing: 20,
        title: const LogoRaizCapital(altura: 60),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: ColoresApp.azulNoche),
            tooltip: 'Iniciar sesión',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PantallaInicioSesion()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          // ===== HERO =====
          Text('BIENVENIDO A RAÍZ CAPITAL', style: temaDeTexto.labelSmall),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: temaDeTexto.displayLarge,
              children: [
                const TextSpan(text: 'Donde tu patrimonio crece seguro'),
                const TextSpan(text: '.'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Casas, departamentos, locales y terrenos en venta y renta.',
            style: temaDeTexto.bodyMedium,
          ),
          const SizedBox(height: 24),

          // ===== BUSCADOR / FILTROS =====
          const _TarjetaBusqueda(),

          const SizedBox(height: 36),

          // ===== LISTADO =====
          Text('INVENTARIO ACTUAL', style: temaDeTexto.labelSmall),
          const SizedBox(height: 4),
          Text('Propiedades destacadas', style: temaDeTexto.headlineSmall),
          const SizedBox(height: 4),
          // aqui va la conexion con el backend Java
          

          // TODO: reemplazar esta lista de ejemplo por las propiedades
          // reales que devuelva la API.
          const _TarjetaPropiedad(
            operacion: 'VENTA',
            precio: '\$2,450,000',
            titulo: 'Casa en Colonia Cacho',
            ubicacion: 'Tijuana, B.C.',
            recamaras: 3,
            banos: 2,
            metros: 180,
          ),
          const SizedBox(height: 18),
          const _TarjetaPropiedad(
            operacion: 'RENTA',
            precio: '\$18,500/mes',
            titulo: 'Departamento en Zona Río',
            ubicacion: 'Tijuana, B.C.',
            recamaras: 2,
            banos: 1,
            metros: 90,
          ),
          const SizedBox(height: 18),
          const _TarjetaPropiedad(
            operacion: 'VENTA',
            precio: '\$1,890,000',
            titulo: 'Casa en Playas de Tijuana',
            ubicacion: 'Tijuana, B.C.',
            recamaras: 3,
            banos: 2,
            metros: 150,
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de búsqueda con filtros 
/// Por ahora son placeholders visuales; 
/// la lógica de filtrado real se conecta después 
class _TarjetaBusqueda extends StatelessWidget {
  const _TarjetaBusqueda();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColoresApp.tarjeta,
        borderRadius: BorderRadius.circular(TemaApp.radio),
        border: Border.all(color: ColoresApp.borde),
        boxShadow: [
          BoxShadow(
            color: ColoresApp.azulNoche.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _CampoFiltro(etiqueta: 'TIPO', valor: 'Todos')),
              const SizedBox(width: 12),
              Expanded(child: _CampoFiltro(etiqueta: 'OPERACIÓN', valor: 'Todas')),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _CampoFiltro(etiqueta: 'ZONA', valor: 'Buscar zona...')),
              const SizedBox(width: 12),
              Expanded(child: _CampoFiltro(etiqueta: 'PRECIO MÁX.', valor: 'Sin límite')),
            ],
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () {
              // aqui va la logica de busqueda/filtrado (RF04)
            },
            child: const Text('Buscar propiedades'),
          ),
        ],
      ),
    );
  }
}

class _CampoFiltro extends StatelessWidget {
  const _CampoFiltro({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final temaDeTexto = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: ColoresApp.textoApagado,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: ColoresApp.crema,
            borderRadius: BorderRadius.circular(TemaApp.radio),
            border: Border.all(color: ColoresApp.borde),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(valor, style: temaDeTexto.bodyMedium, overflow: TextOverflow.ellipsis),
              ),
              const Icon(Icons.keyboard_arrow_down, size: 18, color: ColoresApp.textoApagado),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tarjeta de propiedad 
class _TarjetaPropiedad extends StatelessWidget {
  const _TarjetaPropiedad({
    required this.operacion,
    required this.precio,
    required this.titulo,
    required this.ubicacion,
    required this.recamaras,
    required this.banos,
    required this.metros,
  });

  final String operacion;
  final String precio;
  final String titulo;
  final String ubicacion;
  final int recamaras;
  final int banos;
  final int metros;

  @override
  Widget build(BuildContext context) {
    final temaDeTexto = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: ColoresApp.tarjeta,
        borderRadius: BorderRadius.circular(TemaApp.radio),
        border: Border.all(color: ColoresApp.borde),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // .property-media: degradado navy -> navy-light -> wine
          Stack(
            children: [
              Container(
                height: 150,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ColoresApp.azulNoche,
                      ColoresApp.azulNocheClaro,
                      ColoresApp.vino,
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    operacion,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: ColoresApp.azulNoche,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  precio,
                  style: temaDeTexto.headlineSmall?.copyWith(fontSize: 19),
                ),
                const SizedBox(height: 4),
                Text(
                  titulo,
                  style: temaDeTexto.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(ubicacion, style: temaDeTexto.bodyMedium),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: ColoresApp.borde)),
                  ),
                  child: Row(
                    children: [
                      _MetaItem(icono: Icons.bed_outlined, texto: '$recamaras rec'),
                      const SizedBox(width: 14),
                      _MetaItem(icono: Icons.bathtub_outlined, texto: '$banos baños'),
                      const SizedBox(width: 14),
                      _MetaItem(icono: Icons.square_foot, texto: '$metros m²'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 15, color: ColoresApp.textoApagado),
        const SizedBox(width: 4),
        Text(texto, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
