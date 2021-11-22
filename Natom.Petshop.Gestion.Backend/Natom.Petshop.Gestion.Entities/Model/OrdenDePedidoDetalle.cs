using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Natom.Petshop.Gestion.Entities.Model
{
    [Table("OrdenDePedidoDetalle")]
    public class OrdenDePedidoDetalle
    {
        [Key]
        public int OrdenDePedidoDetalleId { get; set; }

	    public int OrdenDePedidoId { get; set; }
        public OrdenDePedido OrdenDePedido { get; set; }

        public int ProductoId { get; set; }
        public Producto Producto { get; set; }

        public int Cantidad { get; set; }

        public int DepositoId { get; set; }
        public Deposito Deposito { get; set; }
    }
}