/// Modelo de una propiedad. Los objetos se construyen a partir de la
/// respuesta JSON del backend Java (ver servicio_propiedades.dart).
class Propiedad {
  const Propiedad({
    required this.operacion,
    required this.precio,
    required this.precioNumerico,
    required this.titulo,
    required this.ubicacion,
    required this.zonaNombre,
    required this.tipo,
    required this.recamaras,
    required this.banos,
    required this.metros,
    required this.descripcion,
    required this.caracteristicas,
    required this.cantidadFotos,
    required this.imagenesUrls,
    required this.mapsUrl,
  });

  final String operacion;
  final String precio;

  /// Precio real (sin formatear), necesario para filtrar por "precio máximo".
  final num precioNumerico;

  final String titulo;

  /// Texto para mostrar en la tarjeta, ej. "Tijuana, B.C.".
  final String ubicacion;

  /// Nombre exacto de la zona (ej. "Playas de Tijuana"), usado para el
  /// filtro de búsqueda por zona, igual que en la web.
  final String zonaNombre;

  /// Tipo en mayúsculas tal como lo maneja la API: CASA, DEPARTAMENTO,
  /// TERRENO o LOCAL. Se usa para el filtro por tipo.
  final String tipo;

  final int recamaras;
  final int banos;
  final int metros;
  final String descripcion;
  final List<String> caracteristicas;

  /// Cuántas fotos tiene la propiedad (para el carrusel).
  final int cantidadFotos;

  /// Links reales de las fotos (Cloudinary), en el orden en que se publicaron.
  final List<String> imagenesUrls;

  /// Link de Google Maps para esta propiedad específica.
  final String mapsUrl;
}