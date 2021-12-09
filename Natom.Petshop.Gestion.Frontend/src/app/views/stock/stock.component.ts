import { HttpClient } from "@angular/common/http";
import { Component, Input, OnInit, ViewChild } from "@angular/core";
import { Router } from "@angular/router";
import { NotifierService } from "angular-notifier";
import { fromEvent } from 'rxjs';
import { map, distinctUntilChanged, debounceTime, mergeMap } from 'rxjs/operators';
import { DataTableDTO } from '../../classes/data-table-dto';
import { ConfirmDialogService } from "../../components/confirm-dialog/confirm-dialog.service";
import { StockListDTO } from "src/app/classes/dto/stock/stock-list.dto";
import { ApiResult } from "src/app/classes/dto/shared/api-result.dto";
import { ApiService } from "src/app/services/api.service";
import { DepositoDTO } from "src/app/classes/dto/stock/deposito.dto";
import { DataTableDirective } from "angular-datatables/src/angular-datatables.directive";
import { ProductoListDTO } from "src/app/classes/dto/productos/producto-list.dto";
import { AutocompleteResultDTO } from "src/app/classes/dto/shared/autocomplete-result.dto";

@Component({
  selector: 'app-stock',
  styleUrls: ['./stock.component.css'],
  templateUrl: './stock.component.html'
})
export class StockComponent implements OnInit {
  @ViewChild(DataTableDirective, { static: false })
  dtElement: DataTableDirective;
  dtInstance: Promise<DataTables.Api>;
  dtIndex: DataTables.Settings = {};
  Movimientos: StockListDTO[];
  Depositos: Array<DepositoDTO>;
  saldoActual: number;
  filtroFechaValue: string;
  filtroFechaText: string;
  depositoFilterValue: string;
  productoFilterValue: string;
  productoFilterText: string;
  productosSearch: ProductoListDTO[];
  Noty: any;

  decideClosure(event, datepicker) { const path = event.path.map(p => p.localName); if (!path.includes('ngb-datepicker')) { datepicker.close(); } }

  constructor(private apiService: ApiService,
              private routerService: Router,
              private notifierService: NotifierService,
              private confirmDialogService: ConfirmDialogService) {
    this.depositoFilterValue = "";
    this.productoFilterValue = "";
    this.filtroFechaValue = "";
  }

  onFiltroDepositoChange(newValue: string) {
    this.depositoFilterValue = newValue;
    this.dtElement.dtInstance.then((dtInstance: DataTables.Api) => {
      dtInstance.ajax.reload()
    });
  }

  onFiltroFechaChange(newValue) {
    this.filtroFechaValue = newValue.day + "/" + newValue.month + "/" + newValue.year;
    this.dtElement.dtInstance.then((dtInstance: DataTables.Api) => {
      dtInstance.ajax.reload()
    });
  }

  onProductoSearchSelectItem (producto: ProductoListDTO) {
    this.productoFilterValue = producto.encrypted_id;
    this.productoFilterText = producto.marca + " " + producto.descripcion;
    this.closeProductoSearchPopUp();
    this.dtElement.dtInstance.then((dtInstance: DataTables.Api) => {
      dtInstance.ajax.reload()
    });
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

  onProductoSearchChange() {
    if (this.productoFilterText == "") {
      this.productoFilterValue = "";
      this.closeProductoSearchPopUp();
      this.dtElement.dtInstance.then((dtInstance: DataTables.Api) => {
        dtInstance.ajax.reload()
      });
    }
  }

  ngOnInit(): void {

    this.dtIndex = {
      pagingType: 'simple_numbers',
      pageLength: 10,
      serverSide: true,
      processing: true,
      info: true,
      language: {
        emptyTable: '',
        zeroRecords: 'No hay registros',
        lengthMenu: 'Mostrar _MENU_ registros',
        search: 'Buscar:',
        info: 'Mostrando _START_ a _END_ de _TOTAL_ registros',
        infoEmpty: 'De 0 a 0 de 0 registros',
        infoFiltered: '(filtrados de _MAX_ registros totales)',
        paginate: {
          first: 'Primero',
          last: 'Último',
          next: 'Siguiente',
          previous: 'Anterior'
        },
      },
      ajax: (dataTablesParameters: any, callback) => {
        this.apiService.DoPOST<ApiResult<DataTableDTO<StockListDTO>>>("stock/list?depositoFilter=" + encodeURIComponent(this.depositoFilterValue) + "&productoFilter=" + encodeURIComponent(this.productoFilterValue) + "&filtroFecha=" + encodeURIComponent(this.filtroFechaValue), dataTablesParameters, /*headers*/ null,
                      (response) => {
                        if (!response.success) {
                          this.confirmDialogService.showError(response.message);
                        }
                        else {
                          callback({
                            recordsTotal: response.data.recordsTotal,
                            recordsFiltered: response.data.recordsFiltered,
                            data: [] //Siempre vacío para delegarle el render a Angular
                          });
                          this.Movimientos = response.data.records;
                          this.Depositos = <Array<DepositoDTO>>response.data.extraData.depositos;

                          if (this.Movimientos.length > 0) {
                            $('.dataTables_empty').hide();
                          }
                          else {
                            $('.dataTables_empty').show();
                          }
                          setTimeout(function() {
                            (<any>$("tbody tr").find('[data-toggle="tooltip"]')).tooltip();
                          }, 300);
                        }
                      },
                      (errorMessage) => {
                        this.confirmDialogService.showError(errorMessage);
                      });
      },
      columns: [
        { data: 'fechaHora', orderable: false },
        { data: 'deposito', orderable: false },
        { data: 'producto', orderable: false },
        { data: 'tipo', orderable: false },
        { data: 'reservado', orderable: false },
        { data: 'movido', orderable: false },
        { data: 'stock', orderable: false },
        { data: 'observaciones', orderable: false }
      ]
    };
  }

}
