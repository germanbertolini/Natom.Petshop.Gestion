using Microsoft.EntityFrameworkCore;
using Natom.Petshop.Gestion.Entities.DTO.Stock;
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
    public class StockManager : BaseManager
    {
        public StockManager(IServiceProvider serviceProvider) : base(serviceProvider)
        { }

        public List<spMovimientosStockListResult> ObtenerMovimientosStockDataTable(int start, int size, string filter, int? depositoId, int? productoId, DateTime? fecha)
        {
            return _db.spMovimientosStockListResult
                                .FromSqlRaw("spMovimientosStockList {0}, {1}, {2}, {3}, {4}, {5}", depositoId, productoId, filter, start, size, fecha)
                                .AsEnumerable()
                                .ToList();
        }

        public Task<List<Deposito>> ObtenerDepositosActivosAsync()
        {
            return _db.Depositos.Where(d => d.Activo).ToListAsync();
        }

        public async Task GuardarMovimientoAsync(int usuarioId, MovimientoStockDTO movimientoDto)
        {
            var movimiento = new MovimientoStock
            {
                ProductoId = EncryptionService.Decrypt<int>(movimientoDto.ProductoEncryptedId),
                DepositoId = EncryptionService.Decrypt<int>(movimientoDto.DepositoEncryptedId),
                FechaHora = DateTime.Now,
                Cantidad = movimientoDto.Cantidad,
                Tipo = movimientoDto.Tipo,
                Observaciones = movimientoDto.Observaciones,
                UsuarioId = usuarioId,
                ConfirmacionFechaHora = DateTime.Now,
                ConfirmacionUsuarioId = usuarioId
            };
            _db.MovimientosStock.Add(movimiento);
            await _db.SaveChangesAsync();
        }
    }
}
