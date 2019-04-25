import { Component, OnInit, OnDestroy, Input, Output, Inject, Renderer2, ElementRef, ViewChild, AfterViewInit, EventEmitter } from '@angular/core';
import { Subscription, BehaviorSubject } from 'rxjs';
import { DOCUMENT } from '@angular/common';
import { DeviceDetectorService } from 'ngx-device-detector';
import { CookieService } from 'ngx-cookie-service';
import { trigger, state, style, animate, transition } from '@angular/animations';
import { faFacebookSquare } from '@fortawesome/free-brands-svg-icons/faFacebookSquare';
import { faTwitterSquare } from '@fortawesome/free-brands-svg-icons/faTwitterSquare';
import { faTumblrSquare } from '@fortawesome/free-brands-svg-icons/faTumblrSquare';
import { faLinkedinIn } from '@fortawesome/free-brands-svg-icons/faLinkedinIn';
import { Router } from '@angular/router';
import { sortTags } from '../util/sortTags';
import { MatDialog } from '@angular/material';
import * as _moment from 'moment';
import { styler } from '../util/styler';

import { User } from '../user/user.model';
import { UserService } from '../user/user.service';
import { Image } from './image.model';
import { HttpService } from '../services/http/http.service';
import { environment } from '../../environments/environment';

declare var TweenMax: any, Elastic: any, Back: any;

const moment = _moment;

interface CommentElementsPrefix {
  parentClose: string;
  refchildClose: string
};

