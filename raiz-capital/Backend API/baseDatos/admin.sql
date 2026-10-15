USE raiz_capital;

INSERT INTO usuario (nombre, correo, contrasena, rol, telefono) VALUES
 ('Admin de Prueba', 'admin@prueba.com', 'TuContrasenaAqui123', 'ADMINISTRADOR', '6642274833');
 
 UPDATE usuario SET contrasena = '123' WHERE correo = 'admin@prueba.com';
 
 UPDATE usuario SET contrasena = 'contrasena123' WHERE correo = 'admin@prueba.com';
 