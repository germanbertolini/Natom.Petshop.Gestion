using Natom.Petshop.Gestion.Entities.Model;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Entities.DTO.HistoricoCambios
{
    public class HistoricoListDTO
    {
        [JsonProperty("fechaHora")]
        public DateTime FechaHora { get; set; }

        [JsonProperty("descripcion")]
        public string Descripcion { get; set; }

        [JsonProperty("usuario")]
        public string Usuario { get; set; }

        public HistoricoListDTO From(Model.HistoricoCambios entity)
        {
            FechaHora = entity.FechaHora;
            Descripcion = entity.Accion;
            Usuario = entity.Usuario == null ? "Admin" : (entity.Usuario.Nombre + " " + entity.Usuario.Apellido);

            return this;
        }
    }
}
