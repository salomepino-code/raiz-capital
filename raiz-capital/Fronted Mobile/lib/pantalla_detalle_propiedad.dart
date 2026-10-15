import 'package:flutter/material.dart';
import 'modelo_propiedad.dart';
import 'tema_app.dart';
import 'package:url_launcher/url_launcher.dart';

/// Ficha de detalle de una propiedad (caso de uso "Consultar propiedad").
/// Se navega aquí al tocar una tarjeta del catálogo.
///
/// Estructura calcada del boceto: carrusel de fotos con flechas arriba,
/// specs (habitaciones/baños/m²/precio) a un lado, descripción y
/// características abajo, y ubicación al final.
class PantallaDetallePropiedad extends StatefulWidget {
  const PantallaDetallePropiedad({super.key, required this.propiedad});

  final Propiedad propiedad;

  @override
  State<PantallaDetallePropiedad> createState() => _EstadoPantallaDetallePropiedad();
}

class _EstadoPantallaDetallePropiedad extends State<PantallaDetallePropiedad> {
  late final PageController _controladorCarrusel;
  int _fotoActual = 0;

  @override
  void initState() {
    super.initState();
    _controladorCarrusel = PageController();
  }

  @override
  void dispose() {
    _controladorCarrusel.dispose();
    super.dispose();
  }

  void _irAFoto(int indice) {
    _controladorCarrusel.animateToPage(
      indice,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  /// Abre un link fuera de la app: en Chrome se abre en una pestaña nueva
  /// y en un celular abre la app de Maps/WhatsApp si está instalada.
  Future<void> _abrirEnlace(String url) async {
    var abierto = false;
    try {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        abierto = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      abierto = false;
    }

    if (!abierto && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace.')),
      );
    }
  }

    /// Arma el link de WhatsApp (wa.me) con el teléfono del vendedor de esta
  /// propiedad y un mensaje ya escrito. Devuelve null si no hay teléfono.
  String? _linkWhatsApp(Propiedad p) {
    final telefono = p.telefonoVendedor;
    if (telefono == null) return null;

    var numero = telefono.replaceAll(RegExp(r'\D'), ''); // solo dígitos
    if (numero.isEmpty) return null;
    // Números de 10 dígitos (ej. 6641234567): se asume México (+52).
    if (numero.length == 10) numero = '52$numero';

    final mensaje =
        'Hola, me interesa la propiedad "${p.titulo}" (${p.precio}). ¿Sigue disponible?';
    return 'https://wa.me/$numero?text=${Uri.encodeComponent(mensaje)}';
  }

  /// El mapper usa 'https://maps.google.com' como valor por defecto cuando
  /// la propiedad no trae link propio; eso no ubica la propiedad, así que
  /// se trata como "sin link". Si cambiaste ese valor en
  /// servicio_propiedades.dart, ajusta esta comparación.
  bool _tieneLinkDeMapa(Propiedad p) {
    final link = p.mapsUrl.trim();
    return link.isNotEmpty && link != 'https://maps.google.com';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.propiedad;
    final temaDeTexto = Theme.of(context).textTheme;
    final linkWhatsApp = _linkWhatsApp(p);

    return Scaffold(
      backgroundColor: ColoresApp.crema,
      appBar: AppBar(
        backgroundColor: ColoresApp.crema,
        elevation: 0,
        foregroundColor: ColoresApp.azulNoche,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          _buildCarrusel(p),
          if (p.imagenesUrls.length > 1) ...[
            const SizedBox(height: 10),
            _buildMiniaturas(p),
          ],
          const SizedBox(height: 20),

          // ===== Encabezado =====
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: ColoresApp.borde),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              p.operacion,
              style: temaDeTexto.labelSmall?.copyWith(
                color: ColoresApp.azulNoche,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(p.titulo, style: temaDeTexto.headlineSmall),
          const SizedBox(height: 2),
          Text(p.ubicacion, style: temaDeTexto.bodyMedium),
          const SizedBox(height: 20),

          // ===== Caja de specs =====
          _Caja(
            child: Wrap(
              spacing: 18,
              runSpacing: 10,
              children: [
                if (p.recamaras > 0)
                  _EspecItem(texto: '${p.recamaras} habitaciones'),
                if (p.banos > 0)
                  _EspecItem(texto: '${p.banos} baños'),
                _EspecItem(texto: '${p.metros} m²'),
                _EspecItem(texto: p.precio, destacado: true),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ===== Descripción y características =====
          _Caja(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Descripción',
                  style: temaDeTexto.headlineSmall?.copyWith(fontSize: 17),
                ),
                const SizedBox(height: 8),
                Text(p.descripcion, style: temaDeTexto.bodyMedium),
                const SizedBox(height: 16),
                Text(
                  'Características',
                  style: temaDeTexto.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                ...p.caracteristicas.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '•  ',
                          style: TextStyle(color: ColoresApp.dorado),
                        ),
                        Expanded(
                          child: Text(c, style: temaDeTexto.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

                    // ===== Ubicación =====
          _Caja(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ubicación',
                  style: temaDeTexto.headlineSmall?.copyWith(fontSize: 17),
                ),
                const SizedBox(height: 10),
                if (_tieneLinkDeMapa(p))
                  OutlinedButton.icon(
                    onPressed: () => _abrirEnlace(p.mapsUrl),
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Ver en Google Maps'),
                  )
                else
                  Text(
                    'Esta propiedad todavía no tiene ubicación en el mapa.',
                    style: temaDeTexto.bodyMedium,
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // ===== Contacto =====
          if (linkWhatsApp != null)
            ElevatedButton(
              onPressed: () => _abrirEnlace(linkWhatsApp),
              child: const Text('Consultar por WhatsApp'),
            )
          else
            Text(
              'Esta propiedad todavía no tiene un número de contacto registrado.',
              style: temaDeTexto.bodyMedium,
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildCarrusel(Propiedad p) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _controladorCarrusel,
            itemCount: p.imagenesUrls.length,
            onPageChanged: (i) => setState(() => _fotoActual = i),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(TemaApp.radio),
                child: Image.network(
                  p.imagenesUrls[index],
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
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
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white,
                        size: 40,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;

                    return Container(
                      color: ColoresApp.tarjeta,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    );
                  },
                ),
              );
            },
          ),
        ),
        if (p.imagenesUrls.length > 1) ...[
          Positioned(
            left: 8,
            child: _BotonFlecha(
              icono: Icons.chevron_left,
              onTap: () => _irAFoto(
                (_fotoActual - 1 + p.imagenesUrls.length) %
                    p.imagenesUrls.length,
              ),
            ),
          ),
          Positioned(
            right: 8,
            child: _BotonFlecha(
              icono: Icons.chevron_right,
              onTap: () => _irAFoto(
                (_fotoActual + 1) % p.imagenesUrls.length,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMiniaturas(Propiedad p) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: List.generate(p.imagenesUrls.length, (i) {
          final activa = i == _fotoActual;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _irAFoto(i),
              child: Container(
                width: 64,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: activa
                        ? ColoresApp.vino
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  p.imagenesUrls[i],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
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
            ),
          );
        }),
      ),
    );
  }
}

class _BotonFlecha extends StatelessWidget {
  const _BotonFlecha({
    required this.icono,
    required this.onTap,
  });

  final IconData icono;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icono,
          color: ColoresApp.azulNoche,
          size: 20,
        ),
      ),
    );
  }
}

class _Caja extends StatelessWidget {
  const _Caja({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ColoresApp.tarjeta,
        borderRadius: BorderRadius.circular(TemaApp.radio),
        border: Border.all(color: ColoresApp.borde),
      ),
      child: child,
    );
  }
}

class _EspecItem extends StatelessWidget {
  const _EspecItem({
    required this.texto,
    this.destacado = false,
  });

  final String texto;
  final bool destacado;

  @override
  Widget build(BuildContext context) {
    final temaDeTexto = Theme.of(context).textTheme;

    return Text(
      texto,
      style: temaDeTexto.bodyLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: destacado
            ? ColoresApp.vino
            : ColoresApp.tinta,
      ),
    );
  }
}