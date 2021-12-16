import { Component, OnInit, TemplateRef, ViewChild } from "@angular/core";
import { ActivatedRoute, Router } from "@angular/router";
import { NgbModal, NgbModalRef } from "@ng-bootstrap/ng-bootstrap";
import { DataTableDirective } from "angular-datatables/src/angular-datatables.directive";
import { NotifierService } from "angular-notifier";
import { fromEvent } from "rxjs";
import { debounceTime, distinctUntilChanged, map, mergeMap } from "rxjs/operators";
import { ClienteDTO } from "src/app/classes/dto/clientes/cliente.dto";
import { PedidoDTO } from "src/app/classes/dto/pedidos/pedido.dto";
import { RangoHorarioDTO } from "src/app/classes/dto/pedidos/rango-horario.dto";
import { ListaDePreciosDTO } from "src/app/classes/dto/precios/lista-de-precios.dto";
import { ApiResult } from "src/app/classes/dto/shared/api-result.dto";
import { AutocompleteResultDTO } from "src/app/classes/dto/shared/autocomplete-result.dto";
import { DepositoDTO } from "src/app/classes/dto/stock/deposito.dto";
import { VentaDetalleDTO } from "src/app/classes/dto/ventas/venta-detalle.dto";
import { VentaDTO } from "src/app/classes/dto/ventas/venta.dto";
import { CRUDView } from "src/app/classes/views/crud-view.classes";
import { ConfirmDialogService } from "src/app/components/confirm-dialog/confirm-dialog.service";
import { ApiService } from "src/app/services/api.service";
import { AuthService } from "src/app/services/auth.service";

@Component({
  selector: 'app-venta-crud',
  styleUrls: ['./venta-crud.component.css'],
  templateUrl: './venta-crud.component.html'
})

export class VentaCrudComponent implements OnInit {
  @ViewChild('cambiarPrecioModal', { static: false }) cambiarPrecioModal : TemplateRef<any>; // Note: TemplateRef
  @ViewChild(DataTableDirective, { static: false })
  dtElement: DataTableDirective;
  dtInstance: Promise<DataTables.Api>;
  dtDetalle: DataTables.Settings = {};
  crud: CRUDView<VentaDTO>;
  clientesSearch: ClienteDTO[];
  listaDeOrdenes: PedidoDTO[];
  listasDePrecios: Array<ListaDePreciosDTO>;
  general_cliente: string;
  totalizador_monto: number;
  totalizador_peso_gramos: number;
  detalle_ordenDePedido_encrypted_id: string;
  cambiar_precio_modal: NgbModalRef;
  cambiar_precio_index: number;
  cambiar_precio_lista_encrypted_id: string;
  cambiar_precio_monto: number;


  constructor(private modalService: NgbModal,
              private apiService: ApiService,
              private authService: AuthService,
              private routerService: Router,
              private routeService: ActivatedRoute,
              private notifierService: NotifierService,
              private confirmDialogService: ConfirmDialogService) {
                
    this.crud = new CRUDView<VentaDTO>(routeService);
    this.crud.model = new VentaDTO();
    this.crud.model.tipo_factura = "";
    this.totalizador_monto = 0;
    this.totalizador_peso_gramos = 0;
    this.crud.model.detalle = new Array<VentaDetalleDTO>();
    this.crud.model.fechaHora = new Date();
    this.crud.model.usuario = authService.getCurrentUser().first_name;
    this.detalle_ordenDePedido_encrypted_id = "";
    this.cambiar_precio_index = 0;
  }

  onClienteSearchSelectItem (cliente: ClienteDTO) {
    this.general_cliente = cliente.tipoDocumento + " " + cliente.numeroDocumento + " /// " + (cliente.esEmpresa ? cliente.razonSocial : cliente.nombre + " " + cliente.apellido);
    this.crud.model.cliente_encrypted_id = cliente.encrypted_id;
    this.closeClienteSearchPopUp();
    this.obtenerOrdenesDePedido();
    this.crud.model.detalle = new Array<VentaDetalleDTO>();
    this.detalle_ordenDePedido_encrypted_id = "";
    this.recalcularTotales();
  }

  obtenerOrdenesDePedido() {
    this.apiService.DoGET<ApiResult<any>>("pedidos/list_by_cliente?encryptedId=" + encodeURIComponent(this.crud.model.cliente_encrypted_id), /*headers*/ null,
      (response) => {
        if (!response.success) {
          this.confirmDialogService.showError(response.message);
        }
        else {
            this.listaDeOrdenes = <PedidoDTO[]>response.data.listaDeOrdenes;

            setTimeout(function() {
              (<any>$("#title-crud").find('[data-toggle="tooltip"]')).tooltip();
            }, 300);
        }
      },
      (errorMessage) => {
        this.confirmDialogService.showError(errorMessage);
      });
  }

  closeClienteSearchPopUp() {
    setTimeout(() => { this.clientesSearch = undefined; }, 200);    
  }

