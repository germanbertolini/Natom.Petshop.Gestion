using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Entities.Model
{
    [Table("Log")]
    public class Log
    {
        [Key]
        public int LogId { get; set; }
        public int? UsuarioId { get; set; }
        public DateTime FechaHora { get; set; }
        public string UserAgent { get; set; }
        public string Exception { get; set; }
    }
}
