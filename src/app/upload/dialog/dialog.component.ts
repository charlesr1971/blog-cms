import { Component, OnInit, ViewChild } from '@angular/core';
import { MatDialogRef } from '@angular/material';
import { UploadService } from '../upload.service';
import { forkJoin } from 'rxjs/observable/forkJoin';
import { DeviceDetectorService } from 'ngx-device-detector';

import { HttpService } from '../../services/http/http.service';

@Component({
  selector: 'app-dialog',
  templateUrl: './dialog.component.html',
  styleUrls: ['./dialog.component.css']
})
export class DialogComponent implements OnInit {

  @ViewChild('file') file;
  @ViewChild('filename') filename;
  
  public files: Set<File> = new Set();
  progress;
  canBeClosed = true; 
  primaryButtonText = 'Submit';
  showCancelButton = true; 
  uploading = false;
  uploadSuccessful = false;
  maxfilelimitreached = false;
  isMobile: boolean = false;

  debug: boolean = false;

  constructor(public dialogRef: MatDialogRef<DialogComponent>, 
    private deviceDetectorService: DeviceDetectorService,
    private httpService: HttpService,
    public uploadService: UploadService) {

      this.isMobile = this.deviceDetectorService.isMobile();

  }

  ngOnInit() {

    this.uploadService.subscriptionImageError.subscribe( (data: any) => {
      if(this.debug) {
        console.log('dialog.component: subscriptionImageError: data', data);
      }
      this.dialogRef.close();
    });

    this.httpService.galleryImageAdded.subscribe( (data: any) => {
      if(this.debug) {
        console.log('dialog.component: galleryImageAdded: data', data);
      }
      this.dialogRef.close();
    });
    
  }

  onFilesAdded(): void {
    const files: { [key: string]: File } = this.file.nativeElement.files;
    for (const key in files) {
      if (!isNaN(parseInt(key,10))) {
        this.files.add(files[key]);
        this.maxfilelimitreached = true;
      }
    }
  }

  addFiles(): void {
    this.file.nativeElement.click();
  }
  
  closeDialog(): any {
    // if everything was uploaded already, just close the dialog
    if (this.uploadSuccessful) {
      return this.dialogRef.close();
    }
  
    // set the component state to "uploading"
    this.uploading = true;
  
    // start the upload and save the progress map
    this.progress = this.uploadService.upload(this.files);
  
    // convert the progress map into an array
    const allProgressObservables = [];
    for (const key in this.progress) {
      if (this.progress.hasOwnProperty(key)) {
        allProgressObservables.push(this.progress[key].progress);
      }
    }
  
    // Adjust the state variables
  
    // The OK-button should have the text "Finish" now
    this.primaryButtonText = 'Finish';
  
    // The dialog should not be closed while uploading
    this.canBeClosed = false;
    this.dialogRef.disableClose = true;
  
    // Hide the cancel-button
    this.showCancelButton = false;
  
    // When all progress-observables are completed...
    forkJoin(allProgressObservables).subscribe(end => {
      // ... the dialog can be closed again...
      this.canBeClosed = true;
      this.dialogRef.disableClose = false;
  
      // ... the upload was successful...
      this.uploadSuccessful = true;
  
      // ... and the component is no longer uploading
      this.uploading = false;
    });
  }

}
