import { HttpClient } from "@angular/common/http";
import { Component, Input, OnInit, ViewChild } from "@angular/core";
import { Router } from "@angular/router";
import { NotifierService } from "angular-notifier";
import { DataTablesResponse } from '../../classes/data-tables-response';
import { Device } from "../../classes/models/device.model";
import { ConfirmDialogService } from "../../components/confirm-dialog/confirm-dialog.service";

@Component({
  selector: 'app-devices',
  styleUrls: ['./devices.component.css'],
  templateUrl: './devices.component.html'
})
export class DevicesComponent implements OnInit {
  dtDevices: DataTables.Settings = {};
  Devices: Device[];
  Noty: any;

  constructor(private httpClientService: HttpClient,
              private routerService: Router,
              private notifierService: NotifierService,
              private confirmDialogService: ConfirmDialogService) {
    
  }

  onEditClick(id: string) {
    this.routerService.navigate(['/devices/edit/' + id]);
  }

  onDeleteClick(id: string) {
    console.log(id);
    let notifier = this.notifierService;
    this.confirmDialogService.showConfirm("Desea eliminar el dispositivo?", function () {  
      notifier.notify('success', 'Dispositivo eliminado con éxito.');
    });
  }

  ngOnInit(): void {

    this.dtDevices = {
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
        this.Devices = [
          {
            nombre: "Portería 1 - Lector 1",
            device_id: "21987",
            device_ip: "127.0.0.1",
            device_user: "admin",
            device_pass: "1234",
            status: "Activo",
            status_is_online: true,
            encrypted_id: "23498n7234v987h4v2",
            location: "Planta San Justo"
          },
          {
            nombre: "Portería 1 - Lector 2",
            device_id: "32487",
            device_ip: "127.0.0.2",
            device_user: "admin",
            device_pass: "1234",
            status: "Desconectado",
            status_is_online: false,
            encrypted_id: "c3187693c1879b987",
            location: "Planta San Justo"
          },
          {
            nombre: "Portería 2 - Lector 1",
            device_id: "43987",
            device_ip: "127.0.0.3",
            device_user: "admin",
            device_pass: "1234",
            status: "Activo",
            status_is_online: true,
            encrypted_id: "987b2498724398bc",
            location: "Planta San Justo"
          },
        ];
        callback({
          recordsTotal: this.Devices.length,
          recordsFiltered: this.Devices.length,
          data: [] //Siempre vacío para delegarle el render a Angular
        });
        if (this.Devices.length > 0) {
          $('.dataTables_empty').hide();
        }
        else {
          $('.dataTables_empty').show();
        }
        setTimeout(function() {
          (<any>$('[data-toggle="tooltip"]')).tooltip();
        }, 300);
      },
      columns: [
        { data: 'nombre' },
        { data: 'device_id' },
        { data: 'estado' },
        { data: "encrypted_id" }
      ]
    };
  }

}
