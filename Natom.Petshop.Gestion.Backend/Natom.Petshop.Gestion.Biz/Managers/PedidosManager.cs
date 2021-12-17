using Microsoft.EntityFrameworkCore;
using Natom.Petshop.Gestion.Biz.Exceptions;
using Natom.Petshop.Gestion.Entities.DTO.Pedidos;
using Natom.Petshop.Gestion.Entities.Model;
using Natom.Petshop.Gestion.Entities.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Biz.Managers
{
    public class PedidosManager : BaseManager
    {
        public PedidosManager(IServiceProvider serviceProvider) : base(serviceProvider)
        { }

        public Task<int> ObtenerPedidosCountAsync()
                    => _db.OrdenesDePedido
                            .CountAsync();

        public Task<List<OrdenDePedido>> ObtenerPedidosDataTableAsync(int start, int size, string filter, int sortColumnIndex, string sortDirection, string statusFilter)
        {
            var queryable = _db.OrdenesDePedido
                                    .Include(op => op.Cliente)
                                    .Include(op => op.Usuario)
                                    .Include(op => op.PreparacionUsuario)
                                    .Where(u => true);

            //FILTROS
            if (!string.IsNullOrEmpty(filter))
            {
                int numero = 0;
                if (int.TryParse(filter, out numero))
                {
                    queryable = queryable.Where(p => p.NumeroPedido.Equals(numero)
                                                        || p.Venta.NumeroVenta.Equals(numero)
                                                        || p.NumeroRemito.Contains(numero.ToString())
                                                        || p.Venta.NumeroFactura.Contains(numero.ToString()));
                }
                else
                {
                    queryable = queryable.Where(p => p.Cliente.RazonSocial.ToLower().Contains(filter.ToLower())
                                                        || p.NumeroRemito.Contains(filter)
                                                        || p.Venta.NumeroFactura.Contains(filter));
                }
            }

            //FILTRO DE ESTADO
            if (!string.IsNullOrEmpty(statusFilter))
            {
                if (statusFilter.ToUpper().Equals("PENDIENTE")) queryable = queryable.Where(q => q.Activo == true && q.PreparacionFechaHoraInicio == null && q.PreparacionFechaHoraFin == null);
                else if (statusFilter.ToUpper().Equals("EN_PREPARACION")) queryable = queryable.Where(q => q.Activo == true && q.PreparacionFechaHoraInicio != null && q.PreparacionFechaHoraFin == null);
                else if (statusFilter.ToUpper().Equals("PENDIENTE_FACTURACION")) queryable = queryable.Where(q => q.Activo == true && !q.VentaId.HasValue && q.MarcoEntregaFechaHora.HasValue);
                else if (statusFilter.ToUpper().Equals("PENDIENTE_DESPACHO")) queryable = queryable.Where(q => q.Activo == true && !q.RetiraPersonalmente && q.PreparacionFechaHoraInicio != null && q.PreparacionFechaHoraFin != null && q.DespachoFechaHora == null);
                else if (statusFilter.ToUpper().Equals("PENDIENTE_RETIRO")) queryable = queryable.Where(q => q.Activo == true && q.RetiraPersonalmente && q.PreparacionFechaHoraInicio != null && q.PreparacionFechaHoraFin != null && q.MarcoEntregaFechaHora == null);
                else if (statusFilter.ToUpper().Equals("EN_RUTA")) queryable = queryable.Where(q => q.Activo == true && !q.RetiraPersonalmente && q.PreparacionFechaHoraInicio != null && q.PreparacionFechaHoraFin != null && q.DespachoFechaHora != null && q.MarcoEntregaFechaHora == null);
                else if (statusFilter.ToUpper().Equals("ENTREGADO")) queryable = queryable = queryable.Where(q => q.Activo == true && !q.RetiraPersonalmente && q.VentaId.HasValue && q.PreparacionFechaHoraInicio != null && q.PreparacionFechaHoraFin != null && q.DespachoFechaHora != null && q.MarcoEntregaFechaHora != null);
                else if (statusFilter.ToUpper().Equals("ANULADO")) queryable = queryable.Where(q => q.Activo == false);
            }

            //ORDEN
            IOrderedQueryable<OrdenDePedido> queryableOrdered;
            if (sortColumnIndex == 0)
            {
                queryableOrdered = sortDirection.ToLower().Equals("asc")
                                        ? queryable.OrderBy(c => c.NumeroPedido)
                                        : queryable.OrderByDescending(c => c.NumeroPedido);
            }
            else if (sortColumnIndex == 3)
            {
                queryableOrdered = sortDirection.ToLower().Equals("asc")
                                        ? queryable.OrderBy(c => c.FechaHoraPedido)
                                        : queryable.OrderByDescending(c => c.FechaHoraPedido);
            }
            else if (sortColumnIndex == 4)
            {
                queryableOrdered = sortDirection.ToLower().Equals("asc")
                                        ? queryable.OrderBy(c => c.PreparacionFechaHoraFin ?? c.PreparacionFechaHoraInicio)
                                        : queryable.OrderByDescending(c => c.PreparacionFechaHoraFin ?? c.PreparacionFechaHoraInicio);
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
                                        ? queryable.OrderBy(c => sortColumnIndex == 1 ? c.NumeroRemito :
                                                                    sortColumnIndex == 2 ? c.Cliente.RazonSocial :
                                                            "")
                                        : queryable.OrderByDescending(c => sortColumnIndex == 1 ? c.NumeroRemito :
                                                                        sortColumnIndex == 2 ? c.Cliente.RazonSocial :
                                                            "");
            }

            //SKIP Y TAKE
            return queryableOrdered
                    .Skip(start)
                    .Take(size)
                    .ToListAsync();
        }

        public Task<List<OrdenDePedido>> ObtenerPedidosPendientesDeFacturacionAsync(int clienteId)
        {
            return _db.OrdenesDePedido.Where(op => op.VentaId == null && op.ClienteId == clienteId && op.Activo == true).OrderBy(op => op.NumeroPedido).ToListAsync();
        }

        public async Task<int> ObtenerSiguienteNumeroAsync()
        {
            return ((await _db.OrdenesDePedido.MaxAsync(op => (int?)op.NumeroPedido)) ?? 0) + 1;
        }

        public Task<List<RangoHorario>> ObtenerRangosHorariosActivosAsync()
        {
            return _db.RangosHorario.Where(r => r.Activo).ToListAsync();
        }

        public Task<OrdenDePedido> ObtenerPedidoAsync(int pedidoId)
        {
            return _db.OrdenesDePedido
                        .Include(op => op.Cliente)
                        .Include(op => op.Usuario)
                        .Include(op => op.Detalle).ThenInclude(d => d.Producto)
                        .Include(op => op.Detalle).ThenInclude(d => d.Deposito)
                        .Include(op => op.Detalle).ThenInclude(d => d.ListaDePrecios)
                        .FirstAsync(op => op.OrdenDePedidoId == pedidoId);
        }

        public async Task ValidarStockAsync(List<PedidoDetalleDTO> detallePedidoDto)
        {
            var stockManager = new StockManager(_serviceProvider);
            var stockAValidar = detallePedidoDto
                                    .Where(d => string.IsNullOrEmpty(d.EncryptedId))
                                    .GroupBy(k => new
                                    {
                                        ProductoId = EncryptionService.Decrypt<int>(k.ProductoEncryptedId),
                                        ProductoDescripcion = k.ProductoDescripcion,
                                        DepositoId = EncryptionService.Decrypt<int>(k.DepositoEncryptedId),
                                        DepositoDescripcion = k.DepositoDescripcion
                                    },
                                             (k, v) => new
                                             {
                                                 ProductoId = k.ProductoId,
                                                 ProductoDescripcion = k.ProductoDescripcion,
                                                 DepositoId = k.DepositoId,
                                                 DepositoDescripcion = k.DepositoDescripcion,
                                                 Cantidad = v.Sum(p => p.Cantidad)
                                             })
                                    .ToList();
            foreach (var item in stockAValidar)
            {
                int cantidad = await stockManager.ObtenerStockActualAsync(item.ProductoId, item.DepositoId);
                if (cantidad < item.Cantidad)
                    throw new HandledException($"No hay stock disponible para '{item.ProductoDescripcion}' en '{item.DepositoDescripcion}'. Cantidad pedido: {item.Cantidad} / Cantidad disponible actual: {cantidad}");
            }
        }

        public async Task<OrdenDePedido> GuardarPedidoAsync(int usuarioId, PedidoDTO pedidoDto)
        {
            var ahora = DateTime.Now;
            OrdenDePedido pedido = null;
            
            await ValidarStockAsync(pedidoDto.Detalle);

            if (pedidoDto.EntregaEstimadaFecha.Date < ahora.Date)
                throw new HandledException("La Fecha estimada de entrega debe ser mayor.");

            var productosIds = pedidoDto.Detalle.Select(d => EncryptionService.Decrypt<int>(d.ProductoEncryptedId)).ToList();
            var productos = await _db.Productos.Where(p => productosIds.Contains(p.ProductoId)).ToListAsync();

            var numeroPedido = await this.ObtenerSiguienteNumeroAsync();
            pedido = new OrdenDePedido()
            {
                NumeroPedido = numeroPedido,
                ClienteId = EncryptionService.Decrypt<int>(pedidoDto.ClienteEncryptedId),
                FechaHoraPedido = ahora,
                RetiraPersonalmente = pedidoDto.RetiraPersonalmente,
                EntregaEstimadaFecha = pedidoDto.EntregaEstimadaFecha,
                EntregaEstimadaRangoHorarioId = EncryptionService.Decrypt<int>(pedidoDto.EntregaEstimadaRangoHorarioEncryptedId),
                EntregaDomicilio = pedidoDto.EntregaDomicilio,
                EntregaEntreCalles = pedidoDto.EntregaEntreCalles,
                EntregaLocalidad = pedidoDto.EntregaLocalidad,
                EntregaTelefono1 = pedidoDto.EntregaTelefono1,
                EntregaTelefono2 = pedidoDto.EntregaTelefono2,
                EntregaObservaciones = pedidoDto.EntregaObservaciones,
                UsuarioId = usuarioId,
                NumeroRemito = pedidoDto.NumeroRemito,
                VentaId = null,
                Activo = true,
                Observaciones = pedidoDto.Observaciones,
                PesoTotalEnGramos = pedidoDto.Detalle.Sum(d => d.ProductoPesoGramos * d.Cantidad),
                MontoTotal = pedidoDto.Detalle.Sum(d => (d.Precio * d.Cantidad) ?? 0),
                Detalle = pedidoDto.Detalle.Select(d =>
                                productos.First(p => p.ProductoId == EncryptionService.Decrypt<int>(d.ProductoEncryptedId)).MueveStock == true
                                                            ? new OrdenDePedidoDetalle
                                                                {
                                                                    ProductoId = EncryptionService.Decrypt<int>(d.ProductoEncryptedId),
                                                                    Cantidad = d.Cantidad,
                                                                    DepositoId = EncryptionService.Decrypt<int>(d.DepositoEncryptedId),
                                                                    PesoUnitarioEnGramos = d.ProductoPesoGramos,
                                                                    ListaDePreciosId = d.PrecioListaEncryptedId.Equals("-1")
                                                                                            ? (int?)null
                                                                                            : EncryptionService.Decrypt<int>(d.PrecioListaEncryptedId),
                                                                    Precio = d.PrecioListaEncryptedId.Equals("-1")
                                                                                            ? (decimal?)null
                                                                                            : d.Precio,
                                                                    MovimientoStock = new MovimientoStock
                                                                    {
                                                                        ProductoId = EncryptionService.Decrypt<int>(d.ProductoEncryptedId),
                                                                        FechaHora = ahora,
                                                                        UsuarioId = usuarioId,
                                                                        Tipo = "E",
                                                                        Cantidad = d.Cantidad,
                                                                        DepositoId = EncryptionService.Decrypt<int>(d.DepositoEncryptedId),
                                                                        Observaciones = $"Pedido N°{numeroPedido.ToString().PadLeft(8, '0')}"
                                                                    }
                                                                }
                                                            : null
                                            ).ToList()
            };

            _db.OrdenesDePedido.Add(pedido);
            await _db.SaveChangesAsync();

            return pedido;
        }

        public async Task AnularPedidoAsync(int usuarioId, int ordenDePedidoId)
        {
            var ahora = DateTime.Now;
            var ordenDePedido = this._db.OrdenesDePedido.Find(ordenDePedidoId);
            _db.Entry(ordenDePedido).State = EntityState.Modified;
            ordenDePedido.Activo = false;

            var movimientosStockId = await _db.OrdenesDePedidoDetalle.Where(d => d.OrdenDePedidoId == ordenDePedidoId).Select(d => d.MovimientoStockId).ToListAsync();
            var movimientosStock = await _db.MovimientosStock.Where(m => movimientosStockId.Contains(m.MovimientoStockId)).ToListAsync();

            foreach (var movimiento in movimientosStock)
            {
                _db.Entry(movimiento).State = EntityState.Modified;

                if (movimiento.ConfirmacionUsuarioId == null)
                {
                    movimiento.ConfirmacionUsuarioId = usuarioId;
                    movimiento.ConfirmacionFechaHora = ahora;
                }
                
                movimiento.Observaciones += $" (Anulado el {DateTime.Now.ToString("dd/MM/yy")})";

                var contraMovimiento = new MovimientoStock
                {
                    ProductoId = movimiento.ProductoId,
                    FechaHora = ahora,
                    UsuarioId = usuarioId,
                    Tipo = "I",
                    Cantidad = movimiento.Cantidad,
                    DepositoId = movimiento.DepositoId,
                    Observaciones = "Anulación /// " + movimiento.Observaciones,
                    ConfirmacionFechaHora = ahora,
                    ConfirmacionUsuarioId = usuarioId
                };
                _db.MovimientosStock.Add(contraMovimiento);
            }

            await _db.SaveChangesAsync();
        }

        public Task MarcarRegresoPedidoAsync(int usuarioId, int ordenDePedidoId)
        {
            var ordenDePedido = this._db.OrdenesDePedido.Find(ordenDePedidoId);
            _db.Entry(ordenDePedido).State = EntityState.Modified;
            ordenDePedido.DespachoFechaHora = null;
            ordenDePedido.DespachoUsuarioId = null;
            return _db.SaveChangesAsync();
        }

        public Task MarcarEntregaAsync(int usuarioId, int ordenDePedidoId)
        {
            var ordenDePedido = this._db.OrdenesDePedido.Find(ordenDePedidoId);
            _db.Entry(ordenDePedido).State = EntityState.Modified;
            ordenDePedido.MarcoEntregaUsuarioId = usuarioId;
            ordenDePedido.MarcoEntregaFechaHora = DateTime.Now;
            return _db.SaveChangesAsync();
        }

        public Task MarcarDespachoAsync(int usuarioId, int ordenDePedidoId)
        {
            var ordenDePedido = this._db.OrdenesDePedido.Find(ordenDePedidoId);
            _db.Entry(ordenDePedido).State = EntityState.Modified;
            ordenDePedido.DespachoUsuarioId = usuarioId;
            ordenDePedido.DespachoFechaHora = DateTime.Now;
            return _db.SaveChangesAsync();
        }

        public Task MarcarCancelacionPreparacionAsync(int usuarioId, int ordenDePedidoId)
        {
            var ordenDePedido = this._db.OrdenesDePedido.Find(ordenDePedidoId);
            _db.Entry(ordenDePedido).State = EntityState.Modified;
            ordenDePedido.PreparacionFechaHoraInicio = null;
            ordenDePedido.PreparacionUsuarioId = null;
            return _db.SaveChangesAsync();
        }

        public Task MarcarInicioPreparacionAsync(int usuarioId, int ordenDePedidoId)
        {
            var ordenDePedido = this._db.OrdenesDePedido.Find(ordenDePedidoId);
            _db.Entry(ordenDePedido).State = EntityState.Modified;
            ordenDePedido.PreparacionFechaHoraInicio = DateTime.Now;
            ordenDePedido.PreparacionUsuarioId = usuarioId;
            return _db.SaveChangesAsync();
        }

        public async Task MarcarFinalizacionPreparacionAsync(int usuarioId, int ordenDePedidoId)
        {
            var ahora = DateTime.Now;
            var ordenDePedido = this._db.OrdenesDePedido.Find(ordenDePedidoId);
            _db.Entry(ordenDePedido).State = EntityState.Modified;
            ordenDePedido.PreparacionFechaHoraFin = ahora;

            var movimientosStockId = await _db.OrdenesDePedidoDetalle.Where(d => d.OrdenDePedidoId == ordenDePedidoId).Select(d => d.MovimientoStockId).ToListAsync();
            var movimientosStock = await _db.MovimientosStock.Where(m => movimientosStockId.Contains(m.MovimientoStockId)).ToListAsync();

            foreach (var movimiento in movimientosStock)
            {
                _db.Entry(movimiento).State = EntityState.Modified;
                movimiento.ConfirmacionUsuarioId = usuarioId;
                movimiento.ConfirmacionFechaHora = ahora;
            }

            await _db.SaveChangesAsync();
        }
    }
}
