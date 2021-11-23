using Microsoft.EntityFrameworkCore;
using Natom.Petshop.Gestion.Biz.Exceptions;
using Natom.Petshop.Gestion.Entities.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Biz.Managers
{
    public class UsuariosManager : BaseManager
    {
        public UsuariosManager(IServiceProvider serviceProvider) : base(serviceProvider)
        { }

        public async Task<Usuario> LoginAsync(string email, string password)
        {
            if (email.Equals(_configuration["Admin:User"]) && password.Equals(_configuration["Admin:Password"]))
            {
                return new Usuario
                {
                    Nombre = "Admin",
                    Apellido = "",
                    Email = "admin@admin.com",
                    FechaHoraAlta = new DateTime(2021, 12, 01),
                    UsuarioId = 0
                };
            }

            var usuario = await _db.Usuarios.FirstOrDefaultAsync(u => u.Email.ToLower().Equals(email.ToLower()));
            if (usuario == null)
                throw new HandledException("Usuario y/o clave incorrecta");

            if (usuario.FechaHoraBaja.HasValue)
                throw new HandledException("Usuario dado de baja");

            if (!string.IsNullOrEmpty(usuario.SecretConfirmacion) && usuario.FechaHoraConfirmacionEmail == null)
                throw new HandledException("Revise su casilla de correo electrónico para establecer la contraseña");

            if (!usuario.Clave.Equals(password))
                throw new HandledException("Usuario y/o clave incorrecta");

            return usuario;
        }

        public string GenerarToken(Usuario usuario)
        {
            throw new NotImplementedException();
        }

        public Task<List<Permiso>> ObtenerPermisosAsync(int usuarioId)
        {
            if (usuarioId == 0) //ADMIN
                return _db.Permisos.ToListAsync();

            return _db.UsuariosPermisos
                        .Include(p => p.Permiso)
                        .Where(p => p.UsuarioId == usuarioId)
                        .Select(p => p.Permiso)
                        .ToListAsync();
        }
    }
}
