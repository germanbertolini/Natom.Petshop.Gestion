import { HttpClient } from "@angular/common/http";
import { Component, OnInit } from "@angular/core";
import { ActivatedRoute, Router } from "@angular/router";
import { NotifierService } from "angular-notifier";
import { MovimientoCajaDiariaDTO } from "src/app/classes/dto/cajas/movimiento-caja-diaria.dto";
import { ApiResult } from "src/app/classes/dto/shared/api-result.dto";
import { CRUDView } from "src/app/classes/views/crud-view.classes";
import { ConfirmDialogService } from "src/app/components/confirm-dialog/confirm-dialog.service";
import { ApiService } from "src/app/services/api.service";
import { AuthService } from "src/app/services/auth.service";

@Component({
  selector: 'app-caja-diaria-new-crud',
  styleUrls: ['./caja-diaria-new.component.css'],
  templateUrl: './caja-diaria-new.component.html'
})

export class CajaDiariaNewComponent implements OnInit {
  crud: CRUDView<MovimientoCajaDiariaDTO>;

  constructor(private apiService: ApiService,
              private authService: AuthService,
              private routerService: Router,
              private routeService: ActivatedRoute,
              private notifierService: NotifierService,
              private confirmDialogService: ConfirmDialogService) {
                
    this.crud = new CRUDView<MovimientoCajaDiariaDTO>(routeService);
    this.crud.model = new MovimientoCajaDiariaDTO();
    this.crud.model.tipo = "";
    this.crud.model.usuarioNombre = authService.getCurrentUser().first_name;
  }

  onCancelClick() {
    this.confirmDialogService.showConfirm("¿Descartar cambios?", function() {
      window.history.back();
    });
  }

  onSaveClick() {
    if (this.crud.model.tipo === "")
    {
      this.confirmDialogService.showError("Debes seleccionar el Tipo de movimiento.");
      return;
    }

    if (this.crud.model.importe === undefined)
    {
      this.confirmDialogService.showError("Debes ingresar el monto.");
      return;
    }

    if (this.crud.model.importe <= 0)
    {
      this.confirmDialogService.showError("Debes ingresar un monto válido.");
      return;
    }

    if (this.crud.model.observaciones === undefined || this.crud.model.observaciones === "")
    {
      this.confirmDialogService.showError("Debes ingresar una observación.");
      return;
    }

    this.apiService.DoPOST<ApiResult<MovimientoCajaDiariaDTO>>("cajas/diaria/save", this.crud.model, /*headers*/ null,
      (response) => {
        if (!response.success) {
          this.confirmDialogService.showError(response.message);
        }
        else {
          this.notifierService.notify('success', 'Movimiento guardado correctamente.');
          this.routerService.navigate(['/cajas/diaria']);
        }
      },
      (errorMessage) => {
        this.confirmDialogService.showError(errorMessage);
      });
  }

  ngOnInit(): void {

    setTimeout(function() {
      (<any>$("#title-crud").find('[data-toggle="tooltip"]')).tooltip();
    }, 300);
    
  }

}
