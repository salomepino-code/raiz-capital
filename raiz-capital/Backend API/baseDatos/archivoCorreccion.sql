USE raiz_capital;

ALTER TABLE propiedad MODIFY tipo ENUM('CASA','DEPARTAMENTO','TERRENO','LOCAL') NOT NULL;

UPDATE zona SET nombre_zona = 'Zona Río / Centro' WHERE id_zona = 2;
UPDATE zona SET nombre_zona = 'Rosarito' WHERE id_zona = 3;
INSERT INTO zona (nombre_zona, ciudad) VALUES
 ('Zona Este','Tijuana'), ('Otay','Tijuana'), ('La Mesa','Tijuana'),
 ('Agua Caliente','Tijuana'), ('Santa Fe','Tijuana'), ('Zona Sur','Tijuana'),
 ('Zona Oeste','Tijuana'), ('Zona Norte','Tijuana'), ('Valle de las Palmas','Tijuana');