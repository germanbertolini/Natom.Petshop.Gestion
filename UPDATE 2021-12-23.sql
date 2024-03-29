USE PetShop_Gestion;
GO

CREATE TABLE Proveedor
(
	ProveedorId INT NOT NULL IDENTITY(1,1),
	EsEmpresa BIT,
	Nombre NVARCHAR(50),
	Apellido NVARCHAR(50),
	RazonSocial NVARCHAR(50),
	NombreFantasia NVARCHAR(50),
	TipoDocumentoId INT,
	NumeroDocumento NVARCHAR(20),
	Domicilio NVARCHAR(50),
	EntreCalles NVARCHAR(50),
	Localidad NVARCHAR(50),
	ContactoTelefono1 NVARCHAR(30),
	ContactoTelefono2 NVARCHAR(30),
	ContactoEmail1 NVARCHAR(50),
	ContactoEmail2 NVARCHAR(50),
	ContactoObservaciones NVARCHAR(200),
	Activo BIT NOT NULL,
	PRIMARY KEY (ProveedorId),
	FOREIGN KEY (TipoDocumentoId) REFERENCES TipoDocumento(TipoDocumentoId)
);

GO

ALTER TABLE MovimientoStock ADD
	EsCompra BIT NOT NULL DEFAULT 0,
	ProveedorId INT,
	CostoUnitario DECIMAL(18,2);

GO

INSERT INTO Permiso
	VALUES 
		('PROVEEDORES_VER', 'Proveedores: Consultar'),
		('PROVEEDORES_CRUD', 'Proveedores: Alta, Baja, Modificaci�n');

GO

ALTER TABLE Proveedor ADD EsPresupuesto BIT NOT NULL DEFAULT 0;

GO

INSERT INTO Deposito VALUES ('Local', 1);

GO

ALTER TABLE Producto ADD ProveedorId INT;

GO

ALTER TABLE MovimientoCajaDiaria ADD EsCheque BIT NOT NULL DEFAULT 0;
ALTER TABLE MovimientoCajaFuerte ADD EsCheque BIT NOT NULL DEFAULT 0;

GO

DELETE FROM ProductoPrecio WHERE ListaDePreciosId != 1;

GO

ALTER TABLE ListaDePrecios ADD EsPorcentual BIT NOT NULL DEFAULT 0, IncrementoPorcentaje DECIMAL(18,2), IncrementoDeListaDePreciosId INT;

GO

UPDATE ListaDePrecios SET EsPorcentual = 1, IncrementoPorcentaje = -15, IncrementoDeListaDePreciosId = 1 WHERE ListaDePreciosId = 2;
UPDATE ListaDePrecios SET EsPorcentual = 1, IncrementoPorcentaje = -20, IncrementoDeListaDePreciosId = 1 WHERE ListaDePreciosId = 3;

GO

INSERT INTO ListaDePrecios (Descripcion, Activo, EsPorcentual, IncrementoPorcentaje, IncrementoDeListaDePreciosId) VALUES ('Lista de precios 4', 1, 1, -21.6, 1);

GO

CREATE VIEW [dbo].[vwPreciosVigentesFijados]
AS
	SELECT
		ProductoPrecioId,
		ProductoId,
		ListaDePreciosId,
		Precio,
		AplicaDesdeFechaHora,
		HistoricoReajustePrecioId
	FROM
		ProductoPrecio WITH(NOLOCK)
	WHERE
		ProductoPrecioId IN (SELECT MAX(ProductoPrecioId) FROM ProductoPrecio WITH(NOLOCK) WHERE FechaHoraBaja IS NULL GROUP BY ProductoId, ListaDePreciosId);

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
			ROUND(P.Precio / (((L.IncrementoPorcentaje * -1) / 100) + 1), 2)
		ELSE
			ROUND(P.Precio * ((L.IncrementoPorcentaje / 100) + 1), 2)
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


