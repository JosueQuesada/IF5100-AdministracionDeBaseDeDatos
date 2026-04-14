BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @PedidoId INT;

    INSERT INTO PEDIDOS (CLIENTE_ID, MONTO_TOTAL, FECHA)
    VALUES (2, 0, GETDATE());

    SET @PedidoId = SCOPE_IDENTITY();

    SAVE TRANSACTION sp_detalles;

    -- Primer detalle correcto
    INSERT INTO PRODUCTO_PEDIDO (PEDIDO_ID, PRODUCTO_ID, PRECIO_UNITARIO, CANTIDAD, FECHA_REGISTRO)
    SELECT @PedidoId, PRODUCTO_ID, PRECIO_UNITARIO, 1, GETDATE()
    FROM PRODUCTOS WHERE PRODUCTO_ID = 2;

    -- Segundo detalle con error (simulado)
    IF 1 = 1
        THROW 50004, 'Error en segundo detalle', 1;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    -- Volver al punto antes de los detalles
	
    PRINT 'Rollback parcial aplicado (SAVEPOINT)';
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION sp_detalles;

    -- Podemos continuar agregando otros detalles válidos si quisiéramos

    IF @@TRANCOUNT > 0 COMMIT TRANSACTION;
END CATCH;
go
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @PedidoId INT;

    INSERT INTO PEDIDOS (CLIENTE_ID, MONTO_TOTAL, FECHA)
    VALUES (2, 0, GETDATE());

    SET @PedidoId = SCOPE_IDENTITY();

    -- Punto de control antes de agregar detalles
    SAVE TRANSACTION sp_detalles;

    -- 1) Detalle válido
    INSERT INTO PRODUCTO_PEDIDO (PEDIDO_ID, PRODUCTO_ID, PRECIO_UNITARIO, CANTIDAD, FECHA_REGISTRO)
    SELECT @PedidoId, PRODUCTO_ID, PRECIO_UNITARIO, 1, GETDATE()
    FROM PRODUCTOS WHERE PRODUCTO_ID = 2;

    -- 2) Detalle con error (forzado)
    INSERT INTO PRODUCTO_PEDIDO (PEDIDO_ID, PRODUCTO_ID, PRECIO_UNITARIO, CANTIDAD, FECHA_REGISTRO)
    SELECT @PedidoId, PRODUCTO_ID, PRECIO_UNITARIO, 9999, GETDATE()
    FROM PRODUCTOS WHERE PRODUCTO_ID = 1;

    -- Validación que dispara el error
    IF EXISTS (
        SELECT 1 FROM PRODUCTOS WHERE PRODUCTO_ID = 1 AND CANTIDAD < 9999
    )
        THROW 50010, 'Error en segundo detalle (stock insuficiente)', 1;

    COMMIT TRANSACTION; -- No llegará aquí
END TRY
BEGIN CATCH
    PRINT 'Se produjo error: ' + ERROR_MESSAGE();

    -- Volvemos al SAVEPOINT (se elimina TODO lo hecho después de sp_detalles)
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION sp_detalles;

    PRINT 'Rollback parcial aplicado (SAVEPOINT)';

    -- Continuamos la transacción con un detalle válido alternativo
    INSERT INTO PRODUCTO_PEDIDO (PEDIDO_ID, PRODUCTO_ID, PRECIO_UNITARIO, CANTIDAD, FECHA_REGISTRO)
    SELECT @PedidoId, PRODUCTO_ID, PRECIO_UNITARIO, 1, GETDATE()
    FROM PRODUCTOS WHERE PRODUCTO_ID = 3;

    -- Recalcular total
    UPDATE PEDIDOS
    SET MONTO_TOTAL = (
        SELECT SUM(PRECIO_UNITARIO * CANTIDAD)
        FROM PRODUCTO_PEDIDO
        WHERE PEDIDO_ID = @PedidoId
    )
    WHERE PEDIDO_ID = @PedidoId;

    -- Finalizamos correctamente
    IF @@TRANCOUNT > 0 COMMIT TRANSACTION;
END CATCH;

