using Natom.Petshop.Gestion.Entities.Model.Results;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Entities.DTO.Stock
{
    public class StockListDTO
    {
        [JsonProperty("fechaHora")]
        public DateTime FechaHora { get; set; }

        [JsonProperty("deposito")]
        public string Deposito { get; set; }

        [JsonProperty("producto")]
        public string Producto { get; set; }

        [JsonProperty("tipo")]
        public string Tipo { get; set; }

        [JsonProperty("movido")]
        public int? Movido { get; set; }

        [JsonProperty("reservado")]
        public int? Reservado { get; set; }

        [JsonProperty("stock")]
        public int Stock { get; set; }

        [JsonProperty("observaciones")]
        public string Observaciones { get; set; }

        public StockListDTO From(spMovimientosStockListResult entity)
        {
            FechaHora = entity.FechaHora;
            Deposito = entity.Deposito;
            Producto = entity.Producto;
            Tipo = entity.Tipo.Equals("I") ? "Ingreso" : "Egreso";
            Movido = entity.Movido;
            Reservado = entity.Reservado;
            Stock = entity.Stock;
            Observaciones = entity.Observaciones;

            return this;
        }
    }
}
