using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Entities.Model.Results
{
    [Keyless]
    public class spPreciosListaReportResult
    {
        public string ListaDePrecios { get; set; }
        public string Categoria { get; set; }
        public string Producto { get; set; }
        public decimal Precio { get; set; }
    }
}
