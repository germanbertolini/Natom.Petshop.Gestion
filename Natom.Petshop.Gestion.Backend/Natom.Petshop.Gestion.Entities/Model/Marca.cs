using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Entities.Model
{
    [Table("Marca")]
    public class Marca
    {
        [Key]
        public int MarcaId { get; set; }
	    public string Descripcion { get; set; }
        public bool Activo { get; set; }
    }
}
