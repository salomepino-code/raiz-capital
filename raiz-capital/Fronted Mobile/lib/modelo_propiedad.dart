/// Modelo de una propiedad. Por ahora se llena con datos de ejemplo
/// directamente en el código; más adelante estos objetos se construirán
/// a partir de la respuesta JSON del backend Java.
class Propiedad {
  const Propiedad({
    required this.operacion,
    required this.precio,
    required this.titulo,
    required this.ubicacion,
    required this.recamaras,
    required this.banos,
    required this.metros,
    required this.descripcion,
    required this.caracteristicas,
    required this.cantidadFotos,
    required this.mapsUrl,
  });

  final String operacion;
  final String precio;
  final String titulo;
  final String ubicacion;
  final int recamaras;
  final int banos;
  final int metros;
  final String descripcion;
  final List<String> caracteristicas;

  /// Cuántas fotos simular en el carrusel (por ahora se repite el mismo
  /// degradado de color esa cantidad de veces, solo para probar que el
  /// carrusel funciona).
  final int cantidadFotos;

  /// Link de Google Maps para esta propiedad específica.
  // aqui va la conexion con la base de datos: cada propiedad traerá su
  // propio mapsUrl (o su latitud/longitud) desde el backend. Por ahora
  // todas usan un link de ejemplo genérico como placeholder.
  final String mapsUrl;
}
