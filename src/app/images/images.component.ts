import { Component, OnInit, OnDestroy, HostListener, ViewChild, Renderer2, ElementRef, Inject } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { Lightbox, LightboxEvent, LIGHTBOX_EVENT } from 'angular2-lightbox';
import { HttpService } from '../services/http/http.service';
import { UtilsService } from '../services/utils/utils.service';
import { Image } from '../image/image.model';
import { Observable, Subscription } from 'rxjs';
import { DOCUMENT } from '@angular/common';
import { MatAutocompleteTrigger } from '@angular/material';
import { DeviceDetectorService } from 'ngx-device-detector';
import { CookieService } from 'ngx-cookie-service';

import { FormGroup, FormControl, Validators } from '@angular/forms';
import { map, startWith } from 'rxjs/operators';
import { debounceTime, distinctUntilChanged } from 'rxjs/operators';

import { environment } from '../../environments/environment';

import { User } from '../user/user.model';
import { UserService } from '../user/user.service';
import { JwtService } from '../services/jwt/jwt.service';


export interface Option {
  fileid: number;
  title: string;
  directory: string;
}

@Component({
  selector: 'app-images',
  templateUrl: './images.component.html',
  styleUrls: ['./images.component.css']
})
export class ImagesComponent implements OnInit, OnDestroy {

  @ViewChild('autoCompleteInput', { read: MatAutocompleteTrigger }) autoComplete: MatAutocompleteTrigger;

  @ViewChild('infiniteScrollerImagesContainer') infiniteScrollerImagesContainer: ElementRef;
  @ViewChild('searchFormContainer') searchFormContainer: ElementRef;
  @ViewChild('tagsFormContainer') tagsFormContainer: ElementRef;
  @ViewChild('searchSelect') searchSelect;
  @ViewChild('tagsSelect') tagsSelect;

  isMobile: boolean = false;

  currentUser: User;

  lightboxAlbum: Array<any> = [];

  search = new FormControl();
  tags = new FormControl();
  options: Option[] = [];
  filteredOptions: Observable<Option[]>;
  searchDo: boolean = false;
  tagsDo: boolean = false;
  formData = {};

  searchForm: FormGroup;
  tagsForm: FormGroup;
  fetchImageTitlesSubscription: Subscription;
  fetchTagsSubscription: Subscription;
  loginWithTokenSubscription: Subscription;
  lightboxSubscription: Subscription;

  images: Array<any> = [];
  pages = [];
  pagesTags = [];
  searchPage: number = 1;
  tagsPage: number = 1;
  currentTag: string = '';
  currentPage: number = 1;
  currentAuthorPage: number = 1;
  currentCategoryPage: number = 1;
  currentUserid: number = 0;
  currentCategory: string = '';
  currentDatePage: number = 1;
  currentYear: number = 0;
  currentMonth: number = 0;
  scrollCallbackImages;
  screenHeight: number = 0;
  screenWidth: number = 0;
  toolbarHeight: number = 64;
  searchFormHeight: number = 0;
  tagsFormHeight: number = 0;
  categoryImagesUrl: string = '';
  infiniteScrollerImagesContainerHeight: number = 0;
  userid: number = 0;
  singleImageId: string = '';
  isGalleryPage: boolean = true;
  isSection: boolean = false;
  imageCounter: number = 0;

  debug: boolean = false;

  constructor(@Inject(DOCUMENT) private documentBody: Document,
    private lightBox: Lightbox,
    private lightboxEvent: LightboxEvent,
    private httpService: HttpService,
    private utilsService: UtilsService,
    private userService: UserService,
    private deviceDetectorService: DeviceDetectorService,
    private route: ActivatedRoute,
    private cookieService: CookieService,
    private renderer: Renderer2,
    private router: Router,
    private jwtService: JwtService) { 

    if(environment.debugComponentLoadingOrder) {
      console.log('images.component loaded');
    }

    this.isMobile = this.deviceDetectorService.isMobile();

    this.categoryImagesUrl = this.httpService.categoryImagesUrl;
    this.fetchPagesTitles();

    this.route.params.subscribe( (params) => {

      if ((params['fileid'] && params['fileid'] !== '') || (params['tag'] && params['tag'] !== '')) {

        this.isGalleryPage = false;

        if(params['fileid'] && params['fileid'] !== '') {

          if(this.debug) {
            console.log('images.component: params ',params);
          }
          this.singleImageId = params['fileid'];
          this.isSection = true;
          this.images = [];
          this.removeAdverts();
          this.httpService.fetchImage(params['fileid']).do(this.processImageData).subscribe();
          this.resizeConntainer();
          this.scrollCallbackImages = null;

        }
        else{

          this.singleImageId = '';
          if(this.debug) {
            console.log('images.component: params["tag"]: ',params['tag']);
          }
          setTimeout( () => {
            this.httpService.pageTagsDo.next(params['tag']);
          });
          this.images = [];
          this.scrollCallbackImages = null;
          
        }

      }
      else{

        this.isGalleryPage = true;

        this.onResize();
        this.scrollCallbackImages = this.fetchData.bind(this);

      }

    });

    this.userService.currentUser.subscribe( (user: User) => {
      this.currentUser = user;
      if(this.debug) {
        console.log('images.component: this.currentUser: ',this.currentUser);
      }
    });

    this.httpService.galleryPage.subscribe( (page) => {
      if(page > 0) {
        this.searchDo = false;
        this.tagsDo = false;
        this.isSection = true;
        this.images = [];
        this.removeAdverts();
        this.currentPage = page;
        if(this.debug) {
          console.log('images.component: galleryPage.subscribe: this.currentPage: ', this.currentPage);
        }
        this.httpService.fetchImages(this.currentPage).do(this.processData).subscribe();
        this.scrollCallbackImages = null;
      }
    });

    this.httpService.galleryAuthor.subscribe( (data) => {
      if(data['userid'] > 0) {
        this.searchDo = false;
        this.tagsDo = false;
        this.isSection = true;
        this.images = [];
        this.removeAdverts();
        this.currentAuthorPage = data['page'];
        this.currentUserid = data['userid'];
        if(this.debug) {
          console.log('images.component: galleryAuthor.subscribe: this.currentUserid: ', this.currentUserid);
          console.log('images.component: galleryAuthor.subscribe: this.currentAuthorPage: ', this.currentAuthorPage);
        }
        this.httpService.fetchImagesByUserid(this.currentUserid,this.currentAuthorPage,data['authorName']).do(this.processDataByUserid).subscribe();
        this.scrollCallbackImages = null;
      }
    });

    this.httpService.galleryCategory.subscribe( (data) => {
      if(data['category'] !== '') {
        this.searchDo = false;
        this.tagsDo = false;
        this.isSection = true;
        this.images = [];
        this.removeAdverts();
        this.currentCategoryPage = data['page'];
        this.currentCategory = data['category'];
        if(this.debug) {
          console.log('images.component: galleryCategory.subscribe: this.currentCategory: ', this.currentCategory);
          console.log('images.component: galleryCategory.subscribe: this.currentCategoryPage: ', this.currentCategoryPage);
        }
        this.httpService.fetchImagesByCategory(this.currentCategory,this.currentCategoryPage).do(this.processDataByCategory).subscribe();
        this.scrollCallbackImages = null;
      }
    });

    this.httpService.galleryDate.subscribe( (data) => {
      if(!isNaN(data['year']) && !isNaN(data['month'])) {
        this.searchDo = false;
        this.tagsDo = false;
        this.isSection = true;
        this.images = [];
        this.removeAdverts();
        this.currentDatePage = data['page'];
        this.currentYear = data['year'];
        this.currentMonth = data['month'];
        if(this.debug) {
          console.log('images.component: galleryDate.subscribe: this.currentYear: ', this.currentYear);
          console.log('images.component: galleryDate.subscribe: this.currentMonth: ', this.currentMonth);
          console.log('images.component: galleryDate.subscribe: this.currentDatePage: ', this.currentDatePage);
        }
        this.httpService.fetchImagesByDate(this.currentYear,this.currentMonth,this.currentDatePage).do(this.processDataByDate).subscribe();
        this.scrollCallbackImages = null;
      }
    });

    this.httpService.deleteImageId.subscribe( (id) => {
      this.removeImage(id);
    });

    this.createFormControls();
    this.createForm();
    this.monitorFormValueChanges();

    if(this.debug) {
      console.log('images.component: this.tagsDo: ', this.tagsDo);
    }

  }

  ngOnInit() {

    if(environment.debugComponentLoadingOrder) {
      console.log('images.component init');
    }

    this.filteredOptions = this.search.valueChanges
    .pipe(
      startWith<string | Option>(''),
      map(value => typeof value === 'string' ? value : value.title),
      map(title => title ? this._filter(title) : this.options.slice())
    );

    this.fetchImageTitlesSubscription = this.httpService.fetchImageTitles('',this.searchPage).do(this.processImageTitlesData).subscribe();

    this.httpService.searchDo.subscribe( (data) => {
      if(this.debug) {
        console.log('images.component: this.httpService.searchDo: data ',data);
      }  
      this.searchDo = data;
      this.tagsDo = false;
      this.images = [];
      this.removeAdverts();
    });

    this.httpService.pageTagsDo.subscribe( (data: any) => {
      if(this.debug) {
        console.log('images.component: this.httpService.pageTagsDo: data ',data);
      }  
      if(data !== '') {
        this.searchDo = false;
        this.tagsDo = true;
        this.fetchPagesTags(data);
        this.images = [];
        this.removeAdverts();
      }
    });

    if(this.debug || this.httpService.debugForgottenPasswordLoginWithToken) {
      console.log('images.component: this.httpService.commentToken ',this.httpService.commentToken);
    }

    this.userService.currentUser.subscribe( (user: User) => {

      if(this.debug || this.httpService.debugForgottenPasswordLoginWithToken) {
        console.log('images.component: this.userService.currentUser.first().subscribe: user 1 ',user);
      }

      if(user) {

        if(this.debug || this.httpService.debugForgottenPasswordLoginWithToken) {
          console.log('images.component: this.userService.currentUser.first().subscribe: user 2 ',user);
        }

        if(this.httpService.commentToken !== '') {
          const themeObj = this.httpService.themeObj;
          const body = {
            email: '',
            password: '',
            userToken: this.cookieService.check('userToken') ? this.cookieService.get('userToken') : '',
            commentToken: this.httpService.commentToken,
            forgottenPasswordToken: '',
            forgottenPasswordValidated: 0,
            keeploggedin: this.currentUser ? this.currentUser['keeploggedin'] : 0,
            theme: this.currentUser && this.httpService.browserCacheCleared ? themeObj['default'] : this.currentUser['theme']
          };
          if(this.debug) {
            console.log('images.component: this.httpService.commentToken: body ',body);
          }
          this.loginWithTokenSubscription = this.httpService.fetchLogin(body).do(this.processLoginWithTokenData).subscribe();
          this.httpService.commentToken = '';
        }
        else{
          if(this.httpService.forgottenPasswordValidated > 0 && this.httpService.forgottenPasswordToken !== '') {
            if(this.debug || this.httpService.debugForgottenPasswordLoginWithToken) {
              console.log('images.component: this.httpService.forgottenPasswordValidated: inside 1 ');
            }
            const themeObj = this.httpService.themeObj;
            const body = {
              email: '',
              password: '',
              userToken: this.cookieService.check('userToken') ? this.cookieService.get('userToken') : '',
              commentToken: '',
              forgottenPasswordToken: this.httpService.forgottenPasswordToken,
              forgottenPasswordValidated: this.httpService.forgottenPasswordValidated,
              keeploggedin: this.currentUser ? this.currentUser['keeploggedin'] : 0,
              theme: this.httpService.browserCacheCleared ? themeObj['default'] : this.currentUser['theme']
            };
            if(this.debug || this.httpService.debugForgottenPasswordLoginWithToken) {
              console.log('images.component: this.httpService.forgottenPasswordValidated inside 2: body ',body);
            }
            this.loginWithTokenSubscription = this.httpService.fetchLogin(body).do(this.processLoginWithTokenData).subscribe();
            this.httpService.forgottenPasswordToken = '';
          }
        }

      }

    });

    this.httpService.commentsDialogOpened.subscribe( (data) => {
      if(this.isMobile) {
        if(this.debug) {
          console.log('images.component: this.infiniteScrollerImagesContainerHeight ',this.infiniteScrollerImagesContainerHeight);
        }
        if(data) {
          this.renderer.setStyle(this.infiniteScrollerImagesContainer.nativeElement,'overflow','hidden');
          this.renderer.setStyle(this.infiniteScrollerImagesContainer.nativeElement,'height','100%');
          this.renderer.setStyle(this.infiniteScrollerImagesContainer.nativeElement,'position','fixed');
          this.renderer.setStyle(this.infiniteScrollerImagesContainer.nativeElement,'background','#303030');
        }
        else{
          this.renderer.setStyle(this.infiniteScrollerImagesContainer.nativeElement,'overflow','auto');
          this.renderer.setStyle(this.infiniteScrollerImagesContainer.nativeElement,'height',this.infiniteScrollerImagesContainerHeight + 'px');
          this.renderer.removeStyle(this.infiniteScrollerImagesContainer.nativeElement,'position');
          this.renderer.removeStyle(this.infiniteScrollerImagesContainer.nativeElement,'background');
        }
      }
    });

    this.documentBody.querySelector('#infinite-scroller-images').addEventListener('scroll', this.onInfiniteScrollerImagesScroll.bind(this));

  }

  @HostListener('window:resize', ['$event']) onResize(event?) {
    this.resizeConntainer();
  }

  resizeConntainer(): void{
    this.screenHeight = window.innerHeight;
    if(this.debug) {
      console.log('images.component: resizeConntainer(): this.screenHeight ',this.screenHeight);
    }
    this.screenWidth = window.innerWidth;
    if(this.debug) {
      console.log('this.screenWidth: resizeConntainer(): this.screenWidth ',this.screenWidth);
    }
    setTimeout( () => {
      if(this.screenHeight > 0) {
        this.infiniteScrollerImagesContainerHeight = this.screenHeight - this.toolbarHeight;
        this.renderer.setStyle(
          this.infiniteScrollerImagesContainer.nativeElement,
          'height',
          this.infiniteScrollerImagesContainerHeight + 'px'
        );
      }
    })
  }

  onInfiniteScrollerImagesScroll(): void {
    this.searchSelect.close();
    this.tagsSelect.close();
  }

  fetchPagesTitles(): void {
    this.httpService.fetchPagesTitles().subscribe( (data) => {
      if(this.debug) {
        console.log('images.component: fetchPagesTitles: data: ',data);
      }
      if(data) {
        if(!this.utilsService.isEmpty(data) && 'pagestitles' in data && Array.isArray(data['pagestitles']) && data['pagestitles'].length) {
          for(var i = 0; i < data['pagestitles'].length; i++) {
            const obj = {};
            obj['title'] = data['pagestitles'][i];
            this.pages.push(obj);
          }
        }
      }
    });
  }

  fetchPagesTags(tag: string): void {
    this.pagesTags = [];
    this.tags.patchValue(null);
    this.httpService.fetchPagesTags(tag).subscribe( (data) => {
      if(this.debug) {
        console.log('images.component: fetchPagesTags: data: ',data);
      }
      if(data) {
        this.currentTag = tag;
        if(!this.utilsService.isEmpty(data) && 'pages' in data && data['pages'] > 0) {
          for(var i = 0; i < data['pages']; i++) {
            const obj = {};
            obj['title'] = 'Page ' + (i + 1);
            obj['tag'] = tag;
            this.pagesTags.push(obj);
          }
        }
        if(this.debug) {
          console.log('images.component: fetchPagesTags: this.pagesTags: ',this.pagesTags);
        }
      }
    });
  }

  fetchData(): Observable<any> {
    if(this.debug) {
      console.log('images.component: fetchData()');
    }
    return this.httpService.fetchImages(this.currentPage).do(this.processData);
  }

  private processLoginWithTokenData = (data) => {
    if(this.debug || this.httpService.debugForgottenPasswordLoginWithToken) {
      console.log('images.component: processLoginWithTokenData: data',data);
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
          userToken: data['userToken'],
          signUpToken: data['signUpToken'],
          signUpValidated: data['signUpValidated'],
          createdAt: data['createdAt'],
          avatarSrc: data['avatarSrc'],
          emailNotification: data['emailNotification'],
          keeploggedin: data['keeploggedin'],
          submitArticleNotification: data['submitArticleNotification'],
          cookieAcceptance: data['cookieAcceptance'],
          theme: data['theme'],
          roleid: data['roleid'],
          forgottenPasswordToken: data['forgottenPasswordToken'],
          forgottenPasswordValidated: data['forgottenPasswordValidated'],
          displayName: data['displayName']
        });
        this.cookieService.set('userToken', data['userToken']);
        if(this.debug) {
          console.log('images.component: processLoginWithTokenData: this.cookieService.get("userToken")',this.cookieService.get('userToken'));
        }
        user['authenticated'] = data['userid'];
        this.userService.setCurrentUser(user);
        this.userid = data['userid'];
        if(this.debug) {
          console.log('images.component: processLoginWithTokenData: this.currentUser ',this.currentUser);
        }
        this.httpService.userId.next(this.userid);
        this.jwtService.setJwtToken(data['jwtToken']);
        if(data['fileUuid'] !== '' && !isNaN(data['commentid'])) {
          this.openComment(data['fileUuid'], data['commentid']);
        }
        if(this.debug || this.httpService.debugForgottenPasswordLoginWithToken) {
          console.log('images.component: processLoginWithTokenData: this.httpService.isForgottenPasswordValidated 1: ',this.httpService.isForgottenPasswordValidated);
        } 
        if(data['userid'] > 0 && this.httpService.isForgottenPasswordValidated === 1 && data['isForgottenPasswordValidated'] === 1) {
          if(this.debug || this.httpService.debugForgottenPasswordLoginWithToken) {
            console.log('images.component: processLoginWithTokenData: this.httpService.isForgottenPasswordValidated 2: ',this.httpService.isForgottenPasswordValidated);
          } 
          setTimeout( () => {
            this.httpService.navigateToProfile.next(true);
          },1000);
        }
      }
    }
  }

  private processImageTitlesData = (data) => {
    if(this.debug) {
      console.log('images.component: processImageTitlesData: data',data);
    }
    if(data) {
      if('error' in data && data['error'] === '') {
        if('titles' in data && Array.isArray(data['titles']) && data['titles'].length) {
          this.options = data['titles'];
        }
      }
    }
  }

  private processImageData = (data) => {
    if(this.debug) {
      console.log('images.component: processImageData: data: ', data);
    }
    if(data) {
      if(!this.utilsService.isEmpty(data)) {
        this.images = [];
        const _data = [];
        _data.push(data);
        _data.map( (item: any) => {
          const image = new Image({
            id: item['fileUuid'],
            fileid: item['fileid'],
            userid: item['userid'],
            category: item['category'],
            src: this.categoryImagesUrl + '/' + item['src'],
            author: item['author'],
            title: item['title'],
            description: item['description'],
            article: item['article'],
            size: item['size'],
            likes: item['likes'],
            tags: item['tags'],
            publishArticleDate: item['publishArticleDate'], 
            approved: item['approved'],
            createdAt: item['createdAt'],
            avatarSrc: item['avatarSrc']
          });
          this.images.push(image);
        });
        this.sortImages();
        this.createLightboxAlbum();
        if(data['commentid'] > 0) {
          const obj = {
            fileUuid: data['fileUuid'],
            commentid: data['commentid']
          };
          this.httpService.viewCommentData.next(obj);
          this.scrollCallbackImages = null;
        }
        if(this.debug) {
          console.log('images.component: processImageData: this.images: ', this.images);
        }
      }
    }
  }

  private processTagsData = (data) => {
    if(this.debug) {
      console.log('images.component: processTagsData: data',data);
    }
    if(data) {
      this.images = [];
      data.map( (item: any) => {
        const image = new Image({
          id: item['fileUuid'],
          fileid: item['fileid'],
          userid: item['userid'],
          category: item['category'],
          src: this.categoryImagesUrl + '/' + item['src'],
          author: item['author'],
          title: item['title'],
          description: item['description'],
          article: item['article'],
          size: item['size'],
          likes: item['likes'],
          tags: item['tags'],
          publishArticleDate: item['publishArticleDate'],
          approved: item['approved'],
          createdAt: item['createdAt'],
          avatarSrc: item['avatarSrc']
        });
        this.images.push(image);
      });
      this.sortImages();
      this.createLightboxAlbum();
      if(this.images.length > 1) {
        this.singleImageId = '';
      }
      else{
        this.singleImageId = this.images[0]['id'];
      }
      if(this.debug) {
        console.log('images.component: processTagsData: this.images: ', this.images);
        console.log('images.component: this.singleImageId ',this.singleImageId);
      }
    }
  }

  private processData = (data) => {
    if(data && Array.isArray(data) && data.length > 0) {
      this.currentPage++;
      if(this.debug) {
        console.log('images.component: processData: data',data);
        console.log('images.component: processData: this.currentPage',this.currentPage);
      }
      data.map( (item: any) => {
        const image = new Image({
          id: item['fileUuid'],
          fileid: item['fileid'],
          userid: item['userid'],
          category: item['category'],
          src: this.categoryImagesUrl + '/' + item['src'],
          author: item['author'],
          title: item['title'],
          description: item['description'],
          article: item['article'],
          size: item['size'],
          likes: item['likes'],
          tags: item['tags'],
          publishArticleDate: item['publishArticleDate'],
          approved: item['approved'],
          createdAt: item['createdAt'],
          avatarSrc: item['avatarSrc']
        });
        this.images.push(image);
      });
      this.sortImages();
      this.createLightboxAlbum();
      if(this.images.length > 1) {
        this.singleImageId = '';
      }
      else{
        this.singleImageId = this.images[0]['id'];
      }
      if(this.debug) {
        console.log('images.component: processData: this.images: ', this.images);
      }
    }
  }

  private processDataByUserid = (data) => {
    if(data) {
      data.map( (item: any) => {
        const image = new Image({
          id: item['fileUuid'],
          fileid: item['fileid'],
          userid: item['userid'],
          category: item['category'],
          src: this.categoryImagesUrl + '/' + item['src'],
          author: item['author'],
          title: item['title'],
          description: item['description'],
          article: item['article'],
          size: item['size'],
          likes: item['likes'],
          tags: item['tags'],
          publishArticleDate: item['publishArticleDate'],
          approved: item['approved'],
          createdAt: item['createdAt'],
          avatarSrc: item['avatarSrc']
        });
        this.images.push(image);
      });
      this.sortImages();
      this.createLightboxAlbum();
      if(this.images.length > 1) {
        this.singleImageId = '';
      }
      else{
        this.singleImageId = this.images[0]['id'];
      }
      if(this.debug) {
        console.log('images.component: processDataByUserid: this.images: ', this.images);
      }
    }
  }

  private processDataByCategory = (data) => {
    if(data) {
      data.map( (item: any) => {
        const image = new Image({
          id: item['fileUuid'],
          fileid: item['fileid'],
          userid: item['userid'],
          category: item['category'],
          src: this.categoryImagesUrl + '/' + item['src'],
          author: item['author'],
          title: item['title'],
          description: item['description'],
          article: item['article'],
          size: item['size'],
          likes: item['likes'],
          tags: item['tags'],
          publishArticleDate: item['publishArticleDate'],
          approved: item['approved'],
          createdAt: item['createdAt'],
          avatarSrc: item['avatarSrc']
        });
        this.images.push(image);
      });
      this.sortImages();
      this.createLightboxAlbum();
      if(this.images.length > 1) {
        this.singleImageId = '';
      }
      else{
        this.singleImageId = this.images[0]['id'];
      }
      if(this.debug) {
        console.log('images.component: processDataByCategory: this.images: ', this.images);
      }
    }
  }

  private processDataByDate = (data) => {
    if(data) {
      data.map( (item: any) => {
        const image = new Image({
          id: item['fileUuid'],
          fileid: item['fileid'],
          userid: item['userid'],
          category: item['category'],
          src: this.categoryImagesUrl + '/' + item['src'],
          author: item['author'],
          title: item['title'],
          description: item['description'],
          article: item['article'],
          size: item['size'],
          likes: item['likes'],
          tags: item['tags'],
          publishArticleDate: item['publishArticleDate'],
          approved: item['approved'],
          createdAt: item['createdAt'],
          avatarSrc: item['avatarSrc']
        });
        this.images.push(image);
      });
      this.sortImages();
      this.createLightboxAlbum();
      if(this.images.length > 1) {
        this.singleImageId = '';
      }
      else{
        this.singleImageId = this.images[0]['id'];
      }
      if(this.debug) {
        console.log('images.component: processDataByDate: this.images: ', this.images);
      }
    }
  }

  createForm(): void {
    this.searchForm = new FormGroup({
      search: this.search
    });
    this.tagsForm = new FormGroup({
      tags: this.tags
    });
  }

  createFormControls(): void {
    this.search = new FormControl('', [
      Validators.required,
      Validators.minLength(1)
    ]);
    this.tags = new FormControl('', [
      Validators.required,
      Validators.minLength(1)
    ]);
  }

  monitorFormValueChanges(): void {
    if(this.searchForm) {
      this.search.valueChanges
      .pipe(
        debounceTime(400),
        distinctUntilChanged()
      )
      .subscribe(search => {
        if(this.debug) {
          console.log('search: ',search);
        }
        this.formData['search'] = search;
      });
    }
  }

  openComment(fileUuid: string = '', commentid: number = 0): void {
    if(this.debug) {
      console.log('images.component: openComment: fileUuid: ', fileUuid);
      console.log('images.component: openComment: commentid: ', commentid);
    }
    this.singleImageId = fileUuid;
    this.httpService.fetchImage(fileUuid,commentid).do(this.processImageData).subscribe();
  }

  onSearchChange(event): void {
    const page = event.source.value;
    if(this.debug) {
      console.log('onSearchChange: page: ', page);
    }
    this.searchPage = page;
    this.fetchImageTitlesSubscription = this.httpService.fetchImageTitles('',this.searchPage).do(this.processImageTitlesData).subscribe();
  }

  onTagChange(event): void {
    const page = event.source.value;
    if(this.debug) {
      console.log('onTagChange: page: ', page);
      console.log('onTagChange: this.currentTag: ', this.currentTag);
    }
    this.tagsPage = page;
    this.fetchTagsSubscription = this.httpService.fetchTags(this.currentTag,this.tagsPage).do(this.processTagsData).subscribe();
    this.scrollCallbackImages = null;
  }

  searchImage(): void {
    const id = this.formData['search']['fileUuid'];
    if(this.debug) {
      console.log('images.component: searchImage: id: ', id);
      console.log('images.component: searchImage: this.formData["search"]: ', this.formData['search']);
    }
    if(id && id !== '') {
      this.singleImageId = id;
      setTimeout( () => {
        this.autoComplete.closePanel();
      });
      this.httpService.fetchImage(id).do(this.processImageData).subscribe();
      this.scrollCallbackImages = null;
    }
    else{
      this.singleImageId = '';
      if(this.debug) {
        console.log('images.component: searchImage: null');
      }
      this.httpService.searchReset.next(true);
    }
  }

  displayFn(option?: Option): string | undefined {
    return option ? option.title : undefined;
  }

  private _filter(title: string): Option[] {
    const filterValue = title.toLowerCase();
    return this.options.filter(option => option.title.toLowerCase().includes(filterValue));
  }

  closeSearch(): void {
    if(this.debug) {
      console.log('images.component: closeSearch');
    }
    this.httpService.searchReset.next(true);
  }

  closeTags(): void {
    if(this.debug) {
      console.log('images.component: closeTags');
    }
    this.httpService.searchReset.next(true);
  }

  imagesApproved(): boolean {
    const approved = true;
    const temp = this.images.filter( (image: any) => {
      return image['approved'] === 0;
    });
    if(temp.length > 0){
      return false;
    }
    return approved;
  }

  sortImages(): void {
    this.images.sort(function(a, b) {
      const dateA: any = new Date(a.createdAt), dateB: any = new Date(b.createdAt);
      return dateB - dateA;
    });
  }

  removeImage(id: any): void {
    const images = this.images.filter( (image) => {
      return image['id'] !== id;
    });
    this.images = images;
    this.sortImages();
    if(this.debug) {
      console.log('images.component: removeImage: this.images: ', this.images);
    }
  }

  removeAdverts(): void {
    const adverts = Array.prototype.slice.call(this.documentBody.querySelectorAll('.app-advert'));
    if(Array.isArray(adverts) && adverts.length > 0) {
      adverts.map( (advert) => {
        //this.renderer.setStyle(advert,'display','none');
        advert.remove();
      });
    }
  }

  createLightboxAlbum(): void {
    this.lightboxAlbum = [];
    this.images.map( (obj) => {
      const image = {
        src: obj['src']
      };
      this.lightboxAlbum.push(image);
    });
    if(this.debug) {
      console.log('images.component: createLightboxAlbum: this.lightboxAlbum: ', this.lightboxAlbum);
    }
  }

  openLightbox(idx: number = 0): void{   
    this.lightBox.open(this.lightboxAlbum,idx,{disableScrolling:true,centerVertically:true,showImageNumberLabel:false});
    this.createLighboxListener();
    this.renderer.setStyle(this.documentBody.body,'overflow','hidden');
    if(this.debug) {
      console.log('images.component: openLightbox: idx: ', idx);
    }
  }

  createLighboxListener(): void {
    // register your subscription and callback whe open lightbox is fired
    if(this.debug) {
      console.log('images.component: createLighboxListener');
    }
    this.lightboxSubscription = this.lightboxEvent.lightboxEvent$.subscribe( (event) => {
      return this.onLighboxReceivedEvent(event);
    });
  }
 
  private onLighboxReceivedEvent(event: any): void {

    // remember to unsubscribe the event when lightbox is closed
    if (event.id === LIGHTBOX_EVENT.CLOSE) {
      // event CLOSED is fired
      if(this.debug) {
        console.log('images.component: onLighboxReceivedEvent: LIGHTBOX_EVENT.CLOSE');
      }
      this.lightboxSubscription.unsubscribe();
    }
 
    if (event.id === LIGHTBOX_EVENT.OPEN) {
      if(this.debug) {
        console.log('images.component: onLighboxReceivedEvent: LIGHTBOX_EVENT.OPEN');
      }
      // event OPEN is fired
    }
 
    if (event.id === LIGHTBOX_EVENT.CHANGE_PAGE) {
      if(this.debug) {
        console.log('images.component: onLighboxReceivedEvent: LIGHTBOX_EVENT.CHANGE_PAGE');
      }
      // event change page is fired
      if(this.debug) {
        console.log(event.data);
      }
    }

  }

  ngOnDestroy() {

    if (this.fetchImageTitlesSubscription) {
      this.fetchImageTitlesSubscription.unsubscribe();
    }

    if(this.fetchTagsSubscription) {
      this.fetchTagsSubscription.unsubscribe();
    }

    if(this.loginWithTokenSubscription) {
      this.loginWithTokenSubscription.unsubscribe();
    }

  }

}
