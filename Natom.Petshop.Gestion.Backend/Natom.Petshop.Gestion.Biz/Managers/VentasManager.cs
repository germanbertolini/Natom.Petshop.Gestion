using Microsoft.EntityFrameworkCore;
using Natom.Petshop.Gestion.Biz.Exceptions;
using Natom.Petshop.Gestion.Entities.DTO.Ventas;
using Natom.Petshop.Gestion.Entities.Model;
using Natom.Petshop.Gestion.Entities.Model.Results;
using Natom.Petshop.Gestion.Entities.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Biz.Managers
{
    public class VentasManager : BaseManager
    {
        public VentasManager(IServiceProvider serviceProvider) : base(serviceProvider)
        { }

        public Task<int> ObtenerVentasCountAsync()
                    => _db.Ventas
                            .CountAsync();

        public async Task<List<Venta>> ObtenerVentasDataTableAsync(int start, int size, string filter, int sortColumnIndex, string sortDirection, string statusFilter = null)
        {
            var queryable = _db.Ventas
                                    .Include(op => op.Cliente)
                                    .Include(op => op.Usuario)
                                    .Include(op => op.Detalle)
                                            .ThenInclude(d => d.OrdenDePedido)
                                    .Where(u => true);

            //FILTROS
            if (!string.IsNullOrEmpty(filter))
            {
                int numero = 0;
                if (int.TryParse(filter, out numero))
                {
                    queryable = queryable.Where(p => p.NumeroVenta.Equals(numero)
                                                        || p.NumeroFactura.Contains(numero.ToString())
                                                        || p.Detalle.Any(d => d.OrdenDePedido.NumeroPedido == numero)
                                                        || p.Detalle.Any(d => d.OrdenDePedido.NumeroRemito.Contains(numero.ToString())));
                }
                else
                {
                    queryable = queryable.Where(p => p.Cliente.RazonSocial.ToLower().Contains(filter.ToLower())
                                                        || p.Cliente.Nombre.ToLower().Contains(filter.ToLower())
                                                        || p.Cliente.Apellido.ToLower().Contains(filter.ToLower())
                                                        || p.NumeroFactura.Contains(filter)
                                                        || p.Detalle.Any(d => d.OrdenDePedido.NumeroRemito.Contains(filter)));
                }
            }

            //FILTRO DE ESTADO
            if (!string.IsNullOrEmpty(statusFilter))
            {
                if (statusFilter.ToUpper().Equals("FACTURADO")) queryable = queryable.Where(q => q.Activo == true);
                else if (statusFilter.ToUpper().Equals("ANULADO")) queryable = queryable.Where(q => q.Activo == false);
            }

            //ORDEN
            IOrderedQueryable<Venta> queryableOrdered;
            if (sortColumnIndex == 0)
            {
                queryableOrdered = sortDirection.ToLower().Equals("asc")
                                        ? queryable.OrderBy(c => c.NumeroVenta)
                                        : queryable.OrderByDescending(c => c.NumeroVenta);
            }
            else if (sortColumnIndex == 3)
            {
                queryableOrdered = sortDirection.ToLower().Equals("asc")
                                        ? queryable.OrderBy(c => c.FechaHoraVenta)
                                        : queryable.OrderByDescending(c => c.FechaHoraVenta);
            }
            else if (sortColumnIndex == 6)
            {
                queryableOrdered = sortDirection.ToLower().Equals("asc")
                                        ? queryable.OrderBy(c => c.PesoTotalEnGramos)
                                        : queryable.OrderByDescending(c => c.PesoTotalEnGramos);
            }
            else
            {
                queryableOrdered = sortDirection.ToLower().Equals("asc")
                                        ? queryable.OrderBy(c => sortColumnIndex == 1 ? c.TipoFactura + " " + c.NumeroFactura :
                                                                    sortColumnIndex == 2 ? c.Cliente.RazonSocial :
                                                            "")
                                        : queryable.OrderByDescending(c => sortColumnIndex == 1 ? c.TipoFactura + " " + c.NumeroFactura :
                                                                        sortColumnIndex == 2 ? c.Cliente.RazonSocial :
                                                            "");
            }

            var countFiltrados = queryableOrdered.Count();

            //SKIP Y TAKE
            var result = await queryableOrdered
                    .Skip(start)
                    .Take(size)
                    .ToListAsync();

            result.ForEach(r => r.CantidadFiltrados = countFiltrados);

            return result;
        }

        public async Task<int> ObtenerSiguienteNumeroAsync()
        {
            return ((await _db.Ventas.MaxAsync(op => (int?)op.NumeroVenta)) ?? 0) + 1;
        }

        public Task<List<RangoHorario>> ObtenerRangosHorariosActivosAsync()
        {
            return _db.RangosHorario.Where(r => r.Activo).ToListAsync();
        }

        public Task<Venta> ObtenerVentaAsync(int ventaId)
        {
            return _db.Ventas
                        .Include(op => op.Cliente)
                        .Include(op => op.Usuario)
                        .Include(op => op.Detalle).ThenInclude(d => d.Producto)
                        .Include(op => op.Detalle).ThenInclude(d => d.Deposito)
                        .Include(op => op.Detalle).ThenInclude(d => d.ListaDePrecios)
                        .Include(op => op.Detalle).ThenInclude(d => d.OrdenDePedidoDetalle).ThenInclude(d => d.OrdenDePedido)
                        .FirstAsync(op => op.VentaId == ventaId);
        }

        public async Task<Venta> GuardarVentaAsync(int usuarioId, VentaDTO ventaDto)
        {
            var ahora = DateTime.Now;
            Venta venta = null;

            if (_db.Ventas.Any(v => v.Activo && v.TipoFactura == ventaDto.TipoFactura && v.NumeroFactura == ventaDto.NumeroFactura))
                throw new HandledException("Ya existe una Facturación con mismo comprobante.");

            var numeroVenta = await this.ObtenerSiguienteNumeroAsync();
            venta = new Venta()
            {
                NumeroVenta = numeroVenta,
                ClienteId = EncryptionService.Decrypt<int>(ventaDto.ClienteEncryptedId),
                FechaHoraVenta = ahora,
                UsuarioId = usuarioId,
                NumeroFactura = ventaDto.NumeroFactura,
                TipoFactura = ventaDto.TipoFactura,
                Activo = true,
                Observaciones = ventaDto.Observaciones,
                PesoTotalEnGramos = ventaDto.Detalle.Sum(d => (d.ProductoPesoGramos ?? 0) * d.Cantidad),
                MontoTotal = ventaDto.Detalle.Sum(d => (d.Precio * d.Cantidad) ?? 0),
                Detalle = ventaDto.Pedidos.Select(d => new VentaDetalle
                                                        {
                                                            ProductoId = EncryptionService.Decrypt<int>(d.ProductoEncryptedId),
                                                            Cantidad = d.Cantidad,
                                                            DepositoId = EncryptionService.Decrypt<int>(d.DepositoEncryptedId),
                                                            PesoUnitarioEnGramos = d.ProductoPesoGramos,
                                                            NumeroRemito = d.NumeroRemito,
                                                            OrdenDePedidoId = EncryptionService.Decrypt<int>(d.OrdenDePedidoEncryptedId),
                                                            OrdenDePedidoDetalleId = EncryptionService.Decrypt<int>(d.OrdenDePedidoDetalleEncryptedId),
                                                            ListaDePreciosId = (d.PrecioListaEncryptedId?.Equals("-1") ?? true)
                                                                                        ? (int?)null
                                                                                        : EncryptionService.Decrypt<int>(d.PrecioListaEncryptedId),
                                                            Precio = (decimal)d.Precio
                                                        }
                                            ).ToList()
            };

            //AGREGAMOS AL DETALLE LOS ITEMS AGREGADOS SIN PEDIDO
            if (ventaDto.Detalle != null)
            {
                foreach (var d in ventaDto.Detalle)
                {
                    venta.Detalle.Add(new VentaDetalle
                    {
                        ProductoId = EncryptionService.Decrypt<int>(d.ProductoEncryptedId),
                        Cantidad = d.Cantidad,
                        DepositoId = EncryptionService.Decrypt<int>(d.DepositoEncryptedId),
                        PesoUnitarioEnGramos = d.ProductoPesoGramos,
                        ListaDePreciosId = EncryptionService.Decrypt<int>(d.PrecioListaEncryptedId),
                        Precio = (decimal)d.Precio
                    });
                }
            }

            _db.Ventas.Add(venta);

            await _db.SaveChangesAsync();


            ///MOVEMOS EL STOCK DE LOS PRODUCTOS QUE SALIERON SIN ORDEN DE PEDIDO
            if (ventaDto.Detalle != null)
            {
                foreach (var d in ventaDto.Detalle)
                {
                    _db.MovimientosStock.Add(new MovimientoStock
                    {
                        ProductoId = EncryptionService.Decrypt<int>(d.ProductoEncryptedId),
                        FechaHora = ahora,
                        UsuarioId = usuarioId,
                        Tipo = "E",
                        Cantidad = d.Cantidad,
                        ConfirmacionFechaHora = ahora,
                        ConfirmacionUsuarioId = usuarioId,
                        DepositoId = EncryptionService.Decrypt<int>(d.DepositoEncryptedId),
                        Observaciones = $"Venta N°{venta.NumeroVenta.ToString().PadLeft(8, '0')}"
                    });
                }
            }


            ///VINCULAMOS LAS ORDENES DE PEDIDO A LA VENTA
            var ordenesDePedidoId = ventaDto.Pedidos
                                                .Where(d => !string.IsNullOrEmpty(d.OrdenDePedidoEncryptedId) && d.OrdenDePedidoEncryptedId != "-1")
                                                .Select(d => EncryptionService.Decrypt<int>(d.OrdenDePedidoEncryptedId))
                                                .ToList();
            var ordenesDePedido = await _db.OrdenesDePedido
                                                .Include(op => op.Detalle).ThenInclude(d => d.MovimientoStock)
                                                .Where(op => ordenesDePedidoId.Contains(op.OrdenDePedidoId))
                                                .ToListAsync();
            
            foreach (var pedido in ordenesDePedido)
            {
                _db.Entry(pedido).State = EntityState.Modified;
                pedido.VentaId = venta.VentaId;

                foreach (var detalle in pedido.Detalle)
                {
                    _db.Entry(detalle.MovimientoStock).State = EntityState.Modified;
                    detalle.MovimientoStock.Observaciones = detalle.MovimientoStock.Observaciones + " /// " + $"Venta N°{venta.NumeroVenta.ToString().PadLeft(8, '0')}";
                }
            }

            await _db.SaveChangesAsync();


            return venta;
        }

        public List<spReportVentaResult> ObtenerDataVentaReport(int ventaId)
        {
            return _db.spReportVentaResult.FromSqlRaw("spReportVenta {0}", ventaId).AsEnumerable().ToList();
        }

        public async Task<List<OrdenDePedido>> AnularVentaAsync(int usuarioId, int ventaId)
        {
            var ahora = DateTime.Now;
            var venta = this._db.Ventas.Include(d => d.Detalle).First(v => v.VentaId == ventaId);
            _db.Entry(venta).State = EntityState.Modified;
            venta.Activo = false;

            ///DESVINCULAMOS LAS ORDENES DE PEDIDO DE LA VENTA
            var pedidos = await _db.OrdenesDePedido.Where(op => op.VentaId == ventaId).ToListAsync();
            foreach (var pedido in pedidos)
            {
                _db.Entry(pedido).State = EntityState.Modified;
                pedido.VentaId = null;
            }

            ///REINGRESAMOS EL STOCK DE LOS PRODUCTOS SIN ORDEN DE PEDIDO
            foreach (var detalle in venta.Detalle.Where(d => !d.OrdenDePedidoDetalleId.HasValue))
            {
                var contraMovimiento = new MovimientoStock
                {
                    ProductoId = detalle.ProductoId,
                    FechaHora = ahora,
                    UsuarioId = usuarioId,
                    Tipo = "I",
                    Cantidad = detalle.Cantidad,
                    DepositoId = detalle.DepositoId,
                    Observaciones = "Anulación /// " + $"Venta N°{venta.NumeroVenta.ToString().PadLeft(8, '0')}",
                    ConfirmacionFechaHora = ahora,
                    ConfirmacionUsuarioId = usuarioId
                };
                _db.MovimientosStock.Add(contraMovimiento);
            }

            await _db.SaveChangesAsync();

            return pedidos;
        }
    }
}
