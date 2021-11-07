import { HttpClient } from "@angular/common/http";
import { Component, OnInit } from "@angular/core";
import { ActivatedRoute, Router } from "@angular/router";
import { NotifierService } from "angular-notifier";
import { MovimientoCajaFuerte } from "src/app/classes/models/cajas/movimiento-caja-fuerte.model";
import { MovimientoStock } from "src/app/classes/models/stock/movimiento-stock.model";
import { CRUDView } from "src/app/classes/views/crud-view.classes";
import { ConfirmDialogService } from "src/app/components/confirm-dialog/confirm-dialog.service";

@Component({
  selector: 'app-stock-new-crud',
  styleUrls: ['./stock-new.component.css'],
  templateUrl: './stock-new.component.html'
})

export class StockNewComponent implements OnInit {
  crud: CRUDView<MovimientoStock>;
  stockActual: 100;
  valor: 0;

  constructor(private httpClientService: HttpClient,
              private routerService: Router,
              private routeService: ActivatedRoute,
              private notifierService: NotifierService,
              private confirmDialogService: ConfirmDialogService) {
                
    this.crud = new CRUDView<MovimientoStock>(routeService);
    this.crud.model = new MovimientoStock();
    this.crud.model.tipo = "";
  }

  onCancelClick() {
    this.confirmDialogService.showConfirm("¿Descartar cambios?", function() {
      window.history.back();
    });
  }

  onSaveClick() {
    this.notifierService.notify('success', 'Movimiento guardado correctamente.');
    this.routerService.navigate(['/stock']);
  }

  ngOnInit(): void {

    setTimeout(function() {
      (<any>$("#title-crud").find('[data-toggle="tooltip"]')).tooltip();
    }, 300);
    
  }

}