  onClienteSearchKeyUp(event) {
    let observable = fromEvent(event.target, 'keyup')
      .pipe (
        map(value => event.target.value),
        debounceTime(500),
        distinctUntilChanged(),
        mergeMap((search) => {
          return this.apiService.DoGETWithObservable("clientes/search?filter=" + encodeURIComponent(search), /* headers */ null);
        })
      )
    observable.subscribe((data) => {
      var result = <ApiResult<AutocompleteResultDTO<ClienteDTO>>>data;
      if (!result.success) {
        this.confirmDialogService.showError("Se ha producido un error interno.");
      }
      else {
        this.clientesSearch = result.data.results;
      }
    });
  }

  onDetalleTabClick() {
    this.dataTableAdjustColumnSizing();
  }

  dataTableAdjustColumnSizing() {
    let _dtInstance = this.dtElement.dtInstance;
    setTimeout(function() {
      _dtInstance.then((dtInstance: DataTables.Api) => {
        dtInstance.columns.adjust();
      });
    }, 300);
  }

  onCambiarPrecioClick(index) {
    this.cambiar_precio_index = index;
    this.cambiar_precio_lista_encrypted_id = "";
    this.cambiar_precio_modal = this.modalService.open(this.cambiarPrecioModal);
  }

  onAgregarOrdenClick() {
    if (this.detalle_ordenDePedido_encrypted_id === undefined || this.detalle_ordenDePedido_encrypted_id.length === 0) {
      this.confirmDialogService.showError("Debes seleccionar una Orden de Pedido.");
      return;
    }

    for (let i = 0; i < this.crud.model.detalle.length; i ++) {
      if (this.crud.model.detalle[i].pedido_encrypted_id === this.detalle_ordenDePedido_encrypted_id) {
        this.confirmDialogService.showError("La Orden de Pedido ya se encuentra agregada.");
        return;
      }
    }

    this.apiService.DoGET<ApiResult<any>>("pedidos/basics/data?encryptedId=" + encodeURIComponent(this.detalle_ordenDePedido_encrypted_id), /*headers*/ null,
    (response) => {
      if (!response.success) {
        this.confirmDialogService.showError(response.message);
      }
      else {
        let ordenDePedido = <PedidoDTO>response.data.entity;

        for (let i = 0; i < ordenDePedido.detalle.length; i ++) {
          this.crud.model.detalle.push(<VentaDetalleDTO>{
            encrypted_id: "",
            pedido_encrypted_id: ordenDePedido.encrypted_id,
            pedido_detalle_encrypted_id: ordenDePedido.detalle[i].encrypted_id,
            pedido_numero: ordenDePedido.numero,
            producto_encrypted_id: ordenDePedido.detalle[i].producto_encrypted_id,
            producto_descripcion: ordenDePedido.detalle[i].producto_descripcion,
            producto_peso_gramos: ordenDePedido.detalle[i].producto_peso_gramos,
            cantidad: ordenDePedido.detalle[i].cantidad,
            deposito_encrypted_id: ordenDePedido.detalle[i].deposito_encrypted_id,
            deposito_descripcion: ordenDePedido.detalle[i].deposito_descripcion,
            precio_lista_encrypted_id: ordenDePedido.detalle[i].precio_lista_encrypted_id,
            precio_descripcion: ordenDePedido.detalle[i].precio_descripcion,
            precio: ordenDePedido.detalle[i].precio,
            numero_remito: ordenDePedido.numero_remito
          });
        }
        
        this.dataTableAdjustColumnSizing();

        setTimeout(function() {
          (<any>$("#title-crud").find('[data-toggle="tooltip"]')).tooltip();
        }, 300);

        this.detalle_ordenDePedido_encrypted_id = "";
        this.recalcularTotales();
      }
    },
    (errorMessage) => {
      this.confirmDialogService.showError(errorMessage);
    });
  }

  recalcularTotales() {
    this.totalizador_monto = 0;
    this.totalizador_peso_gramos = 0;

    if (this.crud.model.detalle.length > 0) {
      for (let i = 0; i < this.crud.model.detalle.length; i ++) {
        this.totalizador_monto = this.totalizador_monto + (this.crud.model.detalle[i].precio * this.crud.model.detalle[i].cantidad);
        this.totalizador_peso_gramos = this.totalizador_peso_gramos + (this.crud.model.detalle[i].producto_peso_gramos * this.crud.model.detalle[i].cantidad);
      }
    }
  }

  onCancelClick() {
    this.confirmDialogService.showConfirm("¿Descartar cambios?", function() {
      window.history.back();
    });
  }

