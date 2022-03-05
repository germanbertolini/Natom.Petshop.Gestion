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

