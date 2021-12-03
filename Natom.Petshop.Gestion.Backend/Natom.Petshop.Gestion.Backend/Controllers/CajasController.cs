using Microsoft.AspNetCore.Mvc;
using Natom.Petshop.Gestion.Backend.Services;
using Natom.Petshop.Gestion.Biz.Exceptions;
using Natom.Petshop.Gestion.Biz.Managers;
using Natom.Petshop.Gestion.Entities.DTO;
using Natom.Petshop.Gestion.Entities.DTO.Cajas;
using Natom.Petshop.Gestion.Entities.DTO.DataTable;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Backend.Controllers
{
    [ApiController]
    [Route("[controller]/[action]")]
    public class CajasController : BaseController
    {
        public CajasController(IServiceProvider serviceProvider) : base(serviceProvider)
        {
        }

        // POST: cajas/diaria/list?filterDate={filterDate}
        [HttpPost]
        [ActionName("diaria/list")]
        public async Task<IActionResult> PostMovimientosCajaDiariaListAsync([FromBody] DataTableRequestDTO request, [FromQuery]string filterDate = null)
        {
            try
            {
                DateTime dt;
                DateTime? dtFilter = null;
                if (DateTime.TryParse(filterDate, out dt))
                    dtFilter = dt;

                var manager = new CajasManager(_serviceProvider);
                var movimientosCount = await manager.ObtenerMovimientosCajaDiariaCountAsync();
                var movimientos = await manager.ObtenerMovimientosCajaDiariaDataTableAsync(request.Start, request.Length, request.Search.Value, request.Order.First().ColumnIndex, request.Order.First().Direction, dtFilter);
                var saldoActual = await manager.ObtenerSaldoActualCajaDiariaAsync(dtFilter);

                return Ok(new ApiResultDTO<DataTableResponseDTO<MovimientoCajaDiariaDTO>>
                {
                    Success = true,
                    Data = new DataTableResponseDTO<MovimientoCajaDiariaDTO>
                    {
                        RecordsTotal = movimientosCount,
                        RecordsFiltered = movimientos.Count,
                        Records = movimientos.Select(movimiento => new MovimientoCajaDiariaDTO().From(movimiento)).ToList(),
                        ExtraData = new
                        {
                            saldoActual = saldoActual
                        }
                    }
                });
            }
            catch (HandledException ex)
            {
                return Ok(new ApiResultDTO { Success = false, Message = ex.Message });
            }
            catch (Exception ex)
            {
                await LoggingService.LogExceptionAsync(_db, ex, usuarioId: (int?)_token?.UserId, _userAgent);
                return Ok(new ApiResultDTO { Success = false, Message = "Se ha producido un error interno." });
            }
        }

        // POST: cajas/diaria/save
        [HttpPost]
        [ActionName("diaria/save")]
        public async Task<IActionResult> PostMovimientoCajaDiariaSaveAsync([FromBody] MovimientoCajaDiariaDTO user)
        {
            try
            {
                var manager = new CajasManager(_serviceProvider);
                var movimiento = await manager.GuardarMovimientoCajaDiariaAsync(user, (int)(_token?.UserId ?? 0));

                return Ok(new ApiResultDTO<MovimientoCajaDiariaDTO>
                {
                    Success = true,
                    Data = new MovimientoCajaDiariaDTO().From(movimiento)
                });
            }
            catch (HandledException ex)
            {
                return Ok(new ApiResultDTO { Success = false, Message = ex.Message });
            }
            catch (Exception ex)
            {
                await LoggingService.LogExceptionAsync(_db, ex, usuarioId: (int?)_token?.UserId, _userAgent);
                return Ok(new ApiResultDTO { Success = false, Message = "Se ha producido un error interno." });
            }
        }

        // POST: cajas/fuerte/list?filterDate={filterDate}
        [HttpPost]
        [ActionName("fuerte/list")]
        public async Task<IActionResult> PostMovimientosCajaFuerteListAsync([FromBody] DataTableRequestDTO request, [FromQuery] string filterDate = null)
        {
            try
            {
                DateTime dt;
                DateTime? dtFilter = null;
                if (DateTime.TryParse(filterDate, out dt))
                    dtFilter = dt;

                var manager = new CajasManager(_serviceProvider);
                var movimientosCount = await manager.ObtenerMovimientosCajaFuerteCountAsync();
                var movimientos = await manager.ObtenerMovimientosCajaFuerteDataTableAsync(request.Start, request.Length, request.Search.Value, request.Order.First().ColumnIndex, request.Order.First().Direction, dtFilter);
                var saldoActual = await manager.ObtenerSaldoActualCajaFuerteAsync(dtFilter);

                return Ok(new ApiResultDTO<DataTableResponseDTO<MovimientoCajaFuerteDTO>>
                {
                    Success = true,
                    Data = new DataTableResponseDTO<MovimientoCajaFuerteDTO>
                    {
                        RecordsTotal = movimientosCount,
                        RecordsFiltered = movimientos.Count,
                        Records = movimientos.Select(movimiento => new MovimientoCajaFuerteDTO().From(movimiento)).ToList(),
                        ExtraData = new
                        {
                            saldoActual = saldoActual
                        }
                    }
                });
            }
            catch (HandledException ex)
            {
                return Ok(new ApiResultDTO { Success = false, Message = ex.Message });
            }
            catch (Exception ex)
            {
                await LoggingService.LogExceptionAsync(_db, ex, usuarioId: (int?)_token?.UserId, _userAgent);
                return Ok(new ApiResultDTO { Success = false, Message = "Se ha producido un error interno." });
            }
        }

        // POST: cajas/fuerte/save
        [HttpPost]
        [ActionName("fuerte/save")]
        public async Task<IActionResult> PostMovimientoCajaFuerteSaveAsync([FromBody] MovimientoCajaFuerteDTO user)
        {
            try
            {
                var manager = new CajasManager(_serviceProvider);
                var movimiento = await manager.GuardarMovimientoCajaFuerteAsync(user, (int)(_token?.UserId ?? 0));

                return Ok(new ApiResultDTO<MovimientoCajaFuerteDTO>
                {
                    Success = true,
                    Data = new MovimientoCajaFuerteDTO().From(movimiento)
                });
            }
            catch (HandledException ex)
            {
                return Ok(new ApiResultDTO { Success = false, Message = ex.Message });
            }
            catch (Exception ex)
            {
                await LoggingService.LogExceptionAsync(_db, ex, usuarioId: (int?)_token?.UserId, _userAgent);
                return Ok(new ApiResultDTO { Success = false, Message = "Se ha producido un error interno." });
            }
        }
    }
}
