USE [PetShop_Gestion]
GO

ALTER TABLE Producto ALTER COLUMN Codigo NVARCHAR(15);

GO

ALTER PROCEDURE [dbo].[spMovimientosStockList]
(
	@DepositoId INT = NULL,
	@ProductoId INT = NULL,
	@Search NVARCHAR(100) = NULL,
	@Skip INT,
	@Take INT,
	@Fecha DATE = NULL
)
AS
BEGIN

	--GENERAMOS LA GRILLA DE MOVIMIENTOS EN UNA TABLA TEMPORAL
	SELECT
		M.MovimientoStockId,
		M.FechaHora,
		M.FechaHoraControlado,
		D.Descripcion AS Deposito,
		P.ProductoId,
		CASE WHEN P.Codigo IS NULL THEN 
			MA.Descripcion + ' ' + P.DescripcionCorta
		ELSE
			'(' + P.Codigo + ') ' + MA.Descripcion + ' ' + P.DescripcionCorta
		END AS Producto,
		M.Tipo,
		CASE WHEN M.Tipo = 'I' AND M.ConfirmacionFechaHora IS NOT NULL THEN
			M.Cantidad
		WHEN M.Tipo = 'E' AND M.ConfirmacionFechaHora IS NOT NULL THEN
			M.Cantidad * -1
		ELSE
			NULL
		END AS Movido,
		CASE WHEN M.Tipo = 'I' AND M.ConfirmacionFechaHora IS NULL THEN
			M.Cantidad
		WHEN M.Tipo = 'E' AND M.ConfirmacionFechaHora IS NULL THEN
			M.Cantidad * -1
		ELSE
			NULL
		END AS Reservado,
		M.Observaciones
	INTO
		#MOVIMIENTOS_STOCK
	FROM
		MovimientoStock M WITH(NOLOCK)
		INNER JOIN Deposito D WITH(NOLOCK) ON D.DepositoId = M.DepositoId
		INNER JOIN Producto P WITH(NOLOCK) ON P.ProductoId = M.ProductoId
		INNER JOIN Marca MA WITH(NOLOCK) ON MA.MarcaId = P.MarcaId
	WHERE
		M.DepositoId = COALESCE(@DepositoId, M.DepositoId)
		AND M.ProductoId = COALESCE(@ProductoId, M.ProductoId)
		AND CAST(M.FechaHora AS DATE) = COALESCE(@Fecha, CAST(M.FechaHora AS DATE))
	ORDER BY
		M.MovimientoStockId DESC
		

	--TOMAMOS LA CANTIDAD DE REGISTROS EN LA GRILLA
	DECLARE @CantidadRegistros INT = COALESCE((SELECT COUNT(*) FROM #MOVIMIENTOS_STOCK), 0);


	--AHORA SELECCIONAMOS EL RANGO DE REGISTROS A MOSTRAR APLICANDO FILTROS
	SELECT
		M.MovimientoStockId,
		M.FechaHora,
		M.FechaHoraControlado,
		M.Deposito,
		M.Producto,
		M.Tipo,
		M.Movido,
		M.Reservado,
		M.Observaciones,
		[dbo].[fnCalcularStockAlMovimiento](M.MovimientoStockId, @DepositoId, M.ProductoId) AS Stock,
		@CantidadRegistros AS CantidadRegistros
	INTO
		#MOVIMIENTOS_STOCK_FILTRADOS
	FROM
		#MOVIMIENTOS_STOCK M
	WHERE
		1 = 1
		AND
		(
			@Search IS NULL
			OR
			(
				@Search IS NOT NULL
				AND
				(
					M.Deposito LIKE '%' + @Search + '%'
					OR M.Producto LIKE '%' + @Search + '%'
					OR M.Observaciones LIKE '%' + @Search + '%'
				)
			)
		);


	--TOMAMOS LA CANTIDAD DE REGISTROS FILTRADOS EN LA GRILLA
	DECLARE @CantidadFiltrados INT = COALESCE((SELECT COUNT(*) FROM #MOVIMIENTOS_STOCK_FILTRADOS), 0);

	SELECT
		*,
		@CantidadFiltrados AS CantidadFiltrados
	FROM
		#MOVIMIENTOS_STOCK_FILTRADOS M
	ORDER BY
		M.MovimientoStockId DESC
	OFFSET @Skip ROWS
	FETCH NEXT @Take ROWS ONLY;

END

GO

ALTER PROCEDURE [dbo].[spStockListaReport]
	@DepositoId INT = NULL
AS
BEGIN

	--GENERAMOS LA GRILLA DE MOVIMIENTOS EN UNA TABLA TEMPORAL
	SELECT
		--D.Descripcion AS Deposito,
		CASE WHEN @DepositoId IS NULL THEN 'TODOS' ELSE MIN(D.Descripcion) END AS Deposito,
		COALESCE(C.Descripcion, 'Sin categoría') AS Categoria,
		CASE WHEN P.Codigo IS NULL THEN
			P.DescripcionCorta
		ELSE
			'(' + P.Codigo + ') ' + /* MA.Descripcion + ' ' +*/ P.DescripcionCorta
		END AS Producto,
		SUM(
			CASE WHEN M.Tipo = 'I' AND M.ConfirmacionFechaHora IS NOT NULL THEN
				M.Cantidad
			WHEN M.Tipo = 'E' AND M.ConfirmacionFechaHora IS NOT NULL THEN
				M.Cantidad * -1
			ELSE
				0
			END
		) AS Confirmado,
		SUM(
		CASE WHEN M.Tipo = 'I' AND M.ConfirmacionFechaHora IS NULL THEN
			M.Cantidad
		WHEN M.Tipo = 'E' AND M.ConfirmacionFechaHora IS NULL THEN
			M.Cantidad * -1
		ELSE
			0
		END
		) AS Reservado,
		SUM(
		CASE WHEN M.Tipo = 'I' THEN
			M.Cantidad
		ELSE
			M.Cantidad * -1
		END
		) AS [Real]
	FROM
		MovimientoStock M WITH(NOLOCK)
		INNER JOIN Deposito D WITH(NOLOCK) ON D.DepositoId = M.DepositoId
		INNER JOIN Producto P WITH(NOLOCK) ON P.ProductoId = M.ProductoId
		LEFT JOIN CategoriaProducto C WITH(NOLOCK) ON C.CategoriaProductoId = P.CategoriaProductoId
		INNER JOIN Marca MA WITH(NOLOCK) ON MA.MarcaId = P.MarcaId
	WHERE
		M.DepositoId = COALESCE(@DepositoId, M.DepositoId)
	GROUP BY
		MA.Descripcion, P.Codigo, P.DescripcionCorta, /* D.Descripcion, */ C.CategoriaProductoId, C.Descripcion
	ORDER BY
		C.CategoriaProductoId, /* D.Descripcion, */ /* MA.Descripcion, */ /* P.Codigo, */ P.DescripcionCorta

END

GO

ALTER PROCEDURE [dbo].[spPreciosListaReport]
(
	@ListaDePreciosId INT
)
AS
BEGIN

	SELECT
		L.Descripcion AS ListaDePrecios,
		COALESCE(C.Descripcion, 'Sin categoría') AS Categoria,
		CASE WHEN P.Codigo IS NULL THEN
			P.DescripcionCorta
		ELSE
			'(' + P.Codigo + ') ' + P.DescripcionCorta
		END AS Producto,
		PV.Precio
	FROM
		[dbo].[vwPreciosVigentes] PV
		INNER JOIN ListaDePrecios L ON L.ListaDePreciosId = PV.ListaDePreciosId
		INNER JOIN Producto P ON P.ProductoId = PV.ProductoId
		LEFT JOIN CategoriaProducto C ON C.CategoriaProductoId = P.CategoriaProductoId
	WHERE
		P.Activo = 1
		AND PV.ListaDePreciosId = @ListaDePreciosId
	ORDER BY
		C.CategoriaProductoId ASC, /*P.Codigo ASC,*/ P.DescripcionCorta ASC

END

GO

ALTER PROCEDURE [dbo].[spPreciosList]
(
	@ListaDePreciosId INT
)
AS
BEGIN

	DECLARE @Cantidad INT = (SELECT COUNT(*) FROM vwPreciosVigentes WHERE ListaDePreciosId = COALESCE(@ListaDePreciosId, ListaDePreciosId));

	SELECT
		PV.ProductoPrecioId,
		P.ProductoId,
		CASE WHEN P.Codigo IS NULL THEN
			M.Descripcion + ' ' + P.DescripcionCorta
		ELSE
			'(' + P.Codigo + ') ' + M.Descripcion + ' ' + P.DescripcionCorta
		END AS ProductoDescripcion,
		L.ListaDePreciosId,
		L.Descripcion AS ListaDePrecioDescripcion,
		L.EsPorcentual AS ListaDePreciosEsPorcentual,
		PV.AplicaDesdeFechaHora,
		PV.Precio,
		@Cantidad AS CantidadRegistros
	FROM
		vwPreciosVigentes PV
		INNER JOIN Producto P WITH(NOLOCK) ON P.ProductoId = PV.ProductoId
		INNER JOIN Marca M WITH(NOLOCK) ON M.MarcaId = P.MarcaId
		INNER JOIN ListaDePrecios L WITH(NOLOCK) ON L.ListaDePreciosId = PV.ListaDePreciosId
	WHERE
		PV.ListaDePreciosId = COALESCE(@ListaDePreciosId, PV.ListaDePreciosId);

END

GO

ALTER PROCEDURE [dbo].[spPrecioGet]
(
	@ListaDePreciosId INT = NULL,
	@ProductoId INT
)
AS
BEGIN

	SELECT top 100 --parche 21-03-22 para poder listar
		ProductoPrecioId,
		Precio,
		ListaDePreciosId
	FROM
		vwPreciosVigentes PV
	WHERE
		PV.ListaDePreciosId = COALESCE(@ListaDePreciosId, PV.ListaDePreciosId)
		AND PV.ProductoId = @ProductoId;

END