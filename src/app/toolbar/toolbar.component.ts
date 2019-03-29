import { Component, OnInit, OnDestroy, Input, Inject, Output, EventEmitter, ViewChild } from '@angular/core';
import { Subscription } from 'rxjs';
import { DOCUMENT } from '@angular/common';
import { DeviceDetectorService } from 'ngx-device-detector';
import { trigger, state, style, animate, transition } from '@angular/animations';
import { faFacebookSquare } from '@fortawesome/free-brands-svg-icons/faFacebookSquare';
import { faTwitterSquare } from '@fortawesome/free-brands-svg-icons/faTwitterSquare';
import { faTumblrSquare } from '@fortawesome/free-brands-svg-icons/faTumblrSquare';
import { faLinkedinIn } from '@fortawesome/free-brands-svg-icons/faLinkedinIn';
import { Router } from '@angular/router';
import { CookieService } from 'ngx-cookie-service';
import { sortTags } from '../util/sortTags';
import { styler } from '../util/styler';

import { User } from '../user/user.model';
import { Image } from '../image/image.model';
import { HttpService } from '../services/http/http.service';
import { environment } from '../../environments/environment';

declare var TweenMax: any, Elastic: any;

@Component({
  selector: 'app-toolbar',
  templateUrl: './toolbar.component.html',
  styleUrls: ['./toolbar.component.css'],
  animations: [
    trigger('shareFadeInOutAnimation', [
        state('in', style({
          opacity: 1,
          display: 'block'
        })),
        state('out', style({
          opacity: 0,
          display: 'none'
        })),
        transition('out => in', animate('250ms ease-in')),
        transition('in => out', animate('250ms ease-out'))
    ]),
  ]
})
export class ToolbarComponent implements OnInit, OnDestroy {

  @ViewChild('imageTagsSelect') imageTagsSelect;

  private allowMultipleLikesPerUser: number = environment.allowMultipleLikesPerUser;
  @Output() _openComments: EventEmitter<any> = new EventEmitter();
  @Input() image: Image;
  @Input() commentsState: string = 'out';
  @Input() currentUser: User;
  @Input() commentsTotal: number = 0;
  @Input() disableCommentTooltip: boolean = false;

  isMobile: boolean = false;

  likeColorDefault: string = '#ffffff';
  likeColor: string = '#b88be3';
  shareState: string = 'out';
  likesSubscription: Subscription;
  disableFavouriteTooltip: boolean = false;
  showFavouriteTooltipMax: number = 99;
  fbIcon = faFacebookSquare;
  tbrIcon = faTumblrSquare;
  tweetIcon = faTwitterSquare;
  linkedinInIcon = faLinkedinIn;
  tags = [];
  tagDisplay: boolean = false;
  catalogRouterAliasLower: string = environment.catalogRouterAlias;

  debug: boolean = false;

  constructor(@Inject(DOCUMENT) private documentBody: Document,
    private httpService: HttpService,
    private deviceDetectorService: DeviceDetectorService,
    private cookieService: CookieService,
    private router: Router) {

      if(environment.debugComponentLoadingOrder) {
        console.log('gallery-detail.component loaded');
      } 

      this.isMobile = this.deviceDetectorService.isMobile();

      if(this.isMobile) {
        this.disableFavouriteTooltip = true;
        this.commentsState = 'in';
      }

  }

  ngOnInit() {

    if(environment.debugComponentLoadingOrder) {
      console.log('gallery-detail.component init');
    } 

    this.likesSubscription = this.httpService.fetchLikes(this.image['id']).subscribe( (data: any) => {
      if(this.debug) {
        console.log('ngOnInit(): fetchLikes', data);
      }
      if(data) {
        if('error' in data && data['error'] === '') {
          this.image['likes'] = data['likes'];
          if(!this.isMobile) {
            this.disableFavouriteTooltip = this.disabledFavouriteTooltip();
          }
          if(this.image['likes']) {
            const favourite = this.documentBody.querySelector('#favourite-' + this.image['id']);
            if(favourite){
              favourite.classList.add('favorite-in');
              const styles = styler('.favorite-in').get(['color']);
              if(this.debug) {
                console.log('toolbar.component: addLike: styles: ', styles);
                console.log('toolbar.component: addLike: is object: ', typeof styles === 'object');
              }
              if(typeof styles === 'object' && 'color' in styles) {
                this.likeColorDefault = styles['color'];
              }
            }
          }
        }
      }
    });

    if((typeof this.image['tags'] === 'string') && this.image['tags'] !== '') {
      const tags = JSON.parse(this.image['tags']);
      tags.sort(sortTags);
      if(this.debug) {
        console.log('toolbar.component: tags ', tags);
      }
      if(Array.isArray(tags) && tags.length) {
        this.tags = tags;
        this.tagDisplay = true;
      }
    }

    this.documentBody.querySelector('#mat-sidenav-content').addEventListener('scroll', this.onMatSidenavContentScroll.bind(this));

  }

  onMatSidenavContentScroll(): void {
    if(this.imageTagsSelect) {
      this.imageTagsSelect.close();
    }
  }

  addLike(): void {
    const overshoot=5;
    const period=0.25;
    const userToken = this.cookieService.get('userToken').toLowerCase();
    this.httpService.fetchLikes(this.image['id'],1,userToken,this.allowMultipleLikesPerUser).subscribe( (data: any) => {
      if(this.debug) {
        console.log('toolbar.component: addLike(): fetchLikes', data);
      }
      if(data) {
        if('error' in data && data['error'] === '') {
          this.image['likes'] = this.image['likes'] + 1;
          if(!this.isMobile) {
            this.disableFavouriteTooltip = this.disabledFavouriteTooltip();
          }
          const el = this.documentBody.querySelector('#favourite-' + this.image['id']);
          el.classList.add('favorite-in');
          const styles = styler('.favorite-in').get(['color']);
          if(this.debug) {
            console.log('toolbar.component: addLike: styles: ', styles);
            console.log('toolbar.component: addLike: is object: ', typeof styles === 'object');
          }
          if(typeof styles === 'object' && 'color' in styles) {
            this.likeColor = styles['color'];
            TweenMax.to(el,0.5,{
              scale:0.25,
              color:this.likeColor,
              onComplete:function(){
                TweenMax.to(el,1.4,{
                  scale:1,
                  ease:Elastic.easeOut,
                  easeParams:[overshoot,period]
                })
              }
            });
          }
        }
        else{
          if('jwtObj' in data) {
            this.httpService.jwtHandler(data['jwtObj']);
          }
        }
      }
    });
  }

  share(event: any, id: string): void{  
    if(this.debug) {
      console.log('image.component: share: id: ', id);
    } 
    this.shareState = this.shareState === 'in' ? 'out' : 'in';
    event.stopPropagation();
  }

  openComments(event: any): void {
    this._openComments.emit(event);
  }

  disabledFavouriteTooltip(): boolean {
    return this.image['likes'] < this.showFavouriteTooltipMax;
  }

  onTagChange(event): void {
    const value = event.source.value;
    if(this.debug) {
      console.log('image.component: onTagChange: event: ', event);
    }
    this.router.navigate([this.catalogRouterAliasLower,{tag: value}]);
  }

  ngOnDestroy() {

    if (this.likesSubscription) {
      this.likesSubscription.unsubscribe();
    }

  }

}
