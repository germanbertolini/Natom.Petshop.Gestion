import { HttpClient } from "@angular/common/http";
import { Component, OnInit } from "@angular/core";
import { ActivatedRoute, Router } from "@angular/router";
import { NotifierService } from "angular-notifier";
import { DeviceSyncConfig } from "src/app/classes/models/device.sync_config.model";
import { CRUDView } from "src/app/classes/views/crud-view.classes";
import { ConfirmDialogService } from "src/app/components/confirm-dialog/confirm-dialog.service";

@Component({
  selector: 'app-devices-sync-config',
  styleUrls: ['./devices-sync-config.component.css'],
  templateUrl: './devices-sync-config.component.html'
})

export class DevicesSyncConfigComponent implements OnInit {
  crud: CRUDView<DeviceSyncConfig>;
  dtDevices: DataTables.Settings = {};

  constructor(private httpClientService: HttpClient,
              private routerService: Router,
              private routeService: ActivatedRoute,
              private notifierService: NotifierService,
              private confirmDialogService: ConfirmDialogService) {

    this.crud = new CRUDView<DeviceSyncConfig>(routeService);
    this.crud.model = new DeviceSyncConfig();

    //MOCK
    this.crud.model.interval_mins = 5;
    this.crud.model.next_sync = new Date('2021-06-12T06:15:00');
  }

  onCancelClick() {
    this.confirmDialogService.showConfirm("¿Descartar cambios?", function() {
      window.history.back();
    });
  }

  onSaveClick() {
    this.notifierService.notify('success', 'Opciones de sincronización guardadas correctamente.');
    this.routerService.navigate(['/devices']);
  }

  ngOnInit(): void {
    setTimeout(function() {
      (<any>$("#device-crud").find('[data-toggle="tooltip"]')).tooltip();
    }, 300);
  }

}