ALTER PROCEDURE [dbo].[spPreciosList]
(
	@ListaDePreciosId INT
)
AS
BEGIN

	DECLARE @Cantidad INT = (SELECT COUNT(*) FROM vwPreciosVigentes WHERE ListaDePreciosId = COALESCE(@ListaDePreciosId, ListaDePreciosId));

	SELECT
		PV.ProductoPrecioId,
		P.ProductoId,
		'(' + P.Codigo + ') ' + M.Descripcion + ' ' + P.DescripcionCorta AS ProductoDescripcion,
		L.ListaDePreciosId,
		L.Descripcion AS ListaDePrecioDescripcion,
		L.EsPorcentual AS ListaDePreciosEsPorcentual,
		PV.AplicaDesdeFechaHora,
		PV.Precio,
		@Cantidad AS CantidadRegistros
	FROM
		vwPreciosVigentes PV
		INNER JOIN Producto P WITH(NOLOCK) ON P.ProductoId = PV.ProductoId
		INNER JOIN Marca M WITH(NOLOCK) ON M.MarcaId = P.MarcaId
		INNER JOIN ListaDePrecios L WITH(NOLOCK) ON L.ListaDePreciosId = PV.ListaDePreciosId
	WHERE
		PV.ListaDePreciosId = COALESCE(@ListaDePreciosId, PV.ListaDePreciosId);

END

GO

CREATE PROCEDURE [dbo].[spPrecioGet]
(
	@ListaDePreciosId INT,
	@ProductoId INT
)
AS
BEGIN

	SELECT
		Precio
	FROM
		vwPreciosVigentes PV
	WHERE
		PV.ListaDePreciosId = @ListaDePreciosId
		AND PV.ProductoId = @ProductoId;

END

GO

ALTER TABLE MovimientoStock ADD FechaHoraControlado DATETIME, ControladoUsuarioId INT;

GO

