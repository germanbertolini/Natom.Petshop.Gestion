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
		OP.EntregaEstimadaFecha AS EntregaFecha,
		RH.Descripcion AS EntregaRangoHorario,
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
		INNER JOIN RangoHorario RH WITH(NOLOCK) ON RH.RangoHorarioId = OP.EntregaEstimadaRangoHorarioId
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

ALTER PROCEDURE [dbo].[spPrecioGet]
(
	@ListaDePreciosId INT = NULL,
	@ProductoId INT
)
AS
BEGIN

	SELECT
		ProductoPrecioId,
		Precio,
		ListaDePreciosId
	FROM
		vwPreciosVigentes PV
	WHERE
		PV.ListaDePreciosId = COALESCE(@ListaDePreciosId, PV.ListaDePreciosId)
		AND PV.ProductoId = @ProductoId;

END

GO

