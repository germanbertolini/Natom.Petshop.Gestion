﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Natom.Petshop.Gestion.Entities.Model
{
	[Table("Venta")]
	public class Venta
	{
		[Key]
		public int VentaId { get; set; }
		
		public int ClienteId { get; set; }
		public Cliente Cliente { get; set; }

		public DateTime FechaHoraVenta { get; set; }
		public DateTime? EntregaEstimadaFecha { get; set; }

		public int? EntregaEstimadaRangoHorarioId { get; set; }
		[ForeignKey("EntregaEstimadaRangoHorarioId")]
		public RangoHorario EntregaEstimadaRangoHorario { get; set; }

		public string EntregaObservaciones { get; set; }

		public int UsuarioId { get; set; }
		public Usuario Usuario { get; set; }

		public string NumeroFactura { get; set; }
		public bool Activo { get; set; }
		public string Observaciones { get; set; }

		public List<VentaDetalle> Detalle { get; set; }
	}
}