import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'modelo_propiedad.dart';
import 'modelo_zona.dart';
import 'servicio_imagenes.dart';
import 'servicio_propiedades.dart';
import 'servicio_zonas.dart';
import 'sesion_usuario.dart';
import 'tema_app.dart';

/// Formulario para publicar una propiedad nueva (vendedor o administrador)
/// o, si se le pasa [propiedadAEditar], para editar una existente (solo
/// administrador; ver pantalla_detalle_propiedad.dart).
///
/// Regresa true con Navigator.pop cuando se guardó, para que quien lo
/// abrió recargue sus datos.
class PantallaPublicarPropiedad extends StatefulWidget {
  const PantallaPublicarPropiedad({super.key, this.propiedadAEditar});

  final Propiedad? propiedadAEditar;

  @override
  State<PantallaPublicarPropiedad> createState() => _EstadoPantallaPublicarPropiedad();
}

class _EstadoPantallaPublicarPropiedad extends State<PantallaPublicarPropiedad> {
  static const List<String> _tipos = ['CASA', 'DEPARTAMENTO', 'TERRENO', 'LOCAL'];
  static const List<String> _operaciones = ['VENTA', 'RENTA'];

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
  final _servicioImagenes = ServicioImagenes();

  String _tipo = 'CASA';
  String _operacion = 'VENTA';
  int? _idZonaSeleccionada;

  // Fotos que la propiedad ya tiene guardadas (links), solo en modo edición.
  // Se pueden quitar; las nuevas se agregan abajo en _fotosSeleccionadas.
  List<String> _imagenesExistentes = [];

  List<XFile> _fotosSeleccionadas = [];
  bool _subiendoFotos = false;
  int _fotosSubidas = 0;

  List<Zona> _zonas = [];
  bool _cargandoZonas = true;
  String? _errorZonas;
  bool _guardando = false;
  String? _errorGuardar;

  bool get _modoEdicion => widget.propiedadAEditar != null;

