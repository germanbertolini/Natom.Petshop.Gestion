using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Entities.Model
{
    [Table("HistoricoCambiosMotivo")]
    public class HistoricoCambiosMotivo
    {
        [Key]
        public int HistoricoCambiosMotivoId { get; set; }

	    public int HistoricoCambiosId { get; set; }
        public HistoricoCambios HistoricoCambios { get; set; }

        public string Motivo { get; set; }
    }
}
