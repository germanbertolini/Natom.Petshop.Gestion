USE PetShop_Gestion
GO

INSERT INTO Permiso
	VALUES 
		('ZONAS_CRUD', 'Zonas: Alta, Baja, Modificaci�n');

GO

ALTER VIEW [dbo].[vwPreciosVigentes]
AS
	--LISTAS DE PRECIOS NO PORCENTUALES
	SELECT
		ProductoPrecioId,
		ProductoId,
		ListaDePreciosId,
		Precio,
		AplicaDesdeFechaHora,
		HistoricoReajustePrecioId
	FROM
		[dbo].[vwPreciosVigentesFijados]

	UNION

	--LISTAS DE PRECIOS PORCENTUALES
	SELECT
		NULL AS ProductoPrecioId,
		P.ProductoId,
		L.ListaDePreciosId,
		CASE WHEN L.IncrementoPorcentaje < 0 THEN
			ROUND(P.Precio / (((L.IncrementoPorcentaje * -1) / 100) + 1), 0)
		ELSE
			ROUND(P.Precio * ((L.IncrementoPorcentaje / 100) + 1), 0)
		END AS Precio,
		P.AplicaDesdeFechaHora,
		NULL AS HistoricoReajustePrecioId
	FROM
		ListaDePrecios L WITH(NOLOCK)
		INNER JOIN [dbo].[vwPreciosVigentesFijados] P ON P.ListaDePreciosId = L.IncrementoDeListaDePreciosId
		LEFT JOIN [dbo].[vwPreciosVigentesFijados] DEFINIDO ON DEFINIDO.ProductoId = P.ProductoId AND DEFINIDO.ListaDePreciosId = L.ListaDePreciosId
	WHERE
		L.Activo = 1
		AND L.EsPorcentual = 1
		AND DEFINIDO.ProductoPrecioId IS NULL --Y QUE NO EST� DEFINIDO DENTRO DE LA LISTA PORCENTUAL
		

GO

CREATE TABLE [dbo].[Zona](
	[ZonaId] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](50) NULL,
	[Activo] [bit] NOT NULL,
	PRIMARY KEY (ZonaId)
)

GO

ALTER TABLE Cliente ADD ZonaId INT;

GO

ALTER TABLE MovimientoCtaCteCliente ADD VentaId INT;

GO

INSERT INTO Permiso
	VALUES 
		('TRANSPORTES_CRUD', 'Transportes: Alta, Baja, Modificaci�n');

GO

CREATE TABLE [dbo].[Transporte](
	[TransporteId] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [nvarchar](50) NULL,
	[Activo] [bit] NOT NULL,
	PRIMARY KEY ([TransporteId])
)

GO

ALTER TABLE Cliente ADD ListaDePreciosId INT;

GO

ALTER TABLE OrdenDePedido ADD DespachoTransporteId INT;

GO