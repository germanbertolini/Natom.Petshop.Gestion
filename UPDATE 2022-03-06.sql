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

