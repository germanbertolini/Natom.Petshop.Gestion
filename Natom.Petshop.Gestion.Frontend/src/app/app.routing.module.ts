import { NgModule } from "@angular/core";
import { RouterModule, Routes } from "@angular/router";
import { AuthGuard } from "./guards/auth.guards";
import { DeviceCrudComponent } from "./views/devices/crud/device-crud.component";
import { DevicesComponent } from "./views/devices/devices.component";
import { DevicesSyncConfigComponent } from "./views/devices/sync/config/devices-sync-config.component";
import { DocketCrudComponent } from "./views/dockets/crud/docket-crud.component";
import { DocketsComponent } from "./views/dockets/dockets.component";
import { HomeComponent } from "./views/home/home.component";
import { MeProfileComponent } from "./views/me/profile/me-profile.component";
import { Query1AComponent } from "./views/queries/1/A/query-1-a.component";
import { Query1BComponent } from "./views/queries/1/B/query-1-b.component";
import { ReportsAttendanceByDeviceComponent } from "./views/reports/attendance/reports-attendance-by-device.component";
import { ReportsWorkedHoursByDocketComponent } from "./views/reports/worked-hours/reports-worked-hours-by-docket.component";
import { ErrorPageComponent } from "./views/error-page/error-page.component";
import { TitleCrudComponent } from "./views/titles/crud/title-crud.component";
import { TitlesComponent } from "./views/titles/titles.component";
import { UserCrudComponent } from "./views/users/crud/user-crud.component";
import { UsersComponent } from "./views/users/users.component";
import { LoginComponent } from "./views/login/login.component";
import { MarcaCrudComponent } from "./views/marcas/crud/marca-crud.component";
import { MarcasComponent } from "./views/marcas/marcas.component";
import { CajaDiariaComponent } from "./views/cajas/diaria/caja-diaria.component";
import { CajaDiariaNewComponent } from "./views/cajas/diaria/new/caja-diaria-new.component";
import { CajaFuerteComponent } from "./views/cajas/fuerte/caja-fuerte.component";
import { CajaFuerteNewComponent } from "./views/cajas/fuerte/new/caja-fuerte-new.component";

const appRoutes: Routes = [
    { path: 'login', component: LoginComponent, pathMatch: 'full' },
    { canActivate: [ AuthGuard ], path: '', component: HomeComponent, pathMatch: 'full' },
    { path: 'error-page', component: ErrorPageComponent, data: { message: "Se ha producido un error" } },
    { path: 'forbidden', component: ErrorPageComponent, data: { message: "No tienes permisos" } },
    { path: 'not-found', component: ErrorPageComponent, data: { message: "No se encontró la ruta solicitada" } },
    { canActivate: [ AuthGuard ], path: 'devices', component: DevicesComponent },
    { canActivate: [ AuthGuard ], path: "devices/new", component: DeviceCrudComponent },
    { canActivate: [ AuthGuard ], path: "devices/edit/:id", component: DeviceCrudComponent },
    { canActivate: [ AuthGuard ], path: "devices/sync/config", component: DevicesSyncConfigComponent },
    { canActivate: [ AuthGuard ], path: 'users', component: UsersComponent },
    { canActivate: [ AuthGuard ], path: "users/new", component: UserCrudComponent },
    { canActivate: [ AuthGuard ], path: "users/edit/:id", component: UserCrudComponent },
    { canActivate: [ AuthGuard ], path: "me/profile", component: MeProfileComponent },
    { canActivate: [ AuthGuard ], path: 'dockets', component: DocketsComponent },
    { canActivate: [ AuthGuard ], path: "dockets/new", component: DocketCrudComponent },
    { canActivate: [ AuthGuard ], path: "dockets/edit/:id", component: DocketCrudComponent },
    { canActivate: [ AuthGuard ], path: 'titles', component: TitlesComponent },
    { canActivate: [ AuthGuard ], path: "titles/new", component: TitleCrudComponent },
    { canActivate: [ AuthGuard ], path: "titles/edit/:id", component: TitleCrudComponent },
    { canActivate: [ AuthGuard ], path: 'marcas', component: MarcasComponent },
    { canActivate: [ AuthGuard ], path: "marcas/new", component: MarcaCrudComponent },
    { canActivate: [ AuthGuard ], path: "marcas/edit/:id", component: MarcaCrudComponent },
    { canActivate: [ AuthGuard ], path: 'cajas/diaria', component: CajaDiariaComponent },
    { canActivate: [ AuthGuard ], path: "cajas/diaria/new", component: CajaDiariaNewComponent },
    { canActivate: [ AuthGuard ], path: 'cajas/fuerte', component: CajaFuerteComponent },
    { canActivate: [ AuthGuard ], path: "cajas/fuerte/new", component: CajaFuerteNewComponent },
    { canActivate: [ AuthGuard ], path: "queries/1/a", component: Query1AComponent },
    { canActivate: [ AuthGuard ], path: "queries/1/b", component: Query1BComponent },
    { canActivate: [ AuthGuard ], path: "reports/attendance/by_device", component: ReportsAttendanceByDeviceComponent },
    { canActivate: [ AuthGuard ], path: "reports/worked-hours/by_docket/:id", component: ReportsWorkedHoursByDocketComponent }
]

@NgModule({
    imports: [
        RouterModule.forRoot(appRoutes)
    ],
    exports: [ RouterModule ]
})
export class AppRoutingModule {

}