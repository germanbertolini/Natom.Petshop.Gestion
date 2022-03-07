using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Entities.DTO
{
    public class FeatureFlagsDTO
    {
        [JsonProperty("stock")]
        public FeatureFlagsStockDTO Stock { get; set; }
    }

    public class FeatureFlagsStockDTO
    {
        [JsonProperty("permitir_venta_con_stock_negativo")]
        public bool PermitirVentaConStockNegativo { get; set; }
    }
}
