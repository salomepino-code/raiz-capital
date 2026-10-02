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
  /// 
  // Todos los filtros son opcionales (RF04): si no mandas ninguno, trae
  /// el catálogo completo. 'tipo' acepta 'casa'/'departamento'/'terreno'/
  /// 'local', 'operacion' acepta 'venta'/'renta' — en cualquier
  /// mayúscula/minúscula, el backend los normaliza.
  Future<List<Propiedad>> obtenerPropiedades({
    String? tipo,
    String? operacion,
    String? zona,
    double? precioMax,
  }) async {
    final Map<String, String> parametros = {};
    if (tipo != null && tipo.isNotEmpty) parametros['tipo'] = tipo;
    if (operacion != null && operacion.isNotEmpty) parametros['operacion'] = operacion;
    if (zona != null && zona.isNotEmpty) parametros['zona'] = zona;
    if (precioMax != null) parametros['precioMax'] = precioMax.toString();
 
    final uri = Uri.parse('$_urlBase/api/propiedades').replace(
      queryParameters: parametros.isEmpty ? null : parametros,
    );
    
    final respuesta = await http.get(uri);

    if (respuesta.statusCode != 200) {
      throw Exception(
        'No se pudieron cargar las propiedades (código ${respuesta.statusCode})',
      );
    }

    final List<dynamic> datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
    return datos.map((json) => _mapearPropiedad(json)).toList();
  }

  Propiedad _mapearPropiedad(Map<String, dynamic> json) {
    final String operacion = (json['operacion'] as String? ?? '').toUpperCase();
    final num precio = (json['precio'] as num?) ?? 0;
    final zona = json['zona'] as Map<String, dynamic>?;
    final String ciudad = zona?['ciudad'] as String? ?? '';
    final List<dynamic> caracteristicasJson =
        json['caracteristicas'] as List<dynamic>? ?? [];
    final List<dynamic> imagenesJson = json['imagenes'] as List<dynamic>? ?? [];

    return Propiedad(
      operacion: operacion,
      precio: _formatearPrecio(precio, operacion),
      titulo: json['titulo'] as String? ?? '',
      // La API solo da ciudad (Tijuana/Rosarito); ambas son B.C.
      ubicacion: ciudad.isNotEmpty ? '$ciudad, B.C.' : '',
      recamaras: (json['recamaras'] as num?)?.toInt() ?? 0,
      banos: (json['banos'] as num?)?.toInt() ?? 0,
      metros: (json['superficieM2'] as num?)?.round() ?? 0,
      descripcion: json['descripcion'] as String? ?? '',
      caracteristicas: caracteristicasJson.map((c) => c.toString()).toList(),
      // Si la propiedad todavía no tiene fotos cargadas, mostramos 1
      // para que el carrusel no quede vacío.
      cantidadFotos: imagenesJson.isNotEmpty ? imagenesJson.length : 1,
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
