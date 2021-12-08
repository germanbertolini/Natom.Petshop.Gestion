using Microsoft.AspNetCore.Mvc;
using Natom.Petshop.Gestion.Backend.Services;
using Natom.Petshop.Gestion.Biz.Exceptions;
using Natom.Petshop.Gestion.Biz.Managers;
using Natom.Petshop.Gestion.Entities.DTO;
using Natom.Petshop.Gestion.Entities.DTO.DataTable;
using Natom.Petshop.Gestion.Entities.DTO.Precios;
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
    public class PreciosController : BaseController
    {
        public PreciosController(IServiceProvider serviceProvider) : base(serviceProvider)
        {
        }

        // POST: precios/list?filter={filter}
        [HttpPost]
        [ActionName("list")]
        public async Task<IActionResult> PostListAsync([FromBody] DataTableRequestDTO request, [FromQuery] string lista = null)
        {
            try
            {
                int? listaDePreciosId = null;
                if (!string.IsNullOrEmpty(lista))
                    listaDePreciosId = EncryptionService.Decrypt<int>(lista);

                var manager = new PreciosManager(_serviceProvider);
                var precios = manager.ObtenerPreciosDataTable(request.Start, request.Length, request.Search.Value, request.Order.First().ColumnIndex, request.Order.First().Direction, listaDePreciosId);

                var listasDePrecios = await manager.ObtenerListasDePreciosAsync();

                return Ok(new ApiResultDTO<DataTableResponseDTO<PrecioListDTO>>
                {
                    Success = true,
                    Data = new DataTableResponseDTO<PrecioListDTO>
                    {
                        RecordsTotal = precios.FirstOrDefault()?.CantidadRegistros ?? 0,
                        RecordsFiltered = precios.Count,
                        Records = precios.Select(precio => new PrecioListDTO().From(precio)).ToList(),
                        ExtraData = new
                        {
                            listasDePrecios = listasDePrecios.Select(lista => new ListaDePreciosDTO().From(lista))
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
                await LoggingService.LogExceptionAsync(_db, ex, usuarioId: null, _userAgent);
                return Ok(new ApiResultDTO { Success = false, Message = "Se ha producido un error interno." });
            }
        }

        // GET: precios/basics/data
        // GET: precios/basics/data?encryptedId={encryptedId}
        [HttpGet]
        [ActionName("basics/data")]
        public async Task<IActionResult> GetBasicsDataAsync([FromQuery] string encryptedId = null)
        {
            try
            {
                var manager = new PreciosManager(_serviceProvider);
                PrecioDTO entity = null;

                if (!string.IsNullOrEmpty(encryptedId))
                {
                    var productoPrecioId = EncryptionService.Decrypt<int>(Uri.UnescapeDataString(encryptedId));
                    var precio = await manager.ObtenerPrecioAsync(productoPrecioId);
                    entity = new PrecioDTO().From(precio);
                }

                var listasDePrecios = await manager.ObtenerListasDePreciosAsync();

                return Ok(new ApiResultDTO<dynamic>
                {
                    Success = true,
                    Data = new
                    {
                        entity = entity,
                        listasDePrecios = listasDePrecios.Select(lista => new ListaDePreciosDTO().From(lista))
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

        // POST: precios/save
        [HttpPost]
        [ActionName("save")]
        public async Task<IActionResult> PostSaveAsync([FromBody] PrecioDTO precioDto)
        {
            try
            {
                var manager = new PreciosManager(_serviceProvider);
                var precio = await manager.GuardarPrecioAsync(precioDto);

                await RegistrarAccionAsync(precio.ProductoPrecioId, nameof(ProductoPrecio), string.IsNullOrEmpty(precioDto.EncryptedId) ? "Alta" : "Edición");

                return Ok(new ApiResultDTO<PrecioDTO>
                {
                    Success = true,
                    Data = new PrecioDTO().From(precio)
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
