import { Injectable } from '@angular/core';
import { HttpEvent, HttpInterceptor, HttpHandler, HttpRequest, HttpHeaders } from '@angular/common/http';
import { JwtService } from '../../services/jwt/jwt.service';
import { CookieService } from 'ngx-cookie-service';

import { Observable } from 'rxjs';

import { HttpService } from '../../services/http/http.service';

@Injectable()
export class AuthInterceptor implements HttpInterceptor {

    constructor(private jwtService: JwtService,
        private cookieService: CookieService,
        private httpService: HttpService) { 
    }

    intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
        const jwtToken = this.jwtService.getJwtToken();
        if (jwtToken) {
            const cloned = req.clone({
                headers: req.headers.set('Authorization','Bearer ' + jwtToken).set('userToken',this.cookieService.get('userToken'))
            });
            return next.handle(cloned);
        }
        else {
            return next.handle(req);
        }
    }
    
}
