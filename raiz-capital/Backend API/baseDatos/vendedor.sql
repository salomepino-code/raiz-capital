USE raiz_capital;
UPDATE usuario SET contrasena = 'contrasena123' WHERE correo = 'vendedor@prueba.com';

SELECT id_usuario, correo, contrasena FROM usuario WHERE correo LIKE '%vendedor%';

COMMIT;