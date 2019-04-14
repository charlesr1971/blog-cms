import { Component, OnInit, OnDestroy, ElementRef, ViewChild, Renderer2, Input, Inject, TemplateRef } from '@angular/core';
import { Subscription } from 'rxjs';
import { debounceTime, distinctUntilChanged } from 'rxjs/operators';
import { FormGroup, FormControl, Validators } from '@angular/forms';
import { trigger, state, style, animate, transition, AnimationEvent} from '@angular/animations';
import { DeviceDetectorService } from 'ngx-device-detector';
import { DomSanitizer, SafeHtml } from '@angular/platform-browser';
import { CookieService } from 'ngx-cookie-service';
import { DOCUMENT } from '@angular/common';
import { uuid } from '../../util/uuid';
import { addImage } from '../../util/addImage';
import { updateCdkOverlayThemeClass } from '../../util/updateCdkOverlayThemeClass';
import { Router } from '@angular/router';
import { MatSnackBar, MatSnackBarConfig, MatDialog } from '@angular/material';
import { DialogAccountDeleteComponent } from '../../dialog-account-delete/dialog-account-delete.component';
import { UtilsService } from '../../services/utils/utils.service';
import { CategoryEditComponent } from '../../help/dialogs/category-edit/category-edit.component';
import * as _ from 'lodash';
import { AgGridNg2 } from 'ag-grid-angular';
import { SafePipe } from '../../pipes/safe/safe.pipe';

import { UploadService } from '../../upload/upload.service';
import { HttpService } from '../../services/http/http.service';

import { Image } from '../../image/image.model';
import { User } from '../../user/user.model';
import { UserService } from '../../user/user.service';
import { JwtService } from '../../services/jwt/jwt.service';

import { environment } from '../../../environments/environment';
import { max } from 'moment';

declare var TweenMax: any, Elastic: any;

@Component({
  selector: 'app-profile',
  templateUrl: './profile.component.html',
  styleUrls: ['./profile.component.css'],
  animations: [
    trigger('profileApiDashboardFadeInOutAnimation', [
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
      trigger('profileCategoryEditFadeInOutAnimation', [
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
    trigger('profileUserArchiveEditFadeInOutAnimation', [
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
  ],
  providers: [SafePipe]
})
export class ProfileComponent implements OnInit, OnDestroy {

  @ViewChild('avatarContainer') avatarContainer;
  @ViewChild('modal') modal;
  @ViewChild('unapprovedImagesSelect') unapprovedImagesSelect;
  @ViewChild('approvedImagesSelect') approvedImagesSelect;
  @ViewChild('dialogEditCategoriesHelpNotification') private dialogEditCategoriesHelpNotificationTpl: TemplateRef<any>;
  @ViewChild('dialogEditCategoriesHelpNotificationText') dialogEditCategoriesHelpNotificationText: ElementRef;
  @ViewChild('agGridUserArchive') agGridUserArchive: AgGridNg2;
  @Input() profileApiDashboardState: string = 'out';
  @Input() profileCategoryEditState: string = 'out';
  @Input() profileUserArchiveEditState: string = 'in';


  themeObj = {};
  themeRemove: string = '';
  themeAdd: string = '';

  imagesUnapproved: Array<any> = [];
  pageCacheUnapproved = {};
  pagesUnapproved = [];
  currentPageUnapproved: number = 1;

  imagesApproved: Array<any> = [];
  pageCacheApproved = {};
  pagesApproved = [];
  currentPageApproved: number = 1;
  
  editProfileForm: FormGroup;

  forename: FormControl;
  surname: FormControl;
  password: FormControl;
  emailNotification: FormControl;
  theme: FormControl;
  jwtToken: FormControl;
  userToken: FormControl;
  useridFC: FormControl;
  apiDocumentation: FormControl;
  apiEndpoint: FormControl;

  emailNotificationChecked = false;
  themeChecked = false;
  
  formData = {};
  apiUrl: string = '';

  isMobile: boolean = false;
  hasError: boolean = false;
  safeHtml: SafeHtml;
  isEditProfileValid: boolean = false;
  editProfileValidated: number = 0;
  editProfileSubscription: Subscription;
  deleteProfileSubscription: Subscription;
  imagesUnapprovedByUseridSubscription: Subscription;
  imagesApprovedByUseridSubscription: Subscription;
  usersArchiveGetSubscription: Subscription;
  usersArchivePostSubscription: Subscription;
  currentUser: User;
  closeResult: string;
  categoryImagesUrl: string = '';
  userid: number = 0;
  disableCommentGeneralTooltip: boolean = false;
  uploadRouterAliasLower: string = environment.uploadRouterAlias;
  dialogEditCategoriesHeight: number = 0;
  userAccountDeleteSchema: number = 2;
  userArchiveHasNoData: boolean = false;

  gridApiUserArchive;
  gridColumnApiUserArchive;
  userArchiveColumnDefs = [];
  userArchiveRowData = [];
  userArchiveDefaultColDef =  {};
  userArchiveThemeIsLight: boolean = true;
  userArchiveDomLayout: string = '';
  userArchiveRowClassRules = {};

  
  debug: boolean = false;

  constructor(@Inject(DOCUMENT) private documentBody: Document,
    private httpService: HttpService,
    private renderer: Renderer2,
    public el: ElementRef,
    private deviceDetectorService: DeviceDetectorService,
    private sanitizer: DomSanitizer,
    private userService: UserService,
    private cookieService: CookieService,
    private router: Router,
    private uploadService: UploadService,
    private jwtService: JwtService,
    public matSnackBar: MatSnackBar,
    private utilsService: UtilsService,
    private safePipe: SafePipe,
    public dialog: MatDialog) { 

      if(environment.debugComponentLoadingOrder) {
        console.log('profile.component loaded');
      }

      //this.gridApiUserArchive.sizeColumnsToFit();

      this.userAccountDeleteSchema = this.httpService.userAccountDeleteSchema;

      this.themeObj = this.httpService.themeObj;
      this.themeRemove = this.cookieService.check('theme') && this.cookieService.get('theme') === this.themeObj['light'] ? this.themeObj['dark'] : this.themeObj['light'];
      this.themeAdd = this.themeRemove === this.themeObj['light'] ? this.themeObj['dark'] : this.themeObj['light'];

      this.userArchiveThemeIsLight = this.cookieService.check('theme') && this.cookieService.get('theme') === this.themeObj['light'] ? true : false;

      if(this.httpService.currentUserAuthenticated > 0) {
        this.httpService.fetchJwtData();
      }

      this.isMobile = this.deviceDetectorService.isMobile();

      if(this.isMobile) {
        this.disableCommentGeneralTooltip = true;
      }

      this.categoryImagesUrl = this.httpService.categoryImagesUrl;
      this.fetchPagesUnapproved();
      this.fetchPagesApproved();

      this.userService.currentUser.subscribe( (user: User) => {
        this.currentUser = user;
        this.userid = this.currentUser['userid'];
        this.createFormControls();
        this.createForm();
        this.monitorFormValueChanges();
        setTimeout( () => {
          this.forename.patchValue(this.currentUser['forename']);
          this.surname.patchValue(this.currentUser['surname']);
          this.emailNotification.patchValue(!!+this.currentUser['emailNotification']);
          this.theme.patchValue(this.currentUser['theme'] === this.themeObj['dark'] ? false : true);
          if(this.debug) {
            console.log('profile.component: this.currentUser["theme"]: ',this.currentUser['theme']);
            console.log('profile.component: this.themeObj["dark"]: ',this.themeObj['dark']);
            console.log('profile.component: this.theme.value: ',this.theme.value);
          }
          this.jwtToken.patchValue(this.jwtService.getJwtToken());
          this.userToken.patchValue(this.currentUser['userToken']);
          this.useridFC.patchValue(this.currentUser['userid']);
          this.apiDocumentation.patchValue(environment.apiDocumentationUrl);
          this.apiEndpoint.patchValue(environment.apiEndpointUrl);
        });
        if(this.debug) {
          console.log('profile.component: this.currentUser: ',this.currentUser);
        }
        const data = {
          imagePath: '',
          name: '',
          title: '',
          description: '',
          article: '',
          uploadType: 'avatar',
          userToken: this.currentUser['userToken'],
          mode: 'add',
          fileUuid: ''
        }
        if(this.debug) {
          console.log('profile.component: data: ',data);
        }
        setTimeout( () => {
          this.httpService.subjectImagePath.next(data);
          if(this.currentUser['avatarSrc'] && this.currentUser['avatarSrc'] !== '') {
            addImage(TweenMax, this.renderer, this.avatarContainer, this.currentUser['avatarSrc'], 'avatarImage');
          }
        });
      });

      this.uploadService.subscriptionImageUrl.subscribe( (data: any) => {
        if(this.debug) {
          console.log('profile.component: subscriptionImageUrl: data: ',data);
        }
        if(data['uploadType'] === 'avatar') {
          this.currentUser['avatarSrc'] = data['imageUrl'];
          this.userService.setCurrentUser(this.currentUser);
          addImage(TweenMax, this.renderer, this.avatarContainer, data['imageUrl'], 'avatarImage');
        }
      });

      setTimeout( () => {

        this.httpService.chooseImageButtonText.next('Choose Avatar');

      });

      //this.userArchiveDomLayout = "normal";

      /* this.userArchiveRowClassRules = {
        "user-archive-row-even": function(params) {
          if (params.node.rowIndex % 2 === 0) {
            return 'user-archive-row-odd';
          }
        }
      }; */
      
      this.usersArchiveGetSubscription = this.httpService.fetchUsersArchive().do(this.processUsersArchiveGetData).subscribe();

  }

  ngOnInit() {

    if(environment.debugComponentLoadingOrder) {
      console.log('profile.component init');
    }

    this.documentBody.querySelector('#mat-sidenav-content').addEventListener('scroll', this.onMatSidenavContentScroll.bind(this));

  }

  onMatSidenavContentScroll(): void {
    if(this.pagesUnapproved.length > 0) {
      this.unapprovedImagesSelect.close();
    }
    if(this.pagesApproved.length > 0) {
      this.approvedImagesSelect.close();
    }
  }

  fetchPagesUnapproved(): void {
    this.httpService.fetchPagesUnapproved().subscribe( (data) => {
      if(this.debug) {
        console.log('profile.component: fetchPagesUnapproved: data: ',data);
      }
      if(data) {
        if(!this.utilsService.isEmpty(data) && 'pagestitles' in data && Array.isArray(data['pagestitles']) && data['pagestitles'].length) {
          for(var i = 0; i < data['pagestitles'].length; i++) {
            const obj = {};
            obj['title'] = data['pagestitles'][i];
            this.pagesUnapproved.push(obj);
          }
        }
      }
    });
  }

  fetchPagesApproved(): void {
    this.httpService.fetchPagesApproved().subscribe( (data) => {
      if(this.debug) {
        console.log('profile.component: fetchPagesApproved: data: ',data);
      }
      if(data) {
        if(!this.utilsService.isEmpty(data) && 'pagestitles' in data && Array.isArray(data['pagestitles']) && data['pagestitles'].length) {
          for(var i = 0; i < data['pagestitles'].length; i++) {
            const obj = {};
            obj['title'] = data['pagestitles'][i];
            this.pagesApproved.push(obj);
          }
        }
      }
    });
  }

  editProfileFormSubmit(): void {
    const body = {
      forename: this.forename.value,
      surname: this.surname.value,
      password: this.password.value ? this.password.value : '',
      emailNotification: this.emailNotification.value,
      theme: this.theme.value ? this.themeObj['light'] : this.themeObj['dark'],
      userid: this.userid
    };
    if(this.debug) {
      console.log('profile.component: editProfileFormSubmit: body',body);
    }
    this.editProfileSubscription = this.httpService.editUser(body).do(this.processEditProfileData).subscribe();
  }

  private processUsersArchiveGetData = (data) => {
    if(this.debug) {
      console.log('profile.component: processUsersArchiveGetData: data',data);
    }
    if(data) {
      if('error' in data && data['error'] === '' && 'columnDefs' in data && Array.isArray(data['columnDefs']) && data['columnDefs'].length > 0 && 'rowData' in data && Array.isArray(data['rowData']) && data['rowData'].length > 0) {
        this.userArchiveColumnDefs = data['columnDefs'];
        this.userArchiveRowData = data['rowData'];
      }
      else{
        if('jwtObj' in data && !data['jwtObj']['jwtAuthenticated']) {
          this.httpService.jwtHandler(data['jwtObj']);
        }
        else{
          this.openSnackBar(data['error'], 'Error');
          this.userArchiveHasNoData = true;
        }
      }
    }
  }

  private processUsersArchivePostData = (data) => {
    if(this.debug) {
      console.log('profile.component: processUsersArchivePostData: data',data);
    }
    if(data) {
      if('error' in data && data['error'] === '' && 'columnDefs' in data && Array.isArray(data['columnDefs']) && data['columnDefs'].length > 0 && 'rowData' in data && Array.isArray(data['rowData']) && data['rowData'].length > 0) {
        this.userArchiveColumnDefs = data['columnDefs'];
        this.userArchiveRowData = data['rowData'];
        this.refreshUserArchive();
      }
      else{
        if('jwtObj' in data && !data['jwtObj']['jwtAuthenticated']) {
          this.httpService.jwtHandler(data['jwtObj']);
        }
        else{
          this.openSnackBar(data['error'], 'Error');
          this.userArchiveHasNoData = true;
        }
      }
    }
  }

  private processEditProfileData = (data) => {
    if(this.debug) {
      console.log('profile.component: processEditProfileData: data',data);
    }
    if(data) {
      if('error' in data && data['error'] === '') {
        const user: User = new User({
          userid: data['userid'],
          email: data['email'],
          salt: data['salt'],
          password: this.password.value,
          forename: data['forename'],
          surname: data['surname'],
          userToken: this.cookieService.get('userToken'),
          signUpToken: data['signUpToken'],
          signUpValidated: data['signUpValidated'],
          createdAt: data['createdAt'],
          avatarSrc: data['avatarSrc'],
          emailNotification: data['emailNotification'],
          keeploggedin: data['keeploggedin'],
          submitArticleNotification: data['submitArticleNotification'],
          cookieAcceptance: data['cookieAcceptance'],
          theme: data['theme'],
          roleid: data['roleid']
        });
        this.userService.setCurrentUser(user);
        this.currentUser['authenticated'] = this.userid;
        this.emailNotificationChecked = !!+this.currentUser['emailNotification'];
        this.themeChecked = this.currentUser['theme'] === this.themeObj['dark'] ? false : true;
        const themeType = data['theme'] === this.themeObj['light'] ? this.themeObj['light'] : this.themeObj['dark'];
        this.httpService.themeType.next(themeType);
        this.themeRemove = this.cookieService.check('theme') && this.cookieService.get('theme') === this.themeObj['light'] ? this.themeObj['dark'] : this.themeObj['light'];
        this.themeAdd = this.themeRemove === this.themeObj['light'] ? this.themeObj['dark'] : this.themeObj['light'];
        this.userArchiveThemeIsLight = this.cookieService.check('theme') && this.cookieService.get('theme') === this.themeObj['light'] ? true : false;
        this.openSnackBar('Changes have been submitted...', 'Success');
      }
      else{
        if('jwtObj' in data && !data['jwtObj']['jwtAuthenticated']) {
          this.httpService.jwtHandler(data['jwtObj']);
        }
        else{
          this.openSnackBar(data['error'], 'Error');
        }
      }
    }
  }

  deleteProfileFormSubmit(): void {
    this.openDialog();
  }

  deleteProfile(): void {
    const body = {
      userid: this.userid
    };
    if(this.debug) {
      console.log('profile.component: deleteProfileFormSubmit: body',body);
    }
    this.deleteProfileSubscription = this.httpService.deleteUser(body).do(this.processDeleteProfileData).subscribe();
  }

  private processDeleteProfileData = (data) => {
    if(this.debug) {
      console.log('profile.component: processDeleteProfileData: data',data);
    }
    if(data) {
      if('error' in data && data['error'] === '') {
        const user: User = new User();
        this.userService.setCurrentUser(user);
        let userToken = '';
        if(!this.cookieService.check('userToken') || (this.cookieService.check('userToken') && this.cookieService.get('userToken') === '')) {
          const expired = new Date();
          expired.setDate(expired.getDate() + 365);
          this.cookieService.set('userToken', uuid(), expired);
          userToken = this.cookieService.get('userToken');
        }
        else{
          userToken = this.cookieService.get('userToken');
        }
        if(this.cookieService.check('cookieAcceptance')) {
          this.cookieService.delete('cookieAcceptance');
        }
        if(this.cookieService.check('theme')) {
          this.cookieService.delete('theme');
        }
        this.jwtService.removeJwtToken();
        this.currentUser['userToken'] = userToken;
        this.router.navigate([this.uploadRouterAliasLower, {formType: 'login'}]);
      }
      else{
        if('jwtObj' in data && !data['jwtObj']['jwtAuthenticated']) {
          this.httpService.jwtHandler(data['jwtObj']);
        }
        else{
          this.openSnackBar(data['error'], 'Error');
        }
      }
    }
  }

  private imagesUnapprovedByUseridData = (data) => {
    if(this.debug) {
      console.log('profile.component: imagesUnapprovedByUseridData: data',data);
    }
    if(data) {
      this.imagesUnapproved = [];
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
          createdAt: item['createdAt']
        });
        this.imagesUnapproved.push(image);
      });
      this.sortImages();
      this.pageCacheUnapprovedEntryCreate(this.imagesUnapproved, this.currentPageUnapproved);
      if(this.debug) {
        console.log('profile.component: imagesUnapprovedByUseridData: this.pageCacheUnapproved: ', this.pageCacheUnapproved);
      }
      setTimeout( () => {
        this.animateImages('unapproved');
      });
    }
  }

  private imagesApprovedByUseridData = (data) => {
    if(this.debug) {
      console.log('profile.component: imagesApprovedByUseridData: data',data);
    }
    if(data) {
      this.imagesApproved = [];
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
          createdAt: item['createdAt']
        });
        this.imagesApproved.push(image);
      });
      this.sortImages();
      this.pageCacheApprovedEntryCreate(this.imagesApproved, this.currentPageApproved);
      if(this.debug) {
        console.log('profile.component: imagesApprovedByUseridData: this.pageCacheApproved: ', this.pageCacheApproved);
      }
      setTimeout( () => {
        this.animateImages('approved');
      });
    }
  }

  animateImages(type: string): void {
    const className1 = '.image-thumbnail-list-item-image-' + type + '-img';
    const className2 = '.image-thumbnail-list-item-image-' + type;
    const className3 = '.image-thumbnail-list-item-' + type;
    const imagethumbnaillistitemimageimg = Array.prototype.slice.call(this.documentBody.querySelectorAll(className1));
    if(!this.isMobile && imagethumbnaillistitemimageimg.length > 1) {
      const imagethumbnaillistitemimage = Array.prototype.slice.call(this.documentBody.querySelectorAll(className2));
      const imgHeights = [];
      imagethumbnaillistitemimageimg.map( (element) => {
        const height = element.clientHeight ? element.clientHeight : 0;
        if(height > 0) {
          imgHeights.push(height);
        }
      });
      const maxHeight = Math.max.apply(null,imgHeights);
      if(this.debug) {
        console.log('images.component: animateImages: imgHeights: ', imgHeights);
        console.log('images.component: animateImages: maxHeight: ', maxHeight);
      }
      if(!isNaN(maxHeight) && maxHeight > 0) {
        imagethumbnaillistitemimage.map( (element) => {
          this.renderer.setStyle(element,'height',maxHeight + 'px');
        });
      }
    }
    TweenMax.staggerFromTo(className3, 1, {scale:0, ease:Elastic.easeOut, opacity: 0}, {scale:1, ease:Elastic.easeOut, opacity: 1}, 0.1);
    if(this.debug) {
      const imagethumbnaillistitem = this.documentBody.querySelector(className3);
      console.log('images.component: animateImages: imagethumbnaillistitem: ', imagethumbnaillistitem);
      if(type === 'unapproved') {
        console.log('images.component: animateImages: this.imagesUnapproved: ', this.imagesUnapproved);
      }
      else{
        console.log('images.component: animateImages: this.imagesApproved: ', this.imagesApproved);
      }
    }
  }

  createForm(): void {
    this.editProfileForm = new FormGroup({
      forename: this.forename,
      surname: this.surname,
      password: this.password,
      emailNotification: this.emailNotification,
      theme: this.theme,
      jwtToken: this.jwtToken,
      userToken: this.userToken,
      useridFC: this.useridFC,
      apiDocumentation: this.apiDocumentation,
      apiEndpoint: this.apiEndpoint
    });
    if(this.debug) {
      console.log('profile.component: this.editProfileForm ',this.editProfileForm);
    }
  }

  createFormControls(): void {
    this.forename = new FormControl('', [
      Validators.required,
      Validators.minLength(1)
    ]);
    this.surname = new FormControl('', [
      Validators.required,
      Validators.minLength(1)
    ]);
    this.password = new FormControl();
    this.emailNotification = new FormControl();
    this.theme = new FormControl(); 
    this.jwtToken = new FormControl();
    this.userToken = new FormControl();
    this.useridFC = new FormControl();
    this.apiDocumentation = new FormControl(); 
    this.apiEndpoint = new FormControl(); 
  }

  monitorFormValueChanges(): void {
    if(this.editProfileForm) {
      this.forename.valueChanges
      .pipe(
        debounceTime(400),
        distinctUntilChanged()
      )
      .subscribe(forename => {
        if(this.debug) {
          console.log('profile.component: forename: ',forename);
        }
        this.formData['forename'] = forename;
        this.isEditProfileValid = this.isEditProfileFormValid();
      });
      this.surname.valueChanges
      .pipe(
        debounceTime(400),
        distinctUntilChanged()
      )
      .subscribe(surname => {
        if(this.debug) {
          console.log('profile.component: surname: ',surname);
        }
        this.formData['surname'] = surname;
        this.isEditProfileValid = this.isEditProfileFormValid();
      });
      this.password.valueChanges
      .pipe(
        debounceTime(400),
        distinctUntilChanged()
      )
      .subscribe(password => {
        if(this.debug) {
          console.log('profile.component: password: ',password);
        }
        this.formData['password'] = password;
        this.isEditProfileValid = this.isEditProfileFormValid();
      });
      this.emailNotification.valueChanges
      .pipe(
        debounceTime(400),
        distinctUntilChanged()
      )
      .subscribe(emailNotification => {
        if(this.debug) {
          console.log('profile.component: emailNotification: ',emailNotification);
        }
        this.formData['emailNotification'] = emailNotification ? 1 : 0;
      });
      this.theme.valueChanges
      .pipe(
        debounceTime(400),
        distinctUntilChanged()
      )
      .subscribe(theme => {
        if(this.debug) {
          console.log('profile.component: theme: ',theme);
        }
      });
    }
  }

  pageCacheUnapprovedEntryRead(page: number): any {
    const result = this.sortArrayObj(this.pageCacheUnapproved[page]);
    return result;
  }

  pageCacheUnapprovedEntryCreate(arr: any, page: number): void {
    this.pageCacheUnapproved[page] = arr;
  }

  pageCacheUnapprovedEntryExists(page: number): boolean {
    const bool = !this.utilsService.isEmpty(this.pageCacheUnapproved) && page in this.pageCacheUnapproved;
    if(this.debug) {
      console.log('profile.component: pageCacheUnapprovedEntryExists: ', bool);
    }
    return bool;
  }

  pageCacheApprovedEntryRead(page: number): any {
    const result = this.sortArrayObj(this.pageCacheApproved[page]);
    return result;
  }

  pageCacheApprovedEntryCreate(arr: any, page: number): void {
    this.pageCacheApproved[page] = arr;
  }

  pageCacheApprovedEntryExists(page: number): boolean {
    const bool = !this.utilsService.isEmpty(this.pageCacheApproved) && page in this.pageCacheApproved;
    if(this.debug) {
      console.log('profile.component: pageCacheApprovedEntryExists: ', bool);
    }
    return bool;
  }

  onChangeUnapproved(event): void {
    if(this.debug) {
      console.log('profile.component: onChangeUnapproved: event: ', event);
    }
    const page = event.source ? event.source.value : event;
    this.currentPageUnapproved = page;
    if(this.debug) {
      console.log('profile.component: onChangeUnapproved: page: ', page);
    }
    const imagethumbnailcontainerunapproved = this.documentBody.querySelector('#image-thumbnail-container-unapproved');
    if(imagethumbnailcontainerunapproved) {
      const styles = getComputedStyle(imagethumbnailcontainerunapproved);
      this.renderer.setStyle(imagethumbnailcontainerunapproved,'display','block');
    }
    const pageCacheUnapprovedEntryExists = this.pageCacheUnapprovedEntryExists(this.currentPageUnapproved);
    if(this.debug) {
      console.log('profile.component: onChangeUnapproved: pageCacheUnapprovedEntryExists: ', pageCacheUnapprovedEntryExists);
    }
    if(!pageCacheUnapprovedEntryExists) {
      this.imagesUnapprovedByUseridSubscription = this.httpService.fetchImagesUnapprovedByUserid(page).do(this.imagesUnapprovedByUseridData).subscribe();
    }
    else{
      this.imagesUnapproved = this.pageCacheUnapprovedEntryRead(this.currentPageUnapproved);
      setTimeout( () => {
        this.animateImages('unapproved');
      });
    }
  }

  onChangeApproved(event): void {
    if(this.debug) {
      console.log('profile.component: onChangeApproved: event: ', event);
    }
    const page = event.source ? event.source.value : event;
    this.currentPageApproved = page;
    if(this.debug) {
      console.log('profile.component: onChangeApproved: page: ', page);
    }
    const imagethumbnailcontainerapproved = this.documentBody.querySelector('#image-thumbnail-container-approved');
    if(imagethumbnailcontainerapproved) {
      const styles = getComputedStyle(imagethumbnailcontainerapproved);
      this.renderer.setStyle(imagethumbnailcontainerapproved,'display','block');
    }
    const pageCacheApprovedEntryExists = this.pageCacheApprovedEntryExists(this.currentPageApproved);
    if(this.debug) {
      console.log('profile.component: onChangeApproved: pageCacheApprovedEntryExists: ', pageCacheApprovedEntryExists);
    }
    if(!pageCacheApprovedEntryExists) {
      this.imagesApprovedByUseridSubscription = this.httpService.fetchImagesApproved(page).do(this.imagesApprovedByUseridData).subscribe();
    }
    else{
      this.imagesApproved = this.pageCacheApprovedEntryRead(this.currentPageApproved);
      setTimeout( () => {
        this.animateImages('approved');
      });
    }
  }

  isEditProfileFormValid(): boolean {
    return this.forename.value !== '' && this.surname.value !== '' ? true : false;
  }

  toggleError(error: string): void {
    this.safeHtml = this.sanitizer.bypassSecurityTrustHtml(error);
    this.hasError = error !== '' ? true : false;
  }

  openProfileApiDashboard(event: any): void {
    this.profileApiDashboardState = this.profileApiDashboardState === 'in' ? 'out' : 'in';
    event.stopPropagation();
  }

  openProfileCategoryEdit(event: any): void {
    this.profileCategoryEditState = this.profileCategoryEditState === 'in' ? 'out' : 'in';
    event.stopPropagation();
  }

  openProfileUserArchiveEdit(event: any): void {
    this.profileUserArchiveEditState = this.profileUserArchiveEditState === 'in' ? 'out' : 'in';
    event.stopPropagation();
  }

  toggleUnapprovedImages(event: any): void {
    event.stopPropagation();
    const imagethumbnailcontainerunapproved = this.documentBody.querySelector('#image-thumbnail-container-unapproved');
    if(this.debug) {
      console.log('profile.component: toggleUnapprovedImages(): imagethumbnailcontainerunapproved: ', imagethumbnailcontainerunapproved);
    }
    if(imagethumbnailcontainerunapproved) {
      const styles = getComputedStyle(imagethumbnailcontainerunapproved);
      if(this.debug) {
        console.log('profile.component: toggleUnapprovedImages(): styles: ', styles);
      }
      styles.display === 'block' ? this.renderer.setStyle(imagethumbnailcontainerunapproved,'display','none') : this.renderer.setStyle(imagethumbnailcontainerunapproved,'display','block');
    }
  }

  toggleApprovedImages(event: any): void {
    event.stopPropagation();
    const imagethumbnailcontainerapproved = this.documentBody.querySelector('#image-thumbnail-container-approved');
    if(this.debug) {
      console.log('profile.component: toggleApprovedImages(): imagethumbnailcontainerapproved: ', imagethumbnailcontainerapproved);
    }
    if(imagethumbnailcontainerapproved) {
      const styles = getComputedStyle(imagethumbnailcontainerapproved);
      if(this.debug) {
        console.log('profile.component: toggleApprovedImages(): styles: ', styles);
      }
      styles.display === 'block' ? this.renderer.setStyle(imagethumbnailcontainerapproved,'display','none') : this.renderer.setStyle(imagethumbnailcontainerapproved,'display','block');
    }
  }

  goToApiDocumentation(event: any): void {
    window.open(environment.apiDocumentationUrl,'_blank');
    event.stopPropagation();
  }

  sortImages(): void {
    this.imagesUnapproved.sort(function(a, b) {
      const dateA: any = new Date(a.createdAt), dateB: any = new Date(b.createdAt);
      return dateB - dateA;
    });
  }

  sortArrayObj(arr: any): any {
    const result = arr.sort(function(a, b) {
      const dateA: any = new Date(a.createdAt), dateB: any = new Date(b.createdAt);
      return dateB - dateA;
    });
    return result;
  }

  openDialog(): void {
    const dialogRef = this.dialog.open(DialogAccountDeleteComponent, {
      width: this.isMobile ? '90%' :'25%'
    });
    updateCdkOverlayThemeClass(this.themeRemove,this.themeAdd);
    dialogRef.afterClosed().subscribe(result => {
      if(this.debug) {
        console.log('profile.component: openDialog(): The dialog was closed');
      }
      if(result) {
        this.deleteProfile();
        if(this.debug) {
          console.log('profile.component: openDialog(): The action was approved');
        }
      }
    });
  }

  openEditCategoriesHelpNotificationDialog(): void {
    const dialogRef = this.dialog.open(CategoryEditComponent, {
      width: this.isMobile ? '100%' :'50%',
      height: this.isMobile ? '100%' :'75%',
      maxWidth: this.isMobile ? '100%' :'50%',
      hasBackdrop: false,
      disableClose: true,
      id: 'dialog-edit-categories-help-notification'
    });
    if(this.debug) {
      console.log('tree-dynamic: dialog edit categories help notification: before close: this.themeRemove: ', this.themeRemove);
      console.log('tree-dynamic: dialog edit categories help notification: before close: this.themeAdd: ', this.themeAdd);
    }
    updateCdkOverlayThemeClass(this.themeRemove,this.themeAdd);
    dialogRef.beforeClose().subscribe(result => {
      if(this.debug) {
        console.log('tree-dynamic: dialog edit categories help notification: before close');
      }
      if(result) {
        if(this.debug) {
          console.log('tree-dynamic: dialog edit categories help notification: before close: result: ', result);
        }
      }
    });
    dialogRef.afterOpen().subscribe( () => {
      if(this.debug) {
        console.log('tree-dynamic: dialog edit categories help notification: after open');
      }
      const parent = document.querySelector('#dialog-edit-categories-help-notification');
      let height = parent.clientHeight ? parent.clientHeight : 0;
      const offsetHeight = 150;
      if(!isNaN(height) && (height - offsetHeight) > 0) {
        height = height - offsetHeight;
      }
      if(height > 0 ) {
        this.dialogEditCategoriesHeight = height;
        this.httpService.editCategoriesDialogOpened.next(this.dialogEditCategoriesHeight);
      }
      if(this.debug) {
        console.log('tree-dynamic: dialog: this.dialogEditCategoriesHeight: ', this.dialogEditCategoriesHeight);
      }
    });
  }

  openSnackBar(message: string, action: string): void {
    const config = new MatSnackBarConfig();
    config.panelClass = ['custom-class'];
    config.duration = 5000;
    this.matSnackBar.open(message, action, config);
  }

  userArchiveAutoSizeAll(): void {
    var allColumnIds = [];
    this.gridColumnApiUserArchive.getAllColumns().forEach(function(column) {
      allColumnIds.push(column.colId);
    });
    this.gridColumnApiUserArchive.autoSizeColumns(allColumnIds);
  }

  onUserArchiveGridReady(params): void {
    this.gridApiUserArchive = params.api;
    this.gridColumnApiUserArchive = params.columnApi;
    this.gridApiUserArchive.setDomLayout("autoHeight");
    setTimeout( () => {
      this.userArchiveAutoSizeAll();
    });
  }

  getUserArchiveSelectedRows(): void {
    const selectedNodes = this.agGridUserArchive.api.getSelectedNodes();
    const selectedData = selectedNodes.map( node => node.data );
    const selectedDataStringPresentation = selectedData.map( node => node.USER_ID).join(',');
    if(this.debug) {
      console.log('tree-dynamic: getUserArchiveSelectedRows: selectedDataStringPresentation: ', selectedDataStringPresentation);
    }
    this.usersArchivePostSubscription = this.httpService.addUsersFromArchive(selectedDataStringPresentation).do(this.processUsersArchivePostData).subscribe();
  }

  refreshUserArchive(): void {
    var params = {force:true};
    this.gridApiUserArchive.refreshCells(params);
  }

  ngOnDestroy() {

    if (this.editProfileSubscription) {
      this.editProfileSubscription.unsubscribe();
    }

    if (this.deleteProfileSubscription) {
      this.deleteProfileSubscription.unsubscribe();
    }

    if (this.imagesUnapprovedByUseridSubscription) {
      this.imagesUnapprovedByUseridSubscription.unsubscribe();
    }

    if (this.imagesApprovedByUseridSubscription) {
      this.imagesApprovedByUseridSubscription.unsubscribe();
    }

    if(this.usersArchiveGetSubscription) {
      this.usersArchiveGetSubscription.unsubscribe();
    }

    if(this.usersArchivePostSubscription) {
      this.usersArchivePostSubscription.unsubscribe();
    }

  }

}
