import { HttpClient } from "@angular/common/http";
import { Component, OnInit } from "@angular/core";
import { ActivatedRoute, Router } from "@angular/router";
import { NotifierService } from "angular-notifier";
import { ProductoDTO } from "src/app/classes/dto/productos/producto.dto";
import { CRUDView } from "src/app/classes/views/crud-view.classes";
import { ConfirmDialogService } from "src/app/components/confirm-dialog/confirm-dialog.service";

@Component({
  selector: 'app-producto-crud',
  styleUrls: ['./producto-crud.component.css'],
  templateUrl: './producto-crud.component.html'
})

export class ProductoCrudComponent implements OnInit {

  crud: CRUDView<ProductoDTO>;

  constructor(private httpClientService: HttpClient,
              private routerService: Router,
              private routeService: ActivatedRoute,
              private notifierService: NotifierService,
              private confirmDialogService: ConfirmDialogService) {
                
    this.crud = new CRUDView<ProductoDTO>(routeService);
    this.crud.model = new ProductoDTO();
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