  @override
  void initState() {
    super.initState();
    final propiedad = widget.propiedadAEditar;
    if (propiedad != null) _precargar(propiedad);
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

  /// Llena el formulario con los datos de la propiedad que se va a editar.
  void _precargar(Propiedad p) {
    _controladorTitulo.text = p.titulo;
    _controladorDescripcion.text = p.descripcion;
    _controladorPrecio.text = _numeroSinDecimales(p.precioNumerico);
    _controladorRecamaras.text = '${p.recamaras}';
    _controladorBanos.text = '${p.banos}';
    _controladorSuperficie.text = _numeroSinDecimales(p.superficieM2 ?? p.metros);
    _controladorCalle.text = p.calle ?? '';
    _controladorColonia.text = p.colonia ?? '';
    _controladorUbicacionMaps.text = p.ubicacionMapsOriginal ?? '';
    _controladorCaracteristicas.text = p.caracteristicas.join(', ');
    if (_tipos.contains(p.tipo)) _tipo = p.tipo;
    if (_operaciones.contains(p.operacion)) _operacion = p.operacion;
    _imagenesExistentes = [...p.imagenesUrls];
  }

  /// 3999000.0 -> "3999000" (para que el campo no muestre un ".0" de sobra).
  String _numeroSinDecimales(num n) =>
      n == n.truncate() ? n.truncate().toString() : n.toString();

  Future<void> _cargarZonas() async {
    setState(() {
      _cargandoZonas = true;
      _errorZonas = null;
    });
    try {
      final zonas = await _servicioZonas.obtenerZonas();
      setState(() {
        _zonas = zonas;
        // Al editar se selecciona la zona que ya tenía la propiedad (si
        // sigue existiendo); al publicar, la primera de la lista.
        final idOriginal = widget.propiedadAEditar?.idZona;
        final existe = idOriginal != null && zonas.any((z) => z.id == idOriginal);
        _idZonaSeleccionada = existe ? idOriginal : (zonas.isNotEmpty ? zonas.first.id : null);
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

  Future<void> _elegirFotos() async {
    final fotos = await _servicioImagenes.seleccionarFotos();
    if (fotos.isEmpty) return;
    setState(() => _fotosSeleccionadas = [..._fotosSeleccionadas, ...fotos]);
  }

  void _quitarFoto(int indice) {
    setState(() => _fotosSeleccionadas = [..._fotosSeleccionadas]..removeAt(indice));
  }

  void _quitarFotoExistente(int indice) {
    setState(() => _imagenesExistentes = [..._imagenesExistentes]..removeAt(indice));
  }

  Future<void> _guardar() async {
    setState(() => _errorGuardar = null);

    if (!_llaveFormulario.currentState!.validate()) return;
    if (_idZonaSeleccionada == null) {
      setState(() => _errorGuardar = 'Selecciona una zona.');
      return;
    }

    final usuario = SesionUsuario.actual;
    if (usuario == null) {
      setState(() => _errorGuardar = 'Tu sesión expiró, inicia sesión de nuevo.');
      return;
    }

    setState(() => _guardando = true);

    try {
      final caracteristicas = _controladorCaracteristicas.text
          .split(',')
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .toList();

      // Sube las fotos nuevas directo a Cloudinary antes de guardar la
      // propiedad, para mandar los links ya listos.
      List<String> urlsNuevas = [];
      if (_fotosSeleccionadas.isNotEmpty) {
        setState(() {
          _subiendoFotos = true;
          _fotosSubidas = 0;
        });
        urlsNuevas = await _servicioImagenes.subirFotos(
          _fotosSeleccionadas,
          onProgreso: (subidas, total) {
            if (mounted) setState(() => _fotosSubidas = subidas);
          },
        );
        if (mounted) setState(() => _subiendoFotos = false);
      }

      // Las que ya tenía (y no se quitaron) van primero, luego las nuevas.
      final imagenesUrls = [..._imagenesExistentes, ...urlsNuevas];

      final calle = _controladorCalle.text.trim();
      final colonia = _controladorColonia.text.trim();
      final ubicacionMaps = _controladorUbicacionMaps.text.trim();

      final propiedadAEditar = widget.propiedadAEditar;
      if (propiedadAEditar != null) {
        final id = propiedadAEditar.id;
        if (id == null) {
          throw Exception('La propiedad no tiene id, no se puede editar.');
        }
        await _servicioPropiedades.actualizarPropiedad(
          id: id,
          idAdmin: usuario.id,
          idZona: _idZonaSeleccionada!,
          titulo: _controladorTitulo.text.trim(),
          descripcion: _controladorDescripcion.text.trim(),
          precio: num.parse(_controladorPrecio.text.trim()),
          tipo: _tipo,
          operacion: _operacion,
          recamaras: int.parse(_controladorRecamaras.text.trim()),
          banos: int.parse(_controladorBanos.text.trim()),
          superficieM2: num.parse(_controladorSuperficie.text.trim()),
          calle: calle.isEmpty ? null : calle,
          colonia: colonia.isEmpty ? null : colonia,
          ubicacionMaps: ubicacionMaps.isEmpty ? null : ubicacionMaps,
          caracteristicas: caracteristicas,
          imagenesUrls: imagenesUrls,
        );
      } else {
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
          calle: calle.isEmpty ? null : calle,
          colonia: colonia.isEmpty ? null : colonia,
          ubicacionMaps: ubicacionMaps.isEmpty ? null : ubicacionMaps,
          caracteristicas: caracteristicas,
          imagenesUrls: imagenesUrls,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(true); // true = se guardó, para que el catálogo recargue
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorGuardar = _modoEdicion
            ? 'No se pudieron guardar los cambios. Intenta de nuevo.'
            : 'No se pudo publicar la propiedad. Intenta de nuevo.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
          _subiendoFotos = false;
        });
      }
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
        title: Text(_modoEdicion ? 'Editar propiedad' : 'Publicar propiedad'),
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
                        opciones: _tipos,
                        onChanged: (v) => setState(() => _tipo = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _campoDropdown(
                        etiqueta: 'Operación',
                        valor: _operacion,
                        opciones: _operaciones,
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
                const SizedBox(height: 2),
                Text(
                  'En Google Maps: busca la dirección → Compartir → Copiar vínculo',
                  style: temaDeTexto.bodyMedium?.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _controladorUbicacionMaps,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(hintText: 'https://maps.app.goo.gl/...'),
                  validator: (valor) {
                    final texto = (valor ?? '').trim();
                    if (texto.isEmpty) return null; // es opcional
                    final uri = Uri.tryParse(texto);
                    final esWeb = uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
                    return esWeb ? null : 'Pega el link completo (empieza con https://)';
                  },
                ),
                const SizedBox(height: 16),

                Text('Características (separadas por coma)', style: temaDeTexto.bodyMedium),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _controladorCaracteristicas,
                  decoration: const InputDecoration(hintText: 'alberca, jardín, estacionamiento'),
                ),
                const SizedBox(height: 16),

                Text('Fotos', style: temaDeTexto.bodyMedium),
                const SizedBox(height: 6),
                _buildSelectorFotos(),
                const SizedBox(height: 24),

                if (_errorGuardar != null) ...[
                  Text(
                    _errorGuardar!,
                    style: temaDeTexto.bodyMedium?.copyWith(color: ColoresApp.error),
                  ),
                  const SizedBox(height: 12),
                ],

                if (_subiendoFotos) ...[
                  Text(
                    'Subiendo fotos ($_fotosSubidas de ${_fotosSeleccionadas.length})...',
                    style: temaDeTexto.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                ],
                ElevatedButton(
                  onPressed: _guardando ? null : _guardar,
                  child: _guardando
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_modoEdicion ? 'Guardar cambios' : 'Publicar propiedad'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectorFotos() {
    final hayFotos = _imagenesExistentes.isNotEmpty || _fotosSeleccionadas.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hayFotos)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < _imagenesExistentes.length; i++)
                _MiniaturaUrl(
                  url: _imagenesExistentes[i],
                  onQuitar: () => _quitarFotoExistente(i),
                ),
              for (var i = 0; i < _fotosSeleccionadas.length; i++)
                _MiniaturaFoto(foto: _fotosSeleccionadas[i], onQuitar: () => _quitarFoto(i)),
            ],
          ),
        if (hayFotos) const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _subiendoFotos ? null : _elegirFotos,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: Text(hayFotos ? 'Agregar más fotos' : 'Agregar fotos'),
        ),
      ],
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

/// Miniatura de una foto que la propiedad YA tiene guardada (un link), con
/// botón para quitarla. Solo aparece en modo edición.
class _MiniaturaUrl extends StatelessWidget {
  const _MiniaturaUrl({required this.url, required this.onQuitar});

  final String url;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            url,
            width: 72,
            height: 72,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 72,
                height: 72,
                color: ColoresApp.azulNoche,
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              );
            },
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onQuitar,
            child: Container(
              decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
              padding: const EdgeInsets.all(2),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

/// Miniatura de una foto elegida de la galería, con botón para quitarla
/// antes de guardar.
class _MiniaturaFoto extends StatelessWidget {
  const _MiniaturaFoto({required this.foto, required this.onQuitar});

  final XFile foto;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: FutureBuilder<Uint8List>(
            future: foto.readAsBytes(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  width: 72,
                  height: 72,
                  color: ColoresApp.tarjeta,
                );
              }
              return Image.memory(snapshot.data!, width: 72, height: 72, fit: BoxFit.cover);
            },
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onQuitar,
            child: Container(
              decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
              padding: const EdgeInsets.all(2),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}