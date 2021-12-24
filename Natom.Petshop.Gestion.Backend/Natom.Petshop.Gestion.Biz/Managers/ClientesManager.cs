using Microsoft.EntityFrameworkCore;
using Natom.Petshop.Gestion.Biz.Exceptions;
using Natom.Petshop.Gestion.Entities.DTO.Clientes;
using Natom.Petshop.Gestion.Entities.Model;
using Natom.Petshop.Gestion.Entities.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Biz.Managers
{
    public class ClientesManager : BaseManager
    {
        public ClientesManager(IServiceProvider serviceProvider) : base(serviceProvider)
        { }

        public Task<int> ObtenerClientesCountAsync()
                    => _db.Clientes
                            .CountAsync();

        public async Task<List<Cliente>> ObtenerClientesDataTableAsync(int start, int size, string filter, int sortColumnIndex, string sortDirection, string statusFilter)
        {
            var queryable = _db.Clientes.Include(c => c.TipoDocumento).Where(u => true);

            //FILTROS
            if (!string.IsNullOrEmpty(filter))
            {
                queryable = queryable.Where(p => p.NumeroDocumento.ToLower().Contains(filter.ToLower())
                                                    || p.Localidad.ToLower().Contains(filter.ToLower())
                                                    || 
                                                    (
                                                        p.Nombre != null
                                                            ? (p.Nombre + " " + p.Apellido).ToLower().Contains(filter.ToLower())
                                                            : p.RazonSocial.ToLower().Contains(filter.ToLower()) || p.NombreFantasia.ToLower().Contains(filter.ToLower()))
                                                    );
            }

            //FILTRO DE ESTADO
            if (!string.IsNullOrEmpty(statusFilter))
            {
                if (statusFilter.ToUpper().Equals("ACTIVOS")) queryable = queryable.Where(q => q.Activo);
                else if (statusFilter.ToUpper().Equals("INACTIVOS")) queryable = queryable.Where(q => !q.Activo);
            }

            //ORDEN
            var queryableOrdered = sortDirection.ToLower().Equals("asc")
                                        ? queryable.OrderBy(c => sortColumnIndex == 0
                                                                    ? (
                                                                        c.Nombre != null
                                                                            ? (c.Nombre + " " + c.Apellido)
                                                                            : c.RazonSocial
                                                                    ) :
                                                                 sortColumnIndex == 1 ? c.TipoDocumentoId.ToString() :
                                                                 sortColumnIndex == 2 ? c.Localidad :
                                                            "")
                                        : queryable.OrderByDescending(c => sortColumnIndex == 0
                                                                    ? (
                                                                        c.Nombre != null
                                                                            ? (c.Nombre + " " + c.Apellido)
                                                                            : c.RazonSocial
                                                                    ) :
                                                                 sortColumnIndex == 1 ? c.TipoDocumentoId.ToString() :
                                                                 sortColumnIndex == 2 ? c.Localidad :
                                                            "");

            var countFiltrados = queryableOrdered.Count();

            //SKIP Y TAKE
            var result = await queryableOrdered
                    .Skip(start)
                    .Take(size)
                    .ToListAsync();

            result.ForEach(r => r.CantidadFiltrados = countFiltrados);

            return result;
        }

        public async Task<Cliente> GuardarClienteAsync(ClienteDTO clienteDto)
        {
            Cliente cliente = null;
            if (string.IsNullOrEmpty(clienteDto.EncryptedId)) //NUEVO
            {
                if (await _db.Clientes.AnyAsync(m => m.NumeroDocumento.ToLower().Equals(clienteDto.NumeroDocumento.ToLower())))
                    throw new HandledException($"Ya existe un Cliente con ese {(clienteDto.EsEmpresa ? "CUIT" : "DNI")}.");

                cliente = new Cliente()
                {
                    Nombre = clienteDto.Nombre,
                    Apellido = clienteDto.Apellido,
                    RazonSocial = clienteDto.RazonSocial,
                    NombreFantasia = clienteDto.NombreFantasia,
                    Domicilio = clienteDto.Domicilio,
                    EntreCalles = clienteDto.EntreCalles,
                    Localidad = clienteDto.Localidad,
                    EsEmpresa = clienteDto.EsEmpresa,
                    TipoDocumentoId = clienteDto.EsEmpresa ? 2 : 1,
                    NumeroDocumento = clienteDto.NumeroDocumento,
                    ContactoEmail1 = clienteDto.ContactoEmail1,
                    ContactoEmail2 = clienteDto.ContactoEmail2,
                    ContactoTelefono1 = clienteDto.ContactoTelefono1,
                    ContactoTelefono2 = clienteDto.ContactoTelefono2,
                    ContactoObservaciones = clienteDto.ContactoObservaciones,
                    Activo = true
                };

                _db.Clientes.Add(cliente);
                await _db.SaveChangesAsync();
            }
            else //EDICION
            {
                int clienteId = EncryptionService.Decrypt<int>(clienteDto.EncryptedId);

                if (await _db.Clientes.AnyAsync(m => m.NumeroDocumento.ToLower().Equals(clienteDto.NumeroDocumento.ToLower()) && m.ClienteId != clienteId))
                    throw new HandledException($"Ya existe un Cliente con ese {(clienteDto.EsEmpresa ? "CUIT" : "DNI")}.");

                cliente = await _db.Clientes
                                    .FirstAsync(u => u.ClienteId.Equals(clienteId));

                _db.Entry(cliente).State = EntityState.Modified;
                cliente.Nombre = clienteDto.Nombre;
                cliente.Apellido = clienteDto.Apellido;
                cliente.RazonSocial = clienteDto.RazonSocial;
                cliente.NombreFantasia = clienteDto.NombreFantasia;
                cliente.Domicilio = clienteDto.Domicilio;
                cliente.EntreCalles = clienteDto.EntreCalles;
                cliente.Localidad = clienteDto.Localidad;
                cliente.EsEmpresa = clienteDto.EsEmpresa;
                cliente.TipoDocumentoId = clienteDto.EsEmpresa ? 2 : 1;
                cliente.NumeroDocumento = clienteDto.NumeroDocumento;
                cliente.ContactoEmail1 = clienteDto.ContactoEmail1;
                cliente.ContactoEmail2 = clienteDto.ContactoEmail2;
                cliente.ContactoTelefono1 = clienteDto.ContactoTelefono1;
                cliente.ContactoTelefono2 = clienteDto.ContactoTelefono2;
                cliente.ContactoObservaciones = clienteDto.ContactoObservaciones;

                await _db.SaveChangesAsync();
            }

            return cliente;
        }

        public async Task DesactivarClienteAsync(int clienteId)
        {
            var cliente = await _db.Clientes
                                    .FirstAsync(u => u.ClienteId.Equals(clienteId));

            _db.Entry(cliente).State = EntityState.Modified;
            cliente.Activo = false;

            await _db.SaveChangesAsync();
        }

        public async Task ActivarClienteAsync(int clienteId)
        {
            var cliente = await _db.Clientes
                                    .FirstAsync(u => u.ClienteId.Equals(clienteId));

            _db.Entry(cliente).State = EntityState.Modified;
            cliente.Activo = true;

            await _db.SaveChangesAsync();
        }

        public Task<Cliente> ObtenerClienteAsync(int clienteId)
                        => _db.Clientes
                                .Include(d => d.TipoDocumento)
                                .FirstAsync(u => u.ClienteId.Equals(clienteId));

        public Task<List<Cliente>> BuscarClientesAsync(int size, string filter)
        {
            var queryable = _db.Clientes.Include(u => u.TipoDocumento).Where(u => u.Activo == true);

            //FILTROS
            if (!string.IsNullOrEmpty(filter))
            {
                var words = filter.Split(' ').Select(w => w.Trim().ToLower());
                foreach (var word in words)
                {
                    queryable = queryable.Where(p => (
                                                        p.EsEmpresa ? p.RazonSocial.ToLower().Contains(word)
                                                                    : (p.Nombre + " " + p.Apellido).ToLower().Contains(word)
                                                    )
                                                    || p.NumeroDocumento.ToLower().Contains(word));
                }
            }

            //ORDEN
            var queryableOrdered = queryable.OrderBy(c => c.RazonSocial);

            //TAKE
            return queryableOrdered
                    .Take(size)
                    .ToListAsync();
        }
    }
}
