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

## API REST (FastAPI) — estado actual

En este repositorio se ha preparado la estructura del proyecto para implementar la API REST con **FastAPI**, pero **todavía no hay aplicación/endpoint funcional**.

- No hay endpoints CRUD implementados.
- No hay documentación Swagger generada todavía (porque la API no está en ejecución).
- No hay pruebas `pytest` para la API todavía.

### Pendientes de implementación
- CRUD de clientes, modelos y variantes (talla/color).
- Gestión de pedidos.
- Gestión de existencias.
- Descuento concurrente de stock (manejo de concurrencia).
- Cancelación / devolución y actualización del stock.
- Añadir y pasar pruebas con `pytest`.
- Actualizar este README con instrucciones reales de ejecución y Swagger cuando esté listo.

## Próximo trabajo
- Implementar endpoints y lógica de negocio.
- Conectar la API con PostgreSQL.
- Completar pedidos y existencias con concurrencia segura.
- Añadir pruebas y documentar Swagger/comandos reales.
