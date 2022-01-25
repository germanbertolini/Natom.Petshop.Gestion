USE PetShop_Gestion
GO

INSERT INTO Permiso
	VALUES 
		('ZONAS_CRUD', 'Zonas: Alta, Baja, Modificación');

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
	WHERE
		L.Activo = 1
		AND L.EsPorcentual = 1

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

