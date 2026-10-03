import 'modelo_usuario.dart';

/// Guarda al usuario logueado mientras la app está abierta.
/// Simple a propósito: no persiste entre reinicios de la app (eso
/// requeriría algo como shared_preferences, que se puede agregar después
/// si hace falta "recordar sesión").
class SesionUsuario {
  SesionUsuario._();

  static Usuario? actual;

  static bool get haySesion => actual != null;

  static void cerrarSesion() {
    actual = null;
  }
}
