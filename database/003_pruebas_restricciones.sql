-- Ejecutar completo en desarrollo tras la carga inicial, sin escrituras concurrentes.
-- Los errores esperados se controlan dentro de bloques. No deja filas nuevas.
-- Las secuencias de identidad pueden avanzar aunque se reviertan las inserciones.
BEGIN;
DO $$
DECLARE
    ejemplo variantes%ROWTYPE;
    email_existente TEXT;
    cliente_inexistente BIGINT;
    prueba clientes%ROWTYPE;
    restriccion TEXT;
BEGIN
    SELECT * INTO STRICT ejemplo FROM variantes WHERE sku = 'SOL-36-NEG';
    SELECT email INTO STRICT email_existente FROM clientes ORDER BY id LIMIT 1;

    BEGIN
        UPDATE variantes SET stock = -1 WHERE id = ejemplo.id;
        RAISE EXCEPTION 'PRUEBA FALLIDA: stock negativo permitido';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'CORRECTO: stock negativo rechazado';
    END;

    BEGIN
        INSERT INTO variantes (producto_id,talla,color,stock)
        VALUES (ejemplo.producto_id,'41','negro',1);
        RAISE EXCEPTION 'PRUEBA FALLIDA: talla 41 permitida';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'CORRECTO: talla 41 rechazada';
    END;

    BEGIN
        INSERT INTO variantes (producto_id,talla,color,stock)
        VALUES (ejemplo.producto_id,'36','azul',1);
        RAISE EXCEPTION 'PRUEBA FALLIDA: color azul permitido';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'CORRECTO: color azul rechazado';
    END;

    BEGIN
        INSERT INTO clientes (nombre,email) VALUES ('Cliente de prueba',email_existente);
        RAISE EXCEPTION 'PRUEBA FALLIDA: correo duplicado permitido';
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'CORRECTO: correo duplicado rechazado';
    END;

    BEGIN
        INSERT INTO variantes (producto_id,talla,color,stock)
        VALUES (ejemplo.producto_id,ejemplo.talla,ejemplo.color,1);
        RAISE EXCEPTION 'PRUEBA FALLIDA: variante duplicada permitida';
    EXCEPTION WHEN unique_violation THEN
        GET STACKED DIAGNOSTICS restriccion = CONSTRAINT_NAME;
        RAISE NOTICE 'CORRECTO: variante duplicada rechazada por %', restriccion;
    END;

    SELECT COALESCE(MAX(id),0)+1 INTO cliente_inexistente FROM clientes;
    BEGIN
        INSERT INTO pedidos (cliente_id) VALUES (cliente_inexistente);
        RAISE EXCEPTION 'PRUEBA FALLIDA: cliente inexistente permitido';
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE 'CORRECTO: cliente inexistente rechazado';
    END;

    BEGIN
        INSERT INTO productos (nombre,precio) VALUES ('Producto de prueba',0);
        RAISE EXCEPTION 'PRUEBA FALLIDA: precio cero permitido';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'CORRECTO: precio cero rechazado';
    END;

    BEGIN
        INSERT INTO clientes (nombre,email)
        VALUES ('Cliente de prueba','prueba-' || gen_random_uuid()::text || '@example.com')
        RETURNING * INTO prueba;
        IF prueba.telefono IS NOT NULL THEN
            RAISE EXCEPTION 'PRUEBA FALLIDA: telefono omitido no es NULL';
        END IF;
        RAISE SQLSTATE 'Z0001';
    EXCEPTION WHEN SQLSTATE 'Z0001' THEN
        RAISE NOTICE 'CORRECTO: telefono opcional; insercion descartada';
    END;

    IF (SELECT stock FROM variantes WHERE id=ejemplo.id) IS DISTINCT FROM ejemplo.stock THEN
        RAISE EXCEPTION 'PRUEBA FALLIDA: se ha alterado el stock original';
    END IF;
    RAISE NOTICE 'Pruebas de restricciones terminadas. Revertir la transaccion exterior.';
END;
$$;
ROLLBACK;
