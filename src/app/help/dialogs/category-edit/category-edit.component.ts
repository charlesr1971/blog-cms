import { Component, OnInit, Inject, ViewChild, ElementRef, Renderer2, HostListener } from '@angular/core';
import {MAT_DIALOG_DATA, MatDialogRef} from '@angular/material';
import { DeviceDetectorService } from 'ngx-device-detector';

import { HttpService } from '../../../services/http/http.service';

import { environment } from '../../../../environments/environment';

declare var ease, TweenMax, Elastic: any;

@Component({
  selector: 'app-category-edit',
  templateUrl: './category-edit.component.html',
  styleUrls: ['./category-edit.component.css']
})
export class CategoryEditComponent implements OnInit {

  @ViewChild('dialogEditCategoriesHelpNotificationText') dialogEditCategoriesHelpNotificationText: ElementRef;

  isMobile: boolean = false;
  disableEditCategoriesTooltip: boolean = false;
  maxcategoryeditnamelength: number = environment.maxcategoryeditnamelength;

  debug: boolean = false;

  constructor(private dialogRef: MatDialogRef<CategoryEditComponent>,
    @Inject(MAT_DIALOG_DATA) data,
    private httpService: HttpService,
    private renderer: Renderer2,
    private deviceDetectorService: DeviceDetectorService) { 

      if(environment.debugComponentLoadingOrder) {
        console.log('CookiePolicyComponent.component loaded');
      }

      this.isMobile = this.deviceDetectorService.isMobile();

      if(this.isMobile) {
        this.disableEditCategoriesTooltip = true;
      }


    }

  ngOnInit() {

    if(environment.debugComponentLoadingOrder) {
      console.log('CategoryEditComponent.component init');
    }

    setTimeout( () => {

      this.httpService.editCategoriesDialogOpened.subscribe( (height: number) => {
        if(this.debug) {
          console.log('CategoryEditComponent.component: ngOnInit: height: ', height);
        }
        this.renderer.setStyle(this.dialogEditCategoriesHelpNotificationText.nativeElement,'height',height + 'px');
        const parent = document.querySelector('#dialog-edit-categories-help-notification-container');
        if(parent) {
          TweenMax.fromTo(parent, 1, {ease:Elastic.easeOut, opacity: 0}, {ease:Elastic.easeOut, opacity: 1});
        }
      });

    });

  }

  @HostListener('mousedown', ['$event'])
  onMouseDown(event: MouseEvent) {
    this.disableEditCategoriesTooltip = true;
    if(this.debug) {
      console.log('CategoryEditComponent.component: mousedown: this.disableEditCategoriesTooltip: ',this.disableEditCategoriesTooltip);
    }
  }

  @HostListener('mouseup', ['$event'])
  onMouseUp(event: MouseEvent) {
    this.disableEditCategoriesTooltip = false;
    if(this.debug) {
      console.log('CategoryEditComponent.component: mouseup: this.disableEditCategoriesTooltip: ',this.disableEditCategoriesTooltip);
    }
  }

  closeEditCategoriesHelpNotificationDialog() {
    this.dialogRef.close();
  }

}
