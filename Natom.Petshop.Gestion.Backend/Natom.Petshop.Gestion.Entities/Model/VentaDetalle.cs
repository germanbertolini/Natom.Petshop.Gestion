using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Natom.Petshop.Gestion.Entities.Model
{
	[Table("VentaDetalle")]
	public class VentaDetalle
	{
		[Key]
		public int VentaDetalleId { get; set; }

		public int VentaId { get; set; }
		public Venta Venta { get; set; }

		public int ProductoId { get; set; }
		public Producto Producto { get; set; }

		public int Cantidad { get; set; }

		public int DepositoId { get; set; }
		public Deposito Deposito { get; set; }

		public int? MovimientoStockId { get; set; }
		public MovimientoStock MovimientoStock { get; set; }

		public int? ListaDePreciosId { get; set; }
		[ForeignKey("ListaDePreciosId")]
		public ListaDePrecios ListaDePrecios { get; set; }

		public decimal Precio { get; set; }

		public decimal? PesoUnitarioEnGramos { get; set; }

		public int? OrdenDePedidoDetalleId { get; set; }
		public OrdenDePedidoDetalle OrdenDePedidoDetalle { get; set; }
	}
}