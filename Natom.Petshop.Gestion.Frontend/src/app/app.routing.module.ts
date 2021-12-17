import { NgModule } from "@angular/core";
import { RouterModule, Routes } from "@angular/router";
import { AuthGuard } from "./guards/auth.guards";
import { HomeComponent } from "./views/home/home.component";
import { MeProfileComponent } from "./views/me/profile/me-profile.component";
import { ErrorPageComponent } from "./views/error-page/error-page.component";
import { UserCrudComponent } from "./views/users/crud/user-crud.component";
import { UsersComponent } from "./views/users/users.component";
import { LoginComponent } from "./views/login/login.component";
import { MarcaCrudComponent } from "./views/marcas/crud/marca-crud.component";
import { MarcasComponent } from "./views/marcas/marcas.component";
import { CajaDiariaComponent } from "./views/cajas/diaria/caja-diaria.component";
import { CajaDiariaNewComponent } from "./views/cajas/diaria/new/caja-diaria-new.component";
import { CajaFuerteComponent } from "./views/cajas/fuerte/caja-fuerte.component";
import { CajaFuerteNewComponent } from "./views/cajas/fuerte/new/caja-fuerte-new.component";
import { CajaTransferenciaComponent } from "./views/cajas/transferencia/caja-transferencia.component";
import { ClienteCrudComponent } from "./views/clientes/crud/cliente-crud.component";
import { ClientesComponent } from "./views/clientes/clientes.component";
import { ProductosComponent } from "./views/productos/productos.component";
import { ProductoCrudComponent } from "./views/productos/crud/producto-crud.component";
import { PreciosComponent } from "./views/precios/precios.component";
import { PrecioCrudComponent } from "./views/precios/crud/precio-crud.component";
import { PreciosReajustesComponent } from "./views/precios/reajustes/precios-reajustes.component";
import { PrecioReajusteCrudComponent } from "./views/precios/reajustes/crud/precio-reajuste-crud.component";
import { StockComponent } from "./views/stock/stock.component";
import { StockNewComponent } from "./views/stock/new/stock-new.component";
import { PedidosComponent } from "./views/pedidos/pedidos.component";
import { PedidoCrudComponent } from "./views/pedidos/crud/pedido-crud.component";
import { UserConfirmComponent } from "./views/users/confirm/user-confirm.component";
import { VentaCrudComponent } from "./views/ventas/crud/venta-crud.component";
import { VentasComponent } from "./views/ventas/ventas.component";
import { ABMMarcasGuard } from "./guards/marcas/abm.marcas.guards";
import { ABMUsuariosGuard } from "./guards/usuarios/abm.usuarios.guards";
import { CajaDiariaVerGuard } from "./guards/cajas/diaria/caja-diaria.ver.guards";
import { CajaDiariaNuevoMovimientoGuard } from "./guards/cajas/diaria/caja-diaria.nuevo.guards";
import { CajaFuerteVerGuard } from "./guards/cajas/fuerte/caja-fuerte.ver.guards";
import { CajaFuerteNuevoMovimientoGuard } from "./guards/cajas/fuerte/caja-fuerte.nuevo.guards";
import { CajaTransferenciaGuard } from "./guards/cajas/caja.transferencia.guards";
import { CRUDClientesGuard } from "./guards/clientes/clientes.crud.guards";
import { VerClientesGuard } from "./guards/clientes/clientes.ver.guards";
import { VerPedidosGuard } from "./guards/pedidos/ver.pedidos.guards";
import { NuevoPedidoGuard } from "./guards/pedidos/nuevo.pedidos.guards";
import { CRUDPreciosGuard } from "./guards/precios/crud.precios.guards";
import { VerPreciosGuard } from "./guards/precios/ver.precios.guards";
import { ReajustarPreciosGuard } from "./guards/precios/reajustar.precios.guards";
import { VerStockGuard } from "./guards/stock/ver.stock.guards";
import { NuevoMovimientoStockGuard } from "./guards/stock/nuevo.stock.guards";
import { VerProductosGuard } from "./guards/productos/ver.productos.guards";
import { CRUDProductosGuard } from "./guards/productos/crud.productos.guards";
import { VerVentasGuard } from "./guards/ventas/ver.ventas.guards";
import { NuevoVentasGuard } from "./guards/ventas/nuevo.ventas.guards";

