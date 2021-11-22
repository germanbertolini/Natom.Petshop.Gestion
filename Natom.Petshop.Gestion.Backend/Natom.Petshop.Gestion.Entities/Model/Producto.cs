﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Entities.Model
{
	[Table("Producto")]
	public class Producto
    {
		[Key]
		public int ProductoId { get; set; }

		public int MarcaId { get; set; }
		public Marca Marca { get; set; }

		public string Codigo { get; set; }

		public string DescripcionCorta { get; set; }
		public string DescripcionLarga { get; set; }
		
		public int UnidadPesoId { get; set; }
		public UnidadPeso UnidadPeso { get; set; }
		public int PesoUnitario { get; set; }

		public bool MueveStock { get; set; }

	}
}