SELECT p.id_propiedad, p.titulo, u.nombre AS vendedor, u.telefono
FROM propiedad p
JOIN usuario u ON u.id_usuario = p.id_vendedor;