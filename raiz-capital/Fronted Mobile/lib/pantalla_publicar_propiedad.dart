import 'package:flutter/material.dart';
import 'modelo_zona.dart';
import 'servicio_propiedades.dart';
import 'servicio_zonas.dart';
import 'sesion_usuario.dart';
import 'tema_app.dart';

/// Formulario para que un vendedor (o administrador) publique una
/// propiedad nueva. Solo debe ser accesible si SesionUsuario.actual
/// tiene rol vendedor o administrador (ver pantalla_catalogo.dart).
class PantallaPublicarPropiedad extends StatefulWidget {
  const PantallaPublicarPropiedad({super.key});

  @override
  State<PantallaPublicarPropiedad> createState() => _EstadoPantallaPublicarPropiedad();
}

class _EstadoPantallaPublicarPropiedad extends State<PantallaPublicarPropiedad> {
  final _llaveFormulario = GlobalKey<FormState>();
  final _servicioPropiedades = ServicioPropiedades();
  final _servicioZonas = ServicioZonas();

  final _controladorTitulo = TextEditingController();
  final _controladorDescripcion = TextEditingController();
  final _controladorPrecio = TextEditingController();
  final _controladorRecamaras = TextEditingController();
  final _controladorBanos = TextEditingController();
  final _controladorSuperficie = TextEditingController();
  final _controladorCalle = TextEditingController();
  final _controladorColonia = TextEditingController();
  final _controladorUbicacionMaps = TextEditingController();
  final _controladorCaracteristicas = TextEditingController();

  String _tipo = 'CASA';
  String _operacion = 'VENTA';
  int? _idZonaSeleccionada;

  List<Zona> _zonas = [];
  bool _cargandoZonas = true;
  String? _errorZonas;
  bool _publicando = false;
  String? _errorPublicar;

  @override
  void initState() {
    super.initState();
    _cargarZonas();
  }

  @override
  void dispose() {
    _controladorTitulo.dispose();
    _controladorDescripcion.dispose();
    _controladorPrecio.dispose();
    _controladorRecamaras.dispose();
    _controladorBanos.dispose();
    _controladorSuperficie.dispose();
    _controladorCalle.dispose();
    _controladorColonia.dispose();
    _controladorUbicacionMaps.dispose();
    _controladorCaracteristicas.dispose();
    super.dispose();
  }

  Future<void> _cargarZonas() async {
    setState(() {
      _cargandoZonas = true;
      _errorZonas = null;
    });
    try {
      final zonas = await _servicioZonas.obtenerZonas();
      setState(() {
        _zonas = zonas;
        _idZonaSeleccionada = zonas.isNotEmpty ? zonas.first.id : null;
        _cargandoZonas = false;
      });
    } catch (e) {
      setState(() {
        _errorZonas = 'No se pudieron cargar las zonas.';
        _cargandoZonas = false;
      });
    }
  }

  String? _requerido(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Este campo es obligatorio';
    return null;
  }

  String? _requeridoNumerico(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Este campo es obligatorio';
    if (num.tryParse(valor.trim()) == null) return 'Ingresa solo números';
    return null;
  }

