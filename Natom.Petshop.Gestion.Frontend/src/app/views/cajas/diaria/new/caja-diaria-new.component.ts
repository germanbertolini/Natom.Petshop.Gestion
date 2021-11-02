import { HttpClient } from "@angular/common/http";
import { Component, OnInit } from "@angular/core";
import { ActivatedRoute, Router } from "@angular/router";
import { NotifierService } from "angular-notifier";
import { MovimientoCajaDiaria } from "src/app/classes/models/cajas/movimiento-caja-diaria.model";
import { CRUDView } from "src/app/classes/views/crud-view.classes";
import { ConfirmDialogService } from "src/app/components/confirm-dialog/confirm-dialog.service";

@Component({
  selector: 'app-caja-diaria-new-crud',
  styleUrls: ['./caja-diaria-new.component.css'],
  templateUrl: './caja-diaria-new.component.html'
})

export class CajaDiariaNewComponent implements OnInit {
  crud: CRUDView<MovimientoCajaDiaria>;

  constructor(private httpClientService: HttpClient,
              private routerService: Router,
              private routeService: ActivatedRoute,
              private notifierService: NotifierService,
              private confirmDialogService: ConfirmDialogService) {
                
    this.crud = new CRUDView<MovimientoCajaDiaria>(routeService);
    this.crud.model = new MovimientoCajaDiaria();
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
    this.routerService.navigate(['/cajas/diaria']);
  }

  ngOnInit(): void {

    setTimeout(function() {
      (<any>$("#title-crud").find('[data-toggle="tooltip"]')).tooltip();
    }, 300);
    
  }

}
