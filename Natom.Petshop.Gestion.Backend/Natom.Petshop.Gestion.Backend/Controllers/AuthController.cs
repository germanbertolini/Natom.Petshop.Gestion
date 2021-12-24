﻿using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Natom.Petshop.Gestion.Backend.Services;
using Natom.Petshop.Gestion.Biz;
using Natom.Petshop.Gestion.Biz.Exceptions;
using Natom.Petshop.Gestion.Biz.Managers;
using Natom.Petshop.Gestion.Entities.DTO;
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

                var manager = new UsuariosManager(_serviceProvider);
                var usuario = await manager.LoginAsync(email, password);

                //RESTRICCIÓN DE ACCESO: SOLO ADMIN PUEDE INGRESAR FUERA DEL HORARIO LABORAL
                if (usuario.UsuarioId != 0 && (DateTime.Now.Hour >= 21 || DateTime.Now.Hour <= 6))
                    throw new HandledException("Acceso denegado.");

                var permisos = await manager.ObtenerPermisosAsync(usuario.UsuarioId);
                var tokenDurationInSeconds = 24 * 60 * 60; //24 HORAS
                var token = OAuthService.GenerateAccessToken(scope: "gestionBackend", usuario, permisos, tokenDurationInSeconds);

                return Ok(new ApiResultDTO<LoginResultDTO>
                {
                    Success = true,
                    Data = new LoginResultDTO
                    {
                        User = new UserDTO().From(usuario),
                        Permissions = token.Permissions,
                        Token = OAuthService.Encode(token)
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
