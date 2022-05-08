CREATE FUNCTION fn_calcular_saldo_disponible_cliente (
	@ClienteId INT
) RETURNS DECIMAL(18,2)
AS
BEGIN

	DECLARE @MontoCtaCte DECIMAL(18,2) = COALESCE((SELECT MontoCtaCte FROM Cliente WHERE ClienteId = @ClienteId), 0);
	DECLARE @Saldo DECIMAL(18,2);

	SELECT
		@Saldo = COALESCE(SUM(CASE WHEN Tipo = 'C' THEN Importe ELSE -Importe END), 0)
	FROM
		MovimientoCtaCteCliente WITH(NOLOCK)
	WHERE
		ClienteId = @ClienteId

	RETURN @MontoCtaCte + @Saldo;

END

GO

CREATE FUNCTION fn_calcular_saldo_cliente (
	@ClienteId INT
) RETURNS DECIMAL(18,2)
AS
BEGIN

	DECLARE @Saldo DECIMAL(18,2);

	SELECT
		@Saldo = COALESCE(SUM(CASE WHEN Tipo = 'C' THEN Importe ELSE -Importe END), 0)
	FROM
		MovimientoCtaCteCliente WITH(NOLOCK)
	WHERE
		ClienteId = @ClienteId

	RETURN @Saldo;

END

GO

ALTER PROCEDURE [dbo].[spReportVenta]
	@VentaId INT
AS
BEGIN

	DECLARE @ClienteId INT = (SELECT ClienteId FROM Venta WHERE VentaId = @VentaId);
	DECLARE @SaldoCliente DECIMAL(18,2) = (SELECT [dbo].[fn_calcular_saldo_cliente](@ClienteId));

	SELECT
		CASE WHEN CHARINDEX('-',REVERSE(TipoFactura)) = 0 THEN 
			SUBSTRING(TipoFactura, 1, 1)
		ELSE
			SUBSTRING(TipoFactura, LEN(TipoFactura) - CHARINDEX('-',REVERSE(TipoFactura)) + 2, LEN(TipoFactura))
		END AS LetraComprobante,
		CASE WHEN TipoFactura LIKE 'FCE%' THEN
			'FACTURA ELECTRÓNICA'
		WHEN TipoFactura LIKE 'FC%' THEN
			'FACTURA'
		WHEN TipoFactura = 'PRE' THEN
			'PRESUPUESTO'
		WHEN TipoFactura = 'RBO' THEN
			'RECIBO'
		END AS Comprobante,
		REPLACE(STR(V.NumeroVenta, 8), SPACE(1), '0') AS VentaNumero,
		V.NumeroFactura AS NumeroComprobante,
		V.FechaHoraVenta AS FechaHora,
		CASE WHEN C.EsEmpresa = 1 THEN C.RazonSocial ELSE CONCAT(C.Nombre, ' ', C.Apellido) END AS Cliente,
		CASE WHEN C.EsEmpresa = 1 THEN CONCAT('CUIT ', C.NumeroDocumento) ELSE CONCAT('DNI ', C.NumeroDocumento) END AS ClienteDocumento,
		C.Domicilio AS ClienteDomicilio,
		C.Localidad AS ClienteLocalidad,
		@SaldoCliente AS ClienteSaldo,
		dbo.fnVentaGetRemitos(V.VentaId) AS Remitos,
		CASE WHEN V.UsuarioId = 0 THEN 'Admin' ELSE CONCAT(U.Nombre, ' ', U.Apellido) END AS FacturadoPor,
		V.Observaciones,
		CASE WHEN V.Activo = 0 THEN 'ANULADA' ELSE '' END AS Anulado,
		V.MontoTotal,
		CAST(V.PesoTotalEnGramos AS decimal(18,2)) / 1000 AS PesoTotalEnKilogramos,--
		P.Codigo AS DetalleCodigo,
		P.DescripcionCorta AS DetalleDescripcion,
		CASE WHEN OP.NumeroRemito IS NULL THEN '' ELSE OP.NumeroRemito END AS DetalleRemito,
		D.Cantidad AS DetalleCantidad,
		CAST(D.PesoUnitarioEnGramos AS decimal(18,2)) / 1000 AS DetallePesoUnitarioEnKilogramos,--
		D.Precio AS DetallePrecioUnitario,
		(CAST(D.PesoUnitarioEnGramos AS decimal(18,2)) / 1000) * D.Cantidad AS DetallePesoTotalEnKilogramos,--
		(D.Precio) * D.Cantidad AS DetallePrecioTotal,
		L.Descripcion AS DetalleListaDePrecios
	FROM
		Venta V WITH(NOLOCK)
		INNER JOIN Cliente C WITH(NOLOCK) ON C.ClienteId = V.ClienteId
		LEFT JOIN Usuario U WITH(NOLOCK) ON U.UsuarioId = V.UsuarioId
		INNER JOIN VentaDetalle D WITH(NOLOCK) ON D.VentaId = V.VentaId
		LEFT JOIN OrdenDePedidoDetalle OPD WITH(NOLOCK) ON OPD.OrdenDePedidoDetalleId = D.OrdenDePedidoDetalleId
		LEFT JOIN OrdenDePedido OP WITH(NOLOCK) ON OP.OrdenDePedidoId = OPD.OrdenDePedidoId AND OP.NumeroRemito IS NOT NULL AND OP.NumeroRemito != ''
		INNER JOIN Producto P WITH(NOLOCK) ON P.ProductoId = D.ProductoId
		LEFT JOIN ListaDePrecios L WITH(NOLOCK) ON L.ListaDePreciosId = D.ListaDePreciosId
	WHERE
		V.VentaId = @VentaId

END