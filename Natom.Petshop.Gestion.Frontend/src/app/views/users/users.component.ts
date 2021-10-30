import { HttpClient } from "@angular/common/http";
import { Component, Input, OnInit, ViewChild } from "@angular/core";
import { Router } from "@angular/router";
import { NotifierService } from "angular-notifier";
import { User } from "src/app/classes/models/user.model";
import { DataTablesResponse } from '../../classes/data-tables-response';
import { ConfirmDialogService } from "../../components/confirm-dialog/confirm-dialog.service";

@Component({
  selector: 'app-users',
  templateUrl: './users.component.html'
})
export class UsersComponent implements OnInit {

  dtUsers: DataTables.Settings = {};
  Users: User[];
  Noty: any;

  constructor(private httpClientService: HttpClient,
              private routerService: Router,
              private notifierService: NotifierService,
              private confirmDialogService: ConfirmDialogService) {
                
  }

  onEditClick(id: string) {
    this.routerService.navigate(['/users/edit/' + id]);
  }

  onDeleteClick(id: string) {
    console.log(id);
    let notifier = this.notifierService;
    this.confirmDialogService.showConfirm("Desea eliminar el usuario?", function () {  
      notifier.notify('success', 'Usuario eliminado con éxito.');
    });
  }

  ngOnInit(): void {

    this.dtUsers = {
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
        this.Users = [
          {
            encrypted_id: "asddas123132",
            first_name: "German",
            last_name: "Bertolini",
            email: "german.bertolini@gmail.com",
            registered_at: new Date('2020-12-28T00:00:00'),
            business_role_name: "Administrador",
            picture_url: "",
            business_name: "",
            country_icon: ""
          },
          {
            encrypted_id: "2398n23984n",
            first_name: "Gaston",
            last_name: "Sanchez",
            email: "gaston.sanchez@gmail.com",
            registered_at: new Date('2019-02-26T00:00:00'),
            business_role_name: "Administrador",
            picture_url: "",
            business_name: "",
            country_icon: ""
          },
          {
            encrypted_id: "13d2123",
            first_name: "Mariano",
            last_name: "Anello",
            email: "mariano.anello@gmail.com",
            registered_at: new Date('2019-08-10T00:00:00'),
            business_role_name: "Administrador",
            picture_url: "",
            business_name: "",
            country_icon: ""
          },
          {
            encrypted_id: "c424c2423243",
            first_name: "Pedro",
            last_name: "Lopez",
            email: "plopez@hotmail.com",
            registered_at: new Date('2019-10-19T00:00:00'),
            business_role_name: "Operador",
            picture_url: "",
            business_name: "",
            country_icon: ""
          },
          {
            encrypted_id: "24098jsda",
            first_name: "Diana",
            last_name: "Gutierrez",
            email: "dguti@outlook.com.ar",
            registered_at: new Date('2019-10-19T00:00:00'),
            business_role_name: "Operador",
            picture_url: "",
            business_name: "",
            country_icon: ""
          }
        ];
        callback({
          recordsTotal: this.Users.length,
          recordsFiltered: this.Users.length,
          data: [] //Siempre vacío para delegarle el render a Angular
        });
        if (this.Users.length > 0) {
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
        { data: 'first_name' },
        { data: 'last_name' },
        { data: "email" },
        { data: 'registered_at' },
        { data: 'business_role_name' }
      ]
    };
  }

}
