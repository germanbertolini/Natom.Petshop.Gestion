import { BrowserModule } from '@angular/platform-browser';
import { APP_INITIALIZER, CUSTOM_ELEMENTS_SCHEMA, LOCALE_ID, NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpClient, HttpClientModule } from '@angular/common/http';
import { NgbDate, NgbDateParserFormatter, NgbModule } from '@ng-bootstrap/ng-bootstrap';

//Local imports
import localeEsAR from '@angular/common/locales/es-AR';

//Register local imports
import { registerLocaleData } from '@angular/common';
import { NgbDateCustomParserFormatter, NgbdDatepickerPopup } from './utils/datepicker/datepicker-popup';
registerLocaleData(localeEsAR, 'es-AR');

//Components
import { AppComponent } from './app.component';
import { NavMenuComponent } from './components/nav-menu/nav-menu.component';
import { HomeComponent } from './views/home/home.component';
import { DataTablesModule } from 'angular-datatables';
import { AngularFontAwesomeModule } from 'angular-font-awesome';
import { NotifierModule } from 'angular-notifier';
import { ConfirmDialogComponent } from './components/confirm-dialog/confirm-dialog.component';
import { CommonModule } from '@angular/common';
import { ConfirmDialogService } from './components/confirm-dialog/confirm-dialog.service';
import { MeProfileComponent } from './views/me/profile/me-profile.component';
import { UsersComponent } from './views/users/users.component';
import { UserCrudComponent } from './views/users/crud/user-crud.component';
import { SidebarModule } from 'ng-sidebar';
import { AppRoutingModule } from './app.routing.module';
import { ChartsModule, ThemeService } from 'ng2-charts';
import { ErrorPageComponent } from './views/error-page/error-page.component';
import { LoginComponent } from './views/login/login.component';
import { CookieService } from 'ngx-cookie-service';
import { MarcasComponent } from './views/marcas/marcas.component';
import { MarcaCrudComponent } from './views/marcas/crud/marca-crud.component';
import { CajaDiariaComponent } from './views/cajas/diaria/caja-diaria.component';
import { CajaDiariaNewComponent } from './views/cajas/diaria/new/caja-diaria-new.component';
import { CajaFuerteComponent } from './views/cajas/fuerte/caja-fuerte.component';
import { CajaFuerteNewComponent } from './views/cajas/fuerte/new/caja-fuerte-new.component';
import { CajaTransferenciaComponent } from './views/cajas/transferencia/caja-transferencia.component';
import { ClienteCrudComponent } from './views/clientes/crud/cliente-crud.component';
import { ClientesComponent } from './views/clientes/clientes.component';
import { ProductoCrudComponent } from './views/productos/crud/producto-crud.component';
import { ProductosComponent } from './views/productos/productos.component';
import { PreciosComponent } from './views/precios/precios.component';
import { PrecioCrudComponent } from './views/precios/crud/precio-crud.component';
import { PrecioReajusteCrudComponent } from './views/precios/reajustes/crud/precio-reajuste-crud.component';
import { PreciosReajustesComponent } from './views/precios/reajustes/precios-reajustes.component';
import { StockComponent } from './views/stock/stock.component';
import { StockNewComponent } from './views/stock/new/stock-new.component';
import { PedidosComponent } from './views/pedidos/pedidos.component';
import { PedidoCrudComponent } from './views/pedidos/crud/pedido-crud.component';
import { JsonAppConfigService } from './services/json-app-config.service';
import { AppConfig } from './classes/app-config';
import { ApiService } from './services/api.service';
import { UserConfirmComponent } from './views/users/confirm/user-confirm.component';
import { VentasComponent } from './views/ventas/ventas.component';
import { VentaCrudComponent } from './views/ventas/crud/venta-crud.component';
import { HistoricoCambiosService } from './components/historico-cambios/historico-cambios.service';
import { HistoricoCambiosComponent } from './components/historico-cambios/historico-cambios.component';

export function OnInit(jsonAppConfigService: JsonAppConfigService) {
  return () => {
    return jsonAppConfigService.load();
  };
}

@NgModule({
  declarations: [
    AppComponent,
    NavMenuComponent,
    LoginComponent,
    HomeComponent,
    ErrorPageComponent,
    UsersComponent,
    UserCrudComponent,
    UserConfirmComponent,
    MeProfileComponent,
    MarcasComponent,
    MarcaCrudComponent,
    CajaDiariaComponent,
    CajaDiariaNewComponent,
    CajaFuerteComponent,
    CajaFuerteNewComponent,
    CajaTransferenciaComponent,
    ConfirmDialogComponent,
    HistoricoCambiosComponent,
    ClientesComponent,
    ClienteCrudComponent,
    ProductosComponent,
    ProductoCrudComponent,
    PreciosComponent,
    PrecioCrudComponent,
    PreciosReajustesComponent,
    PrecioReajusteCrudComponent,
    StockComponent,
    StockNewComponent,
    PedidosComponent,
    PedidoCrudComponent,
    VentasComponent,
    VentaCrudComponent,
    NgbdDatepickerPopup
  ],
  imports: [
    BrowserModule.withServerTransition({ appId: 'ng-cli-universal' }),
    SidebarModule.forRoot(),
    HttpClientModule,
    FormsModule,
    DataTablesModule,
    AngularFontAwesomeModule,
    NotifierModule,
    BrowserModule,
    CommonModule,
    AppRoutingModule,
    ChartsModule,
    NgbModule
  ],
  exports: [  
    ConfirmDialogComponent,
    HistoricoCambiosComponent
  ], 
  schemas: [ CUSTOM_ELEMENTS_SCHEMA ],
  providers: [
    {
      provide: LOCALE_ID,
      useValue: 'es-AR'
    },
    {
      provide: AppConfig,
      deps: [HttpClient],
      useExisting: JsonAppConfigService
    },
    {
      provide: APP_INITIALIZER,
      multi: true,
      deps: [JsonAppConfigService],
      useFactory: OnInit
    },
    { provide: NgbDateParserFormatter,
      useClass: NgbDateCustomParserFormatter
    },
    ConfirmDialogService,
    HistoricoCambiosService,
    ThemeService,
    CookieService,
    ApiService ],
  bootstrap: [AppComponent]
})
export class AppModule { }
