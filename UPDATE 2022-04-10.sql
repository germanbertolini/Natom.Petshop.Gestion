ALTER TABLE MovimientoStock ALTER COLUMN Cantidad DECIMAL(18,2) NOT NULL;
ALTER TABLE OrdenDePedido ALTER COLUMN PesoTotalEnGramos DECIMAL(18,2) NOT NULL;
ALTER TABLE OrdenDePedidoDetalle ALTER COLUMN Cantidad DECIMAL(18,2) NOT NULL;
ALTER TABLE OrdenDePedidoDetalle ALTER COLUMN CantidadEntregada DECIMAL(18,2);

ALTER TABLE Venta ALTER COLUMN PesoTotalEnGramos DECIMAL(18,2) NOT NULL;
ALTER TABLE VentaDetalle ALTER COLUMN Cantidad DECIMAL(18,2) NOT NULL;

GO


ALTER FUNCTION fnCalcularStockAlMovimiento
(
	@MovimientoStockId INT,
	@DepositoId INT,
	@ProductoId INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN

	DECLARE @Cantidad DECIMAL(18,2) = 0;

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