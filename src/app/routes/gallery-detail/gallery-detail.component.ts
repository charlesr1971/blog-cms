import { Component, OnInit, OnDestroy, Inject, Renderer2, HostListener } from '@angular/core';
import { BehaviorSubject } from 'rxjs';
import { DOCUMENT } from '@angular/common';
import { DeviceDetectorService } from 'ngx-device-detector';
import { ActivatedRoute } from '@angular/router';
import { Location } from '@angular/common';

import { User } from '../../user/user.model';
import { UserService } from '../../user/user.service';
import { UtilsService } from '../../services/utils/utils.service';
import { Image } from '../../image/image.model';
import { HttpService } from '../../services/http/http.service';
import { environment } from '../../../environments/environment';

interface commentElementsPrefix {
  parentClose: string;
  refchildClose: string
};

@Component({
  selector: 'app-gallery-detail',
  templateUrl: './gallery-detail.component.html',
  styleUrls: ['./gallery-detail.component.css']
})
export class GalleryDetailComponent implements OnInit, OnDestroy {

  image:  BehaviorSubject<Image> = new BehaviorSubject<Image>(null);
  user: BehaviorSubject<User> = new BehaviorSubject<User>(null);

  isMobile: boolean = false;

  commentsTotal: number = 0;
  fileid: any = 0;
  commentsState: string = 'out';
  scrollToCommentsPanel: boolean = false;
  currentUser: BehaviorSubject<User> = new BehaviorSubject<User>(null);
  currentUserid: number = 0;
  categoryImagesUrl: string = '';
  disableCommentTooltip: boolean = false;
  disableFavouriteTooltip: boolean = false;
  hasAside: boolean = false;
  hideCommentInput: boolean = false;
  commentElementsPrefix: commentElementsPrefix  = {
    parentClose: '#gallery-detail-comments-container-',
    refchildClose: '#gallery-detail-comments-ref-'
  };
  catalogRouterAliasLower: string = environment.catalogRouterAlias;

  debug: boolean = false;

  constructor(@Inject(DOCUMENT) private documentBody: Document,
    private renderer: Renderer2,
    private httpService: HttpService,
    private userService: UserService,
    private utilsService: UtilsService,
    private deviceDetectorService: DeviceDetectorService,
    private route: ActivatedRoute,
    private location: Location) {

      if(environment.debugComponentLoadingOrder) {
        console.log('gallery-detail.component loaded');
      } 

      if(this.httpService.currentUserAuthenticated > 0) {
        this.httpService.fetchJwtData();
      }

      this.isMobile = this.deviceDetectorService.isMobile();
      this.categoryImagesUrl = this.httpService.categoryImagesUrl;

      this.fileid = this.route.snapshot.paramMap.get('id');

      this.route.queryParams.subscribe(params => {
        if(params['browserRefresh']) {
          this.location.replaceState(this.catalogRouterAliasLower + '/' + this.route.snapshot.paramMap.get('id') + '/' + this.route.snapshot.paramMap.get('title'));
        }
      });

      if(this.debug) {
        console.log('gallery-detail.component: this.fileid: ', this.fileid);
      } 

      this.httpService.fetchImage('',0,this.fileid).do(this.processImageData).subscribe();

      this.onResize();

      if(this.isMobile) {
        this.disableCommentTooltip = true;
        this.disableFavouriteTooltip = true;
      }

      if(environment.openToolbarCommentsPanel && this.isMobile) {
        this.commentsState = 'in';
      }
      else {
        this.scrollToCommentsPanel = true;
      }

  }

  ngOnInit() {

    if(environment.debugComponentLoadingOrder) {
      console.log('gallery-detail.component init');
    } 

    this.currentUser = this.userService.currentUser;

    if(this.debug) {
      console.log('gallery-detail.component: this.currentUser: ', this.currentUser);
    }  
    this.currentUserid = this.currentUser['userid'];
    if(this.debug) {
      console.log('gallery-detail.component: this.currentUserid: ',this.currentUserid);
    }

  }

  @HostListener('window:resize', ['$event']) onResize(event?) {
    if(!this.isMobile) {
      if(this.debug) {
        console.log('gallery-detail.component: window:resize: call this.addAside()');
      }
      setTimeout( () => {
        this.addAside();
      },1000);
    }
  }

  addAside(): void {
    const galleryDetail = this.documentBody.querySelector('.gallery-detail');
    const galleryDetailAside = this.documentBody.querySelector('.gallery-detail-aside');
    if(galleryDetail && galleryDetailAside) {
      const galleryDetailHeight = galleryDetail.clientHeight ? galleryDetail.clientHeight : 0;
      if(this.debug) {
        console.log('gallery-detail.component: addAside: galleryDetailHeight ',galleryDetailHeight);
      }
      this.renderer.setStyle(galleryDetailAside, 'height', galleryDetailHeight +  'px');
    }
  }

  private processImageData = (data) => {
    if(this.debug) {
      console.log('gallery-detail.component: processImageData: data: ', data);
    }
    if(data) {
      if(!this.utilsService.isEmpty(data)) {
          const image = new Image({
            id: data['fileUuid'],
            fileid: data['fileid'],
            userid: data['userid'],
            category: data['category'],
            src: this.categoryImagesUrl + '/' + data['src'],
            author: data['author'],
            title: data['title'],
            description: data['description'],
            article: data['article'],
            size: data['size'],
            likes: data['likes'],
            tags: data['tags'],
            publishArticleDate: data['publishArticleDate'],
            approved: data['approved'],
            createdAt: data['createdAt']
          });
          this.image.next(image);
          if(this.image.value['userid'] > 0) {
            const body = {
              userToken: '',
              userid: this.image.value['userid']
            };
            this.httpService.fetchUser(body).do(this.processUserData).subscribe();
          }
      }
    }
  }

  private processUserData = (data) => {
    if(this.debug) {
      console.log('gallery-detail.component: processUserData: data ',data);
    }
    if(data) {
      if('error' in data && data['error'] === '') {
        const user: User = new User({
          userid: data['userid'],
          email: data['email'],
          salt: data['salt'],
          password: data['password'],
          forename: data['forename'],
          surname: data['surname'],
          userToken: data['usertoken'],
          signUpToken: data['signuptoken'],
          signUpValidated: data['signUpValidated'],
          createdAt: data['createdat'],
          avatarSrc: data['avatarSrc'],
          emailNotification: data['emailNotification'],
          keeploggedin: data['keeploggedin'],
          submitArticleNotification: data['submitArticleNotification'],
          cookieAcceptance: data['cookieAcceptance'],
          theme: data['theme']
        });
        this.user.next(user);
      }
    }
  }

  openComments(event: any): void {
    if(this.debug) {
      console.log('gallery-detail.component: openComments: event ',event);
    }
    this.commentsState = this.commentsState === 'in' ? 'out' : 'in';
    event.stopPropagation();
  }

  sendCommentsTotal(event: any): void {
    this.commentsTotal = event;
    if(this.debug) {
      console.log('gallery-detail.component: sendCommentsTotal: event ',event);
    }
  }

  sendDisableCommentTooltip(event: any): void {
    this.disableCommentTooltip = event;
  }

  sendHideCommentInput(event: any): void {
    this.hideCommentInput = event;
  }

  ngOnDestroy() {

  }

}
