import { HttpClient, HttpErrorResponse, HttpHeaders } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { CookieService } from "ngx-cookie-service";
import { Observable } from "rxjs";
import { AuthService } from "./auth.service";
import { JsonAppConfigService } from "./json-app-config.service";

@Injectable({
    providedIn: 'root'
  })
export class ApiService {

    constructor(private jsonAppConfig: JsonAppConfigService, private httpClient: HttpClient, private cookieService: CookieService) {

    }

    public DoPOST<TResponse>(relativeUrl: string, body: any, headers: HttpHeaders = null, onSuccess: (response: TResponse) => void, onError: (errorMessage: string) => void) {
        if (headers === null)
            headers = new HttpHeaders();

        let token = this.cookieService.get('Auth.Current.Token');
        if (!headers.has("Authorization") && token !== "")
            headers = headers.append("Authorization", "Bearer " + token);


        this.httpClient
                .post(this.jsonAppConfig.baseURL + relativeUrl, body, { headers: headers })
                .subscribe({
                    next: response => {
                        onSuccess(<TResponse>response);
                    },
                    error: error => {
                        onError(error.message);
                    }
                });
    }
}