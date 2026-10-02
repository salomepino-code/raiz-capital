-- Datos de prueba para arrancar (correr DESPUÉS de schema.sql)
USE raiz_capital;

INSERT INTO zona (nombre_zona, ciudad, descripcion) VALUES
 ('Zona Río / Centro',  'Tijuana',  'Zona céntrica con áreas comerciales, residenciales y de servicios'),
 ('Zona Este',          'Tijuana',  'Zona residencial y de crecimiento urbano al este de la ciudad'),
 ('Otay',               'Tijuana',  'Zona fronteriza con áreas residenciales, comerciales e industriales'),
 ('La Mesa',             'Tijuana',  'Zona residencial y comercial ubicada en el centro de Tijuana'),
 ('Agua Caliente',      'Tijuana',  'Zona residencial y comercial con hoteles, restaurantes y servicios'),
 ('Playas de Tijuana',  'Tijuana',  'Zona costera con vista al mar y áreas residenciales'),
 ('Santa Fe',            'Tijuana',  'Zona residencial ubicada al suroeste de Tijuana'),
 ('Zona Sur',            'Tijuana',  'Zona con áreas residenciales y de crecimiento urbano al sur'),
 ('Zona Oeste',          'Tijuana',  'Zona residencial ubicada hacia el oeste de Tijuana'),
 ('Zona Norte',          'Tijuana',  'Zona cercana a la frontera con áreas comerciales y residenciales'),
 ('Valle de las Palmas', 'Tijuana',  'Zona de crecimiento urbano ubicada al este de Tijuana'),
 ('Rosarito',            'Rosarito', 'Zona costera con áreas residenciales, comerciales y turísticas');

-- Vendedor de prueba (la contraseña real se hasheará cuando hagamos el login)
INSERT INTO usuario (nombre, correo, contrasena, rol, telefono) VALUES
 ('Vendedor de Prueba', 'vendedor@prueba.com', 'PENDIENTE_HASH', 'VENDEDOR', '6640000000');

INSERT INTO propiedad
 (id_vendedor, id_zona, titulo, descripcion, precio, tipo, operacion, recamaras, banos, superficie_m2, colonia)
VALUES
 (1, 1, 'Casa colinas california', 'Departamento gran ubicacion, cocina integrada y balcón.', 3999000, 'CASA', 'VENTA', 3, 3, 100, 'Zona Centro'),
 (1, 2, 'Casa céntrica de dos niveles', 'Casa de dos niveles cerca de plazas y servicios.', 2450000, 'CASA', 'VENTA', 3, 2, 140, 'Zona Río');

INSERT INTO propiedad_caracteristica (id_propiedad, caracteristica) VALUES
 (1, 'balcón'), (1, 'estacionamiento'), (2, 'jardín'), (2, 'cochera');
