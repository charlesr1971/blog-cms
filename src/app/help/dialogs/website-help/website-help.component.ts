import { Component, OnInit, Inject, ViewChild, ElementRef, Renderer2, HostListener } from '@angular/core';
import {MAT_DIALOG_DATA, MatDialogRef} from '@angular/material';
import { DeviceDetectorService } from 'ngx-device-detector';

import { HttpService } from '../../../services/http/http.service';

import { environment } from '../../../../environments/environment';

declare var TweenMax: any, Elastic: any;

@Component({
  selector: 'app-website-help',
  templateUrl: './website-help.component.html',
  styleUrls: ['./website-help.component.css']
})
export class WebsiteHelpComponent implements OnInit {

  @ViewChild('dialogWebsiteHelpNotificationText') dialogWebsiteHelpNotificationText: ElementRef;

  isMobile: boolean = false;
  disableWebsiteTooltip: boolean = false;

  debug: boolean = false;

  constructor(private dialogRef: MatDialogRef<WebsiteHelpComponent>,
    @Inject(MAT_DIALOG_DATA) data,
    private httpService: HttpService,
    private renderer: Renderer2,
    private deviceDetectorService: DeviceDetectorService) { 

      if(environment.debugComponentLoadingOrder) {
        console.log('WebsiteHelpComponent.component loaded');
      }

      this.isMobile = this.deviceDetectorService.isMobile();

      if(this.isMobile) {
        this.disableWebsiteTooltip = true;
      }


    }

  ngOnInit() {

    if(environment.debugComponentLoadingOrder) {
      console.log('websiteHelpComponent.component init');
    }

    setTimeout( () => {

      this.httpService.websiteDialogOpened.subscribe( (height: number) => {
        if(this.debug) {
          console.log('websiteHelpComponent.component: ngOnInit: height: ', height);
        }
        this.renderer.setStyle(this.dialogWebsiteHelpNotificationText.nativeElement,'height',height + 'px');
        const parent = document.querySelector('#dialog-website-help-notification-container');
        if(parent) {
          TweenMax.fromTo(parent, 1, {ease:Elastic.easeOut, opacity: 0}, {ease:Elastic.easeOut, opacity: 1});
        }
      });

    });

  }

  @HostListener('mousedown', ['$event'])
  onMouseDown(event: MouseEvent) {
    this.disableWebsiteTooltip = true;
    if(this.debug) {
      console.log('websiteHelpComponent.component: mousedown: this.disableWebsiteTooltip: ',this.disableWebsiteTooltip);
    }
  }

  @HostListener('mouseup', ['$event'])
  onMouseUp(event: MouseEvent) {
    this.disableWebsiteTooltip = false;
    if(this.debug) {
      console.log('websiteHelpComponent.component: mouseup: this.disableWebsiteTooltip: ',this.disableWebsiteTooltip);
    }
  }

  closeWebsiteHelpNotificationDialog() {
    this.dialogRef.close();
  }

}
