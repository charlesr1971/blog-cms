import { Directive, Inject, ElementRef, Input, HostListener, Renderer2, AfterViewInit, OnDestroy } from '@angular/core';
import { DOCUMENT } from '@angular/common';
import { Subject, Observable, Subscription } from 'rxjs';
import { map } from 'rxjs/operators';
import { DeviceDetectorService } from 'ngx-device-detector';

import { HttpService } from '../../services/http/http.service';

import { environment } from '../../../environments/environment';

interface AppImage {
  id: string;
  item: any;
};

interface AppAdvert {
  id: string;
  item: any;
};

@Directive({
  selector: '[appAdZone]'
})
export class AdZoneDirective implements AfterViewInit, OnDestroy {

  @Input() appParentElementId;
  @Input() appChildElementSelector;

  images: AppImage[] = [];
  adverts: AppAdvert[] = [];

  adzoneObserver: any;
  adzoneMutation = new Subject<any>();
  subscriptionAdzoneMutation: Subscription;
  isMobile: boolean = false;
  adZoneUrl: string = '';

  debug: boolean = false;


  constructor(@Inject(DOCUMENT) private documentBody: Document,
    private el: ElementRef,
    private renderer: Renderer2,
    private deviceDetectorService: DeviceDetectorService,
    private httpService: HttpService) { 

      if(environment.debugComponentLoadingOrder) {
        console.log('adZoneDirective.component loaded');
      }

      this.isMobile = this.deviceDetectorService.isMobile();

      this.adZoneUrl = this.httpService.adZoneUrl;


  }

