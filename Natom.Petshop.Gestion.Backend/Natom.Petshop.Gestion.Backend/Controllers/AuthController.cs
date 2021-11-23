using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Natom.Petshop.Gestion.Backend.Services;
using Natom.Petshop.Gestion.Biz;
using Natom.Petshop.Gestion.Biz.Exceptions;
using Natom.Petshop.Gestion.Entities.DTO.Auth;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Backend.Controllers
{
    [ApiController]
    [Route("[controller]/[action]")]
    public class AuthController : BaseController
    {
        public AuthController(IServiceProvider serviceProvider) : base(serviceProvider)
        {
        }

        // POST: auth/login
        [HttpPost]
        [ActionName("login")]
        public async Task<IActionResult> PostLogin()
        {
            try
            {
                string email, password;
                
                GetClientAndSecretFromAuthorizationBasic(out email, out password);

                
                return Ok(new LoginResultDTO
                {
                    User = new UserDTO
                    {
                        EncryptedId = "",
                        FirstName = "",
                        LastName = "",
                        Email = "",
                        PictureURL = "",
                        RegisteredAt = new DateTime(2020, 01, 01)
                    },
                    Permissions = new List<string>(),
                    Token = ""
                });
            }
            catch (HandledException ex)
            {
                return StatusCode(StatusCodes.Status400BadRequest, new { error = ex.Message });
            }
            catch (Exception ex)
            {
                await LoggingService.LogExceptionAsync(_db, ex, usuarioId: null, _userAgent);
                return StatusCode(StatusCodes.Status500InternalServerError, new { error = "Se ha producido un error interno." });
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
