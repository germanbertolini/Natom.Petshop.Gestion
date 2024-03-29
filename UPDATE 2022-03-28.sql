USE [PetShop_Gestion]
GO
/****** Object:  StoredProcedure [dbo].[spStockListaReport]    Script Date: 28/3/2022 20:00:08 ******/
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
		CASE WHEN P.Codigo IS NULL THEN
			P.DescripcionCorta
		ELSE
			'(' + P.Codigo + ') ' + /* MA.Descripcion + ' ' +*/ P.DescripcionCorta
		END AS Producto,
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
		AND P.Activo = 1
	GROUP BY
		MA.Descripcion, P.Codigo, P.DescripcionCorta, /* D.Descripcion, */ C.CategoriaProductoId, C.Descripcion
	ORDER BY
		C.CategoriaProductoId, /* D.Descripcion, */ /* MA.Descripcion, */ /* P.Codigo, */ P.DescripcionCorta

END

GO

ALTER PROCEDURE [dbo].[spReportOrdenDePedido]
	@OrdenDePedido INT
AS
BEGIN

	SELECT
		REPLACE(STR(OP.NumeroPedido, 8), SPACE(1), '0') AS Numero,
		OP.FechaHoraPedido AS FechaHora,
		CASE WHEN C.EsEmpresa = 1 THEN C.RazonSocial ELSE CONCAT(C.Nombre, ' ', C.Apellido) END AS Cliente,
		CASE WHEN C.EsEmpresa = 1 THEN CONCAT('CUIT ', C.NumeroDocumento) ELSE CONCAT('DNI ', C.NumeroDocumento) END AS ClienteDocumento,
		C.Domicilio AS ClienteDomicilio,
		C.Localidad AS ClienteLocalidad,
		CASE WHEN OP.NumeroRemito IS NULL OR OP.NumeroRemito = '' THEN '- SIN REMITO -' ELSE OP.NumeroRemito END AS RemitoNumero,
		CASE WHEN OP.VentaId IS NULL THEN '- Pendiente -' ELSE REPLACE(STR(V.NumeroVenta, 8), SPACE(1), '0') END AS VentaNumero,
		CASE WHEN OP.VentaId IS NULL THEN '- Pendiente -' ELSE CONCAT(V.TipoFactura, ' ', V.NumeroFactura) END AS VentaComprobante,
		COALESCE(convert(varchar, OP.EntregaEstimadaFecha, 3), '- Sin especificar -') AS EntregaFecha,
		COALESCE(RH.Descripcion, '- Sin especificar -') AS EntregaRangoHorario,
		CASE WHEN OP.RetiraPersonalmente = 1 THEN '- Retira personalmente -' ELSE OP.EntregaDomicilio END AS EntregaDomicilio,
		CASE WHEN OP.RetiraPersonalmente = 1 THEN '' ELSE OP.EntregaEntreCalles END AS EntregaEntreCalles,
		CASE WHEN OP.RetiraPersonalmente = 1 THEN '' ELSE OP.EntregaLocalidad END AS EntregaLocalidad,
		OP.EntregaTelefono1 AS EntregaTelefono1,
		OP.EntregaTelefono2 AS EntregaTelefono2,
		OP.EntregaObservaciones,
		CASE WHEN OP.UsuarioId = 0 THEN 'Admin' ELSE CONCAT(U.Nombre, ' ', U.Apellido) END AS CargadoPor,
		OP.Observaciones,
		CASE WHEN OP.Activo = 0 THEN 'ANULADO' ELSE '' END AS Anulado,
		CASE WHEN V.VentaId IS NOT NULL THEN 'FACTURADO' ELSE '' END AS Facturado,
		CASE WHEN OP.MarcoEntregaFechaHora IS NOT NULL THEN 'ENTREGADO' ELSE '' END AS Entregado,
		OP.MontoTotal,
		(CAST(OP.PesoTotalEnGramos AS decimal(18,2)) / 1000) AS PesoTotalEnKilogramos,
		P.Codigo AS DetalleCodigo,
		P.DescripcionCorta AS DetalleDescripcion,
		D.Cantidad AS DetalleCantidad,
		CAST(D.PesoUnitarioEnGramos AS decimal(18,2)) / 1000 AS DetallePesoUnitarioEnKilogramos,
		D.Precio AS DetallePrecioUnitario,
		D.Precio * D.Cantidad AS DetallePrecioTotal,
		(CAST(D.PesoUnitarioEnGramos AS decimal(18,2)) * D.Cantidad) / 1000 AS DetallePesoTotalEnKilogramos,
		DEPO.Descripcion AS DetalleDeposito,
		L.Descripcion AS DetalleListaDePrecios,
		CASE WHEN V.VentaId IS NOT NULL THEN 'PAGADO' ELSE '' END AS Pagado
	FROM
		OrdenDePedido OP WITH(NOLOCK)
		LEFT JOIN RangoHorario RH WITH(NOLOCK) ON RH.RangoHorarioId = OP.EntregaEstimadaRangoHorarioId
		INNER JOIN Cliente C WITH(NOLOCK) ON C.ClienteId = OP.ClienteId
		LEFT JOIN Venta V WITH(NOLOCK) ON V.VentaId = OP.VentaId AND V.Activo = 1
		LEFT JOIN Usuario U WITH(NOLOCK) ON U.UsuarioId = OP.UsuarioId
		INNER JOIN OrdenDePedidoDetalle D WITH(NOLOCK) ON D.OrdenDePedidoId = OP.OrdenDePedidoId
		INNER JOIN Producto P WITH(NOLOCK) ON P.ProductoId = D.ProductoId
		INNER JOIN Deposito DEPO WITH(NOLOCK) ON DEPO.DepositoId = D.DepositoId
		LEFT JOIN ListaDePrecios L WITH(NOLOCK) ON L.ListaDePreciosId = D.ListaDePreciosId
	WHERE
		OP.OrdenDePedidoId = @OrdenDePedido

END

GO

ALTER PROCEDURE [dbo].[spReportRemito]
	@OrdenDePedido INT
AS
BEGIN

	SELECT
		REPLACE(STR(OP.NumeroPedido, 8), SPACE(1), '0') AS Numero,
		OP.FechaHoraPedido AS FechaHora,
		CASE WHEN C.EsEmpresa = 1 THEN C.RazonSocial ELSE CONCAT(C.Nombre, ' ', C.Apellido) END AS Cliente,
		CASE WHEN C.EsEmpresa = 1 THEN CONCAT('CUIT ', C.NumeroDocumento) ELSE CONCAT('DNI ', C.NumeroDocumento) END AS ClienteDocumento,
		C.Domicilio AS ClienteDomicilio,
		C.Localidad AS ClienteLocalidad,
		CASE WHEN OP.NumeroRemito IS NULL OR OP.NumeroRemito = '' THEN '- SIN REMITO -' ELSE OP.NumeroRemito END AS RemitoNumero,
		CASE WHEN OP.VentaId IS NULL THEN '- Pendiente -' ELSE REPLACE(STR(V.NumeroVenta, 8), SPACE(1), '0') END AS VentaNumero,
		CASE WHEN OP.VentaId IS NULL THEN '- Pendiente -' ELSE CONCAT(V.TipoFactura, ' ', V.NumeroFactura) END AS VentaComprobante,
		COALESCE(convert(varchar, OP.EntregaEstimadaFecha, 3), '- Sin especificar -') AS EntregaFecha,
		COALESCE(RH.Descripcion, '- Sin especificar -') AS EntregaRangoHorario,
		CASE WHEN OP.RetiraPersonalmente = 1 THEN '- Retira personalmente -' ELSE OP.EntregaDomicilio END AS EntregaDomicilio,
		CASE WHEN OP.RetiraPersonalmente = 1 THEN '' ELSE OP.EntregaEntreCalles END AS EntregaEntreCalles,
		CASE WHEN OP.RetiraPersonalmente = 1 THEN '' ELSE OP.EntregaLocalidad END AS EntregaLocalidad,
		OP.EntregaTelefono1 AS EntregaTelefono1,
		OP.EntregaTelefono2 AS EntregaTelefono2,
		OP.EntregaObservaciones,
		CASE WHEN OP.UsuarioId = 0 THEN 'Admin' ELSE CONCAT(U.Nombre, ' ', U.Apellido) END AS CargadoPor,
		OP.Observaciones,
		CASE WHEN OP.Activo = 0 THEN 'ANULADO' ELSE '' END AS Anulado,
		CASE WHEN V.VentaId = 1 THEN 'FACTURADO' ELSE '' END AS Facturado,
		CASE WHEN OP.MarcoEntregaFechaHora IS NOT NULL THEN 'ENTREGADO' ELSE '' END AS Entregado,
		OP.MontoTotal,
		CAST(OP.PesoTotalEnGramos AS decimal(18,2)) / 1000 AS PesoTotalEnKilogramos,
		P.Codigo AS DetalleCodigo,
		P.DescripcionCorta AS DetalleDescripcion,
		D.Cantidad AS DetalleCantidad,
		CAST(D.PesoUnitarioEnGramos AS decimal(18,2)) / 1000 AS DetallePesoUnitarioEnKilogramos,
		D.Precio AS DetallePrecioUnitario,
		(CAST(D.PesoUnitarioEnGramos AS decimal(18,2)) / 1000) * D.Cantidad AS DetallePesoTotalEnKilogramos,
		(D.Precio) * D.Cantidad AS DetallePrecioTotal,
		DEPO.Descripcion AS DetalleDeposito,
		L.Descripcion AS DetalleListaDePrecios
	FROM
		OrdenDePedido OP WITH(NOLOCK)
		LEFT JOIN RangoHorario RH WITH(NOLOCK) ON RH.RangoHorarioId = OP.EntregaEstimadaRangoHorarioId
		INNER JOIN Cliente C WITH(NOLOCK) ON C.ClienteId = OP.ClienteId
		LEFT JOIN Venta V WITH(NOLOCK) ON V.VentaId = OP.VentaId AND V.Activo = 1
		LEFT JOIN Usuario U WITH(NOLOCK) ON U.UsuarioId = OP.UsuarioId
		INNER JOIN OrdenDePedidoDetalle D WITH(NOLOCK) ON D.OrdenDePedidoId = OP.OrdenDePedidoId
		INNER JOIN Producto P WITH(NOLOCK) ON P.ProductoId = D.ProductoId
		INNER JOIN Deposito DEPO WITH(NOLOCK) ON DEPO.DepositoId = D.DepositoId
		LEFT JOIN ListaDePrecios L WITH(NOLOCK) ON L.ListaDePreciosId = D.ListaDePreciosId
	WHERE
		OP.OrdenDePedidoId = @OrdenDePedido

END