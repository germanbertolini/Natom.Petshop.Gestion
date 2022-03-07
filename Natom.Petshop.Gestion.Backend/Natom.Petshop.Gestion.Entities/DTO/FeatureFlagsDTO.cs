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

        [JsonProperty("acceso")]
        public FeatureFlagsAccesoDTO Acceso { get; set; }
    }

    public class FeatureFlagsAccesoDTO
    {
        [JsonProperty("restringir_por_horario")]
        public bool RestringirPorHorario { get; set; }

        [JsonProperty("rango_horario_permitido_desde")]
        public int RangoHorarioPermitidoDesde { get; set; }

        [JsonProperty("rango_horario_permitido_hasta")]
        public int RangoHorarioPermitidoHasta { get; set; }
    }

    public class FeatureFlagsStockDTO
    {
        [JsonProperty("permitir_venta_con_stock_negativo")]
        public bool PermitirVentaConStockNegativo { get; set; }
    }
}
