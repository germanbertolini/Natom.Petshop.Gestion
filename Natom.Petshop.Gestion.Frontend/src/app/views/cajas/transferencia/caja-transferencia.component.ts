import { HttpClient } from "@angular/common/http";
import { Component, OnInit } from "@angular/core";
import { ActivatedRoute, Router } from "@angular/router";
import { NotifierService } from "angular-notifier";
import { TransferenciaEntreCajas } from "src/app/classes/models/transferencia-entre-cajas.model";
import { CRUDView } from "src/app/classes/views/crud-view.classes";
import { ConfirmDialogService } from "src/app/components/confirm-dialog/confirm-dialog.service";

@Component({
  selector: 'app-caja-transferencia',
  styleUrls: ['./caja-transferencia.component.css'],
  templateUrl: './caja-transferencia.component.html'
})

export class CajaTransferenciaComponent implements OnInit {
  crud: CRUDView<TransferenciaEntreCajas>;

  constructor(private httpClientService: HttpClient,
              private routerService: Router,
              private routeService: ActivatedRoute,
              private notifierService: NotifierService,
              private confirmDialogService: ConfirmDialogService) {
                
    this.crud = new CRUDView<TransferenciaEntreCajas>(routeService);
    this.crud.model = new TransferenciaEntreCajas();
    this.crud.model.origen = "diaria";
    this.crud.model.destino = "fuerte";
    this.crud.model.usuarioNombre = "German";
  }

  onCancelClick() {
    this.confirmDialogService.showConfirm("¿Cancelar?", function() {
      window.history.back();
    });
  }

  onSaveClick() {
    this.notifierService.notify('success', 'Transferencia registrada correctamente.');
    this.routerService.navigate(['/cajas/diaria']);
  }

  ngOnInit(): void {

    setTimeout(function() {
      (<any>$("#title-crud").find('[data-toggle="tooltip"]')).tooltip();
    }, 300);
    
  }

}
