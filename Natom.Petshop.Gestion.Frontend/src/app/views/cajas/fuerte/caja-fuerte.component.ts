import { HttpClient } from "@angular/common/http";
import { Component, Input, OnInit, ViewChild } from "@angular/core";
import { Router } from "@angular/router";
import { NotifierService } from "angular-notifier";
import { MarcaDTO } from "src/app/classes/dto/marca.dto";
import { MovimientoCajaFuerteDTO } from "src/app/classes/dto/cajas/movimiento-caja-fuerte.dto";
import { DataTableDTO } from "src/app/classes/data-table-dto";
import { ConfirmDialogService } from "../../../components/confirm-dialog/confirm-dialog.service";

@Component({
  selector: 'app-caja-fuerte',
  styleUrls: ['./caja-fuerte.component.css'],
  templateUrl: './caja-fuerte.component.html'
})
export class CajaFuerteComponent implements OnInit {

  dtIndex: DataTables.Settings = {};
  Movimientos: MovimientoCajaFuerteDTO[];
  saldoActual: number;
  filtroFecha: string;
  Noty: any;

  decideClosure(event, datepicker) { const path = event.path.map(p => p.localName); if (!path.includes('ngb-datepicker')) { datepicker.close(); } }

  constructor(private httpClientService: HttpClient,
              private routerService: Router,
              private notifierService: NotifierService,
              private confirmDialogService: ConfirmDialogService) {
                
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
            fechaHora: new Date('2020-12-28T20:30:54'),
            usuarioNombre: "German",
            tipo: "Ingreso",
            importe: 1030.54,
            observaciones: "Venta Nro 380289 /// FCB 0001-29804802"
          },
          {
            encrypted_id: "asddas123133",
            fechaHora: new Date('2020-12-28T22:00:00'),
            usuarioNombre: "German",
            tipo: "Egreso",
            importe: 100.54,
            observaciones: "Cierre caja /// Transferencia de saldo a caja diaria"
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
