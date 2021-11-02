import { HttpClient } from "@angular/common/http";
import { Component, OnInit } from "@angular/core";
import { ActivatedRoute, Router } from "@angular/router";
import { NotifierService } from "angular-notifier";
import { MovimientoCajaFuerte } from "src/app/classes/models/cajas/movimiento-caja-fuerte.model";
import { CRUDView } from "src/app/classes/views/crud-view.classes";
import { ConfirmDialogService } from "src/app/components/confirm-dialog/confirm-dialog.service";

@Component({
  selector: 'app-caja-fuerte-new-crud',
  styleUrls: ['./caja-fuerte-new.component.css'],
  templateUrl: './caja-fuerte-new.component.html'
})

export class CajaFuerteNewComponent implements OnInit {
  crud: CRUDView<MovimientoCajaFuerte>;

  constructor(private httpClientService: HttpClient,
              private routerService: Router,
              private routeService: ActivatedRoute,
              private notifierService: NotifierService,
              private confirmDialogService: ConfirmDialogService) {
                
    this.crud = new CRUDView<MovimientoCajaFuerte>(routeService);
    this.crud.model = new MovimientoCajaFuerte();
    this.crud.model.tipo = "";
    this.crud.model.usuarioNombre = "German";
  }

  onCancelClick() {
    this.confirmDialogService.showConfirm("¿Descartar cambios?", function() {
      window.history.back();
    });
  }

  onSaveClick() {
    this.notifierService.notify('success', 'Movimiento guardado correctamente.');
    this.routerService.navigate(['/cajas/fuerte']);
  }

  ngOnInit(): void {

    setTimeout(function() {
      (<any>$("#title-crud").find('[data-toggle="tooltip"]')).tooltip();
    }, 300);
    
  }

}
