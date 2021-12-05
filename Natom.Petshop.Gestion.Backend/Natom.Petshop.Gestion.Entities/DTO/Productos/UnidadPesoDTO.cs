using Natom.Petshop.Gestion.Entities.Model;
using Natom.Petshop.Gestion.Entities.Services;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Entities.DTO.Productos
{
    public class UnidadPesoDTO
    {
        [JsonProperty("encrypted_id")]
        public string EncryptedId { get; set; }

        [JsonProperty("descripcion")]
        public string Descripcion { get; set; }

		public UnidadPesoDTO From(UnidadPeso entity)
		{
			EncryptedId = EncryptionService.Encrypt(entity.UnidadPesoId);
			Descripcion = entity.Descripcion;

			return this;
		}
	}
}
