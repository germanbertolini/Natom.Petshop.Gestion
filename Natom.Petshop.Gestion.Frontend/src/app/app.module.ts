import { BrowserModule } from '@angular/platform-browser';
import { CUSTOM_ELEMENTS_SCHEMA, LOCALE_ID, NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpClientModule } from '@angular/common/http';
import { NgbDate, NgbDateParserFormatter, NgbModule } from '@ng-bootstrap/ng-bootstrap';

import { AppComponent } from './app.component';
import { NavMenuComponent } from './components/nav-menu/nav-menu.component';
import { HomeComponent } from './views/home/home.component';
import { DevicesComponent } from './views/devices/devices.component';
import { DeviceCrudComponent } from './views/devices/crud/device-crud.component';
import { DataTablesModule } from 'angular-datatables';
import { AngularFontAwesomeModule } from 'angular-font-awesome';
import { NotifierModule } from 'angular-notifier';
import { ConfirmDialogComponent } from './components/confirm-dialog/confirm-dialog.component';
import { CommonModule } from '@angular/common';
import { ConfirmDialogService } from './components/confirm-dialog/confirm-dialog.service';
import { MeProfileComponent } from './views/me/profile/me-profile.component';
import { UsersComponent } from './views/users/users.component';
import { UserCrudComponent } from './views/users/crud/user-crud.component';
import { DocketsComponent } from './views/dockets/dockets.component';
import { DocketCrudComponent } from './views/dockets/crud/docket-crud.component';
import { TitleCrudComponent } from './views/titles/crud/title-crud.component';
import { TitlesComponent } from './views/titles/titles.component';
import { DevicesSyncConfigComponent } from './views/devices/sync/config/devices-sync-config.component';
import { SidebarModule } from 'ng-sidebar';
import { Query1AComponent } from './views/queries/1/A/query-1-a.component';
import { Query1BComponent } from './views/queries/1/B/query-1-b.component';
import { ReportsAttendanceByDeviceComponent } from './views/reports/attendance/reports-attendance-by-device.component';
import { ReportsWorkedHoursByDocketComponent } from './views/reports/worked-hours/reports-worked-hours-by-docket.component';
import { AppRoutingModule } from './app.routing.module';
import { ChartsModule, ThemeService } from 'ng2-charts';
import { ErrorPageComponent } from './views/error-page/error-page.component';
import { LoginComponent } from './views/login/login.component';
import { CookieService } from 'ngx-cookie-service';
import { MarcasComponent } from './views/marcas/marcas.component';
import { MarcaCrudComponent } from './views/marcas/crud/marca-crud.component';
import { CajaDiariaComponent } from './views/cajas/diaria/caja-diaria.component';
import { CajaDiariaNewComponent } from './views/cajas/diaria/new/caja-diaria-new.component';

//Local imports
import localeEsAR from '@angular/common/locales/es-AR';

//Register local imports
import { registerLocaleData } from '@angular/common';
import { CajaFuerteComponent } from './views/cajas/fuerte/caja-fuerte.component';
import { CajaFuerteNewComponent } from './views/cajas/fuerte/new/caja-fuerte-new.component';
import { NgbDateCustomParserFormatter } from './utils/datepicker/datepicker-popup';
registerLocaleData(localeEsAR, 'es-AR');

@NgModule({
  declarations: [
    AppComponent,
    NavMenuComponent,
    LoginComponent,
    HomeComponent,
    ErrorPageComponent,
    DevicesComponent,
    DeviceCrudComponent,
    UsersComponent,
    UserCrudComponent,
    MeProfileComponent,
    DocketsComponent,
    DocketCrudComponent,
    TitlesComponent,
    TitleCrudComponent,
    MarcasComponent,
    MarcaCrudComponent,
    CajaDiariaComponent,
    CajaDiariaNewComponent,
    CajaFuerteComponent,
    CajaFuerteNewComponent,
    DevicesSyncConfigComponent,
    Query1AComponent,
    Query1BComponent,
    ReportsAttendanceByDeviceComponent,
    ReportsWorkedHoursByDocketComponent,
    ConfirmDialogComponent
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
    ConfirmDialogComponent  
  ], 
  schemas: [ CUSTOM_ELEMENTS_SCHEMA ],
  providers: [
    {
      provide: LOCALE_ID,
      useValue: 'es-AR'
    },
    { provide: NgbDateParserFormatter,
      useClass: NgbDateCustomParserFormatter
    },
    ConfirmDialogService,
    ThemeService,
    CookieService ],
  bootstrap: [AppComponent]
})
export class AppModule { }
