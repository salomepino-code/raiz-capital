import 'package:flutter/material.dart';
import 'modelo_propiedad.dart';
import 'tema_app.dart';

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

  @override
  Widget build(BuildContext context) {
    final p = widget.propiedad;
    final temaDeTexto = Theme.of(context).textTheme;

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
          if (p.cantidadFotos > 1) ...[
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
              style: temaDeTexto.labelSmall?.copyWith(color: ColoresApp.azulNoche, fontSize: 11),
            ),
          ),
          const SizedBox(height: 8),
          Text(p.titulo, style: temaDeTexto.headlineSmall),
          const SizedBox(height: 2),
          Text(p.ubicacion, style: temaDeTexto.bodyMedium),
          const SizedBox(height: 20),

          // ===== Caja de specs (esquina superior derecha del boceto) =====
          _Caja(
            child: Wrap(
              spacing: 18,
              runSpacing: 10,
              children: [
                if (p.recamaras > 0) _EspecItem(texto: '${p.recamaras} habitaciones'),
                if (p.banos > 0) _EspecItem(texto: '${p.banos} baños'),
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
                Text('Descripción', style: temaDeTexto.headlineSmall?.copyWith(fontSize: 17)),
                const SizedBox(height: 8),
                Text(p.descripcion, style: temaDeTexto.bodyMedium),
                const SizedBox(height: 16),
                Text(
                  'Características',
                  style: temaDeTexto.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                ...p.caracteristicas.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('•  ', style: TextStyle(color: ColoresApp.dorado)),
                        Expanded(child: Text(c, style: temaDeTexto.bodyMedium)),
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
                Text('Ubicación', style: temaDeTexto.headlineSmall?.copyWith(fontSize: 17)),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    // aqui va la conexion con la base de datos: por ahora
                    // p.mapsUrl es un link genérico; cuando exista el backend
                    // vendrá uno específico por propiedad. Falta agregar el
                    // paquete url_launcher al pubspec.yaml para poder abrir
                    // este link (ver nota debajo del código).
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Ver en Google Maps'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ===== Contacto =====
          ElevatedButton(
            onPressed: () {
              // aqui va la conexion con la base de datos: el número real
              // del vendedor de ESTA propiedad (RF05). También requiere
              // url_launcher para abrir WhatsApp.
            },
            child: const Text('Consultar por WhatsApp'),
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
            itemCount: p.cantidadFotos,
            onPageChanged: (i) => setState(() => _fotoActual = i),
            itemBuilder: (context, index) {
              // Se repite el mismo degradado las veces que indique
              // cantidadFotos, solo para probar que el carrusel funciona
              // sin tener fotos reales todavía. El número "Foto X de N"
              // es nada más una ayuda visual temporal para confirmar que
              // sí estás cambiando de página al deslizar/tocar flechas.
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(TemaApp.radio),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ColoresApp.azulNoche,
                      ColoresApp.azulNocheClaro,
                      ColoresApp.vino,
                    ],
                  ),
                ),
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Foto ${index + 1} de ${p.cantidadFotos}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              );
            },
          ),
        ),
        if (p.cantidadFotos > 1) ...[
          Positioned(
            left: 8,
            child: _BotonFlecha(
              icono: Icons.chevron_left,
              onTap: () => _irAFoto((_fotoActual - 1 + p.cantidadFotos) % p.cantidadFotos),
            ),
          ),
          Positioned(
            right: 8,
            child: _BotonFlecha(
              icono: Icons.chevron_right,
              onTap: () => _irAFoto((_fotoActual + 1) % p.cantidadFotos),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMiniaturas(Propiedad p) {
    return Row(
      children: List.generate(p.cantidadFotos, (i) {
        final activa = i == _fotoActual;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => _irAFoto(i),
            child: Container(
              width: 48,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: activa ? ColoresApp.vino : Colors.transparent,
                  width: 2,
                ),
                gradient: const LinearGradient(
                  colors: [ColoresApp.azulNoche, ColoresApp.vino],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _BotonFlecha extends StatelessWidget {
  const _BotonFlecha({required this.icono, required this.onTap});

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
        child: Icon(icono, color: ColoresApp.azulNoche, size: 20),
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
  const _EspecItem({required this.texto, this.destacado = false});

  final String texto;
  final bool destacado;

  @override
  Widget build(BuildContext context) {
    final temaDeTexto = Theme.of(context).textTheme;
    return Text(
      texto,
      style: temaDeTexto.bodyLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: destacado ? ColoresApp.vino : ColoresApp.tinta,
      ),
    );
  }
}
