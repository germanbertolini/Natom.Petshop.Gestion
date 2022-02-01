USE PetShop_Gestion
GO

ALTER TABLE OrdenDePedidoDetalle ADD CantidadEntregada INT;

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
	WHERE
		L.Activo = 1
		AND L.EsPorcentual = 1
		AND DEFINIDO.ProductoPrecioId IS NULL --Y QUE NO ESTÉ DEFINIDO DENTRO DE LA LISTA PORCENTUAL
		

GO

CREATE PROCEDURE spStockListaReport
	@DepositoId INT = NULL
AS
BEGIN

	--GENERAMOS LA GRILLA DE MOVIMIENTOS EN UNA TABLA TEMPORAL
	SELECT
		D.Descripcion AS Deposito,
		'(' + P.Codigo + ') ' + MA.Descripcion + ' ' + P.DescripcionCorta AS Producto,
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
		INNER JOIN Marca MA WITH(NOLOCK) ON MA.MarcaId = P.MarcaId
	WHERE
		M.DepositoId = COALESCE(@DepositoId, M.DepositoId)
	GROUP BY
		MA.Descripcion, P.Codigo, P.DescripcionCorta, D.Descripcion
	ORDER BY
		D.Descripcion, MA.Descripcion, P.Codigo, P.DescripcionCorta

END

GO

