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
    public class CategoriaProductoDTO
    {
        [JsonProperty("encrypted_id")]
        public string EncryptedId { get; set; }

        [JsonProperty("descripcion")]
        public string Descripcion { get; set; }

		public CategoriaProductoDTO From(CategoriaProducto entity)
		{
			EncryptedId = EncryptionService.Encrypt(entity.CategoriaProductoId);
			Descripcion = entity.Descripcion;

			return this;
		}
	}
}
