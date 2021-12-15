﻿using Microsoft.AspNetCore.Mvc;
using Natom.Petshop.Gestion.Backend.Services;
using Natom.Petshop.Gestion.Biz.Exceptions;
using Natom.Petshop.Gestion.Biz.Managers;
using Natom.Petshop.Gestion.Entities.DTO;
using Natom.Petshop.Gestion.Entities.DTO.DataTable;
using Natom.Petshop.Gestion.Entities.DTO.Pedidos;
using Natom.Petshop.Gestion.Entities.DTO.Precios;
using Natom.Petshop.Gestion.Entities.DTO.Stock;
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
    public class PedidosController : BaseController
    {
        public PedidosController(IServiceProvider serviceProvider) : base(serviceProvider)
        {
        }

        // POST: pedidos/list?status={status}
        [HttpPost]
        [ActionName("list")]
        public async Task<IActionResult> PostListAsync([FromBody] DataTableRequestDTO request, [FromQuery] string status = null)
        {
            try
            {
                var manager = new PedidosManager(_serviceProvider);
                var pedidosCount = await manager.ObtenerPedidosCountAsync();
                var pedidos = await manager.ObtenerPedidosDataTableAsync(request.Start, request.Length, request.Search.Value, request.Order.First().ColumnIndex, request.Order.First().Direction, statusFilter: status);

                return Ok(new ApiResultDTO<DataTableResponseDTO<PedidoListDTO>>
                {
                    Success = true,
                    Data = new DataTableResponseDTO<PedidoListDTO>
                    {
                        RecordsTotal = pedidosCount,
                        RecordsFiltered = pedidos.Count,
                        Records = pedidos.Select(pedido => new PedidoListDTO().From(pedido)).ToList()
                    }
                });
            }
            catch (HandledException ex)
            {
                return Ok(new ApiResultDTO { Success = false, Message = ex.Message });
            }
            catch (Exception ex)
            {
                await LoggingService.LogExceptionAsync(_db, ex, usuarioId: null, _userAgent);
                return Ok(new ApiResultDTO { Success = false, Message = "Se ha producido un error interno." });
            }
        }

        // GET: pedidos/basics/data
        // GET: pedidos/basics/data?encryptedId={encryptedId}
        [HttpGet]
        [ActionName("basics/data")]
        public async Task<IActionResult> GetBasicsDataAsync([FromQuery] string encryptedId = null)
        {
            try
            {
                var manager = new PedidosManager(_serviceProvider);
                var numeroPedido = string.Empty;
                PedidoDTO entity = null;

                if (!string.IsNullOrEmpty(encryptedId))
                {
                    var pedidoId = EncryptionService.Decrypt<int>(Uri.UnescapeDataString(encryptedId));
                    var pedido = await manager.ObtenerPedidoAsync(pedidoId);
                    entity = new PedidoDTO().From(pedido);
                    numeroPedido = entity.Numero;
                }
                else
                {
                    numeroPedido = (await manager.ObtenerSiguienteNumeroAsync()).ToString().PadLeft(8, '0');
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
                        numero_pedido = numeroPedido
                    }
                });
            }
            catch (HandledException ex)
            {
                return Ok(new ApiResultDTO { Success = false, Message = ex.Message });
            }
            catch (Exception ex)
            {
                await LoggingService.LogExceptionAsync(_db, ex, usuarioId: null, _userAgent);
                return Ok(new ApiResultDTO { Success = false, Message = "Se ha producido un error interno." });
            }
        }

        // POST: pedidos/save
        [HttpPost]
        [ActionName("save")]
        public async Task<IActionResult> PostSaveAsync([FromBody] PedidoDTO pedidoDto)
        {
            try
            {
                var manager = new PedidosManager(_serviceProvider);
                var pedido = await manager.GuardarPedidoAsync((int)(_token?.UserId ?? 0), pedidoDto);

                await RegistrarAccionAsync(pedido.OrdenDePedidoId, nameof(OrdenDePedido), string.IsNullOrEmpty(pedidoDto.EncryptedId) ? "Alta" : "Edición");

                return Ok(new ApiResultDTO<PedidoDTO>
                {
                    Success = true,
                    Data = new PedidoDTO().From(pedido)
                });
            }
            catch (HandledException ex)
            {
                return Ok(new ApiResultDTO { Success = false, Message = ex.Message });
            }
            catch (Exception ex)
            {
                await LoggingService.LogExceptionAsync(_db, ex, usuarioId: null, _userAgent);
                return Ok(new ApiResultDTO { Success = false, Message = "Se ha producido un error interno." });
            }
        }

        // POST: pedidos/preparacion/iniciar?encryptedId={encryptedId}
        [HttpPost]
        [ActionName("preparacion/iniciar")]
        public async Task<IActionResult> IniciarPreparacionAsync([FromQuery] string encryptedId)
        {
            try
            {
                var ordenDePedidoId = EncryptionService.Decrypt<int>(Uri.UnescapeDataString(encryptedId));

                var manager = new PedidosManager(_serviceProvider);
                await manager.MarcarInicioPreparacionAsync((int)(_token?.UserId ?? 0), ordenDePedidoId);

                await RegistrarAccionAsync(ordenDePedidoId, nameof(OrdenDePedido), "Inicio de preparación");

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
                await LoggingService.LogExceptionAsync(_db, ex, usuarioId: null, _userAgent);
                return Ok(new ApiResultDTO { Success = false, Message = "Se ha producido un error interno." });
            }
        }

        // POST: pedidos/preparacion/cancelar?encryptedId={encryptedId}
        [HttpPost]
        [ActionName("preparacion/cancelar")]
        public async Task<IActionResult> CancelarPreparacionAsync([FromQuery] string encryptedId)
        {
            try
            {
                var ordenDePedidoId = EncryptionService.Decrypt<int>(Uri.UnescapeDataString(encryptedId));

                var manager = new PedidosManager(_serviceProvider);
                await manager.MarcarCancelacionPreparacionAsync((int)(_token?.UserId ?? 0), ordenDePedidoId);

                await RegistrarAccionAsync(ordenDePedidoId, nameof(OrdenDePedido), "Preparación cancelada");

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
                await LoggingService.LogExceptionAsync(_db, ex, usuarioId: null, _userAgent);
                return Ok(new ApiResultDTO { Success = false, Message = "Se ha producido un error interno." });
            }
        }

        // POST: pedidos/preparacion/finalizacion?encryptedId={encryptedId}
        [HttpPost]
        [ActionName("preparacion/finalizacion")]
        public async Task<IActionResult> FinalizarPreparacionAsync([FromQuery] string encryptedId)
        {
            try
            {
                var ordenDePedidoId = EncryptionService.Decrypt<int>(Uri.UnescapeDataString(encryptedId));

                var manager = new PedidosManager(_serviceProvider);
                await manager.MarcarFinalizacionPreparacionAsync((int)(_token?.UserId ?? 0), ordenDePedidoId);

                await RegistrarAccionAsync(ordenDePedidoId, nameof(OrdenDePedido), "Preparación completada");

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
                await LoggingService.LogExceptionAsync(_db, ex, usuarioId: null, _userAgent);
                return Ok(new ApiResultDTO { Success = false, Message = "Se ha producido un error interno." });
            }
        }

        // DELETE: pedidos/anular?encryptedId={encryptedId}
        [HttpPost]
        [ActionName("anular")]
        public async Task<IActionResult> AnularPedidoAsync([FromQuery] string encryptedId)
        {
            try
            {
                var ordenDePedidoId = EncryptionService.Decrypt<int>(Uri.UnescapeDataString(encryptedId));

                var manager = new PedidosManager(_serviceProvider);
                await manager.AnularPedidoAsync((int)(_token?.UserId ?? 0), ordenDePedidoId);

                await RegistrarAccionAsync(ordenDePedidoId, nameof(OrdenDePedido), "Orden anulada");

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
                await LoggingService.LogExceptionAsync(_db, ex, usuarioId: null, _userAgent);
                return Ok(new ApiResultDTO { Success = false, Message = "Se ha producido un error interno." });
            }
        }
    }
}