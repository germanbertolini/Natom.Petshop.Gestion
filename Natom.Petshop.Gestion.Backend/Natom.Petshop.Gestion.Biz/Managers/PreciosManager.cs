using Microsoft.EntityFrameworkCore;
using Natom.Petshop.Gestion.Entities.DTO.Precios;
using Natom.Petshop.Gestion.Entities.Model;
using Natom.Petshop.Gestion.Entities.Model.Results;
using Natom.Petshop.Gestion.Entities.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Biz.Managers
{
    public class PreciosManager : BaseManager
    {
        public PreciosManager(IServiceProvider serviceProvider) : base(serviceProvider)
        { }

        public Task<int> ObtenerPreciosCountAsync()
                    => _db.ProductosPrecios
                            .CountAsync();

        public List<spPreciosListResult> ObtenerPreciosDataTable(int start, int size, string filter, int sortColumnIndex, string sortDirection, int? listaDePreciosIdFilter)
        {
            var queryable = _db.spPreciosListResult.FromSqlRaw("spPreciosList {0}", listaDePreciosIdFilter).AsEnumerable();

            //FILTROS
            if (!string.IsNullOrEmpty(filter))
            {
                queryable = queryable.Where(p => p.ProductoDescripcion.ToLower().Contains(filter.ToLower())
                                                    || p.ListaDePrecioDescripcion.ToLower().Contains(filter.ToLower()));
            }

            //ORDEN
            IOrderedEnumerable<spPreciosListResult> queryableOrdered;
            if (sortColumnIndex == 2)
            {
                queryableOrdered = sortDirection.ToLower().Equals("asc")
                                        ? queryable.OrderBy(c => c.AplicaDesdeFechaHora)
                                        : queryable.OrderByDescending(c => c.AplicaDesdeFechaHora);
            }
            else if (sortColumnIndex == 3)
            {
                queryableOrdered = sortDirection.ToLower().Equals("asc")
                                        ? queryable.OrderBy(c => c.Precio)
                                        : queryable.OrderByDescending(c => c.Precio);
            }
            else
            {
                queryableOrdered = sortDirection.ToLower().Equals("asc")
                                        ? queryable.OrderBy(c => sortColumnIndex == 0 ? c.ProductoDescripcion :
                                                                    sortColumnIndex == 1 ? c.ListaDePrecioDescripcion :
                                                            "")
                                        : queryable.OrderByDescending(c => sortColumnIndex == 0 ? c.ProductoDescripcion :
                                                                    sortColumnIndex == 1 ? c.ListaDePrecioDescripcion :
                                                            "");
            }

            //SKIP Y TAKE
            return queryableOrdered
                    .Skip(start)
                    .Take(size)
                    .ToList();
        }

        public async Task<ProductoPrecio> GuardarPrecioAsync(PrecioDTO precioDto)
        {
            ProductoPrecio precio = new ProductoPrecio()
            {
                AplicaDesdeFechaHora = DateTime.Now,
                ListaDePreciosId = EncryptionService.Decrypt<int>(precioDto.ListaDePreciosEncryptedId),
                Precio = precioDto.Precio,
                ProductoId = EncryptionService.Decrypt<int>(precioDto.ProductoEncryptedId)
            };

            _db.ProductosPrecios.Add(precio);
            await _db.SaveChangesAsync();

            return precio;
        }

        public Task<ProductoPrecio> ObtenerPrecioAsync(int productoPrecioId)
        {
            return _db.ProductosPrecios
                            .Include(p => p.ListaDePrecios)
                            .Include(p => p.Producto)
                            .FirstAsync(p => p.ProductoPrecioId.Equals(productoPrecioId));
        }

        public Task<List<ListaDePrecios>> ObtenerListasDePreciosAsync()
        {
            return _db.ListasDePrecios.ToListAsync();
        }
    }
}
