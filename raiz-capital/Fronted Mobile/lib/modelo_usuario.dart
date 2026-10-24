/// Usuario logueado (comprador/vendedor/administrador).
class Usuario {
  const Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
  });

  final int id;
  final String nombre;
  final String correo;
  final String rol; // COMPRADOR, VENDEDOR, ADMINISTRADOR

  factory Usuario.desdeJson(Map<String, dynamic> json) {
    return Usuario(
      id: (json['id'] as num).toInt(),
      nombre: json['nombre'] as String? ?? '',
      correo: json['correo'] as String? ?? '',
      rol: (json['rol'] as String? ?? '').toUpperCase(),
    );
  }

  bool get puedePublicar => rol == 'VENDEDOR' || rol == 'ADMINISTRADOR';
  bool get esAdministrador => rol == 'ADMINISTRADOR';
}
