-- Datos ficticios. Precios y stock son ejemplos, no restricciones comerciales.
-- Ejecutar una sola vez tras 001_esquema.sql. No crea pedidos ni descuenta stock.
BEGIN;
INSERT INTO clientes (nombre, email, telefono) VALUES
    ('Ana Ejemplo', 'ana@example.com', NULL),
    ('Luis Ejemplo', 'luis@example.com', '600000000');

INSERT INTO productos (nombre, precio) VALUES
    ('Zapatilla Sol', 49.90),
    ('Zapato Terra', 69.90),
    ('Bota Luna', 89.90);

INSERT INTO variantes (producto_id, talla, color, stock)
SELECT p.id, v.talla, v.color, v.stock
FROM (VALUES
    ('Zapatilla Sol', '36', 'negro', 5),
    ('Zapatilla Sol', '38', 'blanco', 3),
    ('Zapato Terra', '37', 'rojo', 4),
    ('Zapato Terra', '39', 'negro', 5),
    ('Bota Luna', '38', 'negro', 3),
    ('Bota Luna', '40', 'rojo', 2)
) AS v(modelo,talla,color,stock)
JOIN productos p ON p.nombre = v.modelo;
COMMIT;

SELECT p.nombre, v.sku, v.talla, v.color, v.stock, p.precio
FROM variantes v JOIN productos p ON p.id = v.producto_id
ORDER BY p.id, v.talla, v.color;
