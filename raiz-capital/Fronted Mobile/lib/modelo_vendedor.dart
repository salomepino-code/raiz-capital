class Vendedor {
  const Vendedor({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.numeroPropiedades,
  });

  final int id;
  final String nombre;
  final String correo;
  final String? telefono;
  final int numeroPropiedades;

  factory Vendedor.desdeJson(Map<String, dynamic> json) {
    return Vendedor(
      id: (json['id'] as num).toInt(),
      nombre: json['nombre'] as String? ?? '',
      correo: json['correo'] as String? ?? '',
      telefono: json['telefono'] as String?,
      numeroPropiedades:
          (json['numeroPropiedades'] as num?)?.toInt() ?? 0,
    );
  }
}