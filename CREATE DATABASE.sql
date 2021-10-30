CREATE DATABASE PetShop_Gestion;
GO

USE PetShop_Gestion;
GO

CREATE TABLE Permiso
(
	PermisoId INT NOT NULL,
	Descripcion NVARCHAR(200),
	PRIMARY KEY (PermisoId)
);

CREATE TABLE Usuario
(
	UsuarioId INT NOT NULL IDENTITY(1,1),
	Nombre VARCHAR(50) NOT NULL,
	Apellido VARCHAR(50) NOT NULL,
	Email VARCHAR(150) NOT NULL,
	Clave VARCHAR(32) NOT NULL,
	FechaHoraConfirmacionEmail DATETIME NOT NULL,
	SecretConfirmacion CHAR(32) NOT NULL,
	FechaHoraAlta DATETIME NOT NULL,
	FechaHoraBaja DATETIME DEFAULT NULL,
	PRIMARY KEY (UsuarioId)
);

CREATE TABLE UsuarioPermiso
(
	UsuarioPermisoId INT NOT NULL IDENTITY(1,1),
	UsuarioId INT NOT NULL,
	PermisoId INT NOT NULL,
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
	PRIMARY KEY (MovimientoCajaDiariaId),
	FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId)
);

CREATE TABLE MovimientoCajaFuerte
(
	MovimientoCajaFuerteId INT NOT NULL IDENTITY(1,1),
	FechaHora DATETIME NOT NULL,
	UsuarioId INT,
	Tipo CHAR(1) NOT NULL,	--(C)REDITO / (D)EBITO
	Importe DECIMAL(18,2) NOT NULL,
	Observaciones NVARCHAR(200),
	PRIMARY KEY (MovimientoCajaFuerteId),
	FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId)
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
	PesoUnitario INT NOT NULL DEFAULT 0,
	PRIMARY KEY (ProductoId),
	FOREIGN KEY (MarcaId) REFERENCES Marca(MarcaId),
	FOREIGN KEY (UnidadPesoId) REFERENCES UnidadPeso(UnidadPesoId)
);

CREATE TABLE HistoricoReajustePrecio
(
	HistoricoReajustePrecioId INT NOT NULL IDENTITY(1,1),
	FechaHora DATETIME NOT NULL,
	UsuarioId INT NOT NULL,
	EsAumentoPorcentual BIT NOT NULL,
	ValorAumento DECIMAL(18,2) NOT NULL,
	AplicoMarcaId INT NOT NULL,
	AplicaDesdeFechaHora DATETIME NOT NULL,
	PRIMARY KEY (HistoricoReajustePrecioId),
	FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
	FOREIGN KEY (AplicoMarcaId) REFERENCES Marca(MarcaId)
);

CREATE TABLE ProductoPrecio
(
	ProductoPrecioId INT NOT NULL IDENTITY(1,1),
	ProductoId INT NOT NULL,
	ListaDePreciosId INT NOT NULL,
	Precio DECIMAL(18,2) NOT NULL,
	AplicaDesdeFechaHora DATETIME NOT NULL,
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
	DepositoId INT NOT NULL,
	Observaciones NVARCHAR(200),
	PRIMARY KEY (MovimientoStockId),
	FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
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
	ClienteId INT NOT NULL,
	FechaHoraPedido DATETIME NOT NULL,
	EntregaEstimadaFecha DATE,
	EntregaEstimadaRangoHorarioId INT,
	EntregaObservaciones NVARCHAR(200),
	UsuarioId INT,
	NumeroRemito NVARCHAR(20),
	VentaId INT,
	Activo BIT,
	Observaciones NVARCHAR(200),
	PRIMARY KEY (OrdenDePedidoId),
	FOREIGN KEY (ClienteId) REFERENCES Cliente(ClienteId),
	FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId)
);

CREATE TABLE OrdenDePedidoDetalle
(
	OrdenDePedidoDetalleId INT NOT NULL IDENTITY(1,1),
	OrdenDePedidoId INT NOT NULL,
	ProductoId INT NOT NULL,
	Cantidad INT NOT NULL,
	DepositoId INT NOT NULL,
	PRIMARY KEY (OrdenDePedidoDetalleId),
	FOREIGN KEY (OrdenDePedidoId) REFERENCES OrdenDePedido(OrdenDePedidoId),
	FOREIGN KEY (ProductoId) REFERENCES Producto(ProductoId),
	FOREIGN KEY (DepositoId) REFERENCES Deposito(DepositoId)
);

CREATE TABLE Venta
(
	VentaId INT NOT NULL IDENTITY(1,1),
	ClienteId INT NOT NULL,
	FechaHoraVenta DATETIME NOT NULL,
	EntregaEstimadaFecha DATE,
	EntregaEstimadaRangoHorarioId INT,
	EntregaObservaciones NVARCHAR(200),
	UsuarioId INT,
	NumeroFactura NVARCHAR(20),
	Activo BIT,
	Observaciones NVARCHAR(200),
	PRIMARY KEY (VentaId),
	FOREIGN KEY (ClienteId) REFERENCES Cliente(ClienteId),
	FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId)
);

CREATE TABLE VentaDetalle
(
	VentaDetalleId INT NOT NULL IDENTITY(1,1),
	VentaId INT NOT NULL,
	ProductoId INT NOT NULL,
	Cantidad INT NOT NULL,
	DepositoId INT NOT NULL,
	OrdenDePedidoDetalleId INT,
	PRIMARY KEY (VentaDetalleId),
	FOREIGN KEY (VentaId) REFERENCES Venta(VentaId),
	FOREIGN KEY (ProductoId) REFERENCES Producto(ProductoId),
	FOREIGN KEY (DepositoId) REFERENCES Deposito(DepositoId),
	FOREIGN KEY (OrdenDePedidoDetalleId) REFERENCES OrdenDePedidoDetalle(OrdenDePedidoDetalleId)
);