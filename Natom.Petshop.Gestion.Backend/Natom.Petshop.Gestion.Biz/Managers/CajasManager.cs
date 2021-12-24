﻿using Microsoft.EntityFrameworkCore;
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

        public async Task<List<MovimientoCajaDiaria>> ObtenerMovimientosCajaDiariaDataTableAsync(int start, int size, string filter, int sortColumnIndex, string sortDirection, DateTime? dateTimeFilter)
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
            else if (sortColumnIndex == 4) //CHEQUE (BOOL)
            {
                queryableOrdered = sortDirection.ToLower().Equals("asc")
                                        ? queryable.OrderBy(c => c.EsCheque)
                                        : queryable.OrderByDescending(c => c.EsCheque);
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

            var countFiltrados = queryableOrdered.Count();

            //SKIP Y TAKE
            var result = await queryableOrdered
                    .Skip(start)
                    .Take(size)
                    .ToListAsync();

            result.ForEach(r => r.CantidadFiltrados = countFiltrados);

            return result;
        }

        public Task<decimal> ObtenerSaldoActualCajaDiariaAsync(DateTime? dateTimeFilter = null)
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
            if (movimientoDto.Tipo == "D")
            {
                var saldoActual = await ObtenerSaldoActualCajaDiariaAsync();
                if (saldoActual - movimientoDto.Importe < 0)
                    throw new HandledException($"No es posible realizar el Egreso ya que el importe ingresado ({movimientoDto.Importe.ToString("C2")}) es superior al saldo disponible actual ({saldoActual.ToString("C2")})");
            }

            var movimiento = new MovimientoCajaDiaria()
            {
                FechaHora = DateTime.Now,
                Importe = movimientoDto.Importe,
                Observaciones = movimientoDto.Observaciones,
                Tipo = movimientoDto.Tipo,
                UsuarioId = usuarioId,
                EsCheque = movimientoDto.EsCheque
            };

            _db.MovimientosCajaDiaria.Add(movimiento);
            await _db.SaveChangesAsync();

            return movimiento;
        }



        public Task<int> ObtenerMovimientosCajaFuerteCountAsync()
                    => _db.MovimientosCajaFuerte
                            .CountAsync();

        public async Task<List<MovimientoCajaFuerte>> ObtenerMovimientosCajaFuerteDataTableAsync(int start, int size, string filter, int sortColumnIndex, string sortDirection, DateTime? dateTimeFilter)
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
            else if (sortColumnIndex == 4) //CHEQUE (BOOL)
            {
                queryableOrdered = sortDirection.ToLower().Equals("asc")
                                        ? queryable.OrderBy(c => c.EsCheque)
                                        : queryable.OrderByDescending(c => c.EsCheque);
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

            var countFiltrados = queryableOrdered.Count();

            //SKIP Y TAKE
            var result = await queryableOrdered
                    .Skip(start)
                    .Take(size)
                    .ToListAsync();

            result.ForEach(r => r.CantidadFiltrados = countFiltrados);

            return result;
        }

        public Task<decimal> ObtenerSaldoActualCajaFuerteAsync(DateTime? dateTimeFilter = null)
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
            if (movimientoDto.Tipo == "D")
            {
                var saldoActual = await ObtenerSaldoActualCajaFuerteAsync();
                if (saldoActual - movimientoDto.Importe < 0)
                    throw new HandledException($"No es posible realizar el Egreso ya que el importe ingresado ({movimientoDto.Importe.ToString("C2")}) es superior al saldo disponible actual ({saldoActual.ToString("C2")})");
            }

            var movimiento = new MovimientoCajaFuerte()
            {
                FechaHora = DateTime.Now,
                Importe = movimientoDto.Importe,
                Observaciones = movimientoDto.Observaciones,
                Tipo = movimientoDto.Tipo,
                UsuarioId = usuarioId,
                EsCheque = movimientoDto.EsCheque
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

        private async Task GuardarTransferenciaFuerteADiariaAsync(MovimientoEntreCajasDTO movimientoDto, int usuarioId)
        {
            var saldoActual = await ObtenerSaldoActualCajaFuerteAsync();
            if (saldoActual - movimientoDto.Importe < 0)
                throw new HandledException($"No es posible realizar la Transferencia ya que el importe ingresado ({movimientoDto.Importe.ToString("C2")}) es superior al saldo disponible actual en Tesorería ({saldoActual.ToString("C2")})");

            string observaciones = "TRANSFERENCIA TESORERIA A CAJA DIARIA";
            if (!string.IsNullOrEmpty(movimientoDto.Observaciones))
                observaciones += " /// " + movimientoDto.Observaciones;

            var movimientoDebito = new MovimientoCajaFuerte()
            {
                FechaHora = DateTime.Now,
                Importe = movimientoDto.Importe,
                Observaciones = observaciones,
                Tipo = "D", //DEBITO EN CAJA FUERTE
                UsuarioId = usuarioId,
                EsCheque = movimientoDto.EsCheque
            };

            var movimientoCredito = new MovimientoCajaDiaria()
            {
                FechaHora = movimientoDebito.FechaHora,
                Importe = movimientoDto.Importe,
                Observaciones = observaciones,
                Tipo = "C", //CREDITO EN CAJA DIARIA
                UsuarioId = usuarioId,
                EsCheque = movimientoDto.EsCheque
            };

            _db.MovimientosCajaFuerte.Add(movimientoDebito);
            _db.MovimientosCajaDiaria.Add(movimientoCredito);
            await _db.SaveChangesAsync();
        }

        private async Task GuardarTransferenciaDiariaAFuerteAsync(MovimientoEntreCajasDTO movimientoDto, int usuarioId)
        {
            var saldoActual = await ObtenerSaldoActualCajaDiariaAsync();
            if (saldoActual - movimientoDto.Importe < 0)
                throw new HandledException($"No es posible realizar la Transferencia ya que el importe ingresado ({movimientoDto.Importe.ToString("C2")}) es superior al saldo disponible actual en la Caja Diaria ({saldoActual.ToString("C2")})");

            string observaciones = "TRANSFERENCIA CAJA DIARIA A TESORERIA";
            if (!string.IsNullOrEmpty(movimientoDto.Observaciones))
                observaciones += " /// " + movimientoDto.Observaciones;

            var movimientoDebito = new MovimientoCajaDiaria()
            {
                FechaHora = DateTime.Now,
                Importe = movimientoDto.Importe,
                Observaciones = observaciones,
                Tipo = "D", //DEBITO EN CAJA DIARIA
                UsuarioId = usuarioId,
                EsCheque = movimientoDto.EsCheque
            };

            var movimientoCredito = new MovimientoCajaFuerte()
            {
                FechaHora = movimientoDebito.FechaHora,
                Importe = movimientoDto.Importe,
                Observaciones = observaciones,
                Tipo = "C", //CREDITO EN CAJA FUERTE
                UsuarioId = usuarioId,
                EsCheque = movimientoDto.EsCheque
            };

            _db.MovimientosCajaDiaria.Add(movimientoDebito);
            _db.MovimientosCajaFuerte.Add(movimientoCredito);
            _db.SaveChangesAsync();
        }
    }
}
