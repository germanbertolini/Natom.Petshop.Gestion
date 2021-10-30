import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { ConfirmDialogService } from 'src/app/components/confirm-dialog/confirm-dialog.service';
import { AuthService } from 'src/app/services/auth.service';

@Component({
  selector: 'app-login',
  styleUrls: ['./login.component.css'],
  templateUrl: './login.component.html'
})
export class LoginComponent {
    private email : string = "";
    private password : string = "";

    constructor(private _authService: AuthService,
                        private _router: Router,
                        private _confirmDialogService: ConfirmDialogService) {

    }

    onLoginClick() {
        try
        {
            this._authService.Login(this.email, this.password);
            this._router.navigate(['/']);
        }
        catch (error)
        {
            this._confirmDialogService.showError(error.message);
            this.password = "";
        }
    }
}