# Base de datos de la zapatería

## Requisitos y archivos

- PostgreSQL 18 y pgAdmin o el cliente `psql`.
- `001_esquema.sql`: cinco tablas, relaciones, restricciones, índices y SKU automático.
- `002_datos_ejemplo.sql`: dos clientes ficticios, tres modelos y seis variantes.
- `003_pruebas_restricciones.sql`: pruebas repetibles sobre los datos iniciales; revierte sus inserciones y actualizaciones.

El modelo y su diccionario están en [docs/modelo-datos](../docs/modelo-datos/README.md). Los scripts son de inicialización, no migraciones: se ejecutan una sola vez en una base vacía. No contienen `DROP` ni deben usarse para reinicializar una base con trabajo previo.

## Crear el entorno local con pgAdmin

1. Conectar al servidor local con el usuario de desarrollo.
2. En Databases, seleccionar Create → Database y crear `zapateria_dev`. Si ya existe, comprobar su contenido; no borrarla ni volver a cargar los ejemplos.
3. Seleccionar esa base y abrir Tools → Query Tool. Verificar el nombre de la base en la conexión.
4. Abrir `001_esquema.sql` y ejecutar el archivo completo. Debe terminar en `COMMIT` sin errores.
5. Abrir `002_datos_ejemplo.sql` y ejecutar el archivo completo una sola vez. Su consulta final devuelve las seis variantes y los SKU.
6. Ejecutar el recuento siguiente para comprobar el resultado.

Las contraseñas se introducen en el cliente de conexión: no se guardan en estos scripts ni se publican en el repositorio. Cada integrante crea su propia base; GitHub comparte el esquema, no los datos del servidor local.

```sql
SELECT 'clientes' AS tabla, COUNT(*) AS registros FROM clientes
UNION ALL SELECT 'productos', COUNT(*) FROM productos
UNION ALL SELECT 'variantes', COUNT(*) FROM variantes
UNION ALL SELECT 'pedidos', COUNT(*) FROM pedidos
UNION ALL SELECT 'detalles_pedido', COUNT(*) FROM detalles_pedido;
```

Resultado inicial: clientes 2; productos 3; variantes 6; pedidos 0; detalles_pedido 0. Los identificadores pueden tener saltos tras pruebas o errores: no se exige que sean consecutivos.

## Alternativa con psql

Desde la carpeta `database`, con `psql` disponible en PATH:

```text
psql -X -v ON_ERROR_STOP=1 -h localhost -p 5432 -U postgres -d zapateria_dev -f 001_esquema.sql
psql -X -v ON_ERROR_STOP=1 -h localhost -p 5432 -U postgres -d zapateria_dev -f 002_datos_ejemplo.sql
psql -X -v ON_ERROR_STOP=1 -h localhost -p 5432 -U postgres -d zapateria_dev -f 003_pruebas_restricciones.sql
```

`-X` ignora personalizaciones de psql; `ON_ERROR_STOP` detiene el archivo ante un error no controlado; `-d` selecciona la base y `-f` el archivo. En Windows, si psql no está en PATH, puede abrirse SQL Shell o utilizarse su ruta de instalación. La creación de la base es un paso separado.

## Modelo y reglas

- Clientes: nombre y correo obligatorios, correo único y normalizado; teléfono opcional.
- Productos: nombre obligatorio; marca y descripción opcionales. Precio final en EUR con IVA incluido, positivo y común a todas las variantes. El desglose fiscal requerirá una modificación acordada antes de registrar ventas reales.
- Variantes: producto, talla de 36 a 40 sin medias tallas, color negro/blanco/rojo, stock entero no negativo y activo. No se repite producto+talla+color.
- Pedidos: cliente existente, fecha automática y estado pendiente/completado/cancelado.
- Detalles: una línea por variante en cada pedido; cantidad positiva y precio histórico positivo. El total se calcula, no se almacena duplicado.
- Las claves foráneas usan `ON DELETE RESTRICT`; no se eliminan ventas en cascada. La API usará desactivación o cancelación para conservar el historial.

## SKU automático y límites del catálogo inicial

El trigger genera `SOL-36-NEG`, por ejemplo, al insertar una variante. La aplicación omite el campo SKU en el alta. El mapa actual reconoce Zapatilla Sol, Zapato Terra y Bota Luna, con códigos SOL/TERRA/LUNA, y NEG/BLA/ROJ para colores.

El trigger impide transformar una variante existente cambiando producto, talla, color o SKU. Stock y activo sí pueden cambiar. Para otra combinación se crea otra variante y se desactiva la anterior.

Añadir modelos nuevos requiere acordar su código y ampliar la función mediante una migración. Cambiar el nombre de un modelo puede impedir crear nuevas variantes mientras no se actualice el mapa; los SKU anteriores no se regeneran. El esquema no impone nombres de producto únicos, pero un conflicto de SKU se rechaza.

## Estado de validación

Ejecución local realizada por Iván en pgAdmin; resultados comunicados durante la revisión guiada:

| Comprobación | Resultado comunicado |
|---|---|
| Creación del esquema y carga inicial | Completadas; recuentos 2/3/6/0/0 confirmados |
| Stock negativo | Rechazado; stock original conservado |
| Talla 41 y color azul | Rechazados |
| Correo duplicado | Rechazado |
| Pedido con cliente inexistente | Rechazado |
| Precio cero | Rechazado |
| Teléfono omitido | Aceptado; cliente de prueba descartado |
| Variante duplicada | Rechazada por la clave única del SKU en la ejecución completa de 003 |

Iván ha ejecutado el archivo `003_pruebas_restricciones.sql` completo en pgAdmin y ha comunicado sus ocho mensajes de prueba correcta y el `ROLLBACK` final. La variante duplicada fue rechazada por `variantes_sku_key`: se ha comprobado la unicidad del SKU generado, sin aislar de forma independiente la restricción compuesta `uq_variante`. Estas son pruebas del esquema; no constituyen una suite de integración de la API.

Las pruebas revierten las filas y los stocks, pero las secuencias de identidad pueden avanzar. Ejecutarlas solo en una base de desarrollo, sin escrituras concurrentes del equipo.

## Pendiente para la implementación de la API

El esquema no garantiza por sí solo pedidos con al menos una línea, precios copiados desde el catálogo, líneas inmutables ni transiciones válidas de estado. La API debe comprobar cliente y catálogo activos y guardar pedido, detalles y descuento de existencias en una sola transacción, sin sobreventa concurrente.

Completar no descuenta otra vez. Cancelar solo pedidos pendientes y reponer stock una sola vez requiere una transacción y control de concurrencia. Los reintentos de creación también necesitan una decisión de idempotencia. Reposiciones y ajustes guardan stock actual, sin historial de movimientos.

Estos recorridos se implementarán y probarán después. No hay todavía endpoints funcionales, tests de API ni conexión de la aplicación a PostgreSQL verificados.
