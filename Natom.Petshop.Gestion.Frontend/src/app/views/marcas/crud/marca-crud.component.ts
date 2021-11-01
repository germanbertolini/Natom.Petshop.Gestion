import { HttpClient } from "@angular/common/http";
import { Component, OnInit } from "@angular/core";
import { ActivatedRoute, Router } from "@angular/router";
import { NotifierService } from "angular-notifier";
import { Marca } from "src/app/classes/models/marca.model";
import { CRUDView } from "src/app/classes/views/crud-view.classes";
import { ConfirmDialogService } from "src/app/components/confirm-dialog/confirm-dialog.service";
import { DataTablesResponse } from "../../../classes/data-tables-response";

@Component({
  selector: 'app-marca-crud',
  styleUrls: ['./marca-crud.component.css'],
  templateUrl: './marca-crud.component.html'
})

export class MarcaCrudComponent implements OnInit {

  crud: CRUDView<Marca>;

  constructor(private httpClientService: HttpClient,
              private routerService: Router,
              private routeService: ActivatedRoute,
              private notifierService: NotifierService,
              private confirmDialogService: ConfirmDialogService) {
                
    this.crud = new CRUDView<Marca>(routeService);
    this.crud.model = new Marca();
  }

  onCancelClick() {
    this.confirmDialogService.showConfirm("¿Descartar cambios?", function() {
      window.history.back();
    });
  }

  onSaveClick() {
    this.notifierService.notify('success', 'Marca guardada correctamente.');
    this.routerService.navigate(['/marcas']);
  }

  ngOnInit(): void {

    setTimeout(function() {
      (<any>$("#title-crud").find('[data-toggle="tooltip"]')).tooltip();
    }, 300);
    
  }

}
