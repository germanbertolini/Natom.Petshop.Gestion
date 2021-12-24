using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Entities.Model.Results
{
	[Keyless]
	public class spPrecioGetResult
    {
		public decimal Precio { get; set; }
	}
}
