import { HttpClient } from "@angular/common/http";
import { Component, Input, OnInit, ViewChild } from "@angular/core";
import { Router } from "@angular/router";
import { NotifierService } from "angular-notifier";
import { PrecioList } from "src/app/classes/models/precios/precio-list.model";
import { DataTableDTO } from '../../classes/data-table-dto';
import { ConfirmDialogService } from "../../components/confirm-dialog/confirm-dialog.service";

@Component({
  selector: 'app-precios',
  styleUrls: ['./precios.component.css'],
  templateUrl: './precios.component.html'
})
export class PreciosComponent implements OnInit {

  dtIndex: DataTables.Settings = {};
  Precios: PrecioList[];
  Noty: any;

  constructor(private httpClientService: HttpClient,
              private routerService: Router,
              private notifierService: NotifierService,
              private confirmDialogService: ConfirmDialogService) {
                
  }

  onFiltroEstadoChange(newValue: string) {
    console.log(newValue);
  }

  onFiltroListaDePreciosChange(newValue: string) {
    console.log(newValue);
  }

  onRenewClick(id: string) {
    this.routerService.navigate(['/precios/renew/' + id]);
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
        this.Precios = [
          {
            encrypted_id: "asddas123132",
            codigo: "RCA2983",
            descripcion: "Royal Canin Weight Control 15KG",
            precio: 5706.23,
            listaDePrecios: "Lista de precios 1",
            aplicaDesdeFechaHora: new Date('2020-12-28T20:30:54'),
            aplicaDesdeDias: 315
          },
          {
            encrypted_id: "asddas123132",
            codigo: "RCA2983",
            descripcion: "VitalCan mordida pequeña 3KG",
            precio: 2305.40,
            listaDePrecios: "Lista de precios 3",
            aplicaDesdeFechaHora: new Date('2021-11-02T20:30:54'),
            aplicaDesdeDias: 7
          }
        ];
        callback({
          recordsTotal: this.Precios.length,
          recordsFiltered: this.Precios.length,
          data: [] //Siempre vacío para delegarle el render a Angular
        });
        if (this.Precios.length > 0) {
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
