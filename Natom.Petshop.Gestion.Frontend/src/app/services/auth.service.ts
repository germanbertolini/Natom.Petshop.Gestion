import { Injectable } from '@angular/core';
import { CookieService } from 'ngx-cookie-service';
import { HandledError } from '../classes/errors/handled.error';
import { LoginResult } from '../classes/models/auth/login-result.model';
import { ApiResult } from '../classes/models/shared/api-result.model';
import { User } from "../classes/models/user.model";

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private _current_user: User;
  private _current_token: string;
  private _current_permissions: Array<string>;
  
  constructor(private cookieService: CookieService) {
    this._current_user = null;
    this._current_token = null;
    this._current_permissions = null;

    let userCookieData = this.cookieService.get('Auth.Current.User');
    if (userCookieData.length > 0) this._current_user = JSON.parse(userCookieData);
    
    let tokenCookieData = this.cookieService.get('Auth.Current.Token');
    if (tokenCookieData.length > 0) this._current_token = JSON.parse(tokenCookieData);

    let permissionsCookieData = this.cookieService.get('Auth.Current.Permissions');
    if (permissionsCookieData.length > 0) this._current_permissions = JSON.parse(permissionsCookieData);
  }

  public getCurrentUser() {
    return this._current_user;
  }

  public getCurrentToken() {
    return this._current_token;
  }

  public getCurrentPermissions() {
    return this._current_permissions;
  }

  public Login(email: string, password: string): LoginResult {
    //MOCK RESPUESTA API
    let response = new ApiResult<LoginResult>();
    if (email === "admin" && password === "admin") {
      response.success = true;
      response.message = null;
      
      response.data = new LoginResult();

      response.data.User = new User();
      response.data.User.encrypted_id = "adssdadas123e213132";
      response.data.User.first_name = "German";
      response.data.User.last_name = "Bertolini";
      response.data.User.picture_url = "https://electronicssoftware.net/wp-content/uploads/user.png";
      response.data.User.email = "admin@bioanvizplus.com";
      response.data.User.registered_at = new Date('2020-12-28T00:00:00');
      response.data.User.business_name = "BioAnviz+";
      response.data.User.business_role_name = "Administrador";
      response.data.User.country_icon = "arg";
      response.data.Token = "98cb7b439xbx349c8273bc98b73c48927c9";

      response.data.Permissions = new Array<string>();
      response.data.Permissions.push("/");
      response.data.Permissions.push("/queries/1/a");
      response.data.Permissions.push("/queries/1/b");
    }
    else {
      response.success = false;
      response.message = "Usuario y/o clave inválida.";
      response.data = null;
    }
    //FIN MOCK RESPUESTA API

    if (!response.success)
      throw new HandledError(response.message);
      
    this._current_user = response.data.User;
    this._current_token = response.data.Token;
    this._current_permissions = response.data.Permissions.map(function(permission) {
      return permission.toLowerCase();
    });

    this.cookieService.set('Auth.Current.User', JSON.stringify(this._current_user));
    this.cookieService.set('Auth.Current.Token', JSON.stringify(this._current_token));
    this.cookieService.set('Auth.Current.Permissions', JSON.stringify(this._current_permissions));

    return response.data;
  }
}
