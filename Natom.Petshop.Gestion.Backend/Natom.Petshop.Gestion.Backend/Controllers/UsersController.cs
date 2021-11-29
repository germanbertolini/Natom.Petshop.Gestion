using Microsoft.AspNetCore.Mvc;
using Natom.Petshop.Gestion.Backend.Services;
using Natom.Petshop.Gestion.Biz.Exceptions;
using Natom.Petshop.Gestion.Biz.Managers;
using Natom.Petshop.Gestion.Entities.DTO;
using Natom.Petshop.Gestion.Entities.DTO.Auth;
using Natom.Petshop.Gestion.Entities.DTO.DataTable;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Backend.Controllers
{
    [ApiController]
    [Route("[controller]/[action]")]
    public class UsersController : BaseController
    {
        public UsersController(IServiceProvider serviceProvider) : base(serviceProvider)
        {
        }

        // POST: users/list
        [HttpPost]
        [ActionName("list")]
        public async Task<IActionResult> PostList([FromBody]DataTableRequestDTO request)
        {
            try
            {
                var manager = new UsuariosManager(_serviceProvider);
                var usuariosCount = await manager.ObtenerUsuariosCountAsync();
                var usuarios = await manager.ObtenerUsuariosDataTableAsync(request.Start, request.Length, request.Search.Value, request.Order.First().ColumnIndex, request.Order.First().Direction);

                return Ok(new ApiResultDTO<DataTableResponseDTO<UserDTO>>
                {
                    Success = true,
                    Data = new DataTableResponseDTO<UserDTO>
                    {
                        RecordsTotal = usuariosCount,
                        RecordsFiltered = usuarios.Count,
                        Records = usuarios.Select(usuario => new UserDTO
                        {
                            EncryptedId = EncryptionService.Encrypt(usuario.UsuarioId),
                            FirstName = usuario.Nombre,
                            LastName = usuario.Apellido,
                            Email = usuario.Email,
                            RegisteredAt = usuario.FechaHoraAlta,
                            Status = manager.ObtenerEstado(usuario)
                        }).ToList()
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

        private void GetClientAndSecretFromAuthorizationBasic(out string client, out string secret)
        {
            client = null;
            secret = null;

            string authorization = GetAuthorizationFromHeader();
            if (!authorization.StartsWith("Basic")) throw new HandledException("Authorization header inválido");

            var data = Convert.FromBase64String(authorization.Replace("Basic ", ""));
            var authorizationDecoded = Encoding.UTF8.GetString(data);

            if (authorizationDecoded.IndexOf(":") >= 0)
            {
                client = authorizationDecoded.Substring(0, authorizationDecoded.IndexOf(":"));
                secret = authorizationDecoded.Substring(authorizationDecoded.IndexOf(":") + 1);
            }
            else
            {
                throw new HandledException("No se pudo obtener el client y secret");
            }
        }
    }
}