ALTER PROCEDURE [dbo].[spMovimientosStockList]
(
	@DepositoId INT = NULL,
	@ProductoId INT = NULL,
	@Search NVARCHAR(100) = NULL,
	@Skip INT,
	@Take INT,
	@Fecha DATE = NULL
)
AS
BEGIN

	--GENERAMOS LA GRILLA DE MOVIMIENTOS EN UNA TABLA TEMPORAL
	SELECT
		M.MovimientoStockId,
		M.FechaHora,
		M.FechaHoraControlado,
		D.Descripcion AS Deposito,
		P.ProductoId,
		'(' + P.Codigo + ') ' + MA.Descripcion + ' ' + P.DescripcionCorta AS Producto,
		M.Tipo,
		CASE WHEN M.Tipo = 'I' AND M.ConfirmacionFechaHora IS NOT NULL THEN
			M.Cantidad
		WHEN M.Tipo = 'E' AND M.ConfirmacionFechaHora IS NOT NULL THEN
			M.Cantidad * -1
		ELSE
			NULL
		END AS Movido,
		CASE WHEN M.Tipo = 'I' AND M.ConfirmacionFechaHora IS NULL THEN
			M.Cantidad
		WHEN M.Tipo = 'E' AND M.ConfirmacionFechaHora IS NULL THEN
			M.Cantidad * -1
		ELSE
			NULL
		END AS Reservado,
		M.Observaciones
	INTO
		#MOVIMIENTOS_STOCK
	FROM
		MovimientoStock M WITH(NOLOCK)
		INNER JOIN Deposito D WITH(NOLOCK) ON D.DepositoId = M.DepositoId
		INNER JOIN Producto P WITH(NOLOCK) ON P.ProductoId = M.ProductoId
		INNER JOIN Marca MA WITH(NOLOCK) ON MA.MarcaId = P.MarcaId
	WHERE
		M.DepositoId = COALESCE(@DepositoId, M.DepositoId)
		AND M.ProductoId = COALESCE(@ProductoId, M.ProductoId)
		AND CAST(M.FechaHora AS DATE) = COALESCE(@Fecha, CAST(M.FechaHora AS DATE))
	ORDER BY
		M.MovimientoStockId DESC
		

	--TOMAMOS LA CANTIDAD DE REGISTROS EN LA GRILLA
	DECLARE @CantidadRegistros INT = COALESCE((SELECT COUNT(*) FROM #MOVIMIENTOS_STOCK), 0);


	--AHORA SELECCIONAMOS EL RANGO DE REGISTROS A MOSTRAR APLICANDO FILTROS
	SELECT
		M.MovimientoStockId,
		M.FechaHora,
		M.FechaHoraControlado,
		M.Deposito,
		M.Producto,
		M.Tipo,
		M.Movido,
		M.Reservado,
		M.Observaciones,
		[dbo].[fnCalcularStockAlMovimiento](M.MovimientoStockId, @DepositoId, M.ProductoId) AS Stock,
		@CantidadRegistros AS CantidadRegistros
	INTO
		#MOVIMIENTOS_STOCK_FILTRADOS
	FROM
		#MOVIMIENTOS_STOCK M
	WHERE
		1 = 1
		AND
		(
			@Search IS NULL
			OR
			(
				@Search IS NOT NULL
				AND
				(
					M.Deposito LIKE '%' + @Search + '%'
					OR M.Producto LIKE '%' + @Search + '%'
					OR M.Observaciones LIKE '%' + @Search + '%'
				)
			)
		);


	--TOMAMOS LA CANTIDAD DE REGISTROS FILTRADOS EN LA GRILLA
	DECLARE @CantidadFiltrados INT = COALESCE((SELECT COUNT(*) FROM #MOVIMIENTOS_STOCK_FILTRADOS), 0);

	SELECT
		*,
		@CantidadFiltrados AS CantidadFiltrados
	FROM
		#MOVIMIENTOS_STOCK_FILTRADOS M
	ORDER BY
		M.MovimientoStockId DESC
	OFFSET @Skip ROWS
	FETCH NEXT @Take ROWS ONLY;

END

GO

INSERT INTO Permiso (PermisoId, Descripcion) VALUES ('STOCK_CONTROL', 'Stock: Conteo y control');

GO

UPDATE Permiso SET Descripcion = 'Tesorer�a: Registrar movimientos' WHERE PermisoId = 'CAJA_FUERTE_NUEVO_MOVIMIENTO';
UPDATE Permiso SET Descripcion = 'Tesorer�a: Ver movimientos' WHERE PermisoId = 'CAJA_FUERTE_VER';

GO

INSERT INTO Permiso (PermisoId, Descripcion) 
VALUES ('REPORTES_LISTADO_VENTAS_POR_PRODUCTO', 'Reporte: Listado de ventas por producto y/o proveedor'),
('REPORTES_LISTADO_CLIENTES_QUE_NO_COMPRAN', 'Reporte: Listado de clientes que no compran desde una cierta fecha'),
('REPORTES_ESTADISTICA_KILOS_COMPRADOS_POR_PROVEEDOR', 'Reporte: Estad�stica de kilos comprados por cada proveedor'),
('REPORTES_ESTADISTICA_VENTAS_REPARTO_MOSTRADOR', 'Reporte: Estad�stica de cu�nto vendi� reparto vs mostrador'),
('REPORTES_ESTADISTICA_VENTAS_POR_LISTA_DE_PRECIOS', 'Reporte: Estad�stica de cu�nto se vendi� por cada lista de precios'),
('REPORTES_COMPRAS', 'Reporte: Compras'),
('REPORTES_GANANCIAS', 'Reporte: Ganancias');

GO

CREATE PROCEDURE spReportOrdenDePedido
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
		CASE WHEN V.VentaId = 1 THEN 'FACTURADO' ELSE '' END AS Facturado,
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
		L.Descripcion AS DetalleListaDePrecios
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

CREATE PROCEDURE spReportRemito
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

CREATE FUNCTION fnVentaGetRemitos
(
	@VentaId INT
) RETURNS NVARCHAR(MAX)
AS
BEGIN

	DECLARE @Return NVARCHAR(MAX) = '';

	SELECT
		@Return = STRING_AGG(CONCAT('RTO ', R.NumeroRemito), ', ')
	FROM
	(
		SELECT DISTINCT
			V.VentaId,
			OP.NumeroRemito
		FROM
			Venta V WITH(NOLOCK)
			INNER JOIN VentaDetalle D WITH(NOLOCK) ON D.VentaId = V.VentaId
			INNER JOIN OrdenDePedidoDetalle OPD WITH(NOLOCK) ON OPD.OrdenDePedidoDetalleId = D.OrdenDePedidoDetalleId
			INNER JOIN OrdenDePedido OP WITH(NOLOCK) ON OP.OrdenDePedidoId = OPD.OrdenDePedidoId AND OP.NumeroRemito IS NOT NULL AND OP.NumeroRemito != '' AND OP.Activo = 1
		WHERE
			V.VentaId = @VentaId
	) AS R
	GROUP BY
		R.VentaId;

	RETURN @Return;

END

GO

CREATE PROCEDURE spReportVenta
	@VentaId INT
AS
BEGIN

	SELECT
		CASE WHEN CHARINDEX('-',REVERSE(TipoFactura)) = 0 THEN 
			SUBSTRING(TipoFactura, 1, 1)
		ELSE
			SUBSTRING(TipoFactura, LEN(TipoFactura) - CHARINDEX('-',REVERSE(TipoFactura)) + 2, LEN(TipoFactura))
		END AS LetraComprobante,
		CASE WHEN TipoFactura LIKE 'FCE%' THEN
			'FACTURA ELECTR�NICA'
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
		dbo.fnVentaGetRemitos(V.VentaId) AS Remitos,
		CASE WHEN V.UsuarioId = 0 THEN 'Admin' ELSE CONCAT(U.Nombre, ' ', U.Apellido) END AS FacturadoPor,
		V.Observaciones,
		CASE WHEN V.Activo = 0 THEN 'ANULADA' ELSE '' END AS Anulado,
		V.MontoTotal,
		CAST(V.PesoTotalEnGramos AS decimal(18,2)) / 1000 AS PesoTotalEnKilogramos,
		P.Codigo AS DetalleCodigo,
		P.DescripcionCorta AS DetalleDescripcion,
		CASE WHEN OP.NumeroRemito IS NULL THEN '' ELSE OP.NumeroRemito END AS DetalleRemito,
		D.Cantidad AS DetalleCantidad,
		CAST(D.PesoUnitarioEnGramos AS decimal(18,2)) / 1000 AS DetallePesoUnitarioEnKilogramos,
		D.Precio AS DetallePrecioUnitario,
		(CAST(D.PesoUnitarioEnGramos AS decimal(18,2)) / 1000) * D.Cantidad AS DetallePesoTotalEnKilogramos,
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

GO

CREATE PROCEDURE spVentasPorProductoProveedorReport
(
	@ProductoId INT,
	@ProveedorId INT,
	@Desde DATE,
	@Hasta DATE
)
AS
BEGIN

	SELECT
		COALESCE(OP.FechaHoraPedido, V.FechaHoraVenta) AS FechaHora,
		CASE WHEN OP.OrdenDePedidoId IS NULL THEN 'Mostrador' ELSE 'Reparto' END AS VendidoPor,
		CASE WHEN OP.OrdenDePedidoId IS NULL THEN 'VTA ' + REPLACE(STR(V.NumeroVenta, 8), SPACE(1), '0') ELSE 'OP ' + REPLACE(STR(OP.NumeroPedido, 8), SPACE(1), '0') END AS Operacion,
		'RTO ' + OP.NumeroRemito AS Remito,
		REPLACE(STR(V.NumeroVenta, 8), SPACE(1), '0') AS Venta,
		V.TipoFactura + '-' + V.NumeroFactura AS ComprobanteVenta,
		CASE WHEN PR.EsEmpresa = 1 THEN PR.RazonSocial ELSE PR.Nombre + ' ' + PR.Apellido END AS Proveedor,
		CONCAT(P.Codigo, ' ', P.DescripcionCorta) AS Producto,
		D.Cantidad,
		(CAST(D.PesoUnitarioEnGramos AS decimal(18,2)) / 1000) * D.Cantidad AS PesoTotalKilos,
		D.Precio * D.Cantidad AS MontoTotal
	FROM
		VentaDetalle D WITH(NOLOCK)
		INNER JOIN Venta V WITH(NOLOCK) ON V.VentaId = D.VentaId AND V.Activo = 1
		INNER JOIN Producto P WITH(NOLOCK) ON P.ProductoId = D.ProductoId
		LEFT JOIN Proveedor PR WITH(NOLOCK) ON PR.ProveedorId = P.ProveedorId
		LEFT JOIN OrdenDePedidoDetalle OPD WITH(NOLOCK) ON OPD.OrdenDePedidoDetalleId = D.OrdenDePedidoDetalleId
		LEFT JOIN OrdenDePedido OP WITH(NOLOCK) ON OP.OrdenDePedidoId = OPD.OrdenDePedidoDetalleId AND OP.Activo = 1
	WHERE
		P.ProductoId = COALESCE(@ProductoId, P.ProductoId)
		AND P.ProveedorId = COALESCE(@ProveedorId, P.ProveedorId)
		AND COALESCE(OP.FechaHoraPedido, V.FechaHoraVenta) >= @Desde AND COALESCE(OP.FechaHoraPedido, V.FechaHoraVenta) <= @Hasta
	ORDER BY
		P.Codigo, P.DescripcionCorta, PR.RazonSocial, PR.Nombre, PR.Apellido

END

GO

CREATE VIEW vwClientesUltimaCompra
AS

	SELECT
		MAX(R.FechaHora) AS FechaHora,
		R.ClienteId
	FROM
	(
		SELECT
			MAX(COALESCE(OP.FechaHoraPedido, V.FechaHoraVenta)) AS FechaHora,
			V.ClienteId
		FROM
			Venta V WITH(NOLOCK)
			LEFT JOIN OrdenDePedido OP WITH(NOLOCK) ON OP.VentaId = V.VentaId
		WHERE
			V.Activo = 1
		GROUP BY
			V.ClienteId

		UNION

		SELECT
			MAX(OP.FechaHoraPedido) AS FechaHora,
			OP.ClienteId
		FROM
			OrdenDePedido OP WITH(NOLOCK)
		WHERE
			OP.Activo = 1
			AND OP.VentaId IS NULL
		GROUP BY
			OP.ClienteId
	) AS R
	GROUP BY
		R.ClienteId

GO

CREATE PROCEDURE spClientesQueNoCompranDesdeFechaReport
(
	@Desde DATE
)
AS
BEGIN

	SELECT
		CASE WHEN C.EsEmpresa = 1 THEN
			C.RazonSocial
		ELSE
			C.Nombre + ' ' + C.Apellido
		END AS Cliente,
		CASE WHEN C.EsEmpresa = 1 THEN
			'CUIT ' + C.NumeroDocumento
		ELSE
			'DNI ' + C.NumeroDocumento
		END AS Documento,
		UC.FechaHora AS FechaHoraUltimaCompra
	FROM
		Cliente C WITH(NOLOCK)
		INNER JOIN vwClientesUltimaCompra UC ON UC.ClienteId = C.ClienteId
	WHERE
		UC.FechaHora <= @Desde
	ORDER BY
		UC.FechaHora DESC;


END

GO

CREATE PROCEDURE spKilosCompradosPorProveedorReport
(
	@Desde DATE = NULL
)
AS
BEGIN

	SELECT
		SUM(M.Cantidad * CAST(P.PesoUnitario AS decimal(18,2)) * UP.Gramos / 1000) AS TotalKilosComprados,
		CASE WHEN PR.EsEmpresa = 1THEN
			PR.RazonSocial
		ELSE
			PR.Nombre + ' ' + PR.Apellido
		END AS Proveedor,
		CASE WHEN PR.EsEmpresa = 1 THEN
			'CUIT ' + PR.NumeroDocumento
		ELSE
			'DNI ' + PR.NumeroDocumento
		END AS Documento
	FROM
		MovimientoStock M WITH(NOLOCK)
		INNER JOIN Proveedor PR WITH(NOLOCK) ON PR.ProveedorId = M.ProveedorId
		INNER JOIN Producto P WITH(NOLOCK) ON P.ProductoId = M.ProductoId
		INNER JOIN UnidadPeso UP WITH(NOLOCK) ON UP.UnidadPesoId = P.UnidadPesoId
	WHERE
		M.Tipo = 'I'
		AND M.EsCompra = 1
		AND M.FechaHora >= COALESCE(@Desde, M.FechaHora)
	GROUP BY
		PR.ProveedorId, PR.RazonSocial, PR.Nombre, PR.Apellido, PR.EsEmpresa, PR.NumeroDocumento
	ORDER BY
		SUM(M.Cantidad * CAST(P.PesoUnitario AS decimal(18,2)) / 1000) DESC;


END

GO

CREATE FUNCTION fnCalcularVariacion
(
	@Valor1 DECIMAL(18,2),
	@Valor2 DECIMAL(18,2)
) RETURNS DECIMAL(18,2)
AS
BEGIN

	DECLARE @Variacion DECIMAL(18,2) = 0

	IF @Valor1 > @Valor2
		BEGIN
			IF @Valor2 = 0
				SET @Valor2 = 1

			SET @Variacion = @Valor1 / @Valor2 * 100
		END
	ELSE IF @Valor2 > @Valor1
		BEGIN
			IF @Valor1 = 0
				SET @Valor1 = 1

			SET @Variacion = (@Valor2 / @Valor1 * 100) * -1
		END

	RETURN ROUND(@Variacion / 100, 2) --LO DIVIDO POR 100 PORQUE EL REPORT rdlc AL PORCENTAJE LO HACE * 100!!

END

GO


CREATE PROCEDURE spVentasRepartoVsMostradorReport
(
	@Desde DATE
)
AS
BEGIN

	SELECT
		J.Codigo,
		J.Descripcion,
		J.CantidadMostrador,
		J.VariacionCantidadMostrador,
		CASE WHEN J.VariacionCantidadMostrador < 0 THEN 'Red'
		WHEN J.VariacionCantidadMostrador = 0 THEN 'Black'
		ELSE 'Green' END AS ColorVariacionCantidadMostrador,
		J.KilosMostrador,
		J.VariacionKilosMostrador,
		CASE WHEN J.VariacionKilosMostrador < 0 THEN 'Red'
		WHEN J.VariacionKilosMostrador = 0 THEN 'Black'
		ELSE 'Green' END AS ColorVariacionKilosMostrador,
		J.CantidadReparto,
		J.VariacionCantidadReparto,
		CASE WHEN J.VariacionCantidadReparto < 0 THEN 'Red'
		WHEN J.VariacionCantidadReparto = 0 THEN 'Black'
		ELSE 'Green' END AS ColorVariacionCantidadReparto,
		J.KilosReparto,
		J.VariacionKilosReparto,
		CASE WHEN J.VariacionKilosReparto < 0 THEN 'Red'
		WHEN J.VariacionKilosReparto = 0 THEN 'Black'
		ELSE 'Green' END AS ColorVariacionKilosReparto
	FROM
	(
		SELECT
			R.Codigo,
			R.DescripcionCorta AS Descripcion,
			R.CantidadMostrador,
			[dbo].[fnCalcularVariacion] (CAST(R.CantidadMostrador AS DECIMAL(18,2)), CAST(R.CantidadReparto AS decimal(18,2))) AS VariacionCantidadMostrador,
			R.KilosMostrador,
			[dbo].[fnCalcularVariacion] (CAST(R.KilosMostrador AS DECIMAL(18,2)), CAST(R.KilosReparto AS decimal(18,2))) AS VariacionKilosMostrador,

			R.CantidadReparto,		
			[dbo].[fnCalcularVariacion] (CAST(R.CantidadReparto AS DECIMAL(18,2)), CAST(R.CantidadMostrador AS decimal(18,2))) AS VariacionCantidadReparto,
			R.KilosReparto,
			[dbo].[fnCalcularVariacion] (CAST(R.KilosReparto AS DECIMAL(18,2)), CAST(R.KilosMostrador AS decimal(18,2))) AS VariacionKilosReparto
		FROM
		(
			SELECT
				P.Codigo,
				P.DescripcionCorta,
				SUM(CASE WHEN OP.OrdenDePedidoId IS NULL THEN COALESCE(OPD.Cantidad, D.Cantidad) ELSE 0 END) AS CantidadMostrador,
				SUM(CASE WHEN OP.OrdenDePedidoId IS NOT NULL THEN COALESCE(OPD.Cantidad, D.Cantidad) ELSE 0 END) AS CantidadReparto,
				SUM(CASE WHEN OP.OrdenDePedidoId IS NULL THEN COALESCE((OPD.Cantidad * CAST(OPD.PesoUnitarioEnGramos AS DECIMAL(18,2)) / 1000), (D.Cantidad * CAST(D.PesoUnitarioEnGramos AS DECIMAL(18,2)) / 1000)) ELSE 0 END) AS KilosMostrador,
				SUM(CASE WHEN OP.OrdenDePedidoId IS NOT NULL THEN COALESCE((OPD.Cantidad * CAST(OPD.PesoUnitarioEnGramos AS DECIMAL(18,2)) / 1000), (D.Cantidad * CAST(D.PesoUnitarioEnGramos AS DECIMAL(18,2)) / 1000)) ELSE 0 END) AS KilosReparto
			FROM
				VentaDetalle D WITH(NOLOCK)
				INNER JOIN Venta V WITH(NOLOCK) ON V.VentaId = D.VentaId AND V.Activo = 1
				INNER JOIN Producto P WITH(NOLOCK) ON P.ProductoId = D.ProductoId
				LEFT JOIN OrdenDePedidoDetalle OPD WITH(NOLOCK) ON OPD.OrdenDePedidoDetalleId = D.OrdenDePedidoDetalleId
				LEFT JOIN OrdenDePedido OP WITH(NOLOCK) ON OP.OrdenDePedidoId = OPD.OrdenDePedidoDetalleId AND OP.Activo = 1
			WHERE
				@Desde IS NULL
				OR (@Desde IS NOT NULL AND COALESCE(OP.FechaHoraPedido, V.FechaHoraVenta) >= @Desde)
			GROUP BY
				P.ProductoId, P.Codigo, P.DescripcionCorta
		) AS R
	) AS J
	   
END

GO

CREATE PROCEDURE spTotalVendidoPorListaDePreciosReport
(
	@Desde DATE
)
AS
BEGIN

	SELECT
		COALESCE(L.Descripcion, '-Sin lista de precios-') AS ListaDePrecios,
		SUM(D.Precio * D.Cantidad)  AS MontoVendido,
		SUM(CAST(D.PesoUnitarioEnGramos AS DECIMAL(18,2)) / 1000 * D.Cantidad)  AS KilosVendidos
	FROM
		VentaDetalle D WITH(NOLOCK)
		INNER JOIN Venta V WITH(NOLOCK) ON V.VentaId = D.VentaId AND V.Activo = 1
		INNER JOIN Producto P WITH(NOLOCK) ON P.ProductoId = D.ProductoId
		LEFT JOIN ListaDePrecios L WITH(NOLOCK) ON L.ListaDePreciosId = D.ListaDePreciosId
	WHERE
		@Desde IS NULL
		OR (@Desde IS NOT NULL AND V.FechaHoraVenta >= @Desde)
	GROUP BY
		L.ListaDePreciosId, L.Descripcion
			   
END

GO

ALTER TABLE Producto ADD CostoUnitario DECIMAL(18,2) DEFAULT 0;

GO

CREATE PROCEDURE spEstadisticaComprasReport
(
	@Desde DATE,
	@Hasta DATE
)
AS
BEGIN

	IF @Hasta IS NULL
		SET @Hasta = '2099-01-01';

	SELECT
		COALESCE(SUM(CASE WHEN P.EsPresupuesto = 1 THEN M.CostoUnitario * M.Cantidad ELSE 0 END), 0) AS TotalPresupuesto,
		COALESCE(SUM(CASE WHEN P.EsPresupuesto = 0 THEN M.CostoUnitario * M.Cantidad ELSE 0 END), 0) AS TotalCompras
	FROM
		MovimientoStock M WITH(NOLOCK)
		INNER JOIN Proveedor P WITH(NOLOCK) ON P.ProveedorId = M.ProveedorId
		INNER JOIN Producto PR WITH(NOLOCK) ON PR.ProductoId = M.ProductoId
	WHERE
		M.EsCompra = 1
		AND M.FechaHora >= @Desde AND M.FechaHora <= @Hasta
			   
END

GO

CREATE FUNCTION fnCalcularTotalVentas
(
	@Fecha DATE
)
RETURNS DECIMAL(18,2)
AS
BEGIN

	DECLARE @Return DECIMAL(18,2) = 0;

	SELECT
		@Return = SUM(MontoTotal)
	FROM
		Venta V WITH(NOLOCK)
	WHERE
		V.Activo = 1
		AND CAST(V.FechaHoraVenta AS DATE) = @Fecha

	RETURN COALESCE(@Return, 0)

END

GO

CREATE FUNCTION fnCalcularTotalCostosVentas
(
	@Fecha DATE
)
RETURNS DECIMAL(18,2)
AS
BEGIN

	DECLARE @Return DECIMAL(18,2) = 0;

	SELECT
		@Return = SUM(P.CostoUnitario * D.Cantidad)
	FROM
		Venta V WITH(NOLOCK)
		INNER JOIN VentaDetalle D WITH(NOLOCK) ON D.VentaId = V.VentaId
		INNER JOIN Producto P WITH(NOLOCK) ON P.ProductoId = D.ProductoId
	WHERE
		V.Activo = 1
		AND CAST(V.FechaHoraVenta AS DATE) = @Fecha

	RETURN COALESCE(@Return, 0)

END

GO

CREATE FUNCTION fnCalcularEgresosCajaDiaria
(
	@Fecha DATE
)
RETURNS DECIMAL(18,2)
AS
BEGIN

	DECLARE @Return DECIMAL(18,2) = 0;

	SELECT
		@Return = SUM(Importe)
	FROM
		MovimientoCajaDiaria M WITH(NOLOCK)
	WHERE
		M.Tipo = 'D'
		AND M.Observaciones NOT LIKE 'TRANSFERENCIA%' --DEBITOS QUE NO SON TRANSFERENCIA, ES DECIR, GASTOS!
		AND CAST(M.FechaHora AS DATE) = @Fecha

	RETURN COALESCE(@Return, 0)

END

GO

CREATE PROCEDURE spEstadisticaGananciasReport
(
	@Desde DATE,
	@Hasta DATE
)
AS
BEGIN

	IF @Hasta IS NULL
		SET @Hasta = GETDATE()

	CREATE TABLE #dates(Fecha DATETIME)

	DECLARE @TDesde DATE = @Desde;

	WHILE @TDesde <= @Hasta
	BEGIN
		INSERT INTO #dates VALUES (@TDesde);
		SET @TDesde = DATEADD(DAY, 1, @TDesde)
	END  

	SELECT
		R.Fecha,
		R.TotalVentas,
		R.TotalCostosVentas,
		R.TotalEgresosCajaDiaria,
		R.TotalVentas - R.TotalCostosVentas - R.TotalEgresosCajaDiaria AS TotalGanancias
	FROM
	(
		SELECT
			Fecha,
			dbo.fnCalcularTotalVentas(Fecha) AS TotalVentas,
			dbo.fnCalcularTotalCostosVentas(Fecha) AS TotalCostosVentas,
			dbo.fnCalcularEgresosCajaDiaria(Fecha) AS TotalEgresosCajaDiaria
		FROM
			#dates
	) R

END