using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Entities.Model
{
	[Table("MovimientoCajaFuerte")]
	public class MovimientoCajaFuerte
    {
		[Key]
		public int MovimientoCajaFuerteId { get; set; }
		public DateTime FechaHora { get; set; }
		
		public int? UsuarioId { get; set; }
		public Usuario Usuario { get; set; }

		public string Tipo { get; set; }  //(C) REDITO / (D) EBITO
		public decimal Importe { get; set; }

		public string Observaciones { get; set; }
    }
}