const appRoutes: Routes = [
    { path: 'login', component: LoginComponent, pathMatch: 'full' },
    { canActivate: [ AuthGuard ], path: '', component: HomeComponent, pathMatch: 'full' },
    { path: 'error-page', component: ErrorPageComponent, data: { message: "Se ha producido un error" } },
    { path: 'forbidden', component: ErrorPageComponent, data: { message: "No tienes permisos" } },
    { path: 'not-found', component: ErrorPageComponent, data: { message: "No se encontró la ruta solicitada" } },
    { canActivate: [ AuthGuard, ABMUsuariosGuard ], path: 'users', component: UsersComponent },
    { canActivate: [ AuthGuard, ABMUsuariosGuard ], path: "users/new", component: UserCrudComponent },
    { canActivate: [ AuthGuard, ABMUsuariosGuard ], path: "users/edit/:id", component: UserCrudComponent },
    { canActivate: [ AuthGuard ], path: "users/confirm/:data", component: UserConfirmComponent },
    { canActivate: [ AuthGuard ], path: "me/profile", component: MeProfileComponent },
    { canActivate: [ AuthGuard, ABMMarcasGuard ], path: 'marcas', component: MarcasComponent },
    { canActivate: [ AuthGuard, ABMMarcasGuard ], path: "marcas/new", component: MarcaCrudComponent },
    { canActivate: [ AuthGuard, ABMMarcasGuard ], path: "marcas/edit/:id", component: MarcaCrudComponent },
    { canActivate: [ AuthGuard, CajaDiariaVerGuard ], path: 'cajas/diaria', component: CajaDiariaComponent },
    { canActivate: [ AuthGuard, CajaDiariaNuevoMovimientoGuard ], path: "cajas/diaria/new", component: CajaDiariaNewComponent },
    { canActivate: [ AuthGuard, CajaFuerteVerGuard ], path: 'cajas/fuerte', component: CajaFuerteComponent },
    { canActivate: [ AuthGuard, CajaFuerteNuevoMovimientoGuard ], path: "cajas/fuerte/new", component: CajaFuerteNewComponent },
    { canActivate: [ AuthGuard, CajaTransferenciaGuard ], path: "cajas/transferencia", component: CajaTransferenciaComponent },
    { canActivate: [ AuthGuard, VerClientesGuard ], path: 'clientes', component: ClientesComponent },
    { canActivate: [ AuthGuard, CRUDClientesGuard ], path: "clientes/new", component: ClienteCrudComponent },
    { canActivate: [ AuthGuard, CRUDClientesGuard ], path: "clientes/edit/:id", component: ClienteCrudComponent },
    { canActivate: [ AuthGuard, VerProductosGuard ], path: 'productos', component: ProductosComponent },
    { canActivate: [ AuthGuard, CRUDProductosGuard ], path: "productos/new", component: ProductoCrudComponent },
    { canActivate: [ AuthGuard, CRUDProductosGuard ], path: "productos/edit/:id", component: ProductoCrudComponent },
    { canActivate: [ AuthGuard, VerPreciosGuard ], path: "precios", component: PreciosComponent },
    { canActivate: [ AuthGuard, CRUDPreciosGuard ], path: "precios/new", component: PrecioCrudComponent },
    { canActivate: [ AuthGuard, CRUDPreciosGuard ], path: "precios/renew/:id", component: PrecioCrudComponent },
    { canActivate: [ AuthGuard, ReajustarPreciosGuard ], path: "precios/reajustes", component: PreciosReajustesComponent },
    { canActivate: [ AuthGuard, ReajustarPreciosGuard ], path: "precios/reajustes/new", component: PrecioReajusteCrudComponent },
    { canActivate: [ AuthGuard, VerStockGuard ], path: "stock", component: StockComponent },
    { canActivate: [ AuthGuard, NuevoMovimientoStockGuard ], path: "stock/new", component: StockNewComponent },
    { canActivate: [ AuthGuard, VerPedidosGuard ], path: "pedidos", component: PedidosComponent },
    { canActivate: [ AuthGuard, NuevoPedidoGuard ], path: "pedidos/new", component: PedidoCrudComponent },
    { canActivate: [ AuthGuard, VerVentasGuard ], path: "ventas", component: VentasComponent },
    { canActivate: [ AuthGuard, NuevoVentasGuard ], path: "ventas/new", component: VentaCrudComponent },
]

@NgModule({
    imports: [
        RouterModule.forRoot(appRoutes)
    ],
    exports: [ RouterModule ]
})
export class AppRoutingModule {

}