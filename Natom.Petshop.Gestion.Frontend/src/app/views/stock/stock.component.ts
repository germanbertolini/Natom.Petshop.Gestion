import { HttpClient } from "@angular/common/http";
import { Component, Input, OnInit, ViewChild } from "@angular/core";
import { Router } from "@angular/router";
import { NotifierService } from "angular-notifier";
import { DataTablesResponse } from '../../classes/data-tables-response';
import { ConfirmDialogService } from "../../components/confirm-dialog/confirm-dialog.service";
import { StockList } from "src/app/classes/models/stock/stock-list.model";

@Component({
  selector: 'app-stock',
  styleUrls: ['./stock.component.css'],
  templateUrl: './stock.component.html'
})
export class StockComponent implements OnInit {

  dtIndex: DataTables.Settings = {};
  Movimientos: StockList[];
  saldoActual: number;
  filtroFecha: string;
  Noty: any;

  decideClosure(event, datepicker) { const path = event.path.map(p => p.localName); if (!path.includes('ngb-datepicker')) { datepicker.close(); } }

  constructor(private httpClientService: HttpClient,
              private routerService: Router,
              private notifierService: NotifierService,
              private confirmDialogService: ConfirmDialogService) {
                
  }

  onFiltroDepositoChange(newValue: string) {
    console.log(newValue);
  }

  onFiltroProductoChange(newValue: string) {
    console.log(newValue);
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
        this.saldoActual = 100.54;
        this.Movimientos = [
          {
            encrypted_id: "asddas123132",
            deposito: "Deposito 1",
            producto: "Royal Canin 15Kg mordida pequeña",
            tipo: "Egreso",
            cantidad: 15,
            stock: 185,
            fechaHora: new Date('2020-12-28T20:30:54'),
            observaciones: "Pedido Nro 54092 /// Venta Nro 380289"
          },
          {
            encrypted_id: "asddas123132",
            deposito: "Deposito 1",
            producto: "Vitalcan Balance 3Kg",
            tipo: "Egreso",
            cantidad: 30,
            stock: 155,
            fechaHora: new Date('2020-12-28T20:32:02'),
            observaciones: "Pedido Nro 54092 /// Venta Nro 380289"
          },
          {
            encrypted_id: "asddas123132",
            deposito: "Deposito 3",
            producto: "Royal Caning 15Kg mordida pequeña",
            tipo: "Ingreso",
            cantidad: 200,
            stock: 200,
            fechaHora: new Date('2020-12-28T20:35:42'),
            observaciones: "Compra Nro 20931"
          },
        ];
        callback({
          recordsTotal: this.Movimientos.length,
          recordsFiltered: this.Movimientos.length,
          data: [] //Siempre vacío para delegarle el render a Angular
        });
        if (this.Movimientos.length > 0) {
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
