import { HttpClient } from "@angular/common/http";
import { Component, OnInit } from "@angular/core";
import { ActivatedRoute, Router } from "@angular/router";
import { NotifierService } from "angular-notifier";
import { MarcaDTO } from "src/app/classes/dto/marca.dto";
import { CRUDView } from "src/app/classes/views/crud-view.classes";
import { ConfirmDialogService } from "src/app/components/confirm-dialog/confirm-dialog.service";
import { DataTableDTO } from "../../../classes/data-table-dto";

@Component({
  selector: 'app-marca-crud',
  styleUrls: ['./marca-crud.component.css'],
  templateUrl: './marca-crud.component.html'
})

export class MarcaCrudComponent implements OnInit {

  crud: CRUDView<MarcaDTO>;

  constructor(private httpClientService: HttpClient,
              private routerService: Router,
              private routeService: ActivatedRoute,
              private notifierService: NotifierService,
              private confirmDialogService: ConfirmDialogService) {
                
    this.crud = new CRUDView<MarcaDTO>(routeService);
    this.crud.model = new MarcaDTO();
  }

  onCancelClick() {
    this.confirmDialogService.showConfirm("¿Descartar cambios?", function() {
      window.history.back();
    });
  }

  onSaveClick() {
    this.notifierService.notify('success', 'Marca guardada correctamente.');
    this.routerService.navigate(['/marcas']);
  }

  ngOnInit(): void {

    setTimeout(function() {
      (<any>$("#title-crud").find('[data-toggle="tooltip"]')).tooltip();
    }, 300);
    
  }

}
