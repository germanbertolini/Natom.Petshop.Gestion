import { HttpClient } from "@angular/common/http";
import { Component, Input, OnInit, ViewChild } from "@angular/core";
import { Router } from "@angular/router";
import { NotifierService } from "angular-notifier";
import { Marca } from "src/app/classes/models/marca.model";
import { PedidosList } from "src/app/classes/models/pedidos/pedidos-list.model";
import { DataTableDTO } from '../../classes/data-table-dto';
import { ConfirmDialogService } from "../../components/confirm-dialog/confirm-dialog.service";

@Component({
  selector: 'app-pedidos',
  styleUrls: ['./pedidos.component.css'],
  templateUrl: './pedidos.component.html'
})
export class PedidosComponent implements OnInit {

  dtIndex: DataTables.Settings = {};
  Pedidos: PedidosList[];
  Noty: any;

  constructor(private httpClientService: HttpClient,
              private routerService: Router,
              private notifierService: NotifierService,
              private confirmDialogService: ConfirmDialogService) {
                
  }

  onFiltroEstadoChange(newValue: string) {
    console.log(newValue);
  }

  onPrintOrdenClick(id: string) {
    console.log(id);
  }

  onPrintRemitoClick(id: string) {
    console.log(id);
  }

  onIniciarOrdenClick(id: string) {
    console.log(id);
    let notifier = this.notifierService;
    this.confirmDialogService.showConfirm("Desea marcar el pedido como 'En preparación'?", function () {  
      notifier.notify('success', 'Pedido iniciado.');
    });
  }

  onCompletarOrdenClick(id: string) {
    console.log(id);
    let notifier = this.notifierService;
    this.confirmDialogService.showConfirm("Desea marcar el pedido como 'Preparado'?", function () {  
      notifier.notify('success', 'Pedido finalizado.');
    });
  }

  onDeleteClick(id: string) {
    console.log(id);
    let notifier = this.notifierService;
    this.confirmDialogService.showConfirm("Desea anular el pedido?", function () {  
      notifier.notify('success', 'Pedido anulado con éxito.');
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
        },
      },
      ajax: (dataTablesParameters: any, callback) => {
        //this.httpClient
        //  .post<DataTablesResponse>(
        //    this.connectService.URL + 'read_records_dt.php',
        //    dataTablesParameters, {}
        //  ).subscribe(resp => {
        //    this.Members = resp.data;
        //    this.NumberOfMembers = resp.data.length;
        //    $('.dataTables_length>label>select, .dataTables_filter>label>input').addClass('form-control-sm');
        //    callback({
        //      recordsTotal: resp.recordsTotal,
        //      recordsFiltered: resp.recordsFiltered,
        //      data: []
        //    });
        //    if (this.NumberOfMembers > 0) {
        //      $('.dataTables_empty').css('display', 'none');
        //    }
        //  }
        //  );
        this.Pedidos = [
          {
            encrypted_id: "asddas123132",
            numero: "00001928",
            remito: "RTO 0001-00298894",
            venta_encrypted_id: "asddas123132",
            numeroVenta: "VTA 00001204",
            factura: "FCB 0001-03289200",
            cliente: "Veterinaria Del Carmen",
            fechaHora: new Date('2020-12-28T20:30:54'),
            usuario: "German",
            estado: "Pendiente",
            prepared: false
          },
          {
            encrypted_id: "asddas123132",
            numero: "00001928",
            remito: "RTO 0001-00298893",
            venta_encrypted_id: "asddas123132",
            numeroVenta: "VTA 00001203",
            factura: "FCB 0001-03289199",
            cliente: "Veterinaria Del Carmen",
            fechaHora: new Date('2020-12-28T20:30:54'),
            usuario: "German",
            estado: "En preparación",
            prepared: false
          },
          {
            encrypted_id: "asddas123132",
            numero: "00001928",
            remito: "RTO 0001-00298893",
            venta_encrypted_id: "",
            numeroVenta: "",
            factura: "",
            cliente: "Veterinaria 24hs San Justo",
            fechaHora: new Date('2020-12-28T20:30:54'),
            usuario: "German",
            estado: "En preparación",
            prepared: false
          },
          {
            encrypted_id: "asddas123132",
            numero: "00001931",
            remito: "RTO 0001-00298896",
            venta_encrypted_id: "",
            numeroVenta: "",
            factura: "",
            cliente: "Veterinaria 24hs San Justo",
            fechaHora: new Date('2020-12-28T20:30:54'),
            usuario: "German",
            estado: "Entregado",
            prepared: true
          },
        ];
        callback({
          recordsTotal: this.Pedidos.length,
          recordsFiltered: this.Pedidos.length,
          data: [] //Siempre vacío para delegarle el render a Angular
        });
        if (this.Pedidos.length > 0) {
          $('.dataTables_empty').hide();
        }
        else {
          $('.dataTables_empty').show();
        }
        setTimeout(function() {
          (<any>$("tbody tr").find('[data-toggle="tooltip"]')).tooltip();
        }, 300);
      },
      columns: [
        { data: 'name' }
      ]
    };
  }

}
