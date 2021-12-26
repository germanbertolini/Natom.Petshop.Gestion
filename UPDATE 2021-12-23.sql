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



