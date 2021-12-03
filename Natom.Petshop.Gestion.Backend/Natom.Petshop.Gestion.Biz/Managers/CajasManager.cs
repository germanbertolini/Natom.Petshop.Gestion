using Microsoft.EntityFrameworkCore;
using Natom.Petshop.Gestion.Biz.Exceptions;
using Natom.Petshop.Gestion.Entities.DTO.Cajas;
using Natom.Petshop.Gestion.Entities.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Biz.Managers
{
    public class CajasManager : BaseManager
    {
        public CajasManager(IServiceProvider serviceProvider) : base(serviceProvider)
        { }

        public Task<int> ObtenerMovimientosCajaDiariaCountAsync()
                    => _db.MovimientosCajaDiaria
                            .CountAsync();

        public Task<List<MovimientoCajaDiaria>> ObtenerMovimientosCajaDiariaDataTableAsync(int start, int size, string filter, int sortColumnIndex, string sortDirection, DateTime? dateTimeFilter)
        {
            var queryable = _db.MovimientosCajaDiaria.Include(m => m.Usuario).Where(u => true);

            //FILTROS
            if (!string.IsNullOrEmpty(filter))
            {
                queryable = queryable.Where(p => p.Observaciones.ToLower().Contains(filter.ToLower()));
            }

            //FILTRO FECHA
            if (dateTimeFilter != null)
            {
                queryable = queryable.Where(q => q.FechaHora.Date.Equals(dateTimeFilter));
            }

            //ORDEN
            IOrderedQueryable<MovimientoCajaDiaria> queryableOrdered;
            if (sortColumnIndex == 0)   //FECHA HORA
            {
                queryableOrdered = sortDirection.ToLower().Equals("asc")
                                        ? queryable.OrderBy(c => c.FechaHora.Date).ThenBy(c => c.FechaHora.TimeOfDay)
                                        : queryable.OrderByDescending(c => c.FechaHora.Date).ThenByDescending(c => c.FechaHora.TimeOfDay);
            }
            else if (sortColumnIndex == 3) //IMPORTE (DECIMAL)
            {
                queryableOrdered = sortDirection.ToLower().Equals("asc")
                                        ? queryable.OrderBy(c => c.Importe)
                                        : queryable.OrderByDescending(c => c.Importe);
            }
            else //OTROS (STRING)
            {
                queryableOrdered = sortDirection.ToLower().Equals("asc")
                                        ? queryable.OrderBy(c => sortColumnIndex == 1 ? c.Usuario.Nombre :
                                                                    sortColumnIndex == 2 ? c.Tipo :
                                                            "")
                                        : queryable.OrderByDescending(c => sortColumnIndex == 1 ? c.Usuario.Nombre :
                                                                    sortColumnIndex == 2 ? c.Tipo :
                                                            "");
            }

            //SKIP Y TAKE
            return queryableOrdered
                    .Skip(start)
                    .Take(size)
                    .ToListAsync();
        }

        public Task<decimal> ObtenerSaldoActualCajaDiariaAsync(DateTime? dateTimeFilter)
        {
            var queryable = _db.MovimientosCajaDiaria.Where(u => true);

            //FILTRO FECHA
            if (dateTimeFilter != null)
            {
                queryable = queryable.Where(q => q.FechaHora.Date.Equals(dateTimeFilter));
            }

            return queryable.SumAsync(q => (decimal?)(q.Tipo.Equals("C") ? q.Importe : q.Importe * -1) ?? 0);
        }

        public async Task<MovimientoCajaDiaria> GuardarMovimientoCajaDiariaAsync(MovimientoCajaDiariaDTO movimientoDto, int usuarioId)
        {
            var movimiento = new MovimientoCajaDiaria()
            {
                FechaHora = DateTime.Now,
                Importe = movimientoDto.Importe,
                Observaciones = movimientoDto.Observaciones,
                Tipo = movimientoDto.Tipo,
                UsuarioId = usuarioId
            };

            _db.MovimientosCajaDiaria.Add(movimiento);
            await _db.SaveChangesAsync();

            return movimiento;
        }



        public Task<int> ObtenerMovimientosCajaFuerteCountAsync()
                    => _db.MovimientosCajaFuerte
                            .CountAsync();

        public Task<List<MovimientoCajaFuerte>> ObtenerMovimientosCajaFuerteDataTableAsync(int start, int size, string filter, int sortColumnIndex, string sortDirection, DateTime? dateTimeFilter)
        {
            var queryable = _db.MovimientosCajaFuerte.Include(m => m.Usuario).Where(u => true);

            //FILTROS
            if (!string.IsNullOrEmpty(filter))
            {
                queryable = queryable.Where(p => p.Observaciones.ToLower().Contains(filter.ToLower()));
            }

            //FILTRO FECHA
            if (dateTimeFilter != null)
            {
                queryable = queryable.Where(q => q.FechaHora.Date.Equals(dateTimeFilter));
            }

            //ORDEN
            IOrderedQueryable<MovimientoCajaFuerte> queryableOrdered;
            if (sortColumnIndex == 0)   //FECHA HORA
            {
                queryableOrdered = sortDirection.ToLower().Equals("asc")
                                        ? queryable.OrderBy(c => c.FechaHora.Date).ThenBy(c => c.FechaHora.TimeOfDay)
                                        : queryable.OrderByDescending(c => c.FechaHora.Date).ThenByDescending(c => c.FechaHora.TimeOfDay);
            }
            else if (sortColumnIndex == 3) //IMPORTE (DECIMAL)
            {
                queryableOrdered = sortDirection.ToLower().Equals("asc")
                                        ? queryable.OrderBy(c => c.Importe)
                                        : queryable.OrderByDescending(c => c.Importe);
            }
            else //OTROS (STRING)
            {
                queryableOrdered = sortDirection.ToLower().Equals("asc")
                                        ? queryable.OrderBy(c => sortColumnIndex == 1 ? c.Usuario.Nombre :
                                                                    sortColumnIndex == 2 ? c.Tipo :
                                                            "")
                                        : queryable.OrderByDescending(c => sortColumnIndex == 1 ? c.Usuario.Nombre :
                                                                    sortColumnIndex == 2 ? c.Tipo :
                                                            "");
            }

            //SKIP Y TAKE
            return queryableOrdered
                    .Skip(start)
                    .Take(size)
                    .ToListAsync();
        }

        public Task<decimal> ObtenerSaldoActualCajaFuerteAsync(DateTime? dateTimeFilter)
        {
            var queryable = _db.MovimientosCajaFuerte.Where(u => true);

            //FILTRO FECHA
            if (dateTimeFilter != null)
            {
                queryable = queryable.Where(q => q.FechaHora.Date.Equals(dateTimeFilter));
            }

            return queryable.SumAsync(q => (decimal?)(q.Tipo.Equals("C") ? q.Importe : q.Importe * -1) ?? 0);
        }

        public async Task<MovimientoCajaFuerte> GuardarMovimientoCajaFuerteAsync(MovimientoCajaFuerteDTO movimientoDto, int usuarioId)
        {
            var movimiento = new MovimientoCajaFuerte()
            {
                FechaHora = DateTime.Now,
                Importe = movimientoDto.Importe,
                Observaciones = movimientoDto.Observaciones,
                Tipo = movimientoDto.Tipo,
                UsuarioId = usuarioId
            };

            _db.MovimientosCajaFuerte.Add(movimiento);
            await _db.SaveChangesAsync();

            return movimiento;
        }

        public Task GuardarMovimientoEntreCajasAsync(MovimientoEntreCajasDTO movimientoDto, int usuarioId)
        {
            if (movimientoDto.Origen.Equals("diaria"))
                return GuardarTransferenciaDiariaAFuerteAsync(movimientoDto, usuarioId);
            else
                return GuardarTransferenciaFuerteADiariaAsync(movimientoDto, usuarioId);
        }

        private Task GuardarTransferenciaFuerteADiariaAsync(MovimientoEntreCajasDTO movimientoDto, int usuarioId)
        {
            string observaciones = "TRANSFERENCIA CAJA FUERTE A DIARIA";
            if (!string.IsNullOrEmpty(movimientoDto.Observaciones))
                observaciones += " /// " + movimientoDto.Observaciones;

            var movimientoDebito = new MovimientoCajaFuerte()
            {
                FechaHora = DateTime.Now,
                Importe = movimientoDto.Importe,
                Observaciones = observaciones,
                Tipo = "D", //DEBITO EN CAJA FUERTE
                UsuarioId = usuarioId
            };

            var movimientoCredito = new MovimientoCajaDiaria()
            {
                FechaHora = movimientoDebito.FechaHora,
                Importe = movimientoDto.Importe,
                Observaciones = observaciones,
                Tipo = "C", //CREDITO EN CAJA DIARIA
                UsuarioId = usuarioId
            };

            _db.MovimientosCajaFuerte.Add(movimientoDebito);
            _db.MovimientosCajaDiaria.Add(movimientoCredito);
            return _db.SaveChangesAsync();
        }

        private Task GuardarTransferenciaDiariaAFuerteAsync(MovimientoEntreCajasDTO movimientoDto, int usuarioId)
        {
            string observaciones = "TRANSFERENCIA CAJA DIARIA A FUERTE";
            if (!string.IsNullOrEmpty(movimientoDto.Observaciones))
                observaciones += " /// " + movimientoDto.Observaciones;

            var movimientoDebito = new MovimientoCajaDiaria()
            {
                FechaHora = DateTime.Now,
                Importe = movimientoDto.Importe,
                Observaciones = observaciones,
                Tipo = "D", //DEBITO EN CAJA DIARIA
                UsuarioId = usuarioId
            };

            var movimientoCredito = new MovimientoCajaFuerte()
            {
                FechaHora = movimientoDebito.FechaHora,
                Importe = movimientoDto.Importe,
                Observaciones = observaciones,
                Tipo = "C", //CREDITO EN CAJA FUERTE
                UsuarioId = usuarioId
            };

            _db.MovimientosCajaDiaria.Add(movimientoDebito);
            _db.MovimientosCajaFuerte.Add(movimientoCredito);
            return _db.SaveChangesAsync();
        }
    }
}
