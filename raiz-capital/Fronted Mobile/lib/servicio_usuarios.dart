import 'dart:convert';
import 'package:http/http.dart' as http;
import 'modelo_usuario.dart';

const String _urlBase = 'http://localhost:8080';

class ServicioUsuarios {
  /// Llama a POST /api/usuarios/login. Devuelve el Usuario si las
  /// credenciales son correctas, o null si no (401).
  Future<Usuario?> iniciarSesion(String correo, String contrasena) async {
    final respuesta = await http.post(
      Uri.parse('$_urlBase/api/usuarios/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo, 'contrasena': contrasena}),
    );

    if (respuesta.statusCode == 200) {
      return Usuario.desdeJson(jsonDecode(utf8.decode(respuesta.bodyBytes)));
    }
    if (respuesta.statusCode == 401) {
      return null; // credenciales incorrectas
    }
    throw Exception('Error al iniciar sesión (código ${respuesta.statusCode})');
  }
}
