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

const appRoutes: Routes = [
    { path: 'login', component: LoginComponent, pathMatch: 'full' },
    { canActivate: [ AuthGuard ], path: '', component: HomeComponent, pathMatch: 'full' },
    { path: 'error-page', component: ErrorPageComponent, data: { message: "Se ha producido un error" } },
    { path: 'forbidden', component: ErrorPageComponent, data: { message: "No tienes permisos" } },
    { path: 'not-found', component: ErrorPageComponent, data: { message: "No se encontró la ruta solicitada" } },
    { canActivate: [ AuthGuard ], path: 'users', component: UsersComponent },
    { canActivate: [ AuthGuard ], path: "users/new", component: UserCrudComponent },
    { canActivate: [ AuthGuard ], path: "users/edit/:id", component: UserCrudComponent },
    { canActivate: [ AuthGuard ], path: "users/confirm/:data", component: UserConfirmComponent },
    { canActivate: [ AuthGuard ], path: "me/profile", component: MeProfileComponent },
    { canActivate: [ AuthGuard ], path: 'marcas', component: MarcasComponent },
    { canActivate: [ AuthGuard ], path: "marcas/new", component: MarcaCrudComponent },
    { canActivate: [ AuthGuard ], path: "marcas/edit/:id", component: MarcaCrudComponent },
    { canActivate: [ AuthGuard ], path: 'cajas/diaria', component: CajaDiariaComponent },
    { canActivate: [ AuthGuard ], path: "cajas/diaria/new", component: CajaDiariaNewComponent },
    { canActivate: [ AuthGuard ], path: 'cajas/fuerte', component: CajaFuerteComponent },
    { canActivate: [ AuthGuard ], path: "cajas/fuerte/new", component: CajaFuerteNewComponent },
    { canActivate: [ AuthGuard ], path: "cajas/transferencia", component: CajaTransferenciaComponent },
    { canActivate: [ AuthGuard ], path: 'clientes', component: ClientesComponent },
    { canActivate: [ AuthGuard ], path: "clientes/new", component: ClienteCrudComponent },
    { canActivate: [ AuthGuard ], path: "clientes/edit/:id", component: ClienteCrudComponent },
    { canActivate: [ AuthGuard ], path: 'productos', component: ProductosComponent },
    { canActivate: [ AuthGuard ], path: "productos/new", component: ProductoCrudComponent },
    { canActivate: [ AuthGuard ], path: "productos/edit/:id", component: ProductoCrudComponent },
    { canActivate: [ AuthGuard ], path: "precios", component: PreciosComponent },
    { canActivate: [ AuthGuard ], path: "precios/new", component: PrecioCrudComponent },
    { canActivate: [ AuthGuard ], path: "precios/renew/:id", component: PrecioCrudComponent },
    { canActivate: [ AuthGuard ], path: "precios/reajustes", component: PreciosReajustesComponent },
    { canActivate: [ AuthGuard ], path: "precios/reajustes/new", component: PrecioReajusteCrudComponent },
    { canActivate: [ AuthGuard ], path: "stock", component: StockComponent },
    { canActivate: [ AuthGuard ], path: "stock/new", component: StockNewComponent },
    { canActivate: [ AuthGuard ], path: "pedidos", component: PedidosComponent },
    { canActivate: [ AuthGuard ], path: "pedidos/new", component: PedidoCrudComponent },
]

@NgModule({
    imports: [
        RouterModule.forRoot(appRoutes)
    ],
    exports: [ RouterModule ]
})
export class AppRoutingModule {

}