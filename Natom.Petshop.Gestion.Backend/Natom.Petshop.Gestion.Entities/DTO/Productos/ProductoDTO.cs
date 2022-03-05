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
    public class ProductoDTO
    {
		[JsonProperty("encrypted_id")]
		public string EncryptedId { get; set; }

		[JsonProperty("marca_encrypted_id")]
		public string MarcaEncryptedId { get; set; }

		[JsonProperty("codigo")]
		public string Codigo { get; set; }

		[JsonProperty("descripcionCorta")]
		public string DescripcionCorta { get; set; }

		[JsonProperty("descripcionLarga")]
		public string DescripcionLarga { get; set; }

		[JsonProperty("unidadPeso_encrypted_id")]
		public string UnidadPesoEncryptedId { get; set; }

		[JsonProperty("pesoUnitario")]
		public decimal PesoUnitario { get; set; }

		[JsonProperty("categoria_encrypted_id")]
		public string CategoriaEncryptedId { get; set; }

		[JsonProperty("mueveStock")]
		public bool MueveStock { get; set; }

		public ProductoDTO From(Producto entity)
		{
			EncryptedId = EncryptionService.Encrypt(entity.ProductoId);
			MarcaEncryptedId = EncryptionService.Encrypt(entity.MarcaId);
			Codigo = entity.Codigo;
			DescripcionCorta = entity.DescripcionCorta;
			DescripcionLarga = entity.DescripcionLarga;
			UnidadPesoEncryptedId = EncryptionService.Encrypt(entity.UnidadPesoId);
			CategoriaEncryptedId = string.IsNullOrEmpty(entity.CategoriaProductoId) ? string.Empty : EncryptionService.Encrypt(entity.CategoriaProductoId);
			PesoUnitario = entity.PesoUnitario;
			MueveStock = entity.MueveStock;

			return this;
		}
	}
}
