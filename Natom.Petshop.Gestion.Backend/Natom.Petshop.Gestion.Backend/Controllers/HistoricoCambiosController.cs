using Microsoft.AspNetCore.Mvc;
using Natom.Petshop.Gestion.Backend.Services;
using Natom.Petshop.Gestion.Biz.Exceptions;
using Natom.Petshop.Gestion.Biz.Managers;
using Natom.Petshop.Gestion.Entities.DTO;
using Natom.Petshop.Gestion.Entities.DTO.HistoricoCambios;
using Natom.Petshop.Gestion.Entities.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Backend.Controllers
{
    [ApiController]
    [Route("[controller]/[action]")]
    public class HistoricoCambiosController : BaseController
    {
        public HistoricoCambiosController(IServiceProvider serviceProvider) : base(serviceProvider)
        {
        }

        // GET: historicoCambios/get?entity={entity}&encrypted_id={encrypted_id}
        [HttpGet]
        [ActionName("get")]
        public async Task<IActionResult> GetAsync([FromQuery] string entity, [FromQuery] string encrypted_id)
        {
            try
            {
                var manager = new BaseManager(_serviceProvider);
                var historico = await manager.ConsultarHistoricoCambiosAsync(EncryptionService.Decrypt<int>(encrypted_id), entity);

                return Ok(new ApiResultDTO<List<HistoricoListDTO>>
                {
                    Success = true,
                    Data = historico.Select(h => new HistoricoListDTO().From(h)).ToList()
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
