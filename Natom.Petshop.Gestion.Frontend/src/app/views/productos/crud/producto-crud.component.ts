import { HttpClient } from "@angular/common/http";
import { Component, OnInit } from "@angular/core";
import { ActivatedRoute, Router } from "@angular/router";
import { NotifierService } from "angular-notifier";
import { Cliente } from "src/app/classes/models/clientes/cliente.model";
import { Producto } from "src/app/classes/models/productos/producto.model";
import { CRUDView } from "src/app/classes/views/crud-view.classes";
import { ConfirmDialogService } from "src/app/components/confirm-dialog/confirm-dialog.service";
import { DataTableDTO } from "../../../classes/data-table-dto";

@Component({
  selector: 'app-producto-crud',
  styleUrls: ['./producto-crud.component.css'],
  templateUrl: './producto-crud.component.html'
})

export class ProductoCrudComponent implements OnInit {

  crud: CRUDView<Producto>;

  constructor(private httpClientService: HttpClient,
              private routerService: Router,
              private routeService: ActivatedRoute,
              private notifierService: NotifierService,
              private confirmDialogService: ConfirmDialogService) {
                
    this.crud = new CRUDView<Producto>(routeService);
    this.crud.model = new Producto();
    this.crud.model.marca_encrypted_id = "";
    this.crud.model.unidadPeso_encrypted_id = "";
    this.crud.model.mueveStock = true;
  }

  onCancelClick() {
    this.confirmDialogService.showConfirm("¿Descartar cambios?", function() {
      window.history.back();
    });
  }

  onSaveClick() {
    this.notifierService.notify('success', 'Producto guardado correctamente.');
    this.routerService.navigate(['/productos']);
  }

  ngOnInit(): void {

    setTimeout(function() {
      (<any>$("#title-crud").find('[data-toggle="tooltip"]')).tooltip();
    }, 300);
    
  }

}