  Future<void> _publicar() async {
    setState(() => _errorPublicar = null);

    if (!_llaveFormulario.currentState!.validate()) return;
    if (_idZonaSeleccionada == null) {
      setState(() => _errorPublicar = 'Selecciona una zona.');
      return;
    }

    final usuario = SesionUsuario.actual;
    if (usuario == null) {
      setState(() => _errorPublicar = 'Tu sesión expiró, inicia sesión de nuevo.');
      return;
    }

    setState(() => _publicando = true);

    try {
      final caracteristicas = _controladorCaracteristicas.text
          .split(',')
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .toList();

      await _servicioPropiedades.publicarPropiedad(
        idVendedor: usuario.id,
        idZona: _idZonaSeleccionada!,
        titulo: _controladorTitulo.text.trim(),
        descripcion: _controladorDescripcion.text.trim(),
        precio: num.parse(_controladorPrecio.text.trim()),
        tipo: _tipo,
        operacion: _operacion,
        recamaras: int.parse(_controladorRecamaras.text.trim()),
        banos: int.parse(_controladorBanos.text.trim()),
        superficieM2: num.parse(_controladorSuperficie.text.trim()),
        calle: _controladorCalle.text.trim().isEmpty ? null : _controladorCalle.text.trim(),
        colonia: _controladorColonia.text.trim().isEmpty ? null : _controladorColonia.text.trim(),
        ubicacionMaps: _controladorUbicacionMaps.text.trim().isEmpty
            ? null
            : _controladorUbicacionMaps.text.trim(),
        caracteristicas: caracteristicas,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true); // true = se publicó, para que el catálogo recargue
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorPublicar = 'No se pudo publicar la propiedad. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _publicando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final temaDeTexto = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: ColoresApp.crema,
      appBar: AppBar(
        backgroundColor: ColoresApp.crema,
        elevation: 0,
        foregroundColor: ColoresApp.azulNoche,
        title: const Text('Publicar propiedad'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Form(
            key: _llaveFormulario,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Título', style: temaDeTexto.bodyMedium),
                const SizedBox(height: 6),
                TextFormField(controller: _controladorTitulo, validator: _requerido),
                const SizedBox(height: 16),

                Text('Descripción', style: temaDeTexto.bodyMedium),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _controladorDescripcion,
                  maxLines: 4,
                  validator: _requerido,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _campoDropdown(
                        etiqueta: 'Tipo',
                        valor: _tipo,
                        opciones: const ['CASA', 'DEPARTAMENTO', 'TERRENO', 'LOCAL'],
                        onChanged: (v) => setState(() => _tipo = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _campoDropdown(
                        etiqueta: 'Operación',
                        valor: _operacion,
                        opciones: const ['VENTA', 'RENTA'],
                        onChanged: (v) => setState(() => _operacion = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Text('Zona', style: temaDeTexto.bodyMedium),
                const SizedBox(height: 6),
                _buildSelectorZona(),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _campoTexto(
                        etiqueta: 'Precio',
                        controlador: _controladorPrecio,
                        teclado: TextInputType.number,
                        validator: _requeridoNumerico,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _campoTexto(
                        etiqueta: 'Superficie (m²)',
                        controlador: _controladorSuperficie,
                        teclado: TextInputType.number,
                        validator: _requeridoNumerico,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _campoTexto(
                        etiqueta: 'Recámaras',
                        controlador: _controladorRecamaras,
                        teclado: TextInputType.number,
                        validator: _requeridoNumerico,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _campoTexto(
                        etiqueta: 'Baños',
                        controlador: _controladorBanos,
                        teclado: TextInputType.number,
                        validator: _requeridoNumerico,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Text('Calle (opcional)', style: temaDeTexto.bodyMedium),
                const SizedBox(height: 6),
                TextFormField(controller: _controladorCalle),
                const SizedBox(height: 16),

                Text('Colonia (opcional)', style: temaDeTexto.bodyMedium),
                const SizedBox(height: 6),
                TextFormField(controller: _controladorColonia),
                const SizedBox(height: 16),

                Text('Link de Google Maps (opcional)', style: temaDeTexto.bodyMedium),
                const SizedBox(height: 6),
                TextFormField(controller: _controladorUbicacionMaps),
                const SizedBox(height: 16),

                Text('Características (separadas por coma)', style: temaDeTexto.bodyMedium),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _controladorCaracteristicas,
                  decoration: const InputDecoration(hintText: 'alberca, jardín, estacionamiento'),
                ),
                const SizedBox(height: 24),

                if (_errorPublicar != null) ...[
                  Text(
                    _errorPublicar!,
                    style: temaDeTexto.bodyMedium?.copyWith(color: ColoresApp.error),
                  ),
                  const SizedBox(height: 12),
                ],

                ElevatedButton(
                  onPressed: _publicando ? null : _publicar,
                  child: _publicando
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Publicar propiedad'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectorZona() {
    if (_cargandoZonas) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_errorZonas != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_errorZonas!, style: TextStyle(color: ColoresApp.error)),
          TextButton(onPressed: _cargarZonas, child: const Text('Reintentar')),
        ],
      );
    }
    if (_zonas.isEmpty) {
      return const Text('No hay zonas registradas todavía.');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: ColoresApp.tarjeta,
        borderRadius: BorderRadius.circular(TemaApp.radio),
        border: Border.all(color: ColoresApp.borde),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: _idZonaSeleccionada,
          items: _zonas
              .map((z) => DropdownMenuItem(value: z.id, child: Text('${z.nombreZona} (${z.ciudad})')))
              .toList(),
          onChanged: (v) => setState(() => _idZonaSeleccionada = v),
        ),
      ),
    );
  }

  Widget _campoTexto({
    required String etiqueta,
    required TextEditingController controlador,
    TextInputType? teclado,
    String? Function(String?)? validator,
  }) {
    final temaDeTexto = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta, style: temaDeTexto.bodyMedium),
        const SizedBox(height: 6),
        TextFormField(controller: controlador, keyboardType: teclado, validator: validator),
      ],
    );
  }

  Widget _campoDropdown({
    required String etiqueta,
    required String valor,
    required List<String> opciones,
    required ValueChanged<String?> onChanged,
  }) {
    final temaDeTexto = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta, style: temaDeTexto.bodyMedium),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: ColoresApp.tarjeta,
            borderRadius: BorderRadius.circular(TemaApp.radio),
            border: Border.all(color: ColoresApp.borde),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: valor,
              items: opciones.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
