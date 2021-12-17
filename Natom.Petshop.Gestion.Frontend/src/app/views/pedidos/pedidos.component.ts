import { HttpClient } from "@angular/common/http";
import { Component, Input, OnInit, ViewChild } from "@angular/core";
import { Router } from "@angular/router";
import { DataTableDirective } from "angular-datatables/src/angular-datatables.directive";
import { NotifierService } from "angular-notifier";
import { MarcaDTO } from "src/app/classes/dto/marca.dto";
import { PedidosListDTO } from "src/app/classes/dto/pedidos/pedidos-list.dto";
import { ApiResult } from "src/app/classes/dto/shared/api-result.dto";
import { HistoricoCambiosService } from "src/app/components/historico-cambios/historico-cambios.service";
import { ApiService } from "src/app/services/api.service";
import { AuthService } from "src/app/services/auth.service";
import { DataTableDTO } from '../../classes/data-table-dto';
import { ConfirmDialogService } from "../../components/confirm-dialog/confirm-dialog.service";

@Component({
  selector: 'app-pedidos',
  styleUrls: ['./pedidos.component.css'],
  templateUrl: './pedidos.component.html'
})
export class PedidosComponent implements OnInit {
  @ViewChild(DataTableDirective, { static: false })
  dtElement: DataTableDirective;
  dtInstance: Promise<DataTables.Api>;
  dtIndex: DataTables.Settings = {};
  Pedidos: PedidosListDTO[];
  Noty: any;
  filterStatusValue: string;

  constructor(private apiService: ApiService,
              private authService: AuthService,
              private routerService: Router,
              private notifierService: NotifierService,
              private confirmDialogService: ConfirmDialogService,
              private historicoCambiosService: HistoricoCambiosService) {
    this.filterStatusValue = "TODOS";
  }

  onFiltroEstadoChange(newValue: string) {
    this.filterStatusValue = newValue;
    this.dtElement.dtInstance.then((dtInstance: DataTables.Api) => {
      dtInstance.ajax.reload()
    });
  }

  onPrintOrdenClick(id: string) {
    console.log(id);
  }

  onPrintRemitoClick(id: string) {
    console.log(id);
  }

  onVerHistoricoCambiosClick(id: string) {
    this.historicoCambiosService.show("OrdenDePedido", id);
  }

  onIniciarOrdenClick(id: string) {
    let notifier = this.notifierService;
    let confirmDialogService = this.confirmDialogService;
    let apiService = this.apiService;
    let dataTableInstance = this.dtElement.dtInstance;

    this.confirmDialogService.showConfirm("Desea marcar el pedido como 'En preparación'?", function () {  
      apiService.DoPOST<ApiResult<any>>("pedidos/preparacion/iniciar?encryptedId=" + encodeURIComponent(id), {}, /*headers*/ null,
                                            (response) => {
                                              if (!response.success) {
                                                confirmDialogService.showError(response.message);
                                              }
                                              else {
                                                notifier.notify('success', 'Pedido iniciado.');
                                                dataTableInstance.then((dtInstance: DataTables.Api) => {
                                                  dtInstance.ajax.reload()
                                                });
                                              }
                                            },
                                            (errorMessage) => {
                                              confirmDialogService.showError(errorMessage);
                                            });
                                          });
  }

  onCompletarOrdenClick(id: string) {
    let notifier = this.notifierService;
    let confirmDialogService = this.confirmDialogService;
    let apiService = this.apiService;
    let dataTableInstance = this.dtElement.dtInstance;

    this.confirmDialogService.showConfirm("Desea marcar el pedido como 'Preparación completada'?", function () {  
      apiService.DoPOST<ApiResult<any>>("pedidos/preparacion/finalizacion?encryptedId=" + encodeURIComponent(id), {}, /*headers*/ null,
                                            (response) => {
                                              if (!response.success) {
                                                confirmDialogService.showError(response.message);
                                              }
                                              else {
                                                notifier.notify('success', 'Preparación de pedido completada.');
                                                dataTableInstance.then((dtInstance: DataTables.Api) => {
                                                  dtInstance.ajax.reload()
                                                });
                                              }
                                            },
                                            (errorMessage) => {
                                              confirmDialogService.showError(errorMessage);
                                            });
                                          });
  }

  onCancelarPreparacionOrdenClick(id: string) {
    let notifier = this.notifierService;
    let confirmDialogService = this.confirmDialogService;
    let apiService = this.apiService;
    let dataTableInstance = this.dtElement.dtInstance;

    this.confirmDialogService.showConfirm("Desea volver a marcar el pedido como 'Pendiente de preparación'?", function () {  
      apiService.DoPOST<ApiResult<any>>("pedidos/preparacion/cancelar?encryptedId=" + encodeURIComponent(id), {}, /*headers*/ null,
                                            (response) => {
                                              if (!response.success) {
                                                confirmDialogService.showError(response.message);
                                              }
                                              else {
                                                notifier.notify('success', 'Preparación de pedido cancelada.');
                                                dataTableInstance.then((dtInstance: DataTables.Api) => {
                                                  dtInstance.ajax.reload()
                                                });
                                              }
                                            },
                                            (errorMessage) => {
                                              confirmDialogService.showError(errorMessage);
                                            });
                                          });
  }

