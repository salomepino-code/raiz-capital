import 'dart:convert';
import 'package:http/http.dart' as http;
import 'modelo_zona.dart';

const String _urlBase = 'http://localhost:8080';

class ServicioZonas {
  Future<List<Zona>> obtenerZonas() async {
    final respuesta = await http.get(Uri.parse('$_urlBase/api/zonas'));
    if (respuesta.statusCode != 200) {
      throw Exception('No se pudieron cargar las zonas (código ${respuesta.statusCode})');
    }
    final List<dynamic> datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
    return datos.map((json) => Zona.desdeJson(json)).toList();
  }
}
