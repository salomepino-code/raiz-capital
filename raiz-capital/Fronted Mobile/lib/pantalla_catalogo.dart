import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'logo_raiz_capital.dart';
import 'modelo_propiedad.dart';
import 'pantalla_detalle_propiedad.dart';
import 'pantalla_inicio_sesion.dart';
import 'servicio_propiedades.dart';
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
  late Future<List<Propiedad>> _futurePropiedades;

  @override
  void initState() {
    super.initState();
    _futurePropiedades = _servicioPropiedades.obtenerPropiedades();
  }

  Future<void> _recargar() async {
    setState(() {
      _futurePropiedades = _servicioPropiedades.obtenerPropiedades();
    });
    await _futurePropiedades;
  }

  /// Se llama al presionar "Buscar propiedades" en _TarjetaBusqueda.
  /// Manda los filtros como query params a GET /api/propiedades (RF04).
  void _aplicarFiltros({
    String? tipo,
    String? operacion,
    String? zona,
    double? precioMax,
  }) {
    setState(() {
      _futurePropiedades = _servicioPropiedades.obtenerPropiedades(
        tipo: tipo,
        operacion: operacion,
        zona: zona,
        precioMax: precioMax,
      );
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
      body: RefreshIndicator(
        onRefresh: _recargar,
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
            _TarjetaBusqueda(onBuscar: _aplicarFiltros),

            const SizedBox(height: 36),

            // ===== LISTADO =====
            Text('INVENTARIO ACTUAL', style: temaDeTexto.labelSmall),
            const SizedBox(height: 4),
            Text('Propiedades destacadas', style: temaDeTexto.headlineSmall),
            const SizedBox(height: 16),

            FutureBuilder<List<Propiedad>>(
              future: _futurePropiedades,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Text(
                          'No pudimos cargar las propiedades.',
                          style: temaDeTexto.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Verifica que el backend esté corriendo e intenta de nuevo.',
                          style: temaDeTexto.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: _recargar,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                final propiedades = snapshot.data ?? [];

                if (propiedades.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Todavía no hay propiedades publicadas.',
                      style: temaDeTexto.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Mostrando ${propiedades.length} propiedades',
                        style: temaDeTexto.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (final propiedad in propiedades) ...[
                      _TarjetaPropiedad(
                        propiedad: propiedad,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  PantallaDetallePropiedad(propiedad: propiedad),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta de búsqueda con filtros
/// Por ahora son placeholders visuales;
/// la lógica de filtrado real se conecta después
class _TarjetaBusqueda extends StatefulWidget {
  const _TarjetaBusqueda({required this.onBuscar});
  
  final void Function({
    String? tipo,
    String? operacion,
    String? zona,
    double? precioMax,
  }) onBuscar;
 
  @override
  State<_TarjetaBusqueda> createState() => _EstadoTarjetaBusqueda();
}
 
class _EstadoTarjetaBusqueda extends State<_TarjetaBusqueda> {
  // null = "Todos" / "Todas" (sin filtrar por ese campo).
  String? _tipoSeleccionado;
  String? _operacionSeleccionada;
 
  final _controladorZona = TextEditingController();
  final _controladorPrecioMax = TextEditingController();
 
  // Coinciden con el enum Tipo de Propiedad.java (en minúscula; el
  // backend normaliza mayúsculas/minúsculas).
  static const Map<String?, String> _opcionesTipo = {
    null: 'Todos',
    'casa': 'Casa',
    'departamento': 'Departamento',
    'terreno': 'Terreno',
    'local': 'Local',
  };
 
  static const Map<String?, String> _opcionesOperacion = {
    null: 'Todas',
    'venta': 'Venta',
    'renta': 'Renta',
  };
 
  @override
  void dispose() {
    _controladorZona.dispose();
    _controladorPrecioMax.dispose();
    super.dispose();
  }
 
  void _buscar() {
    final textoPrecio = _controladorPrecioMax.text.trim();
    widget.onBuscar(
      tipo: _tipoSeleccionado,
      operacion: _operacionSeleccionada,
      zona: _controladorZona.text.trim().isEmpty ? null : _controladorZona.text.trim(),
      precioMax: textoPrecio.isEmpty ? null : double.tryParse(textoPrecio),
    );
  }
  
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
              Expanded(
                child: _CampoFiltroDropdown(
                  etiqueta: 'TIPO',
                  valor: _tipoSeleccionado,
                  opciones: _opcionesTipo,
                  onChanged: (v) => setState(() => _tipoSeleccionado = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CampoFiltroDropdown(
                  etiqueta: 'OPERACIÓN',
                  valor: _operacionSeleccionada,
                  opciones: _opcionesOperacion,
                  onChanged: (v) => setState(() => _operacionSeleccionada = v),
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
                  controlador: _controladorZona,
                  pista: 'Buscar zona...',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CampoFiltroTexto(
                  etiqueta: 'PRECIO MÁX.',
                  controlador: _controladorPrecioMax,
                  pista: 'Sin límite',
                  teclado: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _buscar,
            child: const Text('Buscar propiedades'),
          ),
        ],
      ),
    );
  }
}
 
/// Caja con el mismo estilo visual de antes, pero con un dropdown real
/// adentro (tipo y operación son listas fijas, no cambian).
class _CampoFiltroDropdown extends StatelessWidget {
  const _CampoFiltroDropdown({
    required this.etiqueta,
    required this.valor,
    required this.opciones,
    required this.onChanged,
  });
 
  final String etiqueta;
  final String? valor;
  final Map<String?, String> opciones;
  final ValueChanged<String?> onChanged;
 
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
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: valor,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: ColoresApp.textoApagado),
              style: temaDeTexto.bodyMedium,
              dropdownColor: ColoresApp.tarjeta,
              items: opciones.entries
                  .map((e) => DropdownMenuItem<String?>(
                        value: e.key,
                        child: Text(e.value, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
 
/// Caja con el mismo estilo visual de antes, pero con un TextField real
/// adentro (zona es búsqueda libre por coincidencia parcial, igual que
/// el autocompletar de la web; precio máximo es numérico).
class _CampoFiltroTexto extends StatelessWidget {
  const _CampoFiltroTexto({
    required this.etiqueta,
    required this.controlador,
    required this.pista,
    this.teclado = TextInputType.text,
  });
 
  final String etiqueta;
  final TextEditingController controlador;
  final String pista;
  final TextInputType teclado;
 
  @override
  Widget build(BuildContext context) {
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
            keyboardType: teclado,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              isDense: true,
              filled: false,
              border: InputBorder.none,
              hintText: pista,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
                    Text(
                      p.precio,
                      style: temaDeTexto.headlineSmall?.copyWith(fontSize: 19),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.titulo,
                      style: temaDeTexto.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
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