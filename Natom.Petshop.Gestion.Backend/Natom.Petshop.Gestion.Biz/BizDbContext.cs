using Microsoft.EntityFrameworkCore;
using Natom.Petshop.Gestion.Entities.Model;
using Natom.Petshop.Gestion.Entities.Model.Results;
using System;

namespace Natom.Petshop.Gestion.Biz
{
    public class BizDbContext : DbContext
    {
        public DbSet<Cliente> Clientes { get; set; }
        public DbSet<Deposito> Depositos { get; set; }
        public DbSet<HistoricoCambios> HistoricosCambios { get; set; }
        public DbSet<HistoricoCambiosMotivo> HistoricosCambiosMotivos { get; set; }
        public DbSet<HistoricoReajustePrecio> HistoricosReajustePrecios { get; set; }
        public DbSet<ListaDePrecios> ListasDePrecios { get; set; }
        public DbSet<Log> Logs { get; set; }
        public DbSet<Marca> Marcas { get; set; }
        public DbSet<MovimientoCajaDiaria> MovimientosCajaDiaria { get; set; }
        public DbSet<MovimientoCajaFuerte> MovimientosCajaFuerte { get; set; }
        public DbSet<MovimientoStock> MovimientosStock { get; set; }
        public DbSet<OrdenDePedido> OrdenesDePedido { get; set; }
        public DbSet<OrdenDePedidoDetalle> OrdenesDePedidoDetalle { get; set; }
        public DbSet<Permiso> Permisos { get; set; }
        public DbSet<Producto> Productos { get; set; }
        public DbSet<ProductoPrecio> ProductosPrecios { get; set; }
        public DbSet<RangoHorario> RangosHorario { get; set; }
        public DbSet<TipoDocumento> TiposDocumento { get; set; }
        public DbSet<TipoResponsable> TiposResponsable { get; set; }
        public DbSet<UnidadPeso> UnidadesPeso { get; set; }
        public DbSet<Usuario> Usuarios { get; set; }
        public DbSet<UsuarioPermiso> UsuariosPermisos { get; set; }
        public DbSet<Venta> Ventas { get; set; }
        public DbSet<VentaDetalle> VentasDetalle { get; set; }


        public DbSet<spPreciosListResult> spPreciosListResult { get; set; }


        public BizDbContext(DbContextOptions<BizDbContext> options) : base(options)
        {

        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            //modelBuilder
            //    .Entity<spBookingGetForCalendarResult>(builder => builder.HasNoKey())
            //    .Entity<spPropertiesGetForAgreementsResult>(builder => builder.HasNoKey());
        }
    }
}
