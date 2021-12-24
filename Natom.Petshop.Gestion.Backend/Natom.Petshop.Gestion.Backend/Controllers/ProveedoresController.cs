using Microsoft.AspNetCore.Mvc;
using Natom.Petshop.Gestion.Backend.Services;
using Natom.Petshop.Gestion.Biz.Exceptions;
using Natom.Petshop.Gestion.Biz.Managers;
using Natom.Petshop.Gestion.Entities.DTO;
using Natom.Petshop.Gestion.Entities.DTO.Autocomplete;
using Natom.Petshop.Gestion.Entities.DTO.Proveedores;
using Natom.Petshop.Gestion.Entities.DTO.DataTable;
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
    public class ProveedoresController : BaseController
    {
        public ProveedoresController(IServiceProvider serviceProvider) : base(serviceProvider)
        {
        }

        // POST: proveedores/list?filter={filter}
        [HttpPost]
        [ActionName("list")]
        public async Task<IActionResult> PostListAsync([FromBody] DataTableRequestDTO request, [FromQuery] string status = null)
        {
            try
            {
                var manager = new ProveedoresManager(_serviceProvider);
                var usuariosCount = await manager.ObtenerProveedoresCountAsync();
                var usuarios = await manager.ObtenerProveedoresDataTableAsync(request.Start, request.Length, request.Search.Value, request.Order.First().ColumnIndex, request.Order.First().Direction, statusFilter: status);

                return Ok(new ApiResultDTO<DataTableResponseDTO<ProveedorDTO>>
                {
                    Success = true,
                    Data = new DataTableResponseDTO<ProveedorDTO>
                    {
                        RecordsTotal = usuariosCount,
                        RecordsFiltered = usuarios.Count,
                        Records = usuarios.Select(usuario => new ProveedorDTO().From(usuario)).ToList()
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

        // GET: proveedores/basics/data
        // GET: proveedores/basics/data?encryptedId={encryptedId}
        [HttpGet]
        [ActionName("basics/data")]
        public async Task<IActionResult> GetBasicsDataAsync([FromQuery] string encryptedId = null)
        {
            try
            {
                var manager = new ProveedoresManager(_serviceProvider);
                ProveedorDTO entity = null;

                if (!string.IsNullOrEmpty(encryptedId))
                {
                    var proveedorId = EncryptionService.Decrypt<int>(Uri.UnescapeDataString(encryptedId));
                    var proveedor = await manager.ObtenerProveedorAsync(proveedorId);
                    entity = new ProveedorDTO().From(proveedor);
                }

                return Ok(new ApiResultDTO<dynamic>
                {
                    Success = true,
                    Data = new
                    {
                        entity = entity
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

        // POST: proveedores/save
        [HttpPost]
        [ActionName("save")]
        public async Task<IActionResult> PostSaveAsync([FromBody] ProveedorDTO proveedorDto)
        {
            try
            {
                var manager = new ProveedoresManager(_serviceProvider);
                var proveedor = await manager.GuardarProveedorAsync(proveedorDto);

                await RegistrarAccionAsync(proveedor.ProveedorId, nameof(Proveedor), string.IsNullOrEmpty(proveedorDto.EncryptedId) ? "Alta" : "Edición");

                return Ok(new ApiResultDTO<ProveedorDTO>
                {
                    Success = true,
                    Data = new ProveedorDTO().From(proveedor)
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

        // GET: proveedores/search?filter={filter}
        [HttpGet]
        [ActionName("search")]
        public async Task<IActionResult> GetSearchAsync([FromQuery] string filter = null)
        {
            try
            {
                var manager = new ProveedoresManager(_serviceProvider);
                var proveedores = await manager.BuscarProveedoresAsync(size: 20, filter);

                return Ok(new ApiResultDTO<AutocompleteResponseDTO<ProveedorDTO>>
                {
                    Success = true,
                    Data = new AutocompleteResponseDTO<ProveedorDTO>
                    {
                        Total = proveedores.Count,
                        Results = proveedores.Select(proveedor => new ProveedorDTO().From(proveedor)).ToList()
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

        // DELETE: proveedores/disable?encryptedId={encryptedId}
        [HttpDelete]
        [ActionName("disable")]
        public async Task<IActionResult> DeleteAsync([FromQuery] string encryptedId)
        {
            try
            {
                var proveedorId = EncryptionService.Decrypt<int>(Uri.UnescapeDataString(encryptedId));

                var manager = new ProveedoresManager(_serviceProvider);
                await manager.DesactivarProveedorAsync(proveedorId);

                await RegistrarAccionAsync(proveedorId, nameof(Proveedor), "Baja");

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

        // POST: proveedores/enable?encryptedId={encryptedId}
        [HttpPost]
        [ActionName("enable")]
        public async Task<IActionResult> EnableAsync([FromQuery] string encryptedId)
        {
            try
            {
                var proveedorId = EncryptionService.Decrypt<int>(Uri.UnescapeDataString(encryptedId));

                var manager = new ProveedoresManager(_serviceProvider);
                await manager.ActivarProveedorAsync(proveedorId);

                await RegistrarAccionAsync(proveedorId, nameof(Proveedor), "Alta");

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
