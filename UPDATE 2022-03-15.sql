USE [PetShop_Gestion]
GO
/****** Object:  StoredProcedure [dbo].[spStockListaReport]    Script Date: 15/3/2022 19:48:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
		'(' + P.Codigo + ') ' + /* MA.Descripcion + ' ' +*/ P.DescripcionCorta AS Producto,
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
		C.CategoriaProductoId, /* D.Descripcion, */ /* MA.Descripcion, */ P.Codigo, P.DescripcionCorta

END
