import { Component, OnInit } from '@angular/core';

import { HttpService } from '../../services/http/http.service';

import { environment } from '../../../environments/environment';

@Component({
  selector: 'app-upload-photo',
  templateUrl: './upload-photo.component.html',
  styleUrls: ['./upload-photo.component.css']
})
export class UploadPhotoComponent implements OnInit {

  constructor(private httpService: HttpService) {

    if(environment.debugComponentLoadingOrder) {
      console.log('uploadPhoto.component loaded');
    }

    if(this.httpService.currentUserAuthenticated > 0) {
      this.httpService.fetchJwtData();
    }

  }

  ngOnInit() {

    if(environment.debugComponentLoadingOrder) {
      console.log('uploadPhoto.component init');
    }

  }

}