  onSaveClick() {
    if (this.crud.model.cliente_encrypted_id === undefined || this.crud.model.cliente_encrypted_id.length === 0)
    {
      this.confirmDialogService.showError("Debes buscar un Cliente.");
      return;
    }

    if (this.crud.model.tipo_factura === undefined || this.crud.model.tipo_factura.length === 0)
    {
      this.confirmDialogService.showError("Debes seleccionar el Tipo de comprobante.");
      return;
    }

    if (this.crud.model.numero_factura === undefined || this.crud.model.numero_factura.length === 0)
    {
      this.confirmDialogService.showError("Debes ingresar el numero de Comprobante.");
      return;
    }
    
    if (this.crud.model.detalle === undefined || this.crud.model.detalle.length === 0)
    {
      this.confirmDialogService.showError("Debes agregar al menos una Orden de Pedido en 'Detalle'.");
      return;
    }

    for (let i = 0; i < this.crud.model.detalle.length; i ++) {
      if (this.crud.model.detalle[i].precio === null) {
        this.confirmDialogService.showError("Quedan precios sin definir en 'Detalle'.");
        return;
      }
    }

    this.confirmDialogService.showConfirm("¿Ya está todo? Una vez guardado no se podrá modificar la Facturación.", () => {
      this.apiService.DoPOST<ApiResult<PedidoDTO>>("ventas/save", this.crud.model, /*headers*/ null,
            (response) => {
              if (!response.success) {
                this.confirmDialogService.showError(response.message);
              }
              else {
                this.notifierService.notify('success', 'Facturación generada correctamente.');
                this.routerService.navigate(['/ventas']);
              }
            },
            (errorMessage) => {
              this.confirmDialogService.showError(errorMessage);
            });
    });
  }

  ngOnInit(): void {

    this.dtDetalle = {
      pagingType: 'simple_numbers',
      pageLength: 100,
      serverSide: false,
      processing: false,
      info: false,
      paging: false,
      searching: false,
      scrollY: "270px",
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
        callback({
          recordsTotal: this.crud.model.detalle.length,
          recordsFiltered: this.crud.model.detalle.length,
          data: [] //Siempre vacío para delegarle el render a Angular
        });
        
        $('.dataTables_empty').hide();
        
        setTimeout(function() {
          (<any>$("tbody tr").find('[data-toggle="tooltip"]')).tooltip();
        }, 300);
      },
      columns: [
        { data: 'pedido', orderable: false },
        { data: 'producto', orderable: false },
        { data: 'cantidad', orderable: false },
        { data: 'peso', orderable: false },
        { data: 'lista', orderable: false },
        { data: 'precio_unitario', orderable: false },
        { data: 'monto_total', orderable: false },
        { data: '', orderable: false } //BOTONERA
      ]
    };
    
    this.apiService.DoGET<ApiResult<any>>("ventas/basics/data", /*headers*/ null,
      (response) => {
        if (!response.success) {
          this.confirmDialogService.showError(response.message);
        }
        else {
            this.crud.model.numero = response.data.numero_venta;
            this.listasDePrecios = <Array<ListaDePreciosDTO>>response.data.listasDePrecios;

            setTimeout(function() {
              (<any>$("#title-crud").find('[data-toggle="tooltip"]')).tooltip();
            }, 300);
        }
      },
      (errorMessage) => {
        this.confirmDialogService.showError(errorMessage);
      });

  }

  consultarPrecioCambiarMontoModal() {
      this.apiService.DoGET<ApiResult<any>>("precios/get?producto=" + encodeURIComponent(this.crud.model.detalle[this.cambiar_precio_index].producto_encrypted_id) + "&lista=" + encodeURIComponent(this.cambiar_precio_lista_encrypted_id), /*headers*/ null,
          (response) => {
            if (!response.success) {
              this.confirmDialogService.showError(response.message);
            }
            else {
              this.cambiar_precio_monto = <number>response.data;
    
              setTimeout(function() {
                (<any>$("#title-crud").find('[data-toggle="tooltip"]')).tooltip();
              }, 300);
            }
          },
          (errorMessage) => {
            this.confirmDialogService.showError(errorMessage);
          });
  }

  aplicarNuevoPrecio() {
    if (this.cambiar_precio_monto === undefined || this.cambiar_precio_monto < 0) {
      this.confirmDialogService.showError("Debes ingresar un Monto válido.");
      return;
    }

    if (this.cambiar_precio_lista_encrypted_id === undefined || this.cambiar_precio_lista_encrypted_id.length === 0) {
      this.crud.model.detalle[this.cambiar_precio_index].precio_descripcion = "";
      this.crud.model.detalle[this.cambiar_precio_index].precio = this.cambiar_precio_monto;
    }
    else {
      let precio_descripcion = "";
      for (let i = 0; i < this.listasDePrecios.length; i ++){
        if (this.listasDePrecios[i].encrypted_id === this.cambiar_precio_lista_encrypted_id) {
          precio_descripcion = this.listasDePrecios[i].descripcion;
          break;
        }
      }
      this.crud.model.detalle[this.cambiar_precio_index].precio_descripcion = precio_descripcion;
      this.crud.model.detalle[this.cambiar_precio_index].precio = this.cambiar_precio_monto;
    }
    this.recalcularTotales();
    this.cambiar_precio_modal.close();
  }

}
