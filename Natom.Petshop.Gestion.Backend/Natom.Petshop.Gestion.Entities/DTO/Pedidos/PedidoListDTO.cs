using Natom.Petshop.Gestion.Entities.Model;
using Natom.Petshop.Gestion.Entities.Services;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Entities.DTO.Pedidos
{
    public class PedidoListDTO
    {
        [JsonProperty("encrypted_id")]
        public string EncryptedId { get; set; }

        [JsonProperty("numero")]
        public string Numero { get; set; }

        [JsonProperty("venta_encrypted_id")]
        public string VentaEncryptedId { get; set; }

        [JsonProperty("numeroVenta")]
        public string NumeroVenta { get; set; }

        [JsonProperty("remito")]
        public string Remito { get; set; }

        [JsonProperty("factura")]
        public string Factura { get; set; }

        [JsonProperty("cliente")]
        public string Cliente { get; set; }

        [JsonProperty("fechaHora")]
        public DateTime FechaHora { get; set; }

        [JsonProperty("usuario")]
        public string Usuario { get; set; }

        [JsonProperty("estado")]
        public string Estado { get; set; }

        [JsonProperty("prepared")]
        public bool Prepared { get; set; }

        public PedidoListDTO From(OrdenDePedido entity)
        {
            EncryptedId = EncryptionService.Encrypt(entity.OrdenDePedidoId);
            Numero = entity.NumeroPedido.ToString().PadLeft(8, '0');
            FechaHora = entity.FechaHoraPedido;
            VentaEncryptedId = EncryptionService.Encrypt(entity.VentaId);
            NumeroVenta = entity.Venta == null ? null : entity.Venta.NumeroVenta.ToString().PadLeft(8, '0');
            Remito = string.IsNullOrEmpty(entity.NumeroRemito) ? null : "RTO " + entity.NumeroRemito;
            Factura = string.IsNullOrEmpty(entity.Venta?.NumeroFactura) ? null : entity.Venta.TipoFactura + " " + entity.Venta.NumeroFactura;
            Cliente = entity.Cliente.RazonSocial;
            Usuario = entity.Usuario?.Nombre ?? "Admin";
            Estado = ResolverEstado(entity);
            Prepared = entity.PreparacionFechaHoraFin.HasValue;

            return this;
        }

        private string ResolverEstado(OrdenDePedido entity)
        {
            if (entity.Activo == false) return "Anulado";
            else if (entity.MarcoEntregaFechaHora.HasValue) return "Entregado";
            else if (entity.DespachoFechaHora.HasValue) return "En ruta";
            else if (entity.PreparacionFechaHoraInicio.HasValue && !entity.PreparacionFechaHoraFin.HasValue) return "En preparación";
            else if (entity.PreparacionFechaHoraFin.HasValue && !entity.VentaId.HasValue) return "Pendiente de Venta (Facturación)";
            else if (entity.PreparacionFechaHoraFin.HasValue && entity.RetiraPersonalmente) return "Listo para retirar por el cliente";
            else if (entity.PreparacionFechaHoraFin.HasValue && !entity.RetiraPersonalmente) return "Pendiente de despacho";
            
            else return "Pendiente de preparación";
        }
    }
}