@Component({
  selector: 'app-image',
  templateUrl: './image.component.html',
  styleUrls: ['./image.component.css'],
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
export class ImageComponent implements OnInit, AfterViewInit, OnDestroy {

  @ViewChild('imageTagsSelect') imageTagsSelect;

  private allowMultipleLikesPerUser: number = environment.allowMultipleLikesPerUser;

  @Output() openLightBox: EventEmitter<any> = new EventEmitter();
  @Input() image: Image;
  @Input() singleImageId: string = '';
  @Input() imageCount: number = 0;

  isMobile: boolean = false;

  formData = {};
 
  tagsArray = [];
  currentPage: number = 1;
  commentsTotal: number = 0;
  id: string = '';
  likeColorDefault: string = '#ffffff';
  likeColor: string = '#b88be3';
  shareState: string = 'out';
  commentsState: string = 'out';
  scrollToCommentsPanel: boolean = false;
  fbIcon = faFacebookSquare;
  tbrIcon = faTumblrSquare;
  tweetIcon = faTwitterSquare;
  linkedinInIcon = faLinkedinIn;
  likesSubscription: Subscription;
  deleteImageSubscription: Subscription;
  currentUser: BehaviorSubject<User> = new BehaviorSubject<User>(null);
  tags = [];
  tagDisplay: boolean = false;
  currentUserid: number = 0;
  disableCommentTooltip: boolean = true;
  disableFavouriteTooltip: boolean = false;
  showFavouriteTooltipMax: number = 99;
  isPublished: boolean = false;
  hideCommentInput: boolean = false;
  CommentElementsPrefix: CommentElementsPrefix  = {
    parentClose: '#image-',
    refchildClose: '#mat-card-actions-'
  };
  catalogRouterAliasLower: string = environment.catalogRouterAlias;
  uploadRouterAliasLower: string = environment.uploadRouterAlias;
  imageMediumSuffix: string = environment.imageMediumSuffix;
  imageMediumEnabled: boolean = environment.imageMediumEnabled;
  lazyLoadImages: boolean = environment.lazyLoadImages;

  debug: boolean = false;

  constructor(@Inject(DOCUMENT) private documentBody: Document,
    private el: ElementRef,
    private renderer: Renderer2,
    private httpService: HttpService,
    private cookieService: CookieService,
    private userService: UserService,
    private deviceDetectorService: DeviceDetectorService,
    public dialog: MatDialog,
    private router: Router) {

      if(environment.debugComponentLoadingOrder) {
        console.log('image.component loaded');
      }

      this.isMobile = this.deviceDetectorService.isMobile();

      if(this.isMobile) {
        this.disableCommentTooltip = true;
        this.disableFavouriteTooltip = true;
      }

  }

  ngOnInit() {

    if(environment.debugComponentLoadingOrder) {
      console.log('image.component init');
    }

    this.currentUser = this.userService.currentUser;
    if(this.debug) {
      console.log('image.component: this.currentUser: ', this.currentUser);
    }  
    this.currentUserid = this.currentUser.value['userid'];
    if(this.debug) {
      console.log('image.component: this.currentUserid: ',this.currentUserid);
    }
    if(this.debug) {
      console.log('image.component: this.image.id: ', this.image.id);
      console.log('image.component: this.image.userid: ', this.image.userid);
    }  
    this.likesSubscription = this.httpService.fetchLikes(this.image.id).subscribe( (data: any) => {
      if(this.debug) {
        console.log('ngOnInit(): fetchLikes', data);
      }
      if(data) {
        if('error' in data && data['error'] === '') {
          this.image.likes = data['likes'];
          if(!this.isMobile) {
            this.disableFavouriteTooltip = this.disabledFavouriteTooltip();
          }
          if(this.image['likes']) {
            const favourite = this.documentBody.querySelector('#favourite-' + this.image['id']);
            if(favourite){
              favourite.classList.add('favorite-in');
              const styles = styler('.favorite-in').get(['color']);
              if(this.debug) {
                console.log('image.component: addLike: styles: ', styles);
                console.log('image.component: addLike: is object: ', typeof styles === 'object');
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
      if(Array.isArray(tags) && tags.length) {
        this.tags = tags;
        this.tagDisplay = true;
      }
    }
    this.isPublished = this.articleIsPublished();

    setTimeout( () => {
      if(this.singleImageId !== '' && !this.isMobile) {
        if(this.debug) {
          console.log('image.component: this.singleImageId ',this.singleImageId);
        }
        const child = this.el.nativeElement.firstElementChild;
        if(this.debug) {
          console.log('image.component: child ',child);
        }
        if(child) {
          this.renderer.addClass(child,'single-image-display');
          this.renderer.removeClass(child,'multiple-image-display');
          const parent = this.documentBody.querySelector('#infinite-scroller-images');
          if(parent){
            const parentWidth = parent.clientWidth;
            const childWidth = child.clientWidth;
            const marginLeft = (parentWidth-childWidth)/2;
            if(this.debug) {
              console.log('image.component: parentWidth ',parentWidth);
              console.log('image.component: childWidth ',childWidth);
              console.log('image.component: marginLeft ',marginLeft);
            }            
            TweenMax.to(child, 1, {
              css:{marginLeft:marginLeft,autoRound:false}, ease:Back.easeOut.config(1.7)
            });
          }
          this.singleImageId = '';
        }
      }
    });

    this.documentBody.querySelector('#infinite-scroller-images').addEventListener('scroll', this.onInfiniteScrollerImagesScroll.bind(this));

  }

  ngAfterViewInit() {
    if(!this.lazyLoadImages) {
      const image = this.documentBody.getElementById('image-img-' + this.image.id);
      if(image) {
        setTimeout( () => {
          if(this.debug) {
            console.log('image.component: ngAfterViewInit');
          }
          this.renderer.setStyle(image,'opacity',1);
        });
      }
    }
  }

  onInfiniteScrollerImagesScroll(): void {
    if(this.tagDisplay) {
      this.imageTagsSelect.close();
    }
  }

  articleIsPublished(): boolean {
    const date2 = new Date();
    let publishArticleDate = date2;
    if(this.image['publishArticleDate'] && this.image['publishArticleDate'] !== '') {
      publishArticleDate = moment(new Date(this.image['publishArticleDate'])).toDate();
    }
    const date1 = new Date(publishArticleDate);
    if(this.debug) {
      console.log('image.component: articleIsPublished: this.image["fileid"]: ', this.image['fileid']);
    }
    if(this.debug) {
      console.log('image.component: articleIsPublished: this.image["publishArticleDate"]: ', this.image['publishArticleDate']);
    }
    if(this.debug) {
      console.log('image.component: articleIsPublished: publishArticleDate: ', publishArticleDate);
    }
    if(this.debug) {
      console.log('image.component: articleIsPublished: date1: ', date1);
    }
    if(this.debug) {
      console.log('image.component: articleIsPublished: date2: ', date2);
    }
    return date2 > date1;
  }

  deleteFile(id: string): void {
    if(this.debug) {
      console.log('image.component: deleteFile: id: ', id);
    }
    const body = {
      fileUuid: id
    };
    this.deleteImageSubscription = this.httpService.deleteImage(body).do(this.processDeleteImageData).subscribe();
  }

  private processDeleteImageData = (data) => {
    if(this.debug) {
      console.log('tree-dynamic: processDeleteImageData: data: ', data);
    }
    if(data) {
      if('error' in data && data['error'] === '') {
        this.httpService.deleteImageId.next(data['fileUuid']);
      }
      else{
        if('jwtObj' in data) {
          this.httpService.jwtHandler(data['jwtObj']);
        }
      }
    }
  }

  share(event: any, id: string): void{  
    if(this.debug) {
      console.log('image.component: share: id: ', id);
    } 
    this.shareState = this.shareState === 'in' ? 'out' : 'in';
    event.stopPropagation();
  }

  openComments(event: any): void {
    this.commentsState = this.commentsState === 'in' ? 'out' : 'in';
    event.stopPropagation();
  }

  disabledFavouriteTooltip(): boolean {
    return this.image.likes < this.showFavouriteTooltipMax;
  }

  onTagChange(event): void {
    const value = event.source.value;
    if(this.debug) {
      console.log('image.component: onTagChange: event: ', event);
    }
    this.httpService.pageTagsDo.next(value);
  }

  editFile(fileid: string): void {   
    if(this.debug) {
      console.log('image.component: editFile: fileid: ', fileid);
    }
    this.router.navigate([this.uploadRouterAliasLower, {fileid: fileid}]);
  }

  addLike(): void {
    const overshoot=5;
    const period=0.25;
    const userToken = this.cookieService.get('userToken').toLowerCase();
    this.httpService.fetchLikes(this.image.id,1,userToken,this.allowMultipleLikesPerUser).subscribe( (data: any) => {
      if(this.debug) {
        console.log('image.component: addLike(): fetchLikes', data);
      }
      if(data) {
        if('error' in data && data['error'] === '') {
          this.image.likes = this.image.likes + 1;
          if(!this.isMobile) {
            this.disableFavouriteTooltip = this.disabledFavouriteTooltip();
          }
          const el = this.documentBody.querySelector('#favourite-' + this.image.id);
          el.classList.add('favorite-in');
          const styles = styler('.favorite-in').get(['color']);
          if(this.debug) {
            console.log('image.component: addLike: styles: ', styles);
            console.log('image.component: addLike: is object: ', typeof styles === 'object');
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

  sendCommentsTotal(event: any): void {
    if(this.debug) {
      console.log('image.component: sendCommentsTotal(): event ', event);
    }
    this.commentsTotal = event;
  }

  sendDisableCommentTooltip(event: any): void {
    this.disableCommentTooltip = event;
  }

  sendHideCommentInput(event: any): void {
    this.hideCommentInput = event;
  }

  openLightbox(idx: number= 0): void {
    if(this.debug) {
      console.log('image.component: openLightbox(): idx ', idx);
    }
    this.openLightBox.emit(idx);
  }

  ngOnDestroy() {

    if (this.likesSubscription) {
      this.likesSubscription.unsubscribe();
    }

    if (this.deleteImageSubscription) {
      this.deleteImageSubscription.unsubscribe();
    }

  }

}
