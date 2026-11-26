-- PostgreSQL. Ejecutar una sola vez en una base de desarrollo vacia.
-- No crea ni elimina bases de datos. No modifica tablas existentes.
BEGIN;

CREATE TABLE clientes (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL CHECK (btrim(nombre) <> ''),
    email VARCHAR(254) NOT NULL UNIQUE
        CHECK (email = lower(btrim(email)) AND email <> ''),
    telefono VARCHAR(30) CHECK (telefono IS NULL OR btrim(telefono) <> ''),
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE productos (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL CHECK (btrim(nombre) <> ''),
    marca VARCHAR(80),
    descripcion TEXT,
    precio NUMERIC(10,2) NOT NULL
        CHECK (precio > 0 AND precio <> 'NaN'::numeric),
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE variantes (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    producto_id BIGINT NOT NULL REFERENCES productos(id) ON DELETE RESTRICT,
    sku VARCHAR(64) NOT NULL UNIQUE,
    talla VARCHAR(10) NOT NULL CHECK (talla IN ('36','37','38','39','40')),
    color VARCHAR(50) NOT NULL CHECK (color IN ('negro','blanco','rojo')),
    stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_variante UNIQUE (producto_id, talla, color)
);

CREATE TABLE pedidos (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cliente_id BIGINT NOT NULL REFERENCES clientes(id) ON DELETE RESTRICT,
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(20) NOT NULL DEFAULT 'pendiente'
        CHECK (estado IN ('pendiente','completado','cancelado'))
);

CREATE TABLE detalles_pedido (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pedido_id BIGINT NOT NULL REFERENCES pedidos(id) ON DELETE RESTRICT,
    variante_id BIGINT NOT NULL REFERENCES variantes(id) ON DELETE RESTRICT,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(10,2) NOT NULL
        CHECK (precio_unitario > 0 AND precio_unitario <> 'NaN'::numeric),
    CONSTRAINT uq_detalle_variante UNIQUE (pedido_id, variante_id)
);

-- Las claves unicas compuestas ya indexan producto_id y pedido_id.
CREATE INDEX ix_pedidos_cliente ON pedidos(cliente_id);
CREATE INDEX ix_pedidos_fecha ON pedidos(fecha_creacion DESC, id DESC);
CREATE INDEX ix_pedidos_estado_fecha ON pedidos(estado, fecha_creacion DESC, id DESC);
CREATE INDEX ix_detalles_variante ON detalles_pedido(variante_id);

-- SKU automatico para el catalogo inicial. No depende de que la API lo envie.
CREATE FUNCTION asignar_sku_variante() RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
    nombre_modelo TEXT;
    codigo_modelo TEXT;
    codigo_color TEXT;
BEGIN
    -- Una variante es una identidad estable: no se transforma en otro zapato.
    IF TG_OP = 'UPDATE' THEN
        IF NEW.producto_id IS DISTINCT FROM OLD.producto_id
           OR NEW.talla IS DISTINCT FROM OLD.talla
           OR NEW.color IS DISTINCT FROM OLD.color
           OR NEW.sku IS DISTINCT FROM OLD.sku THEN
            RAISE EXCEPTION 'No cambiar modelo, talla, color ni SKU: crear otra variante y desactivar la anterior';
        END IF;
        RETURN NEW;
    END IF;

    SELECT nombre INTO nombre_modelo FROM productos WHERE id = NEW.producto_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'El producto indicado no existe' USING ERRCODE = '23503';
    END IF;
    codigo_modelo := CASE lower(btrim(nombre_modelo))
        WHEN 'zapatilla sol' THEN 'SOL'
        WHEN 'zapato terra' THEN 'TERRA'
        WHEN 'bota luna' THEN 'LUNA'
        ELSE NULL END;
    IF codigo_modelo IS NULL THEN
        RAISE EXCEPTION 'Modelo sin codigo SKU acordado: %', nombre_modelo;
    END IF;
    codigo_color := CASE NEW.color
        WHEN 'negro' THEN 'NEG' WHEN 'blanco' THEN 'BLA' WHEN 'rojo' THEN 'ROJ'
        ELSE NULL END;
    IF codigo_color IS NULL THEN
        RAISE EXCEPTION 'Color no permitido' USING ERRCODE = '23514';
    END IF;
    NEW.sku := codigo_modelo || '-' || NEW.talla || '-' || codigo_color;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_sku_variante BEFORE INSERT OR UPDATE ON variantes
FOR EACH ROW EXECUTE FUNCTION asignar_sku_variante();

COMMENT ON COLUMN productos.precio IS 'EUR, precio final con IVA incluido; mismo precio para todas las variantes del modelo.';
COMMENT ON COLUMN detalles_pedido.precio_unitario IS 'Precio final historico copiado al crear el pedido. No se recalcula al cambiar el catalogo.';
COMMENT ON COLUMN variantes.stock IS 'Stock actual. Pedido, lineas y descuento deben guardarse en una transaccion de la API.';
COMMIT;
