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
		('PROVEEDORES_CRUD', 'Proveedores: Alta, Baja, Modificación');

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

