import { Directive, Inject, ElementRef, Input, Renderer2, AfterViewInit, OnDestroy } from '@angular/core';
import { DOCUMENT } from '@angular/common';
import { Subject, Observable, Subscription } from 'rxjs';
import { DeviceDetectorService } from 'ngx-device-detector';

import { HttpService } from '../../services/http/http.service';

import { environment } from '../../../environments/environment';

declare var Waypoint: any;
declare var TweenMax: any, Elastic: any, Linear: any;

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

  @Input() appAdZoneParentElementId;
  @Input() appAdZoneSingleImageId;
  @Input() appAdZoneSearchDo;
  @Input() appAdZoneTagsDo;
  @Input() appAdZoneIsSection;

  images: AppImage[] = [];
  adverts: AppAdvert[] = [];
  adZoneObj = {};
  adZoneHeaderImageWaypoint = {};

  adzoneObserver: any;
  adzoneMutation = new Subject<any>();
  adzoneDataRoleObserver = {};
  subscriptionAdzoneMutation: Subscription;
  isMobile: boolean = false;
  adZoneUrl: string = '';
  maxRate: number = 4;
  metaDataMaxWidth: number = 240;

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

    if(environment.adZoneEnable) {
      this.buildAdZones();
    }

  }


  buildAdZones(): void {

    if(this.appAdZoneSingleImageId === '' && !this.appAdZoneSearchDo && !this.appAdZoneTagsDo && !this.appAdZoneIsSection) {

      if(this.debug) {
        console.log('adZoneDirective.directive: this.appAdZoneSingleImageId: ',this.appAdZoneSingleImageId);
        console.log('adZoneDirective.directive: this.appAdZoneSearchDo: ',this.appAdZoneSearchDo);
        console.log('adZoneDirective.directive: this.appAdZoneTagsDo: ',this.appAdZoneTagsDo);
        console.log('adZoneDirective.directive: this.appAdZoneIsSection: ',this.appAdZoneIsSection);
      }

      const MutationObserver: new(callback) => MutationObserver = ((window as any).MutationObserver as any).__zone_symbol__OriginalDelegate;
      this.adzoneObserver = new MutationObserver( (mutations: MutationRecord[]) => {
        
        mutations.forEach( (mutation: MutationRecord) =>  {
          const target = (mutation.target as HTMLInputElement);
          const children = Array.prototype.slice.call(target.children);
          if(this.appAdZoneSingleImageId === '' && !this.appAdZoneSearchDo && !this.appAdZoneTagsDo && !this.appAdZoneIsSection) {
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
          }
        });

        if(this.debug) {
          console.log('adZoneDirective.directive: this.adzoneObserver: connected...');
        }

        if(this.images.length >= environment.adZoneMinImages) {
          this.adzoneMutation.next(this.images);
        }

      });

      this.adzoneObserver.observe(this.el.nativeElement, {
        childList: true
      });

      this.subscriptionAdzoneMutation = this.adzoneMutation.subscribe( data => {
        if(this.debug) {
          console.log('adZoneDirective.directive: subscriptionAdzoneMutation: data: ', data);
        }
        if(this.debug) {
          console.log('adZoneDirective.directive: subscriptionAdzoneMutation: this.adverts.length: ', this.adverts.length);
          console.log('adZoneDirective.directive: subscriptionAdzoneMutation: this.adverts.length <= environment.adZoneMaxAdverts: ', this.adverts.length <= environment.adZoneMaxAdverts);
        }
        if(this.appAdZoneSingleImageId === '' && !this.appAdZoneSearchDo && !this.appAdZoneTagsDo && !this.appAdZoneIsSection) {
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

              const headerTopImgCircleContainer = this.renderer.createElement('div');
              this.renderer.setAttribute(headerTopImgCircleContainer,'class','app-advert-header-icon-circle-container');

              const headerTopImgCircle = this.renderer.createElement('div');
              this.renderer.setAttribute(headerTopImgCircle,'id','app-advert-header-image-circle-' + lastChild['id']);
              this.renderer.setAttribute(headerTopImgCircle,'class','app-advert-header-icon-circle app-advert-header-image-group-' + lastChild['id']);

              const headerTopImg = this.renderer.createElement('img');
              this.renderer.setAttribute(headerTopImg,'src','/assets/images/advertising-icon-trimmed.svg');
              this.renderer.setAttribute(headerTopImg,'id','app-advert-header-image-' + lastChild['id']);
              this.renderer.setAttribute(headerTopImg,'class','app-advert-header-image-group-' + lastChild['id']);

              headerTopImgCircleContainer.appendChild(headerTopImgCircle);
              headerTopImgCircleContainer.appendChild(headerTopImg);
              headerTop.appendChild(headerTopImgCircleContainer);

              matCard.appendChild(headerTop);

              const header = this.renderer.createElement('div');
              this.renderer.setAttribute(header,'class','image-category');
              
              const headerIcon = this.renderer.createElement('i');
              this.renderer.setAttribute(headerIcon,'class','fa fa-star');
              this.renderer.setStyle(headerIcon,'margin-right','10px');
              header.appendChild(headerIcon);
              const headerText = this.renderer.createText('Advertisements');
              header.appendChild(headerText);
              matCard.appendChild(header);

              matCard.appendChild(img);

              div.appendChild(matCard);
              this.el.nativeElement.insertBefore(div,lastChild['item']);
              
              let adZones = '1,2,1,2,-1';
              let adZoneWidth: any = 180;
              let adZoneHeight: any = 100;
              let adZoneDisplay = "block";
              let adZoneCategoryId = 0;
              let adZoneContentBoxStyle ="";
              let adzoneUseContentBox = false;
              let adZoneRemoteAccess = true;
              let adZoneDivider = true;
              let adZoneMobileFormat = this.isMobile;
              let adZoneRemoteMobileViewportMargin = 29;
              let adZoneMobileIsScaled = false;
              let adZoneRemoteDividerHeight = 10;
              let adZoneRemoteIdentifier = lastChild['id'];
              let adZoneRemoteClass = this.formatAdZoneRemoteClass('hidden-elements');
              let iframeWidth: any = 180;
              let iframeHeight: any = this.parseIframeHeight(0,adZoneHeight,adZones,adZoneRemoteDividerHeight,adZoneDivider);
              let rowHasSingleCell = false;

              if(this.debug) {
                console.log('adZoneDirective.directive: subscriptionAdzoneMutation: adZones: ', adZones);
              }
              
              if(Math.abs(this.adverts.length % 2) === 0) {
                adZones = '5,5';
                adZoneWidth = 240;
                adZoneHeight = 200;
                iframeWidth = 240;
                iframeHeight = this.parseIframeHeight(0,adZoneHeight,adZones,adZoneRemoteDividerHeight,adZoneDivider);
                rowHasSingleCell = false;
                if(this.debug) {
                  console.log('adZoneDirective.directive: subscriptionAdzoneMutation: adZones: ', adZones);
                }
              }

              if(Math.abs(this.adverts.length % 3) === 0) {
                adZones = '7,7';
                adZoneWidth = '100%';
                adZoneHeight = 210;
                adZoneMobileFormat = true;
                adZoneMobileIsScaled = true;
                iframeWidth = '100%';
                iframeHeight = this.parseIframeHeight(0,adZoneHeight,adZones,adZoneRemoteDividerHeight,adZoneDivider);
                rowHasSingleCell = true;
                if(this.debug) {
                  console.log('adZoneDirective.directive: subscriptionAdzoneMutation: adZones: ', adZones);
                }
              }

              const iframe = this.renderer.createElement('iframe');
              const iframeSrc = this.adZoneUrl + '?adzones=' + adZones + '&adzonewidth=' + adZoneWidth + '&adzoneheight=' + adZoneHeight + '&adzonedisplay=' + adZoneDisplay + '&adzonecategoryid=' + adZoneCategoryId + '&adzonecontentboxstyle=' + adZoneContentBoxStyle + '&adzoneusecontentbox=' + adzoneUseContentBox + '&adzoneremoteaccess=' + adZoneRemoteAccess + '&adzonedivider=' + adZoneDivider + '&adzonemobileformat=' + adZoneMobileFormat + '&adzoneremotemobileviewportmargin=' + adZoneRemoteMobileViewportMargin + '&adzonemobileisscaled=' + adZoneMobileIsScaled + '&adzoneremotedividerheight=' + adZoneRemoteDividerHeight + '&adzoneremoteidentifier=' + adZoneRemoteIdentifier;
              this.renderer.setAttribute(iframe,'id','app-advert-iframe-' + lastChild['id']);
              this.renderer.setAttribute(iframe,'name','app-advert-iframe-' + lastChild['id']);
              this.renderer.setAttribute(iframe,'src',iframeSrc);
              this.renderer.setAttribute(iframe,'width',adZoneWidth + '');
              this.renderer.setAttribute(iframe,'height',iframeHeight + '');
              this.renderer.setAttribute(iframe,'scrolling','no');
              this.renderer.setAttribute(iframe,'frameborder','0');

              const advertTable = this.renderer.createElement('table');
              this.renderer.setAttribute(advertTable,'class','app-advert-table');
              const advertTableRow = this.renderer.createElement('tr');

              let advertTableCell1: HTMLElement;
              let advertTableCell2: HTMLElement;

              if(!rowHasSingleCell) {
                advertTableCell1 = this.renderer.createElement('td');
                this.renderer.setAttribute(advertTableCell1,'id','app-advert-table-cell-1-' + lastChild['id']);
                advertTableCell2 = this.renderer.createElement('td');
                this.renderer.setStyle(advertTableCell2,'width','10px');
              }

              const advertTableCell3 = this.renderer.createElement('td');
              this.renderer.setStyle(advertTableCell3,'width',iframeWidth + 'px');

              if(!rowHasSingleCell) {
                advertTableRow.appendChild(advertTableCell1);
                advertTableRow.appendChild(advertTableCell2);
              }

              advertTableRow.appendChild(advertTableCell3);

              if(!rowHasSingleCell) {

                let temp = adZones.split(',');

                if(temp.length > 0) {
                  for (var i = 0; i < temp.length; i++) {
                    const advertTableCell1Block = this.renderer.createElement('div');
                    this.renderer.setAttribute(advertTableCell1Block,'class','app-advert-table-cell-block');
                    this.renderer.setAttribute(advertTableCell1Block,'id','app-advert-table-cell-block-' + (i + 1) + '-' + lastChild['id']);
                    this.renderer.setStyle(advertTableCell1Block,'height',adZoneHeight + 'px');
                    advertTableCell1.appendChild(advertTableCell1Block);
                    advertTableCell1Block.innerHTML = '<svg class="custom-mat-progress-spinner" width="100" height="100" viewbox="-7.5 -7.5 25 25"><circle class="path" cx="5" cy="5" r="5" fill="none" stroke-width="1.5" stroke-miterlimit="0" /></svg>';
                    const advertTableCell1BlockDivider = this.renderer.createElement('div');
                    this.renderer.setAttribute(advertTableCell1BlockDivider,'class','app-advert-table-cell-block-divider');
                    this.renderer.setStyle(advertTableCell1BlockDivider,'height',adZoneRemoteDividerHeight + 'px');
                    advertTableCell1.appendChild(advertTableCell1BlockDivider);
                  }
                }
                
              }

              advertTable.appendChild(advertTableRow);

              advertTableCell3.appendChild(iframe);

              matCard.appendChild(advertTable);

              this.adZoneHeaderImageWaypoint[lastChild['id']] = new Waypoint({
                element: this.documentBody.getElementById('app-advert-header-image-circle-' + lastChild['id']),
                handler: function (direction) {
                  if(this.debug) {
                    console.log('adZoneDirective.directive: subscriptionAdzoneMutation: waypoint detected: ', lastChild['id']);
                  }
                  const that = this;
                  const overshoot=5;
                  const period=0.25;
                  TweenMax.to('#app-advert-header-image-circle-' + lastChild['id'],0.5,{opacity:1,ease:Linear.easeNone});
                  TweenMax.to('#app-advert-header-image-' + lastChild['id'],0.5,{
                    scale:0.25,
                    opacity:0.25,
                    onComplete:function(){
                      TweenMax.to('#app-advert-header-image-' + lastChild['id'],1.4,{
                        scale:1,
                        opacity:1,
                        ease:Elastic.easeOut,
                        easeParams:[overshoot,period]
                      })
                    }
                  });
                  this.destroy();

                },
                context: this.documentBody.getElementById(this.appAdZoneParentElementId),
                offset: '50%'
              });

              if(this.debug) {
                console.log('adZoneDirective.directive: subscriptionAdzoneMutation: this.adZoneHeaderImageWaypoint: ', this.adZoneHeaderImageWaypoint);
              }

              const obj: AppAdvert = {
                id: lastChild['id'],
                item: div
              }
              this.adverts.push(obj);

              if(this.debug) {
                console.log('adZoneDirective.directive: subscriptionAdzoneMutation: this.adverts: ', this.adverts);
              }

              this.adzoneObserver.observe(this.el.nativeElement, {
                childList: true
              });

              const target: HTMLElement = this.documentBody.querySelector('iframe#app-advert-iframe-' + lastChild['id']);

              this.adzoneDataRoleObserver[lastChild['id']] = new MutationObserver( (mutations: MutationRecord[]) => {
          
                mutations.forEach( (mutation: MutationRecord) =>  {
                  const obj = JSON.parse((mutation.target as HTMLInputElement).getAttribute(mutation.attributeName));
                  this.receiveMessage(obj,lastChild['id']);
                });
          
              });
          
              const config = {attributes:true,childList:true,characterData:false,attributeFilter:['data-role-ad-zone']};
              this.adzoneDataRoleObserver[lastChild['id']].observe(target,config);
              if(this.debug) {
                console.log('adZoneDirective.directive: subscriptionAdzoneMutation: this.adzoneDataRoleObserver[lastChild[\'id\']] connected: ', lastChild['id']);
              }

            }
            else{
              this.adzoneObserver.disconnect();
              if(this.debug) {
                console.log('adZoneDirective.directive: subscriptionAdzoneMutation: this.adzoneObserver: disconnected 1...');
              }
            }
          }
          else{
            this.adzoneObserver.disconnect();
            if(this.debug) {
              console.log('adZoneDirective.directive: subscriptionAdzoneMutation: this.adzoneObserver: disconnected 2...');
            }
            if (this.subscriptionAdzoneMutation) {
              this.subscriptionAdzoneMutation.unsubscribe();
            }
          }
        }
      });
      

    }
    else{

      if(this.debug) {
        console.log('adZoneDirective.directive: single image mode');
      }

    }

  }


  receiveMessage(obj: any, key: string): void {
    if(this.debug) {
      console.log('adZoneDirective.directive: receiveMessage: obj: ', obj);
    }
    if(key in obj && Array.isArray(obj[key]) && obj[key].length > 0) {
      const target: HTMLElement = Array.prototype.slice.call(this.documentBody.querySelectorAll('#app-advert-table-cell-1-' + key + ' .app-advert-table-cell-block'));
      if(this.debug) {
        console.log('adZoneDirective.directive: receiveMessage: target: ', target);
      }
      if(Array.isArray(target) && target.length === obj[key].length && !(key in this.adZoneObj)) {
        this.adZoneObj[key] = true;
        const temp = obj[key].filter( (item: any) => {
          return 'impressions' in item;
        })
        if(this.debug) {
          console.log('adZoneDirective.directive: receiveMessage: temp: ', temp);
        }
        const impressionsArray = [];
        temp.map( (item: any) => {
          impressionsArray.push(item['impressions']);
        });
        impressionsArray.sort((a, b) => a - b);
        if(this.debug) {
          console.log('adZoneDirective.directive: receiveMessage: impressionsArray: ', impressionsArray);
        }
        if(impressionsArray.length > 0) {
          temp.map( (item: any, idx: number) => {
            const div1 = this.renderer.createElement('div');
            this.renderer.setAttribute(div1,'class','css-tooltip');
            const span = this.renderer.createElement('span');
            this.renderer.setAttribute(span,'class','tooltiptext');
            const spanText = this.renderer.createText(item['impressions'] + ' impressions');
            span.appendChild(spanText);
            div1.appendChild(span);
            const div2 = this.renderer.createElement('div');
            let rate = this.getRatingIndex(impressionsArray,item['impressions']);
            rate = rate > this.maxRate ? this.maxRate : rate;
            for (var r = 0; r < rate; r++) {
              const i = this.renderer.createElement('i');
              this.renderer.setAttribute(i,'class','fa fa-star');
              div2.appendChild(i);
            }
            if(this.debug) {
              console.log('adZoneDirective.directive: receiveMessage: target[idx]: ', target[idx]);
            }
            if(target.length > idx) {
              div1.appendChild(div2);
              target[idx].innerHTML = '';
              target[idx].appendChild(div1);
            }
          });
          if(target.length > temp.length) {
            if(this.debug) {
              console.log('adZoneDirective.directive: receiveMessage: target.length: ', target.length, ' temp.length: ', temp.length);
            }
            target[target.length - 1].innerHTML = '';
          }
        }
        this.adzoneDataRoleObserver[key].disconnect();
        if(this.debug) {
          console.log('adZoneDirective.directive: receiveMessage: this.adzoneDataRoleObserver[key] disconnected: ', key);
        }
      }
    }
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

  getRatingIndex(array: number[],value: number) {
    return array.indexOf(value) + 1;
  }

  ngOnDestroy() {

    if (this.subscriptionAdzoneMutation) {
      this.subscriptionAdzoneMutation.unsubscribe();
    }

  }

}
