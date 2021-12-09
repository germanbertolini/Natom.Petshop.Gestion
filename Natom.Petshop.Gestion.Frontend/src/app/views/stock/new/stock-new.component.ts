import { HttpClient } from "@angular/common/http";
import { Component, OnInit } from "@angular/core";
import { ActivatedRoute, Router } from "@angular/router";
import { fromEvent } from 'rxjs';
import { map, distinctUntilChanged, debounceTime, mergeMap } from 'rxjs/operators';
import { NotifierService } from "angular-notifier";
import { ProductoListDTO } from "src/app/classes/dto/productos/producto-list.dto";
import { MovimientoStockDTO } from "src/app/classes/dto/stock/movimiento-stock.dto";
import { CRUDView } from "src/app/classes/views/crud-view.classes";
import { ConfirmDialogService } from "src/app/components/confirm-dialog/confirm-dialog.service";
import { ApiService } from "src/app/services/api.service";
import { AuthService } from "src/app/services/auth.service";
import { AutocompleteResultDTO } from "src/app/classes/dto/shared/autocomplete-result.dto";
import { ApiResult } from "src/app/classes/dto/shared/api-result.dto";

@Component({
  selector: 'app-stock-new-crud',
  styleUrls: ['./stock-new.component.css'],
  templateUrl: './stock-new.component.html'
})

export class StockNewComponent implements OnInit {
  crud: CRUDView<MovimientoStockDTO>;
  stockActual: 100;
  valor: 0;
  productoFilterValue: string;
  productoFilterText: string;
  productosSearch: ProductoListDTO[];

  constructor(private apiService: ApiService,
              private authService: AuthService,
              private routerService: Router,
              private routeService: ActivatedRoute,
              private notifierService: NotifierService,
              private confirmDialogService: ConfirmDialogService) {
                
    this.crud = new CRUDView<MovimientoStockDTO>(routeService);
    this.crud.model = new MovimientoStockDTO();
    this.crud.model.tipo = "";
    this.crud.model.deposito_encrypted_id = "";
    this.crud.model.usuarioNombre = authService.getCurrentUser().first_name;
  }

  onProductoSearchSelectItem (producto: ProductoListDTO) {
    this.productoFilterValue = producto.encrypted_id;
    this.productoFilterText = producto.marca + " " + producto.descripcion;
    this.closeProductoSearchPopUp();
  }

  closeProductoSearchPopUp() {
    setTimeout(() => { this.productosSearch = undefined; }, 200);    
  }

  onProductoSearchKeyUp(event) {
    let observable = fromEvent(event.target, 'keyup')
      .pipe (
        map(value => event.target.value),
        debounceTime(1000),
        distinctUntilChanged(),
        mergeMap((search) => {
          return this.apiService.DoGETWithObservable("productos/search?filter=" + encodeURIComponent(search), /* headers */ null);
        })
      )
   observable.subscribe((data) => {
      var result = <ApiResult<AutocompleteResultDTO<ProductoListDTO>>>data;
      if (!result.success) {
        this.confirmDialogService.showError("Se ha producido un error interno.");
      }
      else {
        this.productosSearch = result.data.results;
      }
   });
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
