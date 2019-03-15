import { Injectable } from '@angular/core';
import { CookieService } from 'ngx-cookie-service';

@Injectable({
  providedIn: 'root'
})
export class JwtService {

  constructor(private cookieService: CookieService) { }

  public setJwtToken(jwtToken: string): void {
    localStorage.setItem('jwtToken',jwtToken);
    const expired = new Date();
    expired.setDate(expired.getDate() + 365);
    this.cookieService.set('jwtToken', jwtToken, expired);
  } 

  public getJwtToken(): string {
    let token = localStorage.getItem('jwtToken');
    if((!token || (token && token === '')) && this.cookieService.check('jwtToken')) {
      token = this.cookieService.get('jwtToken');
    }
    return token || '';
  } 

  public removeJwtToken(): void {
    localStorage.removeItem('jwtToken');
    if(this.cookieService.check('jwtToken')) {
      this.cookieService.delete('jwtToken');
    }
  } 

}
