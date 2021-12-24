using Microsoft.AspNetCore.Mvc;
using Natom.Petshop.Gestion.Backend.Services;
using Natom.Petshop.Gestion.Biz.Exceptions;
using Natom.Petshop.Gestion.Biz.Managers;
using Natom.Petshop.Gestion.Entities.DTO;
using Natom.Petshop.Gestion.Entities.DTO.DataTable;
using Natom.Petshop.Gestion.Entities.DTO.Pedidos;
using Natom.Petshop.Gestion.Entities.DTO.Precios;
using Natom.Petshop.Gestion.Entities.DTO.Stock;
using Natom.Petshop.Gestion.Entities.DTO.Ventas;
using Natom.Petshop.Gestion.Entities.Model;
using Natom.Petshop.Gestion.Entities.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Backend.Controllers
{
    [ApiController]
    [Route("[controller]/[action]")]
    public class VentasController : BaseController
    {
        public VentasController(IServiceProvider serviceProvider) : base(serviceProvider)
        {
        }

        // POST: ventas/list?status={status}
        [HttpPost]
        [ActionName("list")]
        public async Task<IActionResult> PostListAsync([FromBody] DataTableRequestDTO request, [FromQuery] string status = null)
        {
            try
            {
                var manager = new VentasManager(_serviceProvider);
                var ventasCount = await manager.ObtenerVentasCountAsync();
                var ventas = await manager.ObtenerVentasDataTableAsync(request.Start, request.Length, request.Search.Value, request.Order.First().ColumnIndex, request.Order.First().Direction, status);

                return Ok(new ApiResultDTO<DataTableResponseDTO<VentaListDTO>>
                {
                    Success = true,
                    Data = new DataTableResponseDTO<VentaListDTO>
                    {
                        RecordsTotal = ventasCount,
                        RecordsFiltered = ventas.Count,
                        Records = ventas.Select(venta => new VentaListDTO().From(venta)).ToList()
                    }
                });
            }
            catch (HandledException ex)
            {
                return Ok(new ApiResultDTO { Success = false, Message = ex.Message });
            }
            catch (Exception ex)
            {
                await LoggingService.LogExceptionAsync(_db, ex, usuarioId: (int)(_token?.UserId ?? 0), _userAgent);
                return Ok(new ApiResultDTO { Success = false, Message = "Se ha producido un error interno." });
            }
        }

        // GET: ventas/basics/data
        // GET: ventas/basics/data?encryptedId={encryptedId}
        [HttpGet]
        [ActionName("basics/data")]
        public async Task<IActionResult> GetBasicsDataAsync([FromQuery] string encryptedId = null)
        {
            try
            {
                var manager = new VentasManager(_serviceProvider);
                var numeroVenta = string.Empty;
                VentaDTO entity = null;

                if (!string.IsNullOrEmpty(encryptedId))
                {
                    var ventaId = EncryptionService.Decrypt<int>(Uri.UnescapeDataString(encryptedId));
                    var venta = await manager.ObtenerVentaAsync(ventaId);
                    entity = new VentaDTO().From(venta);
                    numeroVenta = entity.Numero;
                }
                else
                {
                    numeroVenta = (await manager.ObtenerSiguienteNumeroAsync()).ToString().PadLeft(8, '0');
                }

                var stockManager = new StockManager(_serviceProvider);
                var depositos = await stockManager.ObtenerDepositosActivosAsync();

                var preciosManager = new PreciosManager(_serviceProvider);
                var listasDePrecios = await preciosManager.ObtenerListasDePreciosAsync();

                var rangosHorarios = await manager.ObtenerRangosHorariosActivosAsync();

                return Ok(new ApiResultDTO<dynamic>
                {
                    Success = true,
                    Data = new
                    {
                        entity = entity,
                        depositos = depositos.Select(deposito => new DepositoDTO().From(deposito)).ToList(),
                        listasDePrecios = listasDePrecios.Select(lista => new ListaDePreciosDTO().From(lista)),
                        rangos_horarios = rangosHorarios.Select(rango => new RangoHorarioDTO().From(rango)).ToList(),
                        numero_venta = numeroVenta
                    }
                });
            }
            catch (HandledException ex)
            {
                return Ok(new ApiResultDTO { Success = false, Message = ex.Message });
            }
            catch (Exception ex)
            {
                await LoggingService.LogExceptionAsync(_db, ex, usuarioId: (int)(_token?.UserId ?? 0), _userAgent);
                return Ok(new ApiResultDTO { Success = false, Message = "Se ha producido un error interno." });
            }
        }

        // POST: ventas/save
        [HttpPost]
        [ActionName("save")]
        public async Task<IActionResult> PostSaveAsync([FromBody] VentaDTO ventaDto)
        {
            try
            {
                var manager = new VentasManager(_serviceProvider);
                var venta = await manager.GuardarVentaAsync((int)(_token?.UserId ?? 0), ventaDto);

                await RegistrarAccionAsync(venta.VentaId, nameof(Venta), "Alta");

                var ordenesDePedidoId = venta.Detalle
                                                .Where(d => d.OrdenDePedidoId.HasValue)
                                                .Select(d => d.OrdenDePedidoId.Value)
                                                .GroupBy(k => k, (k, v) => k);

                foreach (var ordenDePedidoId in ordenesDePedidoId)
                    await RegistrarAccionAsync(ordenDePedidoId, nameof(OrdenDePedido), $"Facturado en Venta N°{venta.NumeroVenta.ToString().PadLeft(8, '0')}");

                return Ok(new ApiResultDTO<VentaDTO>
                {
                    Success = true,
                    Data = new VentaDTO().From(venta)
                });
            }
            catch (HandledException ex)
            {
                return Ok(new ApiResultDTO { Success = false, Message = ex.Message });
            }
            catch (Exception ex)
            {
                await LoggingService.LogExceptionAsync(_db, ex, usuarioId: (int)(_token?.UserId ?? 0), _userAgent);
                return Ok(new ApiResultDTO { Success = false, Message = "Se ha producido un error interno." });
            }
        }

        // DELETE: ventas/anular?encryptedId={encryptedId}
        [HttpPost]
        [ActionName("anular")]
        public async Task<IActionResult> AnularVentaAsync([FromQuery] string encryptedId)
        {
            try
            {
                var ordenDeVentaId = EncryptionService.Decrypt<int>(Uri.UnescapeDataString(encryptedId));

                var manager = new VentasManager(_serviceProvider);
                var pedidos = await manager.AnularVentaAsync((int)(_token?.UserId ?? 0), ordenDeVentaId);

                await RegistrarAccionAsync(ordenDeVentaId, nameof(Venta), "Venta anulada");

                foreach (var pedido in pedidos)
                    await RegistrarAccionAsync(pedido.OrdenDePedidoId, nameof(OrdenDePedido), $"Venta anulada. Vuelve a pendiente de facturar.");

                return Ok(new ApiResultDTO
                {
                    Success = true
                });
            }
            catch (HandledException ex)
            {
                return Ok(new ApiResultDTO { Success = false, Message = ex.Message });
            }
            catch (Exception ex)
            {
                await LoggingService.LogExceptionAsync(_db, ex, usuarioId: (int)(_token?.UserId ?? 0), _userAgent);
                return Ok(new ApiResultDTO { Success = false, Message = "Se ha producido un error interno." });
            }
        }
    }
}
