CREATE DATABASE PetShop_Gestion;
GO

USE PetShop_Gestion;
GO

CREATE TABLE Permiso
(
	PermisoId NVARCHAR(50) NOT NULL,
	Descripcion NVARCHAR(200),
	PRIMARY KEY (PermisoId)
);

CREATE TABLE Usuario
(
	UsuarioId INT NOT NULL IDENTITY(1,1),
	Nombre VARCHAR(50) NOT NULL,
	Apellido VARCHAR(50) NOT NULL,
	Email VARCHAR(150) NOT NULL,
	Clave VARCHAR(32),
	FechaHoraConfirmacionEmail DATETIME,
	SecretConfirmacion CHAR(32),
	FechaHoraAlta DATETIME NOT NULL,
	FechaHoraBaja DATETIME DEFAULT NULL,
	PRIMARY KEY (UsuarioId)
);

CREATE TABLE UsuarioPermiso
(
	UsuarioPermisoId INT NOT NULL IDENTITY(1,1),
	UsuarioId INT NOT NULL,
	PermisoId NVARCHAR(50) NOT NULL,
	PRIMARY KEY (UsuarioPermisoId),
	FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
	FOREIGN KEY (PermisoId) REFERENCES Permiso(PermisoId)
);

CREATE TABLE HistoricoCambios
(
	HistoricoCambiosId INT NOT NULL IDENTITY(1,1),
	UsuarioId INT,
	FechaHora DATETIME NOT NULL,
	EntityName VARCHAR(50),
	EntityId INT,
	Accion VARCHAR(80) NOT NULL,
	PRIMARY KEY (HistoricoCambiosId)
);

CREATE TABLE HistoricoCambiosMotivo
(
	HistoricoCambiosMotivoId INT NOT NULL IDENTITY(1,1),
	HistoricoCambiosId INT NOT NULL,
	Motivo NVARCHAR(200),
	PRIMARY KEY (HistoricoCambiosMotivoId),
	FOREIGN KEY (HistoricoCambiosId) REFERENCES HistoricoCambios(HistoricoCambiosId)
);

CREATE TABLE MovimientoCajaDiaria
(
	MovimientoCajaDiariaId INT NOT NULL IDENTITY(1,1),
	FechaHora DATETIME NOT NULL,
	UsuarioId INT,
	Tipo CHAR(1) NOT NULL,	--(C)REDITO / (D)EBITO
	Importe DECIMAL(18,2) NOT NULL,
	Observaciones NVARCHAR(200),
	PRIMARY KEY (MovimientoCajaDiariaId)
);

CREATE TABLE MovimientoCajaFuerte
(
	MovimientoCajaFuerteId INT NOT NULL IDENTITY(1,1),
	FechaHora DATETIME NOT NULL,
	UsuarioId INT,
	Tipo CHAR(1) NOT NULL,	--(C)REDITO / (D)EBITO
	Importe DECIMAL(18,2) NOT NULL,
	Observaciones NVARCHAR(200),
	PRIMARY KEY (MovimientoCajaFuerteId)
);

CREATE TABLE TipoResponsable
(
	TipoResponsableId INT NOT NULL IDENTITY(1,1),
	CodigoAFIP NVARCHAR(10) NOT NULL,
	Descripcion NVARCHAR(50) NOT NULL,
	Activo BIT NOT NULL,
	PRIMARY KEY (TipoResponsableId)
);

INSERT INTO TipoResponsable (CodigoAFIP, Descripcion, Activo) VALUES
							('1', 'IVA Responsable Inscripto', 1),
							('2', 'IVA Responsable no Inscripto', 1),
							('3', 'IVA no Responsable', 1),
							('4', 'IVA Sujeto Exento', 1),
							('5', 'Consumidor Final', 1),
							('6', 'Responsable Monotributo', 1),
							('7', 'Sujeto no Categorizado', 0),
							('8', 'Proveedor del Exterior', 0),
							('9', 'Cliente del Exterior', 0),
							('10', 'IVA Liberado – Ley Nº 19.640', 0),
							('11', 'IVA Responsable Inscripto – Agente de Percepción', 0),
							('12', 'Pequeño Contribuyente Eventual', 0),
							('13', 'Monotributista Social', 0),
							('14', 'Pequeño Contribuyente Eventual Social', 0);

CREATE TABLE TipoDocumento
(
	TipoDocumentoId INT NOT NULL,
	Descripcion NVARCHAR(10),
	PRIMARY KEY (TipoDocumentoId)
);

INSERT INTO TipoDocumento (TipoDocumentoId, Descripcion) VALUES
								(1, 'DNI'),
								(2, 'CUIT');

