# Proyecto CRUD — Equipo 3

Proyecto colaborativo del Bootcamp de Inteligencia Artificial.

## Integrantes

- Carmen
- Iván
- Octavio
- Valentina

## Zapatería: catálogo y pedidos

API de gestión de clientes, modelos de zapatos, variantes por talla y color, pedidos y existencias. El esquema inicial usa PostgreSQL; la implementación de la API está pendiente.

## Modelo de datos y base de desarrollo

- [Diagrama, diccionario de campos y mantenimiento](docs/modelo-datos/README.md).
- [Diagrama SVG](docs/modelo-datos/diagrama-zapateria.svg).
- [Documento HTML responsive](docs/modelo-datos/modelo-zapateria.html) (abrir en un navegador).
- [Crear la base local, cargar ejemplos y comprobar restricciones](database/README.md).
- [Enunciado original](Enunciado/README.md).

El SQL de inicialización se aplica una sola vez a una base de desarrollo vacía llamada `zapateria_dev`. Cada integrante prepara su base local; no se comparten contraseñas en el código. La carga contiene dos clientes ficticios, tres productos y seis variantes.

La creación del esquema y las comprobaciones básicas se han realizado en pgAdmin según los resultados comunicados por Iván. La venta, el descuento concurrente de stock y la cancelación necesitan todavía implementación y pruebas de API. El detalle de las comprobaciones y sus límites está en `database/README.md`.
