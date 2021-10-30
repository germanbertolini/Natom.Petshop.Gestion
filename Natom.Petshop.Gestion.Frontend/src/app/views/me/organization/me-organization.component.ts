import { HttpClient } from "@angular/common/http";
import { Component, OnInit } from "@angular/core";
import { ActivatedRoute, Router } from "@angular/router";
import { NotifierService } from "angular-notifier";
import { Docket } from "src/app/classes/models/docket.model";
import { Organization } from "src/app/classes/models/organization.model";
import { CRUDView } from "src/app/classes/views/crud-view.classes";
import { ConfirmDialogService } from "src/app/components/confirm-dialog/confirm-dialog.service";
import { DataTablesResponse } from "../../../classes/data-tables-response";

@Component({
  selector: 'app-me-organization',
  styleUrls: ['./me-organization.component.css'],
  templateUrl: './me-organization.component.html'
})

export class MeOrganizationComponent implements OnInit {

  model: Organization;

  constructor(private httpClientService: HttpClient,
              private routerService: Router,
              private routeService: ActivatedRoute,
              private notifierService: NotifierService,
              private confirmDialogService: ConfirmDialogService) {

    this.model = new Organization();

    //MOCK
    this.model.encrypted_id = "adssdadas123e213132";
    this.model.registered_at = new Date('2020-12-28T00:00:00');
    this.model.business_name = "Natom";
    this.model.country_icon = "arg";
    this.model.picture_url = "https://seeklogo.com/images/V/Volkswagen-logo-9A1203CE20-seeklogo.com.png";
    this.model.jornada_tolerancia_ingreso_mins = 10;
    this.model.jornada_tolerancia_egreso_mins = 10;
    this.model.almuerzo_rango_horario_desde = new Date('0001-01-01T12:00:00');
    this.model.almuerzo_rango_horario_hasta = new Date('0001-01-01T15:00:00');
    this.model.almuerzo_tiempo_limite_mins = 65;
  }

  onCancelClick() {
    this.confirmDialogService.showConfirm("¿Descartar cambios?", function() {
      window.history.back();
    });
  }

  onSaveClick() {
    this.notifierService.notify('success', 'Configuración guardada correctamente.');
  }

  ngOnInit(): void {

    setTimeout(function() {
      (<any>$("#docket-crud").find('[data-toggle="tooltip"]')).tooltip();
    }, 300);
    
  }

}