  ngAfterViewInit() {

    const MutationObserver: new(callback) => MutationObserver = ((window as any).MutationObserver as any).__zone_symbol__OriginalDelegate;
    this.adzoneObserver = new MutationObserver( (mutations: MutationRecord[]) => {
      
      mutations.forEach( (mutation: MutationRecord) =>  {
        const target = (mutation.target as HTMLInputElement);
        const children = Array.prototype.slice.call(target.children);
        children.map( (child) => {
          if(child.tagName.toLowerCase() === 'app-image') {
            let cached = false;
            this.images.map( (image) => {
              if(image.id === this.getAppImageId(child.getAttribute('id'))) {
                cached = true;
                return;
              }
            });
            if(!cached) {
              const obj: AppImage = {
                id: this.getAppImageId(child.getAttribute('id')),
                item: child
              }
              this.images.push(obj);
            }
          }
        });
      });

      if(this.debug) {
        console.log('adZoneDirective.directive: adzoneMutation: this.adzoneObserver: connected...');
      }

      this.adzoneMutation.next(this.images);

    });
    this.adzoneObserver.observe(this.el.nativeElement, {
      childList: true
    });

    this.subscriptionAdzoneMutation = this.adzoneMutation.subscribe( data => {
      if(this.debug) {
        console.log('adZoneDirective.directive: adzoneMutation: data: ', data);
      }
      if(this.debug) {
        console.log('adZoneDirective.directive: adzoneMutation: this.adverts.length: ', this.adverts.length);
        console.log('adZoneDirective.directive: adzoneMutation: this.adverts.length <= environment.adZoneMaxAdverts: ', this.adverts.length <= environment.adZoneMaxAdverts);
      }
      if(Array.isArray(data) && data.length > 0 && this.adverts.length < environment.adZoneMaxAdverts) {
        const lastChild = data[data.length-1];
        if(lastChild) {
          this.adzoneObserver.disconnect();
          const div = this.renderer.createElement('div');
          this.renderer.setAttribute(div,'class','app-advert');
          this.renderer.setAttribute(div,'id','app-advert-' + lastChild['id']);
          const matCard = this.renderer.createElement('mat-card');
          this.renderer.setAttribute(matCard,'class','mat-card');
          const img = this.renderer.createElement('img');
          this.renderer.setAttribute(img,'class','advertiser-icon-default');
          this.renderer.setAttribute(img,'src','/assets/images/advertising-icon-trimmed.svg');

          const headerTop = this.renderer.createElement('div');
          this.renderer.setAttribute(headerTop,'class','app-advert-header-icon');

          const headerTopImgCircle = this.renderer.createElement('div');
          this.renderer.setAttribute(headerTopImgCircle,'class','app-advert-header-icon-circle');

          const headerTopImg = this.renderer.createElement('img');
          this.renderer.setAttribute(headerTopImg,'src','/assets/images/advertising-icon-trimmed.svg');
          this.renderer.appendChild(headerTopImgCircle,headerTopImg);
          this.renderer.appendChild(headerTop,headerTopImgCircle);

          this.renderer.appendChild(matCard,headerTop);

          const header = this.renderer.createElement('div');
          this.renderer.setAttribute(header,'class','image-category');
          
          
          const headerIcon = this.renderer.createElement('i');
          this.renderer.setAttribute(headerIcon,'class','fa fa-star');
          this.renderer.setStyle(headerIcon,'margin-right','10px');
          this.renderer.appendChild(header,headerIcon);
          const headerText = this.renderer.createText('Advertisements');
          this.renderer.appendChild(header,headerText);
          this.renderer.appendChild(matCard,header);

          this.renderer.appendChild(matCard,img);

          this.renderer.appendChild(div,matCard);
          this.renderer.insertBefore(this.el.nativeElement,div,lastChild['item']);
          
          const adZones = '1,2,1,2,-1';
          const adZoneWidth = 180;
          const adZoneHeight = 100;
          const adZoneDisplay = "block";
          const adZoneCategoryId = 0;
          const adZoneContentBoxStyle ="";
          const adzoneUseContentBox = false;
          const adZoneRemoteAccess = true;
          const adZoneDivider = true;
          const adZoneMobileFormat = this.isMobile;
          const adZoneRemoteMobileViewportMargin = 29;
          const adZoneMobileIsScaled = false;
          const adZoneRemoteDividerHeight = 10;
          const adZoneRemoteIdentifier = lastChild['id'];
          let adZoneRemoteClass = this.formatAdZoneRemoteClass('hidden-elements');
          const iframeWidth = 180;
          let iframeHeight = this.parseIframeHeight(0,adZoneHeight,adZones,adZoneRemoteDividerHeight,adZoneDivider);

          const iframe = this.renderer.createElement('iframe');
          const iframeSrc = this.adZoneUrl + '?adzones=' + adZones + '&adzonewidth=' + adZoneWidth + '&adzoneheight=' + adZoneHeight + '&adzonedisplay=' + adZoneDisplay + '&adzonecategoryid=' + adZoneCategoryId + '&adzonecontentboxstyle=' + adZoneContentBoxStyle + '&adzoneusecontentbox=' + adzoneUseContentBox + '&adzoneremoteaccess=' + adZoneRemoteAccess + '&adzonedivider=' + adZoneDivider + '&adzonemobileformat=' + adZoneMobileFormat + '&adzoneremotemobileviewportmargin=' + adZoneRemoteMobileViewportMargin + '&adzonemobileisscaled=' + adZoneMobileIsScaled + '&adzoneremotedividerheight=' + adZoneRemoteDividerHeight + '&adzoneremoteidentifier=' + adZoneRemoteIdentifier;
          this.renderer.setAttribute(iframe,'id','app-advert-iframe-' + lastChild['id']);
          this.renderer.setAttribute(iframe,'name','app-advert-iframe-' + lastChild['id']);
          this.renderer.setAttribute(iframe,'src',iframeSrc);
          this.renderer.setAttribute(iframe,'width',iframeWidth + '');
          this.renderer.setAttribute(iframe,'height',iframeHeight + '');
          this.renderer.setAttribute(iframe,'scrolling','no');
          this.renderer.setAttribute(iframe,'frameborder','0');

          const advertTable = this.renderer.createElement('table');
          this.renderer.setAttribute(advertTable,'class','app-advert-table');
          const advertTableRow = this.renderer.createElement('tr');
          const advertTableCell1 = this.renderer.createElement('td');
          const advertTableCell2 = this.renderer.createElement('td');
          this.renderer.setStyle(advertTableCell2,'width','10px');
          const advertTableCell3 = this.renderer.createElement('td');
          this.renderer.setStyle(advertTableCell3,'width',adZoneWidth + 'px');
          this.renderer.appendChild(advertTableRow,advertTableCell1);
          this.renderer.appendChild(advertTableRow,advertTableCell2);
          this.renderer.appendChild(advertTableRow,advertTableCell3);

          let temp = adZones.split(',');

          if(temp.length > 0) {
            for (var i = 0; i < temp.length; i++) {
              const advertTableCell1Block = this.renderer.createElement('div');
              this.renderer.setAttribute(advertTableCell1Block,'class','app-advert-table-cell-block');
              this.renderer.setStyle(advertTableCell1Block,'height',adZoneHeight + 'px');
              this.renderer.appendChild(advertTableCell1,advertTableCell1Block);
              const advertTableCell1BlockDivider = this.renderer.createElement('div');
              this.renderer.setAttribute(advertTableCell1BlockDivider,'class','app-advert-table-cell-block-divider');
              this.renderer.setStyle(advertTableCell1BlockDivider,'height',adZoneRemoteDividerHeight + 'px');
              this.renderer.appendChild(advertTableCell1,advertTableCell1BlockDivider);
            }
          }

          this.renderer.appendChild(advertTable,advertTableRow);

          this.renderer.appendChild(advertTableCell3,iframe);

          matCard.appendChild(advertTable);

          const obj: AppAdvert = {
            id: lastChild['id'],
            item: iframe
          }
          this.adverts.push(obj);

          this.adzoneObserver.observe(this.el.nativeElement, {
            childList: true
          });

          /* setTimeout( () => {
            const iframeMetaData: HTMLElement = this.documentBody.querySelector('iframe#app-advert-iframe-' + lastChild['id']);
            if(this.debug) {
              console.log('adZoneDirective.directive: adzoneMutation: iframeMetaData: ', iframeMetaData);
            }
            if(iframeMetaData) {
              const dataroleadzone = JSON.parse(iframeMetaData.dataset['roleAdZone']);
              if(this.debug) {
                console.log('adZoneDirective.directive: adzoneMutation: dataroleadzone: ', dataroleadzone);
              }
            }
          },2000); */

        }
        else{
          this.adzoneObserver.disconnect();
          if(this.debug) {
            console.log('adZoneDirective.directive: adzoneMutation: this.adzoneObserver: disconnected 1...');
          }
        }
      }
      else{
        this.adzoneObserver.disconnect();
        if(this.debug) {
          console.log('adZoneDirective.directive: adzoneMutation: this.adzoneObserver: disconnected 2...');
        }
        if (this.subscriptionAdzoneMutation) {
          this.subscriptionAdzoneMutation.unsubscribe();
        }
      }
    });

  }

