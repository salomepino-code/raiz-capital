import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'logo_raiz_capital.dart';
import 'modelo_propiedad.dart';
import 'pantalla_detalle_propiedad.dart';
import 'pantalla_inicio_sesion.dart';
import 'pantalla_publicar_propiedad.dart';
import 'servicio_propiedades.dart';
import 'sesion_usuario.dart';
import 'tarjeta_busqueda.dart';
import 'pantalla_gestionar_vendedores.dart';
import 'tema_app.dart';

/// Pantalla de catálogo — puerta de entrada de la app
/// Cualquier visitante puede ver esto sin cuenta.
/// El ícono de perfil lleva al login, que es secundario y opcional.
/// Estructura calcada del index.html de la web


class PantallaCatalogo extends StatefulWidget {
  const PantallaCatalogo({super.key});

  @override
  State<PantallaCatalogo> createState() => _PantallaCatalogoState();
}

class _PantallaCatalogoState extends State<PantallaCatalogo> {
  final ServicioPropiedades _servicioPropiedades = ServicioPropiedades();
  final TextEditingController _controladorZona = TextEditingController();

  bool _cargando = true;
  String? _error;
  List<Propiedad> _todas = [];
  List<Propiedad> _filtradas = [];

  String _tipoSeleccionado = 'Todos';
  String _operacionSeleccionada = 'Todas';
  String? _precioMaxSeleccionado; // guarda el 'value' del rango, no el label

  @override
  void initState() {
    super.initState();
    _cargarPropiedades();
  }

  @override
  void dispose() {
    _controladorZona.dispose();
    super.dispose();
  }

  Future<void> _cargarPropiedades() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final datos = await _servicioPropiedades.obtenerPropiedades();
      setState(() {
        _todas = datos;
        _filtradas = datos;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  void _aplicarFiltros() {
    final zonaBuscada = _controladorZona.text.trim().toLowerCase();
    final tipoFiltro = _tipoSeleccionado == 'Todos' ? null : _tipoSeleccionado.toUpperCase();
    final operacionFiltro =
        _operacionSeleccionada == 'Todas' ? null : _operacionSeleccionada.toUpperCase();
    final precioMax = _precioMaxSeleccionado != null ? num.tryParse(_precioMaxSeleccionado!) : null;

    setState(() {
      _filtradas = _todas.where((p) {
        if (tipoFiltro != null && p.tipo != tipoFiltro) return false;
        if (operacionFiltro != null && p.operacion != operacionFiltro) return false;
        if (zonaBuscada.isNotEmpty && !p.zonaNombre.toLowerCase().contains(zonaBuscada)) {
          return false;
        }
        if (precioMax != null && p.precioNumerico > precioMax) return false;
        return true;
      }).toList();
    });
  }

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
          if (SesionUsuario.haySesion &&
    SesionUsuario.actual!.esAdministrador)
  IconButton(
    tooltip: 'Gestionar vendedores',
    icon: const Icon(Icons.people_alt_outlined),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PantallaGestionarVendedores(),
        ),
      );
    },
  ),
          if (SesionUsuario.haySesion && SesionUsuario.actual!.puedePublicar)
            IconButton(
              icon: const Icon(Icons.add_home_outlined, color: ColoresApp.azulNoche),
              tooltip: 'Publicar propiedad',
              onPressed: () async {
                final sePublico = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const PantallaPublicarPropiedad()),
                );
                if (sePublico == true) {
                  _cargarPropiedades();
                }
              },
            ),
          IconButton(
            icon: Icon(
              SesionUsuario.haySesion ? Icons.person : Icons.person_outline,
              color: ColoresApp.azulNoche,
            ),
            tooltip: SesionUsuario.haySesion ? SesionUsuario.actual!.nombre : 'Iniciar sesión',
            onPressed: () async {
              if (SesionUsuario.haySesion) {
                setState(() => SesionUsuario.cerrarSesion());
                return;
              }
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PantallaInicioSesion()),
              );
              setState(() {}); // refresca el AppBar con el resultado del login
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarPropiedades,
        child: ListView(
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
            TarjetaBusqueda(
              tipoSeleccionado: _tipoSeleccionado,
              operacionSeleccionada: _operacionSeleccionada,
              controladorZona: _controladorZona,
              precioMaxSeleccionado: _precioMaxSeleccionado,
              onTipoChanged: (v) => setState(() => _tipoSeleccionado = v),
              onOperacionChanged: (v) => setState(() {
                _operacionSeleccionada = v;
                _precioMaxSeleccionado = null; // igual que actualizarRangosPrecio() en la web
              }),
              onPrecioMaxChanged: (v) => setState(() => _precioMaxSeleccionado = v),
              onBuscar: _aplicarFiltros,
            ),

            const SizedBox(height: 36),

            // ===== LISTADO =====
            Text('INVENTARIO ACTUAL', style: temaDeTexto.labelSmall),
            const SizedBox(height: 4),
            Text('Propiedades destacadas', style: temaDeTexto.headlineSmall),
            const SizedBox(height: 16),

            _buildContenidoListado(temaDeTexto),
          ],
        ),
      ),
    );
  }

  Widget _buildContenidoListado(TextTheme temaDeTexto) {
    if (_cargando) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Text('No pudimos cargar las propiedades.', style: temaDeTexto.bodyLarge, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text('Verifica que el backend esté corriendo e intenta de nuevo.',
                style: temaDeTexto.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            ElevatedButton(onPressed: _cargarPropiedades, child: const Text('Reintentar')),
          ],
        ),
      );
    }

    if (_filtradas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'No encontramos propiedades con esos filtros. Prueba ajustando el precio o la zona.',
          style: temaDeTexto.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Mostrando ${_filtradas.length} propiedades', style: temaDeTexto.bodyMedium),
        ),
        const SizedBox(height: 16),
        for (final propiedad in _filtradas) ...[
          _TarjetaPropiedad(
            propiedad: propiedad,
              onTap: () async {
              final huboCambios = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => PantallaDetallePropiedad(propiedad: propiedad)),
              );
              if (huboCambios == true && mounted) _cargarPropiedades();
            },
          ),
          const SizedBox(height: 18),
        ],
      ],
    );
  }
}

/// Tarjeta de propiedad
class _TarjetaPropiedad extends StatelessWidget {
  const _TarjetaPropiedad({required this.propiedad, required this.onTap});

  final Propiedad propiedad;
  final VoidCallback onTap;

  Widget _fondoDegradado() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColoresApp.azulNoche,
            Color(0xFF1D4E70),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final temaDeTexto = Theme.of(context).textTheme;
    final p = propiedad;

    return Material(
      color: ColoresApp.tarjeta,
      borderRadius: BorderRadius.circular(TemaApp.radio),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TemaApp.radio),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TemaApp.radio),
            border: Border.all(color: ColoresApp.borde),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  if (p.imagenesUrls.isNotEmpty)
                    Image.network(
                      p.imagenesUrls.first,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progreso) {
                        if (progreso == null) return child;
                        return Container(height: 150, color: ColoresApp.tarjeta);
                      },
                      errorBuilder: (context, error, stack) => _fondoDegradado(),
                    )
                  else
                    _fondoDegradado(),
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
                        p.operacion,
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
                    Text(p.precio, style: temaDeTexto.headlineSmall?.copyWith(fontSize: 19)),
                    const SizedBox(height: 4),
                    Text(p.titulo, style: temaDeTexto.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(p.ubicacion, style: temaDeTexto.bodyMedium),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: ColoresApp.borde)),
                      ),
                      child: Row(
                        children: [
                          _MetaItem(icono: Icons.bed_outlined, texto: '${p.recamaras} rec'),
                          const SizedBox(width: 14),
                          _MetaItem(icono: Icons.bathtub_outlined, texto: '${p.banos} baños'),
                          const SizedBox(width: 14),
                          _MetaItem(icono: Icons.square_foot, texto: '${p.metros} m²'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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