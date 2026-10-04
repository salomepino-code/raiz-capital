import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// Mismo cloud name que ya usas en el dashboard de Cloudinary.
const String _cloudName = 'ugwwgzzs';

// Nombre del "unsigned upload preset" que vas a crear en Cloudinary
// (ver instrucciones). Es DISTINTO de "ml_default": ese es para subir
// tú mismo desde el dashboard; este es para que la APP suba fotos
// directo, sin que nadie entre a Cloudinary.
const String _uploadPreset = 'raiz_capital_unsigned';

class ServicioImagenes {
  final ImagePicker _selector = ImagePicker();

  /// Abre la galería del celular/computadora y permite elegir varias fotos.
  Future<List<XFile>> seleccionarFotos() {
    return _selector.pickMultiImage(imageQuality: 80);
  }

  /// Sube una foto directo a Cloudinary (sin pasar por tu backend) y
  /// devuelve el link ya listo para guardar en la propiedad.
  Future<String> _subirFoto(XFile foto) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
    final bytes = await foto.readAsBytes();

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: foto.name));

    final respuestaStream = await request.send();
    final respuesta = await http.Response.fromStream(respuestaStream);

    if (respuesta.statusCode != 200) {
      throw Exception('No se pudo subir "${foto.name}" (código ${respuesta.statusCode})');
    }

    final datos = jsonDecode(respuesta.body) as Map<String, dynamic>;
    return datos['secure_url'] as String;
  }

  /// Sube varias fotos en orden y reporta el avance (ej. "3 de 10").
  Future<List<String>> subirFotos(
    List<XFile> fotos, {
    void Function(int subidas, int total)? onProgreso,
  }) async {
    final urls = <String>[];
    for (var i = 0; i < fotos.length; i++) {
      final url = await _subirFoto(fotos[i]);
      urls.add(url);
      onProgreso?.call(i + 1, fotos.length);
    }
    return urls;
  }
}
