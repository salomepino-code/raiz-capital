import 'dart:convert';
import 'package:http/http.dart' as http;
import 'modelo_propiedad.dart';

/// URL base del backend. Cambia según dónde corras la app:
/// - Chrome (flutter run -d chrome): localhost funciona tal cual, no la toques.
/// - Emulador Android: cambia a 10.0.2.2
/// - Celular físico en la misma red WiFi: cambia a la IP de tu PC (ej. 192.168.1.X)
const String _urlBase = 'http://localhost:8080';

class ServicioPropiedades {
  /// Trae el catálogo completo desde GET /api/propiedades y lo convierte
  /// a la misma clase Propiedad que ya usa pantalla_catalogo.dart.
  Future<List<Propiedad>> obtenerPropiedades() async {
    final respuesta = await http.get(Uri.parse('$_urlBase/api/propiedades'));

    if (respuesta.statusCode != 200) {
      throw Exception(
        'No se pudieron cargar las propiedades (código ${respuesta.statusCode})',
      );
    }

    final List<dynamic> datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
    return datos.map((json) => _mapearPropiedad(json)).toList();
  }

  /// Publica una propiedad nueva (POST /api/propiedades). idVendedor es el
  /// id del usuario logueado (ver SesionUsuario); idZona viene del
  /// dropdown de zona en el formulario.
  Future<void> publicarPropiedad({
    required int idVendedor,
    required int idZona,
    required String titulo,
    required String descripcion,
    required num precio,
    required String tipo, // CASA, DEPARTAMENTO, TERRENO, LOCAL
    required String operacion, // VENTA, RENTA
    required int recamaras,
    required int banos,
    required num superficieM2,
    String? calle,
    String? colonia,
    String? ubicacionMaps,
    List<String> caracteristicas = const [],
    List<String> imagenesUrls = const [],
  }) async {
    final respuesta = await http.post(
      Uri.parse('$_urlBase/api/propiedades'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'idVendedor': idVendedor,
        'idZona': idZona,
        'titulo': titulo,
        'descripcion': descripcion,
        'precio': precio,
        'tipo': tipo,
        'operacion': operacion,
        'recamaras': recamaras,
        'banos': banos,
        'superficieM2': superficieM2,
        'calle': calle,
        'colonia': colonia,
        'ubicacionMaps': ubicacionMaps,
        'caracteristicas': caracteristicas,
        'imagenesUrls': imagenesUrls,
      }),
    );

    if (respuesta.statusCode != 200) {
      throw Exception('No se pudo publicar la propiedad (código ${respuesta.statusCode})');
    }
  }

  Propiedad _mapearPropiedad(Map<String, dynamic> json) {
    final String operacion = (json['operacion'] as String? ?? '').toUpperCase();
    final num precio = (json['precio'] as num?) ?? 0;
    final zona = json['zona'] as Map<String, dynamic>?;
    final String ciudad = zona?['ciudad'] as String? ?? '';
    final String nombreZona = zona?['nombreZona'] as String? ?? '';
    final List<dynamic> caracteristicasJson =
        json['caracteristicas'] as List<dynamic>? ?? [];
    final List<dynamic> imagenesJson = json['imagenes'] as List<dynamic>? ?? [];
    final List<String> imagenesUrls = imagenesJson
        .map((img) => (img as Map<String, dynamic>)['url'] as String? ?? '')
        .where((url) => url.isNotEmpty)
        .toList();

    return Propiedad(
      operacion: operacion,
      precio: _formatearPrecio(precio, operacion),
      precioNumerico: precio,
      titulo: json['titulo'] as String? ?? '',
      // La API solo da ciudad (Tijuana/Rosarito); ambas son B.C.
      ubicacion: ciudad.isNotEmpty ? '$ciudad, B.C.' : '',
      zonaNombre: nombreZona,
      tipo: (json['tipo'] as String? ?? '').toUpperCase(),
      recamaras: (json['recamaras'] as num?)?.toInt() ?? 0,
      banos: (json['banos'] as num?)?.toInt() ?? 0,
      metros: (json['superficieM2'] as num?)?.round() ?? 0,
      descripcion: json['descripcion'] as String? ?? '',
      caracteristicas: caracteristicasJson.map((c) => c.toString()).toList(),
      // Si la propiedad todavía no tiene fotos cargadas, mostramos 1
      // para que el carrusel no quede vacío (usa el degradado de respaldo).
      cantidadFotos: imagenesUrls.isNotEmpty ? imagenesUrls.length : 1,
      imagenesUrls: imagenesUrls,
      mapsUrl: json['ubicacionMaps'] as String? ?? 'https://maps.google.com',
    );
  }

  /// La API devuelve el precio como número (18500.00); aquí se arma el
  /// mismo formato de texto que ya usaba datos_ejemplo.dart (ej. "$18,500/mes").
  String _formatearPrecio(num precio, String operacion) {
    final String digitos = precio.truncate().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < digitos.length; i++) {
      final int posicionesDesdeElFinal = digitos.length - i;
      buffer.write(digitos[i]);
      if (posicionesDesdeElFinal > 1 && posicionesDesdeElFinal % 3 == 1) {
        buffer.write(',');
      }
    }

    final String formateado = '\$${buffer.toString()}';
    return operacion == 'RENTA' ? '$formateado/mes' : formateado;
  }
}