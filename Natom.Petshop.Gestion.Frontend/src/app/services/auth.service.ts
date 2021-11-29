import { HttpHeaders } from '@angular/common/http';
import { toBase64String } from '@angular/compiler/src/output/source_map';
import { Injectable } from '@angular/core';
import { CookieService } from 'ngx-cookie-service';
import { HandledError } from '../classes/errors/handled.error';
import { LoginResult } from '../classes/models/auth/login-result.model';
import { ApiResult } from '../classes/models/shared/api-result.model';
import { User } from "../classes/models/user.model";
import { ApiService } from './api.service';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private _current_user: User;
  private _current_token: string;
  private _current_permissions: Array<string>;
  
  constructor(private cookieService: CookieService, private apiService: ApiService) {
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

  public Login(email: string, password: string, onSuccess: () => void, onError: (errorMessage: string) => void) {
    let response = new ApiResult<LoginResult>();
    let headers = new HttpHeaders();
    headers = headers.append('Authorization', 'Basic ' + btoa(email + ":" + password));

    this.apiService.DoPOST<ApiResult<LoginResult>>("auth/login", {}, headers,
                      (response) => {
                        if (!response.success) {
                          onError(response.message);
                        }
                        else {
                          this._current_user = response.data.user;
                          this._current_token = response.data.token;
                          this._current_permissions = response.data.permissions.map(function(permission) {
                            return permission.toLowerCase();
                          });

                          this.cookieService.set('Auth.Current.User', JSON.stringify(this._current_user));
                          this.cookieService.set('Auth.Current.Token', JSON.stringify(this._current_token));
                          this.cookieService.set('Auth.Current.Permissions', JSON.stringify(this._current_permissions));

                          onSuccess();
                        }
                      },
                      (errorMessage) => {
                        onError(errorMessage);
                      });
  }
}
