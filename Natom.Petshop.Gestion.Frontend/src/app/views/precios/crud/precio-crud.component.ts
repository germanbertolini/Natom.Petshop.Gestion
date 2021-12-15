import { HttpClient } from "@angular/common/http";
import { Component, OnInit } from "@angular/core";
import { ActivatedRoute, Router } from "@angular/router";
import { NotifierService } from "angular-notifier";
import { fromEvent } from 'rxjs';
import { map, distinctUntilChanged, debounceTime, mergeMap } from 'rxjs/operators';
import { PrecioDTO } from "src/app/classes/dto/precios/precio.dto";
import { ProductoListDTO } from "src/app/classes/dto/productos/producto-list.dto";
import { CRUDView } from "src/app/classes/views/crud-view.classes";
import { ConfirmDialogService } from "src/app/components/confirm-dialog/confirm-dialog.service";
import { DataTableDTO } from "../../../classes/data-table-dto";
import { ApiService } from "src/app/services/api.service";
import { ApiResult } from "src/app/classes/dto/shared/api-result.dto";
import { AutocompleteResultDTO } from "src/app/classes/dto/shared/autocomplete-result.dto";
import { ListaDePreciosDTO } from "src/app/classes/dto/precios/lista-de-precios.dto";

@Component({
  selector: 'app-precio-crud',
  styleUrls: ['./precio-crud.component.css'],
  templateUrl: './precio-crud.component.html'
})

export class PrecioCrudComponent implements OnInit {

  crud: CRUDView<PrecioDTO>;
  productosSearch: ProductoListDTO[];
  ListasDePrecios: Array<ListaDePreciosDTO>;


  constructor(private apiService: ApiService,
              private routerService: Router,
              private routeService: ActivatedRoute,
              private notifierService: NotifierService,
              private confirmDialogService: ConfirmDialogService) {
                
    this.crud = new CRUDView<PrecioDTO>(routeService);
    this.crud.model = new PrecioDTO();
    this.crud.model.listaDePrecios_encrypted_id = "";
  }

  onCancelClick() {
    this.confirmDialogService.showConfirm("¿Descartar cambios?", function() {
      window.history.back();
    });
  }

  onSaveClick() {
    if (this.crud.model.producto_encrypted_id === undefined || this.crud.model.producto_encrypted_id.length === 0)
    {
      this.confirmDialogService.showError("Debes seleccionar un Producto.");
      return;
    }

    if (this.crud.model.listaDePrecios_encrypted_id === undefined || this.crud.model.listaDePrecios_encrypted_id.length === 0)
    {
      this.confirmDialogService.showError("Debes seleccionar una Lista de precios.");
      return;
    }

    if (this.crud.model.precio === undefined || this.crud.model.precio <= 0)
    {
      this.confirmDialogService.showError("Debes ingresar un Precio válido.");
      return;
    }

    this.apiService.DoPOST<ApiResult<PrecioDTO>>("precios/save", this.crud.model, /*headers*/ null,
      (response) => {
        if (!response.success) {
          this.confirmDialogService.showError(response.message);
        }
        else {
          this.notifierService.notify('success', 'Precio guardado correctamente.');
          this.routerService.navigate(['/precios']);
        }
      },
      (errorMessage) => {
        this.confirmDialogService.showError(errorMessage);
      });
  }

  onProductoSearchSelectItem (producto: ProductoListDTO) {
    this.crud.model.producto_encrypted_id = producto.encrypted_id;
    this.crud.model.producto = "(" + producto.codigo + ") " + producto.marca + " " + producto.descripcion;
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

  ngOnInit(): void {

    this.apiService.DoGET<ApiResult<any>>("precios/basics/data" + (this.crud.isRenewMode ? "?encryptedId=" + encodeURIComponent(this.crud.id) : ""), /*headers*/ null,
      (response) => {
        if (!response.success) {
          this.confirmDialogService.showError(response.message);
        }
        else {
          if (response.data.entity !== null)
            this.crud.model = response.data.entity;
          
          this.ListasDePrecios = <Array<ListaDePreciosDTO>>response.data.listasDePrecios;

          setTimeout(function() {
            (<any>$("#title-crud").find('[data-toggle="tooltip"]')).tooltip();
          }, 300);
        }
      },
      (errorMessage) => {
        this.confirmDialogService.showError(errorMessage);
      });
    
  }

}
