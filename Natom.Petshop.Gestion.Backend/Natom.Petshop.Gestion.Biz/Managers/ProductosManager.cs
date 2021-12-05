using Microsoft.EntityFrameworkCore;
using Natom.Petshop.Gestion.Biz.Exceptions;
using Natom.Petshop.Gestion.Entities.DTO.Productos;
using Natom.Petshop.Gestion.Entities.Model;
using Natom.Petshop.Gestion.Entities.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Biz.Managers
{
    public class ProductosManager : BaseManager
    {
        public ProductosManager(IServiceProvider serviceProvider) : base(serviceProvider)
        { }

        public Task<int> ObtenerProductosCountAsync()
                    => _db.Productos
                            .CountAsync();

        public Task<List<Producto>> ObtenerProductosDataTableAsync(int start, int size, string filter, int sortColumnIndex, string sortDirection, string statusFilter)
        {
            var queryable = _db.Productos.Include(p => p.Marca).Where(u => true);

            //FILTROS
            if (!string.IsNullOrEmpty(filter))
            {
                queryable = queryable.Where(p => p.Codigo.ToLower().Contains(filter.ToLower())
                                                    || p.DescripcionCorta.ToLower().Contains(filter.ToLower())
                                                    || p.Marca.Descripcion.ToLower().Contains(filter.ToLower()));
            }

            //FILTRO DE ESTADO
            if (!string.IsNullOrEmpty(statusFilter))
            {
                if (statusFilter.ToUpper().Equals("ACTIVOS")) queryable = queryable.Where(q => q.Activo);
                else if (statusFilter.ToUpper().Equals("INACTIVOS")) queryable = queryable.Where(q => !q.Activo);
            }

            //ORDEN
            var queryableOrdered = sortDirection.ToLower().Equals("asc")
                                        ? queryable.OrderBy(c => sortColumnIndex == 0 ? c.Codigo :
                                                                    sortColumnIndex == 1 ? c.DescripcionCorta :
                                                                    sortColumnIndex == 2 ? c.Marca.Descripcion :
                                                            "")
                                        : queryable.OrderByDescending(c => sortColumnIndex == 0 ? c.Codigo :
                                                                            sortColumnIndex == 1 ? c.DescripcionCorta :
                                                                            sortColumnIndex == 2 ? c.Marca.Descripcion :
                                                            "");

            //SKIP Y TAKE
            return queryableOrdered
                    .Skip(start)
                    .Take(size)
                    .ToListAsync();
        }

        public async Task<Producto> GuardarProductoAsync(ProductoDTO productoDto)
        {
            Producto producto = null;
            if (string.IsNullOrEmpty(productoDto.EncryptedId)) //NUEVO
            {
                if (await _db.Productos.AnyAsync(m => m.Codigo.ToLower().Equals(productoDto.Codigo.ToLower())))
                    throw new HandledException("Ya existe una Producto con mismo código.");

                producto = new Producto()
                {
                    Codigo = productoDto.Codigo.ToUpper(),
                    DescripcionCorta = productoDto.DescripcionCorta,
                    DescripcionLarga = productoDto.DescripcionLarga,
                    MarcaId = EncryptionService.Decrypt<int>(productoDto.MarcaEncryptedId),
                    MueveStock = productoDto.MueveStock,
                    PesoUnitario = productoDto.PesoUnitario,
                    UnidadPesoId = EncryptionService.Decrypt<int>(productoDto.UnidadPesoEncryptedId),
                    Activo = true
                };

                _db.Productos.Add(producto);
                await _db.SaveChangesAsync();
            }
            else //EDICION
            {
                int productoId = EncryptionService.Decrypt<int>(productoDto.EncryptedId);

                if (await _db.Productos.AnyAsync(m => m.Codigo.ToLower().Equals(productoDto.Codigo.ToLower()) && m.ProductoId != productoId))
                    throw new HandledException("Ya existe una Producto con mismo código.");

                producto = await _db.Productos
                                    .FirstAsync(u => u.ProductoId.Equals(productoId));

                _db.Entry(producto).State = EntityState.Modified;
                producto.Codigo = productoDto.Codigo.ToUpper();
                producto.DescripcionCorta = productoDto.DescripcionCorta;
                producto.DescripcionLarga = productoDto.DescripcionLarga;
                producto.MarcaId = EncryptionService.Decrypt<int>(productoDto.EncryptedId);
                producto.MueveStock = productoDto.MueveStock;
                producto.PesoUnitario = productoDto.PesoUnitario;
                producto.UnidadPesoId = EncryptionService.Decrypt<int>(productoDto.UnidadPesoEncryptedId);

                await _db.SaveChangesAsync();
            }

            return producto;
        }

        public async Task DesactivarProductoAsync(int productoId)
        {
            var producto = await _db.Productos
                                    .FirstAsync(u => u.ProductoId.Equals(productoId));

            _db.Entry(producto).State = EntityState.Modified;
            producto.Activo = false;

            await _db.SaveChangesAsync();
        }

        public async Task ActivarProductoAsync(int productoId)
        {
            var producto = await _db.Productos
                                    .FirstAsync(u => u.ProductoId.Equals(productoId));

            _db.Entry(producto).State = EntityState.Modified;
            producto.Activo = true;

            await _db.SaveChangesAsync();
        }

        public Task<Producto> ObtenerProductoAsync(int productoId)
                        => _db.Productos
                                .FirstAsync(u => u.ProductoId.Equals(productoId));

        public Task<List<UnidadPeso>> ObtenerUnidadesPesoAsync()
                        => _db.UnidadesPeso
                                .ToListAsync();
    }
}
