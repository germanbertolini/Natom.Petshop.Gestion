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

    public DoGETWithObservable(relativeUrl: string, headers: HttpHeaders = null) : Observable<Object> {
        headers = this.SetAPIHeaders(headers);
        return this.httpClient.get(this.jsonAppConfig.baseURL + relativeUrl, { headers: headers });
    }
    
    public DoGET<TResponse>(relativeUrl: string, headers: HttpHeaders = null, onSuccess: (response: TResponse) => void, onError: (errorMessage: string) => void) {
        headers = this.SetAPIHeaders(headers);
        this.DoGETWithObservable(relativeUrl, headers)
                .subscribe({
                    next: response => {
                        onSuccess(<TResponse>response);
                    },
                    error: error => {
                        onError(error.message);
                    }
                });
    }

    public DoPOST<TResponse>(relativeUrl: string, body: any, headers: HttpHeaders = null, onSuccess: (response: TResponse) => void, onError: (errorMessage: string) => void) {
        headers = this.SetAPIHeaders(headers);
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

    public DoDELETE<TResponse>(relativeUrl: string, headers: HttpHeaders = null, onSuccess: (response: TResponse) => void, onError: (errorMessage: string) => void) {
        headers = this.SetAPIHeaders(headers);
        this.httpClient
                .delete(this.jsonAppConfig.baseURL + relativeUrl, { headers: headers })
                .subscribe({
                    next: response => {
                        onSuccess(<TResponse>response);
                    },
                    error: error => {
                        onError(error.message);
                    }
                });
    }

    private SetAPIHeaders (headers: HttpHeaders) : HttpHeaders {
        if (headers === null)
            headers = new HttpHeaders();

        let token = atob(this.cookieService.get('Auth.Current.Token'));
        if (!headers.has("Authorization") && token !== "")
            headers = headers.append("Authorization", "Bearer " + token.substring(1, token.length - 1));

        return headers;
    }
}