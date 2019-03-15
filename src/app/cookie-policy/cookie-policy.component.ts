import { Component, OnInit, Inject, ViewChild, ElementRef, Renderer2 } from '@angular/core';
import {MAT_DIALOG_DATA, MatDialogRef} from "@angular/material";
import { DeviceDetectorService } from 'ngx-device-detector';

import { HttpService } from '../services/http/http.service';

import { environment } from '../../environments/environment';

declare var ease, TweenMax, Elastic: any;

@Component({
  selector: 'app-cookie-policy',
  templateUrl: './cookie-policy.component.html',
  styleUrls: ['./cookie-policy.component.css']
})
export class CookiePolicyComponent implements OnInit {

  @ViewChild('cookiePolicyText') cookiePolicyText: ElementRef;

  isMobile: boolean = false;
  disableArticleTooltip: boolean = false;

  debug: boolean = false;

  constructor(private dialogRef: MatDialogRef<CookiePolicyComponent>,
    @Inject(MAT_DIALOG_DATA) data,
    private httpService: HttpService,
    private renderer: Renderer2,
    private deviceDetectorService: DeviceDetectorService) { 

      if(environment.debugComponentLoadingOrder) {
        console.log('CookiePolicyComponent.component loaded');
      }

      this.isMobile = this.deviceDetectorService.isMobile();

      if(this.isMobile) {
        this.disableArticleTooltip = true;
      }

    }

  ngOnInit() {

    if(environment.debugComponentLoadingOrder) {
      console.log('CookiePolicyComponent.component init');
    }

    setTimeout( () => {

      this.httpService.cookiePolicyDialogOpened.subscribe( (height: number) => {
        if(this.debug) {
          console.log('CookiePolicyComponent.component: ngOnInit: height: ', height);
        }
        this.renderer.setStyle(this.cookiePolicyText.nativeElement,'height',height + 'px');
        const parent = document.querySelector('#cookie-policy-container');
        if(parent) {
          TweenMax.fromTo(parent, 1, {ease:Elastic.easeOut, opacity: 0}, {ease:Elastic.easeOut, opacity: 1});
        }
      });

    });

  }

  closeCookiePolicyDialog() {
    this.dialogRef.close();
  }

}
