import { Component } from '@angular/core';
import { MatDialog } from '@angular/material';
import { DialogComponent } from './dialog/dialog.component';
import { updateCdkOverlayThemeClass } from '../util/updateCdkOverlayThemeClass';

import { CookieService } from 'ngx-cookie-service';
import { DeviceDetectorService } from 'ngx-device-detector';
import { UploadService } from './upload.service';
import { HttpService } from '../services/http/http.service';

import { environment } from '../../environments/environment';

@Component({
  selector: 'app-upload',
  templateUrl: './upload.component.html',
  styleUrls: ['./upload.component.css']
})
export class UploadComponent {

  isMobile: boolean = false;
  isValid: boolean = false;
  chooseImageButtonText: string = 'Choose Image';
  themeObj = {};
  themeRemove: string = '';

  debug: boolean = false;

  constructor(public dialog: MatDialog, 
    public uploadService: UploadService,
    private cookieService: CookieService,
    private deviceDetectorService: DeviceDetectorService,
    private httpService: HttpService) {

      if(environment.debugComponentLoadingOrder) {
        console.log('upload.service loaded');
      }

      const themeObj = this.httpService.themeObj;
      this.themeRemove = this.cookieService.check('theme') && this.cookieService.get('theme') == themeObj['light'] ? themeObj['dark'] : themeObj['light'];

      this.isMobile = this.deviceDetectorService.isMobile();

      this.httpService.subjectImagePath.subscribe( (data: any) => {
        if(this.debug) {
          console.log('upload.service: data: ',data);
        }
        if(data['imagePath'] !== '' && data['name'] !== '' && data['title'] !== '' || data['uploadType'] === 'avatar') {
          this.isValid = true;
        }
      });

      this.httpService.chooseImageButtonText.subscribe( (data: any) => {
        if(data !== '') {
          this.chooseImageButtonText = data;
        }
      });
      
    }

  public openUploadDialog(): void {
    const dialogRef = this.dialog.open(DialogComponent, { 
      width: this.isMobile ? '90%' :'50%', 
      height: this.isMobile ? '60%' :'50%' 
    });
    updateCdkOverlayThemeClass(this.themeRemove);
    this.uploadService.subscriptionImageError.next('');
  }

}
