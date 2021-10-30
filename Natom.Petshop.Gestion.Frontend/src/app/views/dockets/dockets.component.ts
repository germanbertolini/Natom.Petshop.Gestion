import { HttpClient } from "@angular/common/http";
import { Component, Input, OnInit, ViewChild } from "@angular/core";
import { Router } from "@angular/router";
import { NotifierService } from "angular-notifier";
import { Docket } from "src/app/classes/models/docket.model";
import { DataTablesResponse } from '../../classes/data-tables-response';
import { ConfirmDialogService } from "../../components/confirm-dialog/confirm-dialog.service";

@Component({
  selector: 'app-dockets',
  templateUrl: './dockets.component.html'
})
export class DocketsComponent implements OnInit {  
  dtDockets: DataTables.Settings = {};
  Dockets: Docket[];
  Noty: any;

  constructor(private httpClientService: HttpClient,
              private routerService: Router,
              private notifierService: NotifierService,
              private confirmDialogService: ConfirmDialogService) {
                
  }

  onReportWorkedHoursClick(id: string) {
    this.routerService.navigate(['/reports/worked-hours/by_docket/' + id]);
  }

  onEditClick(id: string) {
    this.routerService.navigate(['/dockets/edit/' + id]);
  }

  onDeleteClick(id: string) {
    console.log(id);
    let notifier = this.notifierService;
    this.confirmDialogService.showConfirm("Desea eliminar el legajo?", function () {  
      notifier.notify('success', 'Legajo eliminado con éxito.');
    });
  }

  ngOnInit(): void {

    this.dtDockets = {
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
        this.Dockets = [
          {
            encrypted_id: "231987213987987",
            docket_number: "10001",
            employee_first_name: "Eduardo",
            employee_last_name: "Alsina",
            employee_dni: "24.287.129",
            employee_title: "Jefe de mantenimiento"
          },
          {
            encrypted_id: "3198xcnn8xnbn",
            docket_number: "10002",
            employee_first_name: "Ramiro",
            employee_last_name: "Garcia",
            employee_dni: "30.282.123",
            employee_title: "Manufactura"
          },
          {
            encrypted_id: "3198xcnn8xnbn",
            docket_number: "10002",
            employee_first_name: "Ramiro",
            employee_last_name: "Garcia",
            employee_dni: "30.282.123",
            employee_title: "Manufactura"
          }
        ];
        callback({
          recordsTotal: this.Dockets.length,
          recordsFiltered: this.Dockets.length,
          data: [] //Siempre vacío para delegarle el render a Angular
        });
        if (this.Dockets.length > 0) {
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
        { data: 'docket_number' },
        { data: 'employee_first_name' },
        { data: "employee_last_name" },
        { data: 'employee_dni' },
        { data: 'employee_title' }
      ]
    };
  }

}
