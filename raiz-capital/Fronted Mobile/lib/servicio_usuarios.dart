
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'modelo_usuario.dart';
import 'modelo_vendedor.dart';

const String _urlBase = 'http://localhost:8080';

class ServicioUsuarios {
  Future<Usuario?> iniciarSesion(
    String correo,
    String contrasena,
  ) async {
    final respuesta = await http.post(
      Uri.parse('$_urlBase/api/usuarios/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'correo': correo,
        'contrasena': contrasena,
      }),
    );

    if (respuesta.statusCode == 200) {
      return Usuario.desdeJson(
        jsonDecode(utf8.decode(respuesta.bodyBytes)),
      );
    }

    if (respuesta.statusCode == 401) {
      return null;
    }

    throw Exception(
      'Error al iniciar sesión (código ${respuesta.statusCode})',
    );
  }

  Future<Usuario> registrarComprador(
    String nombre,
    String correo,
    String contrasena,
  ) async {
    final respuesta = await http.post(
      Uri.parse('$_urlBase/api/usuarios/registro'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'correo': correo,
        'contrasena': contrasena,
      }),
    );

    if (respuesta.statusCode == 200) {
      return Usuario.desdeJson(
        jsonDecode(utf8.decode(respuesta.bodyBytes)),
      );
    }

    if (respuesta.statusCode == 409) {
      throw Exception('CORREO_DUPLICADO');
    }

    throw Exception(
      'Error al registrar usuario (código ${respuesta.statusCode})',
    );
  }

  static Future<List<Vendedor>> obtenerVendedores({
    required int idAdmin,
  }) async {
    final respuesta = await http.get(
      Uri.parse('$_urlBase/api/usuarios/vendedores'),
      headers: {
        'X-Usuario-Id': idAdmin.toString(),
      },
    );

    if (respuesta.statusCode == 200) {
      final List<dynamic> datos =
          jsonDecode(utf8.decode(respuesta.bodyBytes));

      return datos
          .map(
            (json) => Vendedor.desdeJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception(
      'Error al obtener vendedores: ${respuesta.body}',
    );
  }

  static Future<void> crearVendedor({
    required int idAdmin,
    required String nombre,
    required String correo,
    required String contrasena,
    required String telefono,
  }) async {
    final respuesta = await http.post(
      Uri.parse('$_urlBase/api/usuarios/vendedores'),
      headers: {
        'Content-Type': 'application/json',
        'X-Usuario-Id': idAdmin.toString(),
      },
      body: jsonEncode({
        'nombre': nombre,
        'correo': correo,
        'contrasena': contrasena,
        'telefono': telefono,
      }),
    );

    if (respuesta.statusCode != 200) {
      throw Exception(
        respuesta.body.isNotEmpty
            ? respuesta.body
            : 'Error al crear vendedor',
      );
    }
  }

  static Future<void> eliminarVendedor({
    required int idAdmin,
    required int id,
    int? reasignarA,
  }) async {
    final parametros = <String, String>{};

    if (reasignarA != null) {
      parametros['reasignarA'] = reasignarA.toString();
    }

    final uri = Uri.parse(
      '$_urlBase/api/usuarios/vendedores/$id',
    ).replace(
      queryParameters:
          parametros.isEmpty ? null : parametros,
    );

    final respuesta = await http.delete(
      uri,
      headers: {
        'X-Usuario-Id': idAdmin.toString(),
      },
    );

    if (respuesta.statusCode != 204 &&
        respuesta.statusCode != 200) {
      throw Exception(
        respuesta.body.isNotEmpty
            ? respuesta.body
            : 'Error al eliminar vendedor',
      );
    }
  }
}