CREATE TABLE Cliente
(
	ClienteId INT NOT NULL IDENTITY(1,1),
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
	PRIMARY KEY (ClienteId),
	FOREIGN KEY (TipoDocumentoId) REFERENCES TipoDocumento(TipoDocumentoId)
);

CREATE TABLE Marca
(
	MarcaId INT NOT NULL IDENTITY(1,1),
	Descripcion NVARCHAR(50),
	Activo BIT NOT NULL,
	PRIMARY KEY (MarcaId)
);

CREATE TABLE ListaDePrecios
(
	ListaDePreciosId INT NOT NULL IDENTITY(1,1),
	Descripcion NVARCHAR(50),
	Activo BIT NOT NULL,
	PRIMARY KEY (ListaDePreciosId)
);

INSERT INTO ListaDePrecios (Descripcion, Activo) VALUES
							('Lista de precios 1', 1),
							('Lista de precios 2', 1),
							('Lista de precios 3', 1);

CREATE TABLE UnidadPeso
(
	UnidadPesoId INT NOT NULL IDENTITY(1,1),
	Descripcion NVARCHAR(10),
	Gramos INT,
	PRIMARY KEY (UnidadPesoId)
);

INSERT INTO UnidadPeso (Descripcion, Gramos) VALUES
						('Gr', 1),
						('Kg', 1000);

						
CREATE TABLE Producto
(
	ProductoId INT NOT NULL IDENTITY(1,1),
	MarcaId INT NOT NULL,
	Codigo NVARCHAR(15) NOT NULL,
	DescripcionCorta NVARCHAR(50),
	DescripcionLarga NVARCHAR(200),
	UnidadPesoId INT NOT NULL,
	PesoUnitario DECIMAL(18,2) NOT NULL DEFAULT 0,
	MueveStock BIT NOT NULL DEFAULT 1,
	Activo BIT NOT NULL DEFAULT 1,
	PRIMARY KEY (ProductoId),
	FOREIGN KEY (MarcaId) REFERENCES Marca(MarcaId),
	FOREIGN KEY (UnidadPesoId) REFERENCES UnidadPeso(UnidadPesoId)
);

CREATE TABLE HistoricoReajustePrecio
(
	HistoricoReajustePrecioId INT NOT NULL IDENTITY(1,1),
	FechaHora DATETIME NOT NULL,
	UsuarioId INT NOT NULL,
	EsIncremento BIT NOT NULL,
	EsPorcentual BIT NOT NULL,
	Valor DECIMAL(18,2) NOT NULL,
	AplicoMarcaId INT NOT NULL,
	AplicoListaDePreciosId INT,
	AplicaDesdeFechaHora DATETIME NOT NULL,
	FechaHoraBaja DATETIME,
	PRIMARY KEY (HistoricoReajustePrecioId),
	FOREIGN KEY (AplicoMarcaId) REFERENCES Marca(MarcaId)
);

CREATE TABLE ProductoPrecio
(
	ProductoPrecioId INT NOT NULL IDENTITY(1,1),
	ProductoId INT NOT NULL,
	ListaDePreciosId INT,
	Precio DECIMAL(18,2) NOT NULL,
	AplicaDesdeFechaHora DATETIME NOT NULL,
	FechaHoraBaja DATETIME NULL,
	HistoricoReajustePrecioId INT,	--POR SI FUE PRODUCTO DE UN REAJUSTE POR MARCA CON PORCENTAJE
	PRIMARY KEY (ProductoPrecioId),
	FOREIGN KEY (ProductoId) REFERENCES Producto(ProductoId),
	FOREIGN KEY (ListaDePreciosId) REFERENCES ListaDePrecios(ListaDePreciosId)
);

CREATE TABLE Deposito
(
	DepositoId INT NOT NULL IDENTITY(1,1),
	Descripcion NVARCHAR(50),
	Activo BIT NOT NULL,
	PRIMARY KEY (DepositoId)
);

INSERT INTO Deposito (Descripcion, Activo) VALUES
						('Galpón 1', 1),
						('Galpón 2', 1),
						('Galpón 3', 1);

CREATE TABLE MovimientoStock
(
	MovimientoStockId INT NOT NULL IDENTITY(1,1),
	ProductoId INT NOT NULL,
	FechaHora DATETIME NOT NULL,
	UsuarioId INT,
	Tipo CHAR(1) NOT NULL,	--(I)NGRESO / (E)GRESO
	Cantidad INT NOT NULL,
	ConfirmacionFechaHora DATETIME,
	ConfirmacionUsuarioId INT,
	DepositoId INT NOT NULL,
	Observaciones NVARCHAR(200),
	PRIMARY KEY (MovimientoStockId),
	FOREIGN KEY (DepositoId) REFERENCES Deposito(DepositoId),
	FOREIGN KEY (ProductoId) REFERENCES Producto(ProductoId)
);

CREATE TABLE RangoHorario
(
	RangoHorarioId INT NOT NULL IDENTITY(1,1),
	Descripcion NVARCHAR(50) NOT NULL,
	Activo BIT,
	PRIMARY KEY (RangoHorarioId)
);

INSERT INTO RangoHorario (Descripcion, Activo) VALUES
							('Por la mañana', 1),
							('Por la tarde', 1);
							
CREATE TABLE OrdenDePedido
(
	OrdenDePedidoId INT NOT NULL IDENTITY(1,1),
	NumeroPedido INT NOT NULL,
	ClienteId INT NOT NULL,
	FechaHoraPedido DATETIME NOT NULL,
	RetiraPersonalmente BIT NOT NULL DEFAULT 0,
	EntregaEstimadaFecha DATE,
	EntregaEstimadaRangoHorarioId INT,
	EntregaDomicilio NVARCHAR(50),
	EntregaEntreCalles NVARCHAR(50),
	EntregaLocalidad NVARCHAR(50),
	EntregaTelefono1 NVARCHAR(30),
	EntregaTelefono2 NVARCHAR(30),
	EntregaObservaciones NVARCHAR(200),
	UsuarioId INT,
	NumeroRemito NVARCHAR(20),
	VentaId INT,
	Activo BIT,
	Observaciones NVARCHAR(200),
	PreparacionFechaHoraInicio DATETIME,
	PreparacionFechaHoraFin DATETIME,
	PreparacionUsuarioId INT,
	DespachoFechaHora DATETIME,
	DespachoUsuarioId INT,
	MarcoEntregaFechaHora DATETIME,
	MarcoEntregaUsuarioId INT,
	PesoTotalEnGramos INT NOT NULL,
	MontoTotal DECIMAL(18,2),
	PRIMARY KEY (OrdenDePedidoId),
	FOREIGN KEY (ClienteId) REFERENCES Cliente(ClienteId)
);

CREATE TABLE OrdenDePedidoDetalle
(
	OrdenDePedidoDetalleId INT NOT NULL IDENTITY(1,1),
	OrdenDePedidoId INT NOT NULL,
	MovimientoStockId INT,
	ProductoId INT NOT NULL,
	Cantidad INT NOT NULL,
	DepositoId INT NOT NULL,
	PesoUnitarioEnGramos INT NOT NULL,
	ListaDePreciosId INT,
	Precio DECIMAL(18,2),
	PRIMARY KEY (OrdenDePedidoDetalleId),
	FOREIGN KEY (OrdenDePedidoId) REFERENCES OrdenDePedido(OrdenDePedidoId),
	FOREIGN KEY (ProductoId) REFERENCES Producto(ProductoId),
	FOREIGN KEY (DepositoId) REFERENCES Deposito(DepositoId),
	FOREIGN KEY (MovimientoStockId) REFERENCES MovimientoStock(MovimientoStockId),
	FOREIGN KEY (ListaDePreciosId) REFERENCES ListaDePrecios(ListaDePreciosId)
);

CREATE TABLE Venta
(
	VentaId INT NOT NULL IDENTITY(1,1),
	NumeroVenta INT NOT NULL,
	ClienteId INT NOT NULL,
	FechaHoraVenta DATETIME NOT NULL,
	EntregaEstimadaFecha DATE,
	EntregaEstimadaRangoHorarioId INT,
	EntregaObservaciones NVARCHAR(200),
	UsuarioId INT,
	TipoFactura NVARCHAR(10),
	NumeroFactura NVARCHAR(20),
	Activo BIT,
	Observaciones NVARCHAR(200),
	MontoTotal DECIMAL(18,2) NOT NULL,
	PRIMARY KEY (VentaId),
	FOREIGN KEY (ClienteId) REFERENCES Cliente(ClienteId)
);

CREATE TABLE VentaDetalle
(
	VentaDetalleId INT NOT NULL IDENTITY(1,1),
	VentaId INT NOT NULL,
	MovimientoStockId INT,
	ProductoId INT NOT NULL,
	Cantidad INT NOT NULL,
	DepositoId INT NOT NULL,
	OrdenDePedidoDetalleId INT,
	PesoUnitarioEnGramos INT,
	ListaDePreciosId INT,
	Precio DECIMAL(18,2) NOT NULL,
	PRIMARY KEY (VentaDetalleId),
	FOREIGN KEY (VentaId) REFERENCES Venta(VentaId),
	FOREIGN KEY (ProductoId) REFERENCES Producto(ProductoId),
	FOREIGN KEY (DepositoId) REFERENCES Deposito(DepositoId),
	FOREIGN KEY (OrdenDePedidoDetalleId) REFERENCES OrdenDePedidoDetalle(OrdenDePedidoDetalleId),
	FOREIGN KEY (MovimientoStockId) REFERENCES MovimientoStock(MovimientoStockId),
	FOREIGN KEY (ListaDePreciosId) REFERENCES ListaDePrecios(ListaDePreciosId)
);

CREATE TABLE [Log]
(
	LogId INT NOT NULL IDENTITY(1,1),
	UsuarioId INT,
	FechaHora DATETIME NOT NULL,
	UserAgent NVARCHAR(400),
	Exception NVARCHAR(MAX)
);

INSERT INTO Permiso (PermisoId, Descripcion) VALUES
							('ABM_USUARIOS', 'ABM Usuarios'),
							('ABM_MARCAS', 'ABM Marcas'),
							('CAJA_DIARIA_VER', 'Caja diaria: Ver movimientos'),
							('CAJA_DIARIA_NUEVO_MOVIMIENTO', 'Caja diaria: Registrar movimientos'),
							('CAJA_FUERTE_VER', 'Caja fuerte: Ver movimientos'),
							('CAJA_FUERTE_NUEVO_MOVIMIENTO', 'Caja fuerte: Registrar movimientos'),
							('CAJA_TRANSFERENCIA', 'Transferencia entre cajas'),
							('CLIENTES_VER', 'Clientes: Consultar'),
							('CLIENTES_CRUD', 'Clientes: Alta, Baja, Modificación'),
							('PRODUCTOS_VER', 'Productos: Consultar'),
							('PRODUCTOS_CRUD', 'Productos: Alta, Baja, Modificación'),
							('PRECIOS_VER', 'Precios: Consultar'),
							('PRECIOS_CRUD', 'Precios: Alta, Baja, Modificación'),
							('PRECIOS_REAJUSTAR', 'Precios: Reajuste por Marca'),
							('STOCK_VER', 'Stock: Ver movimientos'),
							('STOCK_NUEVO_MOVIMIENTO', 'Stock: Registrar movimientos'),
							('PEDIDOS_VER', 'Pedidos: Ver pedidos'),
							('PEDIDOS_NUEVO', 'Pedidos: Carga nuevo pedido'),
							('PEDIDOS_ANULAR', 'Pedidos: Anular pedido'),
							('PEDIDOS_DEPOSITO', 'Pedidos: Armado / Finalización de preparación'),
							('VENTAS_VER', 'Ventas: Ver ventas'),
							('VENTAS_NUEVO', 'Ventas: Carga nueva venta'),
							('VENTAS_ANULAR', 'Ventas: Anular venta');

GO

CREATE VIEW vwPreciosVigentes
AS
	SELECT
		*
	FROM
		ProductoPrecio WITH(NOLOCK)
	WHERE
		ProductoPrecioId IN (SELECT MAX(ProductoPrecioId) FROM ProductoPrecio WITH(NOLOCK) WHERE	FechaHoraBaja IS NULL GROUP BY ProductoId, ListaDePreciosId);

GO

CREATE PROCEDURE spPreciosList
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

CREATE FUNCTION fnCalcularStockAlMovimiento
(
	@MovimientoStockId INT,
	@DepositoId INT,
	@ProductoId INT
)
RETURNS INT
AS
BEGIN

	DECLARE @Cantidad INT = 0;

	SELECT
		@Cantidad = SUM (CASE WHEN Tipo = 'E' THEN Cantidad * -1 ELSE Cantidad END)
	FROM
		MovimientoStock WITH(NOLOCK)
	WHERE
		MovimientoStockId <= @MovimientoStockId
		AND DepositoId = COALESCE(@DepositoId, DepositoId)
		AND ProductoId = @ProductoId;

	RETURN COALESCE(@Cantidad, 0);
END

GO

CREATE PROCEDURE spMovimientosStockList
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
		M.FechaHora,
		M.Deposito,
		M.Producto,
		M.Tipo,
		M.Movido,
		M.Reservado,
		M.Observaciones,
		[dbo].[fnCalcularStockAlMovimiento](M.MovimientoStockId, @DepositoId, M.ProductoId) AS Stock,
		@CantidadRegistros AS CantidadRegistros
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
		)
	ORDER BY
		M.MovimientoStockId DESC
	OFFSET @Skip ROWS
	FETCH NEXT @Take ROWS ONLY;
END