using Natom.Petshop.Gestion.Entities.Model;
using Natom.Petshop.Gestion.Entities.Services;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Entities.DTO.Marcas
{
    public class MarcaDTO
    {
        [JsonProperty("encrypted_id")]
        public string EncryptedId { get; set; }

        [JsonProperty("descripcion")]
        public string Descripcion { get; set; }

        [JsonProperty("activo")]
        public bool Activo { get; set; }

        public MarcaDTO From(Marca entity)
        {
            EncryptedId = EncryptionService.Encrypt(entity.MarcaId);
            Descripcion = entity.Descripcion;
            Activo = entity.Activo;

            return this;
        }
    }
}
