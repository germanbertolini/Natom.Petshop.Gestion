using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Entities.Model
{
    [Table("UnidadPeso")]
    public class UnidadPeso
    {
        [Key]
        public int UnidadPesoId { get; set; }
	    public string Descripcion { get; set; }
        public int Gramos { get; set; }
    }
}
