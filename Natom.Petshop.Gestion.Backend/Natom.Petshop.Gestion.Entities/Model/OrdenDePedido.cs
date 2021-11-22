using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Entities.Model
{
	[Table("OrdenDePedido")]
	public class OrdenDePedido
    {
		[Key]
		public int OrdenDePedidoId { get; set; }
		
		public int ClienteId { get; set; }
		public Cliente Cliente { get; set; }

		public DateTime FechaHoraPedido { get; set; }

		public DateTime? EntregaEstimadaFecha { get; set; }
		public int? EntregaEstimadaRangoHorarioId { get; set; }
		[ForeignKey("EntregaEstimadaRangoHorarioId")]
		public RangoHorario EntregaEstimadaRangoHorario { get; set; }
		public string EntregaObservaciones { get; set; }

		public int? UsuarioId { get; set; }
		public Usuario Usuario { get; set; }

		public string NumeroRemito { get; set; }

		public int? VentaId { get; set; }
		public Venta Venta { get; set; }

		public bool? Activo { get; set; }
		public string Observaciones { get; set; }

		public List<OrdenDePedidoDetalle> Detalle { get; set; }
	}
}
