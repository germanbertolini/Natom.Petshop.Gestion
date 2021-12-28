using Microsoft.EntityFrameworkCore;
using Natom.Petshop.Gestion.Biz.Exceptions;
using Natom.Petshop.Gestion.Entities.DTO.Ventas;
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
    public class ReportingManager : BaseManager
    {
        public ReportingManager(IServiceProvider serviceProvider) : base(serviceProvider)
        { }

        public List<spVentasPorProductoProveedorReportResult> ObtenerDataVentasPorProductoProveedorReport(int? productoId, int? proveedorId, DateTime desde, DateTime hasta)
        {
            return _db.spVentasPorProductoProveedorReportResult.FromSqlRaw("spVentasPorProductoProveedorReport {0}, {1}, {2}, {3}", productoId, proveedorId, desde, hasta).AsEnumerable().ToList();
        }

        public List<spClientesQueNoCompranDesdeFechaReportResult> ObtenerDataClientesQueNoCompranDesdeFechaReport(DateTime desde)
        {
            return _db.spClientesQueNoCompranDesdeFechaReportResult.FromSqlRaw("spClientesQueNoCompranDesdeFechaReport {0}", desde).AsEnumerable().ToList();
        }
        
        public List<spKilosCompradosPorProveedorReportResult> ObtenerDataKilosCompradosPorProveedorReport(DateTime? desde)
        {
            return _db.spKilosCompradosPorProveedorReportResult.FromSqlRaw("spKilosCompradosPorProveedorReport {0}", desde).AsEnumerable().ToList();
        }
        
        public List<spVentasRepartoVsMostradorReportResult> ObtenerDataVentasRepartoVsMostradorReport(DateTime? desde)
        {
            return _db.spVentasRepartoVsMostradorReportResult.FromSqlRaw("spVentasRepartoVsMostradorReport {0}", desde).AsEnumerable().ToList();
        }

    }
}
