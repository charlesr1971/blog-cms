import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class UtilsService {

  constructor() { }

  isEmpty(obj) {
    for(const key in obj) {
        if(obj.hasOwnProperty(key)) {
            return false;
        }
    }
    return true;
  }
  
}
