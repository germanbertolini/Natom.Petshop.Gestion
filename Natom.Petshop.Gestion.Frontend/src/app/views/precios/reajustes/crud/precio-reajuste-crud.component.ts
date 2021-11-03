import { HttpClient } from "@angular/common/http";
import { Component, OnInit } from "@angular/core";
import { ActivatedRoute, Router } from "@angular/router";
import { NotifierService } from "angular-notifier";
import { PrecioReajuste } from "src/app/classes/models/precios/precio-reajuste.model";
import { CRUDView } from "src/app/classes/views/crud-view.classes";
import { ConfirmDialogService } from "src/app/components/confirm-dialog/confirm-dialog.service";
import { DataTablesResponse } from "../../../../classes/data-tables-response";

@Component({
  selector: 'app-precio-reajuste-crud',
  styleUrls: ['./precio-reajuste-crud.component.css'],
  templateUrl: './precio-reajuste-crud.component.html'
})

export class PrecioReajusteCrudComponent implements OnInit {

  crud: CRUDView<PrecioReajuste>;

  decideClosure(event, datepicker) { const path = event.path.map(p => p.localName); if (!path.includes('ngb-datepicker')) { datepicker.close(); } }

  constructor(private httpClientService: HttpClient,
              private routerService: Router,
              private routeService: ActivatedRoute,
              private notifierService: NotifierService,
              private confirmDialogService: ConfirmDialogService) {
                
    this.crud = new CRUDView<PrecioReajuste>(routeService);
    this.crud.model = new PrecioReajuste();
    this.crud.model.aplicoListaDePrecios_encrypted_id = "";
    this.crud.model.aplicoMarca_encrypted_id = "";
  }

  onCancelClick() {
    this.confirmDialogService.showConfirm("¿Descartar cambios?", function() {
      window.history.back();
    });
  }

  onSaveClick() {
    this.notifierService.notify('success', 'Precio guardado correctamente.');
    this.routerService.navigate(['/precios/reajustes']);
  }

  ngOnInit(): void {

    setTimeout(function() {
      (<any>$("#title-crud").find('[data-toggle="tooltip"]')).tooltip();
    }, 300);
    
  }

}
