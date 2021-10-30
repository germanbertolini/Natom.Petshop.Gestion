import { HttpClient } from "@angular/common/http";
import { Component, OnInit } from "@angular/core";
import { ActivatedRoute, Router } from "@angular/router";
import { NotifierService } from "angular-notifier";
import { Docket } from "src/app/classes/models/docket.model";
import { CRUDView } from "src/app/classes/views/crud-view.classes";
import { ConfirmDialogService } from "src/app/components/confirm-dialog/confirm-dialog.service";
import { DataTablesResponse } from "../../../classes/data-tables-response";

@Component({
  selector: 'app-docket-crud',
  styleUrls: ['./docket-crud.component.css'],
  templateUrl: './docket-crud.component.html'
})

export class DocketCrudComponent implements OnInit {
  crud: CRUDView<Docket>;

  constructor(private httpClientService: HttpClient,
              private routerService: Router,
              private routeService: ActivatedRoute,
              private notifierService: NotifierService,
              private confirmDialogService: ConfirmDialogService) {
    this.crud = new CRUDView<Docket>(routeService);
    this.crud.model = new Docket();
  }

  onCancelClick() {
    this.confirmDialogService.showConfirm("¿Descartar cambios?", function() {
      window.history.back();
    });
  }

  onSaveClick() {
    this.notifierService.notify('success', 'Legajo guardado correctamente.');
    this.routerService.navigate(['/dockets']);
  }

  ngOnInit(): void {

    setTimeout(function() {
      (<any>$("#docket-crud").find('[data-toggle="tooltip"]')).tooltip();
    }, 300);
    
  }

}
