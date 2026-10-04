import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'logo_raiz_capital.dart';
import 'modelo_propiedad.dart';
import 'pantalla_detalle_propiedad.dart';
import 'pantalla_inicio_sesion.dart';
import 'pantalla_publicar_propiedad.dart';
import 'servicio_propiedades.dart';
import 'sesion_usuario.dart';
import 'tema_app.dart';

/// Pantalla de catálogo — puerta de entrada de la app
/// Cualquier visitante puede ver esto sin cuenta.
/// El ícono de perfil lleva al login, que es secundario y opcional.
/// Estructura calcada del index.html de la web

const List<String> _tiposDisponibles = ['Todos', 'Casa', 'Departamento', 'Terreno', 'Local'];
const List<String> _operacionesDisponibles = ['Todas', 'Venta', 'Renta'];

// Mismos rangos que RANGOS_PRECIO en script.js (la web)
const Map<String, List<Map<String, String>>> _rangosPrecio = {
  'VENTA': [
    {'value': '2000000', 'label': 'Hasta \$2,000,000'},
    {'value': '4000000', 'label': 'Hasta \$4,000,000'},
    {'value': '6000000', 'label': 'Hasta \$6,000,000'},
    {'value': '8000000', 'label': 'Hasta \$8,000,000'},
    {'value': '10000000', 'label': 'Hasta \$10,000,000'},
    {'value': '15000000', 'label': 'Hasta \$15,000,000'},
  ],
  'RENTA': [
    {'value': '10000', 'label': 'Hasta \$10,000'},
    {'value': '15000', 'label': 'Hasta \$15,000'},
    {'value': '20000', 'label': 'Hasta \$20,000'},
    {'value': '25000', 'label': 'Hasta \$25,000'},
    {'value': '30000', 'label': 'Hasta \$30,000'},
    {'value': '40000', 'label': 'Hasta \$40,000'},
    {'value': '50000', 'label': 'Hasta \$50,000'},
  ],
};

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
            _TarjetaBusqueda(
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
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PantallaDetallePropiedad(propiedad: propiedad)),
              );
            },
          ),
          const SizedBox(height: 18),
        ],
      ],
    );
  }
}

/// Tarjeta de búsqueda con filtros reales, conectados al estado de la pantalla.
class _TarjetaBusqueda extends StatelessWidget {
  const _TarjetaBusqueda({
    required this.tipoSeleccionado,
    required this.operacionSeleccionada,
    required this.controladorZona,
    required this.precioMaxSeleccionado,
    required this.onTipoChanged,
    required this.onOperacionChanged,
    required this.onPrecioMaxChanged,
    required this.onBuscar,
  });

  final String tipoSeleccionado;
  final String operacionSeleccionada;
  final TextEditingController controladorZona;
  final String? precioMaxSeleccionado;
  final ValueChanged<String> onTipoChanged;
  final ValueChanged<String> onOperacionChanged;
  final ValueChanged<String?> onPrecioMaxChanged;
  final VoidCallback onBuscar;

  @override
  Widget build(BuildContext context) {
    final opcionesPrecio = _rangosPrecio[operacionSeleccionada.toUpperCase()] ?? [];

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
              Expanded(
                child: _CampoFiltroDropdown(
                  etiqueta: 'TIPO',
                  valor: tipoSeleccionado,
                  opciones: _tiposDisponibles,
                  onChanged: (v) => onTipoChanged(v ?? 'Todos'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CampoFiltroDropdown(
                  etiqueta: 'OPERACIÓN',
                  valor: operacionSeleccionada,
                  opciones: _operacionesDisponibles,
                  onChanged: (v) => onOperacionChanged(v ?? 'Todas'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _CampoFiltroTexto(
                  etiqueta: 'ZONA',
                  controlador: controladorZona,
                  placeholder: 'Buscar zona...',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CampoFiltroDropdown(
                  etiqueta: 'PRECIO MÁX.',
                  valor: precioMaxSeleccionado,
                  opciones: opcionesPrecio.map((r) => r['value']!).toList(),
                  etiquetasOpciones: {for (final r in opcionesPrecio) r['value']!: r['label']!},
                  valorMostrado: precioMaxSeleccionado == null
                      ? 'Sin límite'
                      : (opcionesPrecio.firstWhere((r) => r['value'] == precioMaxSeleccionado)['label']),
                  onChanged: onPrecioMaxChanged,
                  incluirOpcionVacia: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: onBuscar,
            child: const Text('Buscar propiedades'),
          ),
        ],
      ),
    );
  }
}

/// Campo de filtro tipo dropdown, con el mismo look que el diseño original
/// (_CampoFiltro), pero funcional.
class _CampoFiltroDropdown extends StatelessWidget {
  const _CampoFiltroDropdown({
    required this.etiqueta,
    required this.valor,
    required this.opciones,
    required this.onChanged,
    this.etiquetasOpciones,
    this.valorMostrado,
    this.incluirOpcionVacia = false,
  });

  final String etiqueta;
  final String? valor;
  final List<String> opciones;
  final ValueChanged<String?> onChanged;
  final Map<String, String>? etiquetasOpciones;
  final String? valorMostrado;
  final bool incluirOpcionVacia;

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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: ColoresApp.crema,
            borderRadius: BorderRadius.circular(TemaApp.radio),
            border: Border.all(color: ColoresApp.borde),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              isExpanded: true,
              value: valor,
              icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: ColoresApp.textoApagado),
              style: temaDeTexto.bodyMedium,
              items: [
                if (incluirOpcionVacia)
                  const DropdownMenuItem<String?>(value: null, child: Text('Sin límite')),
                ...opciones.map(
                  (o) => DropdownMenuItem<String?>(
                    value: o,
                    child: Text(
                      etiquetasOpciones != null ? etiquetasOpciones![o] ?? o : o,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

/// Campo de filtro de texto libre (usado para Zona), mismo look que el diseño original.
class _CampoFiltroTexto extends StatelessWidget {
  const _CampoFiltroTexto({
    required this.etiqueta,
    required this.controlador,
    required this.placeholder,
  });

  final String etiqueta;
  final TextEditingController controlador;
  final String placeholder;

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
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: ColoresApp.crema,
            borderRadius: BorderRadius.circular(TemaApp.radio),
            border: Border.all(color: ColoresApp.borde),
          ),
          child: TextField(
            controller: controlador,
            style: temaDeTexto.bodyMedium,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: placeholder,
              hintStyle: temaDeTexto.bodyMedium?.copyWith(color: ColoresApp.textoApagado),
            ),
          ),
        ),
      ],
    );
  }
}

/// Tarjeta de propiedad
class _TarjetaPropiedad extends StatelessWidget {
  const _TarjetaPropiedad({required this.propiedad, required this.onTap});

  final Propiedad propiedad;
  final VoidCallback onTap;

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