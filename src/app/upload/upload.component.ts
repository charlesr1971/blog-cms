import { Component } from '@angular/core';
import { MatDialog } from '@angular/material';
import { DialogComponent } from './dialog/dialog.component';
import { DeviceDetectorService } from 'ngx-device-detector';
import { UploadService } from './upload.service';
import { HttpService } from '../services/http/http.service';

@Component({
  selector: 'app-upload',
  templateUrl: './upload.component.html',
  styleUrls: ['./upload.component.css']
})
export class UploadComponent {

  isMobile: boolean = false;
  isValid: boolean = false;
  chooseImageButtonText: string = 'Choose Image';

  debug: boolean = false;

  constructor(public dialog: MatDialog, 
    public uploadService: UploadService,
    private deviceDetectorService: DeviceDetectorService,
    private httpService: HttpService) {

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
    this.uploadService.subscriptionImageError.next('');
  }

}