  onDeleteClick(id: string) {
    let notifier = this.notifierService;
    let confirmDialogService = this.confirmDialogService;
    let apiService = this.apiService;
    let dataTableInstance = this.dtElement.dtInstance;

    this.confirmDialogService.showConfirm("IMPORTANTE: Una vez anulado se revertirá el Stock y no se podrá deshacer la acción. ¿Desea continuar?", function () {  
      apiService.DoPOST<ApiResult<any>>("pedidos/anular?encryptedId=" + encodeURIComponent(id), {}, /*headers*/ null,
                                            (response) => {
                                              if (!response.success) {
                                                confirmDialogService.showError(response.message);
                                              }
                                              else {
                                                notifier.notify('success', 'Pedido anulado con éxito.');
                                                dataTableInstance.then((dtInstance: DataTables.Api) => {
                                                  dtInstance.ajax.reload()
                                                });
                                              }
                                            },
                                            (errorMessage) => {
                                              confirmDialogService.showError(errorMessage);
                                            });
                                          });
  }

  onDespacharOrdenClick(id: string) {
    let notifier = this.notifierService;
    let confirmDialogService = this.confirmDialogService;
    let apiService = this.apiService;
    let dataTableInstance = this.dtElement.dtInstance;

    this.confirmDialogService.showConfirm("Desea marcar el pedido como 'Despachado'?", function () {  
      apiService.DoPOST<ApiResult<any>>("pedidos/despachar?encryptedId=" + encodeURIComponent(id), {}, /*headers*/ null,
                                            (response) => {
                                              if (!response.success) {
                                                confirmDialogService.showError(response.message);
                                              }
                                              else {
                                                notifier.notify('success', 'Orden despachada correctamente.');
                                                dataTableInstance.then((dtInstance: DataTables.Api) => {
                                                  dtInstance.ajax.reload()
                                                });
                                              }
                                            },
                                            (errorMessage) => {
                                              confirmDialogService.showError(errorMessage);
                                            });
                                          });
  }

  onEntregadoOrdenClick(id: string) {
    let notifier = this.notifierService;
    let confirmDialogService = this.confirmDialogService;
    let apiService = this.apiService;
    let dataTableInstance = this.dtElement.dtInstance;

    this.confirmDialogService.showConfirm("Desea marcar el pedido como 'Entregado'?", function () {  
      apiService.DoPOST<ApiResult<any>>("pedidos/entregado?encryptedId=" + encodeURIComponent(id), {}, /*headers*/ null,
                                            (response) => {
                                              if (!response.success) {
                                                confirmDialogService.showError(response.message);
                                              }
                                              else {
                                                notifier.notify('success', 'Orden entregada correctamente.');
                                                dataTableInstance.then((dtInstance: DataTables.Api) => {
                                                  dtInstance.ajax.reload()
                                                });
                                              }
                                            },
                                            (errorMessage) => {
                                              confirmDialogService.showError(errorMessage);
                                            });
                                          });
  }

  onNoEntregadoOrdenClick(id: string) {
    let notifier = this.notifierService;
    let confirmDialogService = this.confirmDialogService;
    let apiService = this.apiService;
    let dataTableInstance = this.dtElement.dtInstance;

    this.confirmDialogService.showConfirm("Desea marcar el pedido nuevamente como 'Pendiente de despacho'?", function () {  
      apiService.DoPOST<ApiResult<any>>("pedidos/no_entrega?encryptedId=" + encodeURIComponent(id), {}, /*headers*/ null,
                                            (response) => {
                                              if (!response.success) {
                                                confirmDialogService.showError(response.message);
                                              }
                                              else {
                                                notifier.notify('success', 'Orden nuevamente en Pendiente de despacho.');
                                                dataTableInstance.then((dtInstance: DataTables.Api) => {
                                                  dtInstance.ajax.reload()
                                                });
                                              }
                                            },
                                            (errorMessage) => {
                                              confirmDialogService.showError(errorMessage);
                                            });
                                          });
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
        }
      },
      order: [[0, "desc"]],
      ajax: (dataTablesParameters: any, callback) => {
          this.apiService.DoPOST<ApiResult<DataTableDTO<PedidosListDTO>>>("pedidos/list?status=" + this.filterStatusValue, dataTablesParameters, /*headers*/ null,
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
                            this.Pedidos = response.data.records;
                            if (this.Pedidos.length > 0) {
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
        { data: 'pedido' },
        { data: 'documento' },
        { data: 'cliente' },
        { data: 'fechaHora' },
        { data: 'fechaHoraPreparado' },
        { data: 'estado', orderable: false },
        { data: 'peso_total' },
        { data: '', orderable: false } //BOTONERA
      ]
    };
  }

}
