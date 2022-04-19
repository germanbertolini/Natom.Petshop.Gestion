USE [PetShop_Gestion]
GO

/****** Object:  View [dbo].[vwPreciosVigentes]    Script Date: 18/04/2022 22:28:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER TABLE Producto ADD ListaB INT NULL;

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
			ROUND(((100 + L.IncrementoPorcentaje) * P.Precio) / 100, 0)
		ELSE
			ROUND(P.Precio * ((L.IncrementoPorcentaje / 100) + 1), 0)
		END AS Precio,
		P.AplicaDesdeFechaHora,
		NULL AS HistoricoReajustePrecioId
	FROM
		ListaDePrecios L WITH(NOLOCK)
		INNER JOIN [dbo].[vwPreciosVigentesFijados] P ON P.ListaDePreciosId = L.IncrementoDeListaDePreciosId
		LEFT JOIN [dbo].[vwPreciosVigentesFijados] DEFINIDO ON DEFINIDO.ProductoId = P.ProductoId AND DEFINIDO.ListaDePreciosId = L.ListaDePreciosId
		INNER JOIN [dbo].[Producto] PROD ON PROD.ProductoId = P.ProductoId
	WHERE
		L.Activo = 1
		AND L.EsPorcentual = 1
		AND DEFINIDO.ProductoPrecioId IS NULL --Y QUE NO ESTÉ DEFINIDO DENTRO DE LA LISTA PORCENTUAL
		AND
		(
			(L.ListaDePreciosId = 4 AND PROD.ListaB IS NULL)
			OR (L.ListaDePreciosId = 5 AND PROD.ListaB = 1)
			OR L.ListaDePreciosId NOT IN (4, 5)
		)
		

GO


