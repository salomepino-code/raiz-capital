import 'modelo_propiedad.dart';

// aqui va la conexion con la base de datos
// Endpoint esperado: GET /api/propiedades (catálogo) y GET /api/propiedades/{id}
// (detalle). Mientras no exista el backend Java, se usa esta lista fija.
const List<Propiedad> propiedadesEjemplo = [
  Propiedad(
    operacion: 'VENTA',
    precio: '\$2,450,000',
    titulo: 'Casa en Colonia Cacho',
    ubicacion: 'Tijuana, B.C.',
    recamaras: 3,
    banos: 2,
    metros: 180,
    descripcion:
        'Amplia casa familiar en una de las zonas más solicitadas de la ciudad, con acabados de calidad, buena iluminación natural y a pocos minutos de escuelas y centros comerciales.',
    caracteristicas: ['Área común', '3 habitaciones', '2 estacionamientos'],
    cantidadFotos: 3,
    // Link de ejemplo genérico; cada propiedad tendrá el suyo cuando exista backend.
    mapsUrl: 'https://maps.google.com/?q=Colonia+Cacho,+Tijuana',
  ),
  Propiedad(
    operacion: 'RENTA',
    precio: '\$18,500/mes',
    titulo: 'Departamento en Zona Río',
    ubicacion: 'Tijuana, B.C.',
    recamaras: 2,
    banos: 1,
    metros: 90,
    descripcion:
        'Departamento moderno y funcional en pleno corazón de Zona Río, ideal para quien busca cercanía con oficinas, restaurantes y vida nocturna.',
    caracteristicas: ['Amueblado', 'Balcón', '1 estacionamiento'],
    cantidadFotos: 2,
    mapsUrl: 'https://maps.google.com/?q=Zona+Rio,+Tijuana',
  ),
  Propiedad(
    operacion: 'VENTA',
    precio: '\$1,890,000',
    titulo: 'Casa en Playas de Tijuana',
    ubicacion: 'Tijuana, B.C.',
    recamaras: 3,
    banos: 2,
    metros: 150,
    descripcion:
        'Casa a unos minutos de la playa, perfecta para quienes buscan tranquilidad sin alejarse de la ciudad. Cuenta con patio trasero y cochera techada.',
    caracteristicas: ['Patio trasero', '3 habitaciones', 'Cochera techada'],
    cantidadFotos: 4,
    mapsUrl: 'https://maps.google.com/?q=Playas+de+Tijuana',
  ),
];
