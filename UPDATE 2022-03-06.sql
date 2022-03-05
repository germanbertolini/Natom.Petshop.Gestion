USE PetShop_Gestion
GO

CREATE TABLE CategoriaProducto
(
	CategoriaProductoId NVARCHAR(40) NOT NULL,
	Descripcion NVARCHAR(50) NOT NULL,
	Eliminado BIT NOT NULL DEFAULT 0,
	CONSTRAINT [PK_CategoriaProducto] PRIMARY KEY CLUSTERED (CategoriaProductoId ASC)
);

GO

INSERT INTO CategoriaProducto VALUES ('Z_OTROS', 'Otros', 0);

GO

ALTER TABLE Producto ADD CategoriaProductoId NVARCHAR(40);

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
		'(' + P.Codigo + ') ' + P.DescripcionCorta AS Producto,
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
		C.CategoriaProductoId ASC, P.Codigo ASC, P.DescripcionCorta ASC

END

GO


ALTER PROCEDURE [dbo].[spStockListaReport]
	@DepositoId INT = NULL
AS
BEGIN

	--GENERAMOS LA GRILLA DE MOVIMIENTOS EN UNA TABLA TEMPORAL
	SELECT
		D.Descripcion AS Deposito,
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
		MA.Descripcion, P.Codigo, P.DescripcionCorta, D.Descripcion, C.CategoriaProductoId, C.Descripcion
	ORDER BY
		C.CategoriaProductoId, D.Descripcion, /* MA.Descripcion, */ P.Codigo, P.DescripcionCorta

END

GO

