# Modelo de datos de la zapatería

## Consultar el diagrama

- [HTML responsive y diccionario de campos](modelo-zapateria.html).
- [Imagen SVG](diagrama-zapateria.svg).
- [Scripts e instrucciones de PostgreSQL](../../database/README.md).

Para ver el HTML, descargar o abrir el archivo en un navegador. GitHub muestra su código fuente; el SVG puede consultarse como imagen. El HTML funciona sin conexión, sin cuenta y sin dependencias externas. Mantener el SVG junto a él permite utilizar además su botón de descarga.

En pantallas grandes se muestra el diagrama completo. En ventanas medianas se organiza en dos columnas de tarjetas y en móvil en una. Cada tarjeta incluye relaciones escritas; los botones destacan entidades relacionadas. El diccionario explica los 27 campos. PK es clave primaria, FK clave foránea y UK clave única.

## Entidades y relaciones

| Entidad | Responsabilidad |
|---|---|
| clientes | Identidad y contacto; teléfono opcional |
| productos | Modelo comercial y precio común a sus variantes |
| variantes | Modelo+talla+color, SKU automático y stock propio |
| pedidos | Cliente, fecha y estado de una compra |
| detalles_pedido | Variante comprada, cantidad y precio histórico |

Un cliente puede tener muchos pedidos; un pedido válido contiene una o varias líneas. Cada línea referencia una variante y cada variante pertenece a un producto. La obligación de al menos una línea corresponde a la transacción de la API, no solo a las claves foráneas.

Catálogo inicial: Zapatilla Sol, Zapato Terra y Bota Luna; tallas 36–40 sin medias tallas; colores negro, blanco y rojo. Se crean seis variantes de ejemplo, no todas las combinaciones posibles.

## Mantener el documento

La fuente está en `herramientas/generar_diagrama.py`. Desde esta carpeta:

```text
python herramientas/generar_diagrama.py
```

Requiere Python 3.12 o posterior; utiliza únicamente la biblioteca estándar. Sobrescribe `modelo-zapateria.html` y `diagrama-zapateria.svg` en esta carpeta; no ejecuta SQL ni modifica datos. La lista `tables` genera campos, tipos, explicaciones y tarjetas; `edges` define las conexiones del SVG. Al mover entidades hay que ajustar sus líneas y revisar la presentación.

Modificar la fuente y regenerar, en lugar de cambiar únicamente el HTML de salida. Revisar cada modificación del modelo también en el SQL: el dibujo no aplica restricciones a la base de datos. Los retoques de presentación no necesitan un historial dentro del documento.
