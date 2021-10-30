import { HttpClient } from "@angular/common/http";
import { Component, Input, OnInit, ViewChild } from "@angular/core";
import { Router } from "@angular/router";
import { NotifierService } from "angular-notifier";
import { Title } from "src/app/classes/models/title.model";
import { User } from "src/app/classes/models/user.model";
import { DataTablesResponse } from '../../classes/data-tables-response';
import { ConfirmDialogService } from "../../components/confirm-dialog/confirm-dialog.service";

@Component({
  selector: 'app-titles',
  templateUrl: './titles.component.html'
})
export class TitlesComponent implements OnInit {

  dtTitles: DataTables.Settings = {};
  Titles: Title[];
  Noty: any;

  constructor(private httpClientService: HttpClient,
              private routerService: Router,
              private notifierService: NotifierService,
              private confirmDialogService: ConfirmDialogService) {
                
  }

  onEditClick(id: string) {
    this.routerService.navigate(['/titles/edit/' + id]);
  }

  onDeleteClick(id: string) {
    console.log(id);
    let notifier = this.notifierService;
    this.confirmDialogService.showConfirm("Desea eliminar el cargo?", function () {  
      notifier.notify('success', 'Cargo eliminado con éxito.');
    });
  }

  ngOnInit(): void {

    this.dtTitles = {
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
        this.Titles = [
          {
            encrypted_id: "asddas123132",
            name: "Jefe de Mantenimiento"
          },
          {
            encrypted_id: "2398n23984n",
            name: "Manufactura"
          }
        ];
        callback({
          recordsTotal: this.Titles.length,
          recordsFiltered: this.Titles.length,
          data: [] //Siempre vacío para delegarle el render a Angular
        });
        if (this.Titles.length > 0) {
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