  @HostListener("window:message", ["$event"]) receiveMessage(event) {
    //console.log('adZoneDirective.directive: window:message: event: ', event);
  }

  getAppImageId(id: string): string {
    return id.replace(/app\-image\-(.*)/,'$1').toLowerCase().trim();
  }

  getRandomInt(min: number = 1000000, max: number = 9999999): number {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min)) + min;
  }

  formatAdZoneRemoteClass(remoteClass: string): string {
    return remoteClass.trim() !== '' ? ' ' + remoteClass : remoteClass;
  }

  parseIframeHeight(iframeHeight: any, adZoneHeight: any, adZones: string, adZoneRemoteDividerHeight: any, adZoneDivider: boolean): number {
    var iframeHeight = isNaN(iframeHeight) ? 0 : iframeHeight;
    if(iframeHeight === 0 && !isNaN(adZoneHeight) && adZones.trim() !== '') {
      iframeHeight = Math.floor(adZones.split(',').length * adZoneHeight);
      if(!isNaN(adZoneRemoteDividerHeight) && adZoneDivider && (adZones.split(',').length - 1) > 0) {
        iframeHeight = Math.floor(iframeHeight + (adZones.split(',').length - 1) * adZoneRemoteDividerHeight);
      }
    }
    return iframeHeight;
  }

  ngOnDestroy() {

    if (this.subscriptionAdzoneMutation) {
      this.subscriptionAdzoneMutation.unsubscribe();
    }

  }

}
