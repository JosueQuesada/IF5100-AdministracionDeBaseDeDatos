--Mostrar el nombre del cliente, el ID del pedido y el monto total utilizando INNER JOIN

select C.NOMBRE, P.PEDIDO_ID, P.MONTO_TOTAL from Clientes C
inner join Pedidos P on C.CLIENTE_ID = P.CLIENTE_ID

--Mostrar todos los clientes, aunque no tengan pedidos utilizando LEFT JOIN.

Select C.NOMBRE, P.PEDIDO_ID from CLIENTES C
left join PEDIDOS P on C.CLIENTE_ID = P.CLIENTE_ID

--Mostrar todos los pedidos, incluso si el cliente no aparece utilizando RIGHT.

Select C.NOMBRE, P.PEDIDO_ID from CLIENTES C
right join PEDIDOS P on C.CLIENTE_ID = P.CLIENTE_ID

--Mostrar el nombre del cliente, el nombre del producto, la cantidad vendida y el precio unitario vendido.
select c.NOMBRE, pro.NOMBRE, pp.CANTIDAD, pp.PRECIO_UNITARIO from clientes c
inner join PEDIDOS p on c.CLIENTE_ID = p.CLIENTE_ID
inner join PRODUCTO_PEDIDO pp on p.PEDIDO_ID = pp.PEDIDO_ID
inner join PRODUCTOS pro on pp.PRODUCTO_ID = pro.PRODUCTO_ID

--Calcule el total gastado por cliente utilizando CTE.


WITH TOTAL_CLIENTE AS
(
    SELECT 
        P.CLIENTE_ID,
        SUM(PP.CANTIDAD * PP.PRECIO_UNITARIO) AS TOTAL
    FROM PEDIDOS P
    INNER JOIN PRODUCTO_PEDIDO PP
        ON P.PEDIDO_ID = PP.PEDIDO_ID
    GROUP BY P.CLIENTE_ID
)

SELECT 
C.NOMBRE,
T.TOTAL
FROM TOTAL_CLIENTE T
INNER JOIN CLIENTES C
    ON T.CLIENTE_ID = C.CLIENTE_ID;

--Utilizando CTE calcule el total vendido por producto, mostrando el nombre del producto y
--el total vendido.

WITH TOTAL_VENDIDO AS (
	SELECT PP.PRODUCTO_ID, 
	SUM(PP.CANTIDAD * PP.PRECIO_UNITARIO) AS TOTAL
	FROM PRODUCTO_PEDIDO PP
	GROUP BY PP.PRODUCTO_ID
)

SELECT P.NOMBRE, T.TOTAL FROM PRODUCTOS P
INNER JOIN TOTAL_VENDIDO T ON P.PRODUCTO_ID = T.PRODUCTO_ID 


WITH TOTAL_CLIENTE AS
(
    SELECT 
        P.CLIENTE_ID,
        SUM(PP.CANTIDAD * PP.PRECIO_UNITARIO) AS TOTAL
    FROM PEDIDOS P
    INNER JOIN PRODUCTO_PEDIDO PP
        ON P.PEDIDO_ID = PP.PEDIDO_ID
    GROUP BY P.CLIENTE_ID
)

SELECT 
C.NOMBRE,
T.TOTAL
FROM TOTAL_CLIENTE T
INNER JOIN CLIENTES C
    ON T.CLIENTE_ID = C.CLIENTE_ID;

--SUBQUERY
SELECT 
C.NOMBRE,
(
    SELECT SUM(PP.CANTIDAD * PP.PRECIO_UNITARIO)
    FROM PEDIDOS P
    INNER JOIN PRODUCTO_PEDIDO PP
        ON P.PEDIDO_ID = PP.PEDIDO_ID
    WHERE P.CLIENTE_ID = C.CLIENTE_ID
) AS TOTAL_GASTADO
FROM CLIENTES C;