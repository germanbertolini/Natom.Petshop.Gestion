import { HttpClient } from "@angular/common/http";
import { Component, OnInit } from "@angular/core";
import { ActivatedRoute, Router } from "@angular/router";
import { NotifierService } from "angular-notifier";
import { PedidoDTO } from "src/app/classes/dto/pedidos/pedido.dto";
import { CRUDView } from "src/app/classes/views/crud-view.classes";
import { ConfirmDialogService } from "src/app/components/confirm-dialog/confirm-dialog.service";
import { DataTableDTO } from "../../../classes/data-table-dto";

@Component({
  selector: 'app-pedido-crud',
  styleUrls: ['./pedido-crud.component.css'],
  templateUrl: './pedido-crud.component.html'
})

export class PedidoCrudComponent implements OnInit {

  crud: CRUDView<PedidoDTO>;

  constructor(private httpClientService: HttpClient,
              private routerService: Router,
              private routeService: ActivatedRoute,
              private notifierService: NotifierService,
              private confirmDialogService: ConfirmDialogService) {
                
    this.crud = new CRUDView<PedidoDTO>(routeService);
    this.crud.model = new PedidoDTO();
    this.crud.model.numero = "00049302";
    this.crud.model.fechaHora = new Date();
    this.crud.model.usuario = "German";
  }

  onCancelClick() {
    this.confirmDialogService.showConfirm("¿Descartar cambios?", function() {
      window.history.back();
    });
  }

  onSaveClick() {
    this.notifierService.notify('success', 'Pedido generado correctamente.');
    this.routerService.navigate(['/pedidos']);
  }

  ngOnInit(): void {

    setTimeout(function() {
      (<any>$("#title-crud").find('[data-toggle="tooltip"]')).tooltip();
    }, 300);
    
  }

}
