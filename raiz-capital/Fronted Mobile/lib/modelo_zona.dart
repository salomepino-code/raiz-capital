class Zona {
  const Zona({required this.id, required this.nombreZona, required this.ciudad});

  final int id;
  final String nombreZona;
  final String ciudad;

  factory Zona.desdeJson(Map<String, dynamic> json) {
    return Zona(
      id: (json['id'] as num).toInt(),
      nombreZona: json['nombreZona'] as String? ?? '',
      ciudad: json['ciudad'] as String? ?? '',
    );
  }
}
