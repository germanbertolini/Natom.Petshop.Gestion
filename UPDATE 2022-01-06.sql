USE [PetShop_Gestion]
GO

CREATE PROCEDURE spPreciosListaReport
(
	@ListaDePreciosId INT
)
AS
BEGIN

	SELECT
		L.Descripcion AS ListaDePrecios,
		'(' + P.Codigo + ') ' + P.DescripcionCorta AS Producto,
		PV.Precio
	FROM
		[dbo].[vwPreciosVigentes] PV
		INNER JOIN ListaDePrecios L ON L.ListaDePreciosId = PV.ListaDePreciosId
		INNER JOIN Producto P ON P.ProductoId = PV.ProductoId
	WHERE
		P.Activo = 1
		AND PV.ListaDePreciosId = @ListaDePreciosId
	ORDER BY
		P.Codigo ASC, P.DescripcionCorta ASC

END

GO

ALTER TABLE Cliente ADD MontoCtaCte DECIMAL(18,2) DEFAULT 0;

GO

UPDATE Cliente SET MontoCtaCte = 0;

GO

INSERT INTO Permiso (PermisoId, Descripcion) VALUES ('CLIENTES_CTA_CTE_VER', 'Clientes: Consultar Cuenta Corriente');

GO

CREATE TABLE [dbo].[MovimientoCtaCteCliente](
	[MovimientoCtaCteClienteId] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[FechaHora] [datetime] NOT NULL,
	ClienteId INT NOT NULL,
	[UsuarioId] [int] NULL,
	[Tipo] [char](1) NOT NULL,
	[Importe] [decimal](18, 2) NOT NULL,
	[Observaciones] [nvarchar](200) NULL,
	FOREIGN KEY (ClienteId) REFERENCES Cliente(ClienteId)
)

GO

ALTER TABLE MovimientoCajaDiaria ADD VentaId INT;

GO

ALTER TABLE MovimientoCajaDiaria ADD MedioDePago NVARCHAR(30);

GO

ALTER TABLE MovimientoCajaFuerte ADD VentaId INT;

GO

ALTER TABLE MovimientoCajaFuerte ADD MedioDePago NVARCHAR(30);

GO

ALTER TABLE Venta ADD PagoReferencia NVARCHAR(50), MedioDePago NVARCHAR(30);

GO

ALTER TABLE MovimientoCajaDiaria ADD Referencia NVARCHAR(50);

GO

ALTER TABLE MovimientoCajaFuerte ADD Referencia NVARCHAR(50);

GO
