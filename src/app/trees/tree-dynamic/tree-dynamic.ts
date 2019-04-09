import { CollectionViewer, SelectionChange } from '@angular/cdk/collections';
import { FlatTreeControl } from '@angular/cdk/tree';
import { Component, Injectable, OnInit, OnDestroy, Inject, ElementRef, ViewChild, Renderer2, TemplateRef } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { BehaviorSubject, merge, Observable, Subscription } from 'rxjs';
import { debounceTime, distinctUntilChanged } from 'rxjs/operators';
import { map } from 'rxjs/operators';
import { HttpClient } from '@angular/common/http';
import { FormGroup, FormControl, Validators } from '@angular/forms';
import { DeviceDetectorService } from 'ngx-device-detector';
import { DOCUMENT } from '@angular/common'; 
import { DomSanitizer, SafeHtml } from '@angular/platform-browser';
import { CookieService } from 'ngx-cookie-service';
import { addImage } from '../../util/addImage';
import { sortTags } from '../../util/sortTags';
import { MatSnackBar, MatSnackBarConfig } from '@angular/material';
import { MatDialog } from '@angular/material';
import { MomentDateAdapter } from '@angular/material-moment-adapter';
import { DateAdapter, MAT_DATE_FORMATS, MAT_DATE_LOCALE } from '@angular/material/core';
import { SeoTitleFormatPipe } from '../../pipes/seo-title-format/seo-title-format.pipe';
import { getUriMatches } from '../../util/regexUtils';
import { titleFromAlias } from '../../util/titleFromAlias';
import { updateCdkOverlayThemeClass } from '../../util/updateCdkOverlayThemeClass';

import * as _moment from 'moment';

import { HttpService } from '../../services/http/http.service';
import { UploadService } from '../../upload/upload.service';
import { JwtService } from '../../services/jwt/jwt.service';

import { User } from '../../user/user.model';
import { UserService } from '../../user/user.service';

import { environment } from '../../../environments/environment';

declare var TweenMax: any, Elastic: any;

const moment = _moment;

// See the Moment.js docs for the meaning of these formats:
// https://momentjs.com/docs/#/displaying/format/
export const MY_FORMATS = {
  parse: {
    dateInput: 'LL',
  },
  display: {
    dateInput: 'LL',
    monthYearLabel: 'MMM YYYY',
    dateA11yLabel: 'LL',
    monthYearA11yLabel: 'MMMM YYYY',
  },
};

/** Flat node with expandable and level information */

export class DynamicFlatNode {
  constructor(public item: string, public level = 1, public expandable = false,
              public isLoading = false, public alias: string) {}
}

/**
 * Database for dynamic data. When expanding a node in the tree, the data source will need to fetch
 * the descendants data from the database.
 */

@Injectable()
export class DynamicDatabase  {

  dataChange = new BehaviorSubject<DynamicFlatNode[]>([]);
  dataMap = new Map<string, string[]>();
  rootLevelNodes: string[] = [];
  http: Observable<any>;
  httpService;

  debug: boolean = false;

  constructor(httpService: HttpService) {
    
    this.httpService = httpService;
    this.fetchData();

  }

  fetchData(): void {
    this.http = this.httpService.fetchDirectoryTree().subscribe( (data: any) => {
      if(data) {
        this.dataMap = new Map<string, string[]>(data);
        if(this.debug) {
          console.log('DynamicDatabase: fetchData(): this.dataMap: ', this.dataMap);
        }
        for (const value of data) {
          if(Array.isArray(value) && value.length > 0){
            this.rootLevelNodes.push(value[0]);
          }
        }
        if(this.debug) {
          console.log('DynamicDatabase: fetchData(): this.rootLevelNodes: ', this.rootLevelNodes);
        }
        this.dataChange.next(this.rootLevelNodes.map(name => new DynamicFlatNode(name, 0, true, false, this.pathFormat(name))));
      }
    });
  }

  /** Initial data from database */
  initialData(): DynamicFlatNode[] {
    return this.rootLevelNodes.map(name => new DynamicFlatNode(name, 0, true, false, this.pathFormat(name)));
  }

  getChildren(node: string): string[] | undefined {
    return this.dataMap.get(node);
  }

  isExpandable(node: string): boolean {
    return this.dataMap.has(node);
  }

  pathFormat(alias: string): any {
    let last:any = alias.split('//');
    last = Array.isArray(last) ? last[last.length-1] : alias;
    return last;
  }

}

/**
 * File database, it can build a tree structured Json object from string.
 * Each node in Json object represents a file or a directory. For a file, it has filename and type.
 * For a directory, it has filename and children (a list of files or directories).
 * The input will be a json object string, and the output is a list of `FileNode` with nested
 * structure.
 */

@Injectable()
export class DynamicDataSource {

  dataChange = new BehaviorSubject<DynamicFlatNode[]>([]);

  get data(): DynamicFlatNode[] { return this.dataChange.value; }
  set data(value: DynamicFlatNode[]) {
    this.treeControl.dataNodes = value;
    this.dataChange.next(value);
  }

  constructor(private treeControl: FlatTreeControl<DynamicFlatNode>,
              private database: DynamicDatabase) {}

  connect(collectionViewer: CollectionViewer): Observable<DynamicFlatNode[]> {
    this.treeControl.expansionModel.onChange!.subscribe(change => {
      if ((change as SelectionChange<DynamicFlatNode>).added ||
        (change as SelectionChange<DynamicFlatNode>).removed) {
        this.handleTreeControl(change as SelectionChange<DynamicFlatNode>);
      }
    });
    return merge(collectionViewer.viewChange, this.dataChange).pipe(map(() => this.data));
  }

  /** Handle expand/collapse behaviors */

  handleTreeControl(change: SelectionChange<DynamicFlatNode>): void {
    if (change.added) {
      change.added.forEach(node => this.toggleNode(node, true));
    }
    if (change.removed) {
      change.removed.slice().reverse().forEach(node => this.toggleNode(node, false));
    }
  }

  /**
   * Toggle the node, remove from display list
   */

  toggleNode(node: DynamicFlatNode, expand: boolean): void {
    const children = this.database.getChildren(node.item);
    const index = this.data.indexOf(node);
    if (!children || index < 0) { // If no children, or cannot find the node, no op
      return;
    }

    node.isLoading = true;

    setTimeout(() => {
      if (expand) {
        const nodes = children.map(name =>
          new DynamicFlatNode(name, node.level + 1, this.database.isExpandable(name), false, this.database.pathFormat(name)));
        this.data.splice(index + 1, 0, ...nodes);
      } else {
        let count = 0;
        for (let i = index + 1; i < this.data.length
          && this.data[i].level > node.level; i++, count++) {}
        this.data.splice(index + 1, count);
      }

      // notify the change
      this.dataChange.next(this.data);
      node.isLoading = false;
    }, 1000);
  }
}

/**
 * @title Tree with dynamic data
 */

@Component({
  selector: 'app-tree-dynamic',
  templateUrl: 'tree-dynamic.html',
  styleUrls: ['tree-dynamic.css'],
  providers: [
    SeoTitleFormatPipe,
    DynamicDatabase,
    // `MomentDateAdapter` can be automatically provided by importing `MomentDateModule` in your
    // application's root module. We provide it at the component level here, due to limitations of
    // our example generation script.
    {provide: DateAdapter, useClass: MomentDateAdapter, deps: [MAT_DATE_LOCALE]},

    {provide: MAT_DATE_FORMATS, useValue: MY_FORMATS},
    
  ],
})
export class TreeDynamic implements OnInit, OnDestroy {

  private userToken: string = '';

  @ViewChild('uploadedImageContainer') uploadedImageContainer;
  @ViewChild('dialogArticle') private dialogArticleTpl: TemplateRef<any>;
  @ViewChild('dialogSubmitArticleNotification') private dialogSubmitArticleNotificationTpl: TemplateRef<any>;
  @ViewChild('dialogArticleMaxWordCountNotification') private dialogArticleMaxWordCountNotificationTpl: TemplateRef<any>;
  @ViewChild('dialogArticleHelpNotification') private dialogArticleHelpNotificationTpl: TemplateRef<any>;
  @ViewChild('dialogArticleHelpNotificationText') dialogArticleHelpNotificationText: ElementRef;


  public tinyMceSettings = {
    skin_url: '/assets/tinymce/skins/lightgray',
    inline: false,
    statusbar: false,
    browser_spellcheck: true,
    height: 320,
    plugins: 'fullscreen',
  };

  public validators = [this.containsPunctuation];

  public errorMessages = {
    'containsPunctuation': 'Tags cannot contain punctuation except for a hypen',
  };

  tagsArray = [];
  imagePath: string;
  selectedFile: File;
  directorySelected: string;
  treeForm: FormGroup;
  signUpForm: FormGroup;
  loginForm: FormGroup;
  submitArticleNotificationForm: FormGroup;
  name: FormControl;
  maxNameLength: number = 20;
  title: FormControl;
  maxTitleLength: number = 40;
  description: FormControl;
  publishArticleDate: FormControl;
  maxDescriptionLength: number = 140;
  tags: FormControl;
  maxTagsLength: number = 20;
  maxcontentlengthInMb: string = '0';
  htmlStr: string = '';

  forename: FormControl;
  surname: FormControl;
  email: FormControl;
  password: FormControl;
  captcha:  FormControl;
  keeploggedin: FormControl;
  submitArticleNotification: FormControl;
  
  formData = {};
  apiUrl: string = '';

  treeControl: FlatTreeControl<DynamicFlatNode>;
  dataSource: DynamicDataSource;
  isMobile: boolean = false;
  hasError: boolean = false;
  safeHtml: SafeHtml;
  isSignUpValid: boolean = false;
  isLoginValid: boolean = false;
  isEditImageValid: boolean = true;
  signUpValidated: number = 0;
  signupSubscription: Subscription;
  editImageSubscription: Subscription;
  currentUser: User;
  mode: string = 'add';
  editImageId: string = '';
  fileImageId: number = 0;
  categoryImagesUrl: string = '';
  dialogArticleHeight: number = 0;
  tinyMceArticleElementId: string = 'tinyMceArticle';
  tinyMceArticleContent: string = '';
  disableArticleTooltip: boolean = false;
  tinymceArticleImageCount: number = 0;
  tinyMceArticleMaxWordCount: number = environment.tinymcearticlemaxwordcount;
  tinymceArticleImages = [];
  themeRemove: string = '';
  themeAdd: string = '';
  hasUnsavedChanges: boolean = false;
  userid: number = 0;
  catalogRouterAliasLower: string = environment.catalogRouterAlias;
  catalogRouterAliasTitle: string = titleFromAlias(environment.catalogRouterAlias);
  uploadRouterAliasLower: string = environment.uploadRouterAlias;
  googleRecaptchaSiteKey: string = environment.googleRecaptchaSiteKey;

  debug: boolean = false;

  getLevel = (node: DynamicFlatNode) => node.level;
  isExpandable = (node: DynamicFlatNode) => node.expandable;
  hasChild = (_: number, _nodeData: DynamicFlatNode) => _nodeData.expandable;

  constructor(@Inject(DOCUMENT) private documentBody: Document, 
    database: DynamicDatabase, 
    private http: HttpClient,
    private httpService: HttpService,
    private uploadService: UploadService,
    private renderer: Renderer2,
    public el: ElementRef,
    private deviceDetectorService: DeviceDetectorService,
    private sanitizer: DomSanitizer,
    private cookieService: CookieService,
    private route: ActivatedRoute,
    public matSnackBar: MatSnackBar,
    public dialog: MatDialog,
    private seoTitleFormatPipe: SeoTitleFormatPipe,
    private router: Router,
    private userService: UserService,
    private jwtService: JwtService) {

    if(environment.debugComponentLoadingOrder) {
      console.log('tree-dynamic.component loaded');
    }

    const themeObj = this.httpService.themeObj;
    this.themeRemove = this.cookieService.check('theme') && this.cookieService.get('theme') === themeObj['light'] ? themeObj['dark'] : themeObj['light'];
    this.themeAdd = this.themeRemove === themeObj['light'] ? themeObj['dark'] : themeObj['light'];

    this.apiUrl = this.httpService.apiUrl;
    this.categoryImagesUrl = this.httpService.categoryImagesUrl;

    this.treeControl = new FlatTreeControl<DynamicFlatNode>(this.getLevel, this.isExpandable);
    this.dataSource = new DynamicDataSource(this.treeControl, database);

    database.dataChange.subscribe(data => {
      this.dataSource.data = data;
    });

    this.isMobile = this.deviceDetectorService.isMobile();

    this.userService.currentUser.subscribe( (user: User) => {
      this.currentUser = user;
      this.signUpValidated = this.currentUser['signUpValidated'];
      this.createFormControls();
      this.createForm();
      this.monitorFormValueChanges();
      if(this.keeploggedin) {
        if(this.debug) {
          console.log('tree-dynamic: constructor: userService.currentUser: this.currentUser["keeploggedin"]:  ',this.currentUser['keeploggedin']);
        }
        this.keeploggedin.patchValue(!!+this.currentUser['keeploggedin']);
      }
      if(this.debug) {
        console.log('tree-dynamic: constructor: userService.currentUser: this.currentUser:  ',this.currentUser);
      }
      if(this.debug) {
        console.log('tree-dynamic: this.currentUser: ',this.currentUser);
      }
    });

    const maxcontentlength = Number(this.httpService.maxcontentlength);
    this.maxcontentlengthInMb = (maxcontentlength/1000000).toFixed(2);
    this.htmlStr = 'The image uploaded must be less than ' + this.maxcontentlengthInMb + 'MB';

    this.isMobile = this.deviceDetectorService.isMobile();

    if(this.isMobile) {
      this.disableArticleTooltip = true;
    }

  }

  ngOnInit() {

    if(environment.debugComponentLoadingOrder) {
      console.log('tree-dynamic.component init');
    }

    setTimeout( () => {

      this.route.params.subscribe( (params) => {
        if(this.debug) {
          console.log('tree-dynamic.component: this.route.params.subscribe ',params);
        }
        if(this.debug) {
          console.log('tree-dynamic.component: this.cookieService.get("userToken")',this.cookieService.get('userToken'));
          console.log('tree-dynamic.component: ngOnInit: this.currentUser ',this.currentUser);
        }
        if (params['formType'] && params['formType'] === 'login') { 
          this.signUpValidated = 1;
          if(this.debug) {
            console.log('tree-dynamic: login');
          }
        }
        if (params['formType'] && params['formType'] === 'logout') { 
          this.signUpValidated = 1;
          this.userid = 0;
          this.currentUser['authenticated'] = 0;
          this.currentUser['avatarSrc'] = '';
          this.currentUser['keeploggedin'] = 0;
          this.userService.setCurrentUser(this.currentUser);
          this.httpService.userId.next(0);
          this.httpService.login.next(false);
          if(this.debug) {
            console.log('tree-dynamic: logout');
          }
        }
        if (params['formType'] && params['formType'] === 'uploadPhoto') {
          this.signUpValidated = this.currentUser ? this.currentUser['signUpValidated'] : 0;
          this.userid = this.currentUser['authenticated'];
          this.mode = 'add';
          const maxcontentlength = Number(this.httpService.maxcontentlength);
          this.maxcontentlengthInMb = (maxcontentlength/1000000).toFixed(2);
          this.htmlStr = 'The image uploaded must be less than ' + this.maxcontentlengthInMb + 'MB';
          const uploadedimagecontainer = this.documentBody.querySelector('#uploaded-image-container');
          if(uploadedimagecontainer){
            uploadedimagecontainer.innerHTML = this.htmlStr;
          }
          this.editImageId = '';
          this.fileImageId = 0;
          if(this.debug) {
            console.log('tree-dynamic: upload photo: this.userid ',this.userid);
            console.log('tree-dynamic: upload photo');
          }
        }
        if (params['fileid'] && params['fileid'] !== '') {
          this.signUpValidated = this.currentUser ? this.currentUser['signUpValidated'] : 0;
          this.userid = this.currentUser['authenticated'];
          this.mode = 'edit';
          this.editImageId = params['fileid'];
          if(this.debug) {
            console.log('tree-dynamic: editFile: params["fileid"] ',params['fileid']);
            console.log('tree-dynamic: editFile');
          }
          this.createFormControls();
          this.createForm();
          this.monitorFormValueChanges();
          if(this.debug) {
            console.log('tree-dynamic: before this this.fetchImage');
          }
          if(this.debug) {
            console.log('tree-dynamic: ngOnInit: this.fileImageId: ', this.fileImageId);
          }
          this.fetchImage(params['fileid']);
        }
        if(this.debug) {
          console.log('tree-dynamic: this.signUpValidated: ',this.signUpValidated);
        }
        if (params['formType']) {
          this.createFormControls();
          this.createForm();
          this.monitorFormValueChanges();
        }
        if(this.debug) {
          console.log('tree-dynamic: params: ',params);
        }
      });

    });

    this.uploadService.subscriptionImageError.subscribe( (data: any) => {
      if(this.debug) {
        console.log('tree-dynamic: subscriptionImageError: data', data);
      }
      this.toggleError(data);
    });

    this.uploadService.subscriptionImageUrl.subscribe( (data: any) => {
      if(this.debug) {
        console.log('tree.dynamic: data: ',data);
      }
      if(data['uploadType'] === 'gallery') {
        addImage(TweenMax, this.renderer, this.uploadedImageContainer, data['imageUrl'], 'uploadedImage');
        this.httpService.galleryImageAdded.next(true);
      }
    });

    this.httpService.tinymceArticleDeletedImages.subscribe( (data: any) => {
      this.formData['tinymceArticleDeletedImages'] = data;
      this.httpService.subjectImagePath.next(this.formData);
      if(this.debug) {
        console.log('tree.dynamic: this.formData: ',this.formData);
      }
    });

    if(this.cookieService.check('userToken')) {
      this.userToken = this.cookieService.get( 'userToken' );
    }

    if(this.debug) {
      console.log('this.userToken',this.userToken);
    }

    this.httpService.tinymceArticleOnChange.subscribe( (data: any) => {
      this.formData['article'] = data;
      this.httpService.subjectImagePath.next(this.formData);
      if(this.debug) {
        console.log('tree-dynamic: this.httpService.tinymceArticleOnChange: this.formData: ', this.formData);
      }
    });

    this.httpService.tinymceArticleMetaData.subscribe( (data: any) => {
      if(this.debug) {
        console.log('tree-dynamic: this.httpService.tinymceArticleMetaData: data: ', data);
      }
      if('words' in data && !isNaN(data['words']) && this.tinyMceArticleMaxWordCount > 0){
        if(data['words'] > this.tinyMceArticleMaxWordCount){
          const dialogarticlemaxwordcountnotification = this.documentBody.querySelector('#dialog-article-max-word-count-notification');
          if(this.debug) {
            console.log('tree-dynamic: this.httpService.tinymceArticleMetaData: dialogarticlemaxwordcountnotification: ', dialogarticlemaxwordcountnotification);
          }
          if(!dialogarticlemaxwordcountnotification) {
            try {
              this.openArticleMaxWordCountNotificationDialog();
            }
            catch(e) {
              if(this.debug) {
                console.log('tree-dynamic: this.httpService.tinymceArticleMetaData: error: ', e);
              }
            }
          }
        }
      }
    });

    this.httpService.tinymceArticleHasUnsavedChanges.subscribe( (bool: boolean) => {
      this.hasUnsavedChanges = bool;
    });

    const initialNumericValue = this.currentUser ? this.currentUser['submitArticleNotification'] : 1;
    this.formData['submitArticleNotification'] = initialNumericValue;
    const initialBoolValue = this.currentUser ? !!+this.currentUser['submitArticleNotification'] : true;
    this.submitArticleNotification = new FormControl(initialBoolValue);
    if(this.debug) {
      console.log('tree-dynamic: ngOnInit: this.formData["submitArticleNotification"]: ',this.formData['submitArticleNotification']);
    }
    this.submitArticleNotificationForm = new FormGroup({
      submitArticleNotification: this.submitArticleNotification
    });
    this.submitArticleNotification.valueChanges
    .pipe(
      debounceTime(400),
      distinctUntilChanged()
    )
    .subscribe(submitArticleNotification => {
      if(this.debug) {
        console.log('tree-dynamic: submitArticleNotification.valueChanges: submitArticleNotification: ',submitArticleNotification);
      }
      this.formData['submitArticleNotification'] = submitArticleNotification ? 1 : 0;
      if(this.debug) {
        console.log('tree-dynamic: submitArticleNotification.valueChanges: this.formData["submitArticleNotification"]: ',this.formData['submitArticleNotification']);
      }
    });

    if(this.debug) {
      console.log('tree-dynamic: ngOnInit loaded...');
    }

  }

  next(): void {
    this.httpService.fetchImageNextPrevious(this.editImageId,'next',this.userid).do(this.processNextImageData).subscribe();
  }

  previous(): void {
    this.httpService.fetchImageNextPrevious(this.editImageId,'previous',this.userid).do(this.processPreviousImageData).subscribe();
  }

  fetchImage(id: string): void {
    if(this.debug) {
      console.log('tree-dynamic: fetchImage(): id: ', id);
    }
    this.httpService.fetchImage(id).do(this.processImageData).subscribe();
  }

  editImage(id: string): void {
    const body = {
      fileUuid: id,
      imagePath: this.imagePath,
      name: this.formData['name'],
      title: this.formData['title'],
      description: this.formData['description'],
      article: this.formData['article'],
      tags: this.formData['tags'],
      publishArticleDate: '_d' in this.formData['publishArticleDate'] ? new Date(this.formData['publishArticleDate']['_d']) : '',
      tinymceArticleDeletedImages: this.formData['tinymceArticleDeletedImages'] || [],
      submitArticleNotification: this.formData['submitArticleNotification'] || 0
    };
    if(this.debug) {
      console.log('tree-dynamic: editImage: body',body);
    }
    if(this.debug) {
      console.log('tree-dynamic: editImage: this.formData["submitArticleNotification"]: ',this.formData['submitArticleNotification']);
    }
    this.editImageSubscription = this.httpService.editImage(body).do(this.processEditImageData).subscribe();
  }

  deferEditImage(id: string): void {
    if(this.debug) {
      console.log('tree-dynamic: deferEditImage: id ',id);
    }
    if(this.formData['submitArticleNotification']) {
      this.openSubmitArticleNotificationDialog();
    }
    else{
      this.editImage(this.editImageId);
      this.dialog.closeAll();
    }
  }

  public fetchAutocompleteItems = (term: string): Observable<Response> => {
    return this.httpService.fetchAutocompleteItemsObservable(term);
  }

  signUpFormSubmit(): void {
    const body = {
      forename: this.forename.value,
      surname: this.surname.value,
      email: this.email.value,
      password: this.password.value,
      userToken: this.userToken
    };
    if(this.debug) {
      console.log('signUp: body',body);
    }
    this.signupSubscription = this.httpService.fetchSignUp(body).do(this.processSignUpData).subscribe();
  }

  loginFormSubmit(): void {
    const themeObj = this.httpService.themeObj;
    const body = {
      email: this.email.value,
      password: this.password.value,
      userToken: this.userToken,
      commentToken: '',
      keeploggedin: this.keeploggedin.value,
      theme: this.httpService.browserCacheCleared ? themeObj['default'] : this.currentUser['theme']
    };
    if(this.debug) {
      console.log('login: body',body);
    }
    this.signupSubscription = this.httpService.fetchLogin(body).do(this.processLoginData).subscribe();
  }

  private processImageData = (data) => {
    if(this.debug) {
      console.log('tree-dynamic: processImageData: data: ', data);
    }
    if(data) {
      this.name.patchValue(data['author']);
      this.title.patchValue(data['title']);
      this.description.patchValue(data['description']);
      this.tinyMceArticleContent = data['article'];
      this.formData['article'] = data['article'];
      this.publishArticleDate.patchValue(moment(new Date(data['publishArticleDate']),'MMMM DD, YYYY'));
      this.fileImageId = data['fileid'];
      if(this.debug) {
        console.log('tree-dynamic: processImageData: this.fileImageId: ', this.fileImageId);
      }
      if((typeof data['tags'] === 'string' || data['tags'] instanceof String) && data['tags'] !== '') {
        const tags = JSON.parse(data['tags']);
        tags.sort(sortTags);
        this.tags.patchValue(tags);
      }
      const node = this.extractTreeNode(data['imagePath']);
      if(this.debug) {
        console.log('tree-dynamic: processImageData: node: ', node);
      }
      this.imagePath = node;
      this.isEditImageValid = true;
      addImage(TweenMax, this.renderer, this.uploadedImageContainer, this.categoryImagesUrl + '/' + data['imagePath'], 'uploadedImage');
      if(data['imagePath'] === '') {
        this.isEditImageValid = false;
      }
      this.tinymceArticleImageCount = data['tinymceArticleImageCount'];
      const regex = /<img\s+[^>]*?src=("|')([^'"]+)/ig;
      this.tinymceArticleImages = getUriMatches(data['article'], regex, 2);
      if(this.debug) {
        console.log('tree-dynamic: processImageData: this.tinymceArticleImageCount',this.tinymceArticleImageCount);
        console.log('tree-dynamic: processImageData: this.tinymceArticleImages',this.tinymceArticleImages);
      }
      if(this.submitArticleNotification) {
        this.submitArticleNotification.patchValue(!!+data['submitArticleNotification']);
      }
    }
  }

  private processEditImageData = (data) => {
    if(this.debug) {
      console.log('processEditImageData: data',data);
    }
    if(data) {
      if('error' in data && data['error'] === '') {
        this.tinyMceArticleContent = data['article'];
        this.tinymceArticleImageCount = data['tinymceArticleImageCount'];
        const regex = /<img\s+[^>]*?src=("|')([^'"]+)/ig;
        this.tinymceArticleImages = getUriMatches(data['article'], regex, 2);
        this.currentUser['submitArticleNotification'] = data['submitArticleNotification'];
        if(this.debug) {
          console.log('tree-dynamic: processEditImageData: this.tinymceArticleImageCount',this.tinymceArticleImageCount);
          console.log('tree-dynamic: processEditImageData: this.tinymceArticleImages',this.tinymceArticleImages);
        }
        this.hasUnsavedChanges = false;
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

  private processSignUpData = (data) => {
    if(this.debug) {
      console.log('tree-dynamic: processSignUpData: data',data);
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
          createdAt: data['createdat'],
          submitArticleNotification: 1,
          cookieAcceptance: data['cookieAcceptance'],
          roleid: data['roleid']
        });
        this.userService.setCurrentUser(user);
        this.openSnackBar('Please check your e-mail to validate your sign up', 'Success');
        this.router.navigate([this.catalogRouterAliasLower]);
      }
      else{
        this.openSnackBar(data['error'], 'Error');
      }
    }
  }

  private processLoginData = (data) => {
    if(this.debug) {
      console.log('tree-dynamic: processLoginData: data',data);
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
          roleid: data['roleid']
        });
        this.cookieService.set('userToken', data['userToken']);
        if(this.debug) {
          console.log('tree-dynamic.component: processLoginData: this.cookieService.get("userToken")',this.cookieService.get('userToken'));
        }
        user['authenticated'] = data['userid'];
        this.userService.setCurrentUser(user);
        this.userid = data['userid'];
        if(this.debug) {
          console.log('tree-dynamic.component: processLoginData: this.currentUser ',this.currentUser);
        }
        this.httpService.login.next(true);
        this.httpService.userId.next(this.userid);
        this.jwtService.setJwtToken(data['jwtToken']);
        if(this.userid > 0) {
          this.createFormControls();
          this.createForm();
          this.monitorFormValueChanges();
        }
        else{
          if(this.currentUser['signUpValidated']) {
            this.openSnackBar('Login failed. Please try again...', 'Error');
          }
          else{
            this.openSnackBar('Login failed. Please sign-up...', 'Error');
          }
        }
        const cookieAcceptance = this.cookieService.check('cookieAcceptance') ? parseInt(this.cookieService.get('cookieAcceptance')) : null;
        if((cookieAcceptance === null || (cookieAcceptance !== null && cookieAcceptance === 0)) && data['cookieAcceptance'] === 1) {
          const cookieAcceptanceExpired = new Date();
          cookieAcceptanceExpired.setDate(cookieAcceptanceExpired.getDate() + 365);
          this.cookieService.set('cookieAcceptance', '1', cookieAcceptanceExpired);
          if(this.debug) {
            console.log('tree-dynamic: processLoginData: cookieAcceptanceExpired',cookieAcceptanceExpired);
            console.log('tree-dynamic: processLoginData: this.cookieService.get("cookieAcceptance")',this.cookieService.get('cookieAcceptance'));
          }
        }
        if(this.debug) {
          console.log('tree-dynamic: processLoginData: this.cookieService.get("cookieAcceptance")',this.cookieService.get('cookieAcceptance'));
        }
      }
      else{
        this.openSnackBar(data['error'], 'Error');
        this.httpService.login.next(false);
      }
    }
  }

  createForm(): void {
    if(this.userid > 0 && this.signUpValidated === 1) {
      this.treeForm = new FormGroup({
        name: this.name,
        title: this.title,
        description: this.description,
        publishArticleDate: this.publishArticleDate,
        tags: this.tags
      });
    }
    else{
      if(this.userid === 0 && this.signUpValidated === 0) {
        this.signUpForm = new FormGroup({
          forename: this.forename,
          surname: this.surname,
          email: this.email,
          password: this.password
        });
      }
      else{
        this.loginForm = new FormGroup({
          email: this.email,
          password: this.password,
          keeploggedin: this.keeploggedin,
          captcha: this.captcha,
        });
      }
    }
    if(this.debug) {
      console.log('this.treeForm ',this.treeForm);
      console.log('this.signUpForm ',this.signUpForm);
      console.log('this.loginForm ',this.loginForm);
    }
  }

  createFormControls(): void {
    if(this.userid > 0 && this.signUpValidated === 1) {
      this.name = new FormControl('', [
        Validators.required,
        Validators.minLength(1),
        Validators.maxLength(this.maxNameLength)
      ]);
      this.title = new FormControl('', [
        Validators.required,
        Validators.minLength(1),
        Validators.maxLength(this.maxTitleLength)
      ]);
      this.description = new FormControl('', [
        Validators.required,
        Validators.minLength(1),
        Validators.maxLength(this.maxDescriptionLength)
      ]);
      this.tags = new FormControl('', [
        Validators.required,
        Validators.minLength(1),
        Validators.maxLength(this.maxTagsLength)
      ]);
      this.publishArticleDate = new FormControl(moment());
      this.submitArticleNotification = new FormControl();
      if(this.debug) {
        console.log('tree-dynamic: createFormControls: 1');
      }
    }
    else{
      if(this.userid === 0 && this.signUpValidated === 0) {
        this.forename = new FormControl('', [
          Validators.required,
          Validators.minLength(1)
        ]);
        this.surname = new FormControl('', [
          Validators.required,
          Validators.minLength(1)
        ]);
        if(this.debug) {
          console.log('tree-dynamic: createFormControls: 2');
        }
      }
      this.email = new FormControl('', [
        Validators.required,
        Validators.minLength(1)
      ]);
      this.password = new FormControl('', [
        Validators.required,
        Validators.minLength(1)
      ]);
      if(this.userid === 0 && this.signUpValidated === 1) {
        this.keeploggedin = new FormControl();
        this.captcha = new FormControl();
      }
      if(this.debug) {
        console.log('tree-dynamic: createFormControls: 3');
      }
    }
  }

  monitorFormValueChanges(): void {
    if(this.treeForm) {
      this.name.valueChanges
      .pipe(
        debounceTime(400),
        distinctUntilChanged()
      )
      .subscribe(name => {
        if(this.debug) {
          console.log('name: ',name);
        }
        this.formData['name'] = name;
        this.httpService.subjectImagePath.next(this.formData);
      });
      this.title.valueChanges
      .pipe(
        debounceTime(400),
        distinctUntilChanged()
      )
      .subscribe(title => {
        if(this.debug) {
          console.log('title: ',title);
        }
        this.formData['title'] = title;
        this.httpService.subjectImagePath.next(this.formData);
      });
      this.description.valueChanges
      .pipe(
        debounceTime(400),
        distinctUntilChanged()
      )
      .subscribe(description => {
        if(this.debug) {
          console.log('description: ',description);
        }
        this.formData['description'] = description;
        this.httpService.subjectImagePath.next(this.formData);
      });
      this.tags.valueChanges
      .pipe(
        debounceTime(400),
        distinctUntilChanged()
      )
      .subscribe(tags => {
        if(this.debug) {
          console.log('tags: ',tags);
        }
        this.formData['tags'] = tags;
        if(this.debug) {
          console.log('tree-dynamic: this.formData["tags"]: ', this.formData['tags']);
        }
        this.httpService.subjectImagePath.next(this.formData);
      });
      this.publishArticleDate.valueChanges
      .pipe(
        debounceTime(400),
        distinctUntilChanged()
      )
      .subscribe(publishArticleDate => {
        if(this.debug) {
          console.log('publishArticleDate: ',publishArticleDate);
        }
        this.formData['publishArticleDate'] = publishArticleDate;
        if(this.debug) {
          console.log('tree-dynamic: this.formData["publishArticleDate"]: ', this.formData['publishArticleDate']);
        }
        this.httpService.subjectImagePath.next(this.formData);
      });
    }
    if(this.signUpForm) {
      this.forename.valueChanges
      .pipe(
        debounceTime(400),
        distinctUntilChanged()
      )
      .subscribe(forename => {
        if(this.debug) {
          console.log('forename: ',forename);
        }
        this.formData['forename'] = forename;
        this.isSignUpValid = this.isSignUpFormValid();
      });
      this.surname.valueChanges
      .pipe(
        debounceTime(400),
        distinctUntilChanged()
      )
      .subscribe(surname => {
        if(this.debug) {
          console.log('surname: ',surname);
        }
        this.formData['surname'] = surname;
        this.isSignUpValid = this.isSignUpFormValid();
      });
    }
    if(this.signUpForm || this.loginForm) {
      this.email.valueChanges
      .pipe(
        debounceTime(400),
        distinctUntilChanged()
      )
      .subscribe(email => {
        if(this.debug) {
          console.log('email: ',email);
        }
        this.formData['email'] = email;
        if(this.signUpForm) {
          this.isSignUpValid = this.isSignUpFormValid();
        }
        else{
          this.isLoginValid = this.isLoginFormValid();
        }
      });
      this.password.valueChanges
      .pipe(
        debounceTime(400),
        distinctUntilChanged()
      )
      .subscribe(password => {
        if(this.debug) {
          console.log('password: ',password);
        }
        this.formData['password'] = password;
        if(this.signUpForm) {
          this.isSignUpValid = this.isSignUpFormValid();
        }
        else{
          this.isLoginValid = this.isLoginFormValid();
        }
      });
    }
    if(this.loginForm) {
      this.keeploggedin.valueChanges
      .pipe(
        debounceTime(400),
        distinctUntilChanged()
      )
      .subscribe(keeploggedin => {
        if(this.debug) {
          console.log('keeploggedin: ',keeploggedin);
        }
        this.formData['keeploggedin'] = keeploggedin ? 1 : 0;
      });
    }
  }

  private processNextImageData = (data) => {
    if(data) {
      this.router.navigate([this.uploadRouterAliasLower, {fileid: data['fileUuid']}]);
    }
  }

  private processPreviousImageData = (data) => {
    if(data) {
      this.router.navigate([this.uploadRouterAliasLower, {fileid: data['fileUuid']}]);
    }
  }

  back(id: string): void {
    this.router.navigate([this.catalogRouterAliasLower, {fileid: id}]);
  }

  extractTreeNode(value: any): string {
    if(this.debug) {
      console.log('tree-dynamic: extractTreeNode: value: ', value);
    }
    const last: any[] = value.split('/');
    if(this.debug) {
      console.log('tree-dynamic: extractTreeNode: last: ', last);
    }
    let result: any;
    if(Array.isArray(last)) {
      result = last.splice(0,last.length-1);
      result = result.join('/');
      if(this.debug) {
        console.log('tree-dynamic: extractTreeNode: result: ', result);
      }
    }
    return result;
  }

  onTagAdded(event: any): void {
    if(this.debug) {
      console.log('tree-dynamic: onTagAdded: event: ', event);
    }
  }

  onTagInputTextChange(event: any): void {
    if(this.debug) {
      console.log('tree-dynamic: onTagInputTextChange: event: ', event);
    }
  }

  onTagRemoved(event: any): void {
    if(this.debug) {
      console.log('tree-dynamic: onTagRemoved: event: ', event);
    }
  }

  isSignUpFormValid(): boolean {
    return this.forename.value !== '' && this.surname.value !== '' && this.email.value !== '' && this.password.value !== '' ? true : false;
  }

  isLoginFormValid(): boolean {
    return true;
  }

  toggleError(error: string): void {
    this.safeHtml = this.sanitizer.bypassSecurityTrustHtml(error);
    this.hasError = error !== '' ? true : false;
  }

  addPath(event: any, item: string): void {
    this.imagePath = item;
    this.formData['imagePath'] = this.imagePath;
    this.formData['userToken'] = this.userToken;
    this.formData['uploadType'] = 'gallery';
    this.httpService.subjectImagePath.next(this.formData);
    this.directorySelected = this.imagePath;
    const gradeEl = this.documentBody.getElementById('directory-' + this.pathFormat(this.imagePath));
    if(this.debug) {
      console.log('addPath: gradeEl: ',gradeEl);
    }
    TweenMax.fromTo(gradeEl, 1, {scale:0, ease:Elastic.easeOut, opacity: 0, rotation: 1}, {scale:1, ease:Elastic.easeOut, opacity: 1, rotation: 359});
  }

  pathFormat(value: any): any {
    let last = value.split('//');
    last = Array.isArray(last) ? last[last.length-1] : value;
    return last;
  }

  stringFromUTF8Array(data: any): string {
    const extraByteMap = [ 1, 1, 1, 1, 2, 2, 3, 0 ];
    const count = data.length;
    var str = '';
    for (var index = 0;index < count;) {
      var ch = data[index++];
      if (ch & 0x80) {
        var extra = extraByteMap[(ch >> 3) & 0x07];
        if (!(ch & 0x40) || !extra || ((index + extra) > count)) {
          return null;
        }
        ch = ch & (0x3F >> extra);
        for (;extra > 0;extra -= 1) {
          const chx = data[index++];
          if ((chx & 0xC0) !== 0x80) {
            return null;
          }
          ch = (ch << 6) | (chx & 0x3F);
        }
      }
      str += String.fromCharCode(ch);
    }
    return str;
  }

  private containsPunctuation(control: FormControl): any {
    const patt = /[.,\/#!$%\^&\*;:{}=\_`~()]/g;
    if(patt.test(control.value)) {
      return {
          'containsPunctuation': true
      };
    }
    return null;
  }

  previewArticle(): void {
    this.router.navigate([this.catalogRouterAliasLower,this.fileImageId,this.seoTitleFormatPipe.transform(this.formData['title'])]);
  }

  closeArticleDialog(): void {
    this.dialog.closeAll();
  }

  openArticleDialog(): void {
    const dialogRef = this.dialog.open(this.dialogArticleTpl, {
      width: this.isMobile ? '100%' : '75%',
      height: this.isMobile ? '100%' :'90%',
      maxWidth: 1278,
      id: 'dialog-article'
    });
    updateCdkOverlayThemeClass(this.themeRemove,this.themeAdd);
    dialogRef.beforeClose().subscribe(result => {
      if(this.debug) {
        console.log('tree-dynamic: dialog aticle: before close');
      }
      if(result) {
        if(this.debug) {
          console.log('tree-dynamic: dialog aticle: before close: result: ', result);
        }
      }
      this.tinyMceArticleContent = this.formData['article'];
      this.tinymceArticleImageCount = this.tinymceArticleImageCount;
      if(this.debug) {
        console.log('tree-dynamic: openArticleDialog: beforeClose: this.tinyMceArticleContent: ', this.tinyMceArticleContent);
      }
      const data = {
        height: 0,
        fileImageId: this.fileImageId
      };
      this.httpService.articleDialogOpened.next(data);
    });
    dialogRef.afterOpen().subscribe( () => {
      if(this.debug) {
        console.log('tree-dynamic: dialog aticle: after open');
      }
      const parent = this.documentBody.querySelector('#dialog-article');
      let height = parent.clientHeight ? parent.clientHeight : 0;
      const offsetHeight = this.isMobile ? 333 : 220;
      if(!isNaN(height) && (height - offsetHeight) > 0) {
        height = height - offsetHeight;
      }
      if(height > 0 ) {
        this.dialogArticleHeight = height;
        const data = {
          height: this.dialogArticleHeight,
          fileImageId: this.fileImageId
        };
        this.httpService.articleDialogOpened.next(data);
      }
      if(this.debug) {
        console.log('tree-dynamic: dialog: this.dialogArticleHeight: ', this.dialogArticleHeight);
      }
    });
  }

  openSubmitArticleNotificationDialog(): void {
    const dialogRef = this.dialog.open(this.dialogSubmitArticleNotificationTpl, {
      width: this.isMobile ? '90%' :'25%',
      id: 'dialog-submit-article-notification'
    });
    updateCdkOverlayThemeClass(this.themeRemove,this.themeAdd);
    dialogRef.beforeClose().subscribe(result => {
      if(this.debug) {
        console.log('tree-dynamic: dialog submit article notification: before close');
      }
      if(result) {
        if(this.debug) {
          console.log('tree-dynamic: dialog submit article notification: before close: result: this.editImageId: ', this.editImageId);
        }
        this.editImage(this.editImageId);
        this.dialog.closeAll();
        if(this.debug) {
          console.log('tree-dynamic: dialog submit article notification: before close: result: ', result);
        }
      }
    });
    dialogRef.afterOpen().subscribe( () => {
      if(this.debug) {
        console.log('tree-dynamic: dialog submit article notification: after open');
      }
    });
  }

  openArticleMaxWordCountNotificationDialog(): void {
    const dialogRef = this.dialog.open(this.dialogArticleMaxWordCountNotificationTpl, {
      width: this.isMobile ? '90%' :'25%',
      id: 'dialog-article-max-word-count-notification'
    });
    updateCdkOverlayThemeClass(this.themeRemove,this.themeAdd);
    dialogRef.beforeClose().subscribe(result => {
      if(this.debug) {
        console.log('tree-dynamic: dialog article max word count notification: before close');
      }
      if(result) {
        if(this.debug) {
          console.log('tree-dynamic: dialog article max word count notification: before close: result: ', result);
        }
      }
    });
    dialogRef.afterOpen().subscribe( () => {
      if(this.debug) {
        console.log('tree-dynamic: dialog article max word count notification: after open');
      }
    });
  }

  openArticleHelpNotificationDialog(): void {
    const dialogRef = this.dialog.open(this.dialogArticleHelpNotificationTpl, {
      width: this.isMobile ? '100%' :'50%',
      height: this.isMobile ? '100%' :'75%',
      maxWidth: this.isMobile ? '100%' :'50%',
      id: 'dialog-article-help-notification'
    });
    updateCdkOverlayThemeClass(this.themeRemove,this.themeAdd);
    dialogRef.beforeClose().subscribe(result => {
      if(this.debug) {
        console.log('tree-dynamic: dialog article help notification: before close');
      }
      if(result) {
        if(this.debug) {
          console.log('tree-dynamic: dialog article help notification: before close: result: ', result);
        }
      }
    });
    dialogRef.afterOpen().subscribe( () => {
      if(this.debug) {
        console.log('tree-dynamic: dialog article help notification: after open');
      }
      if(this.isMobile) {
        const parent = document.querySelector('#dialog-article-help-notification');
        let height = parent.clientHeight ? parent.clientHeight : 0;
        const offsetHeight = 150;
        if(!isNaN(height) && (height - offsetHeight) > 0) {
          height = height - offsetHeight;
        }
        if(this.debug) {
          console.log('tree-dynamic: dialog article help notification: height: ', height);
        }
        if(height > 0 ) {
          this.renderer.setStyle(this.dialogArticleHelpNotificationText.nativeElement,'height',height + 'px');
        }
        const dialogarticlehelpnotificationcontainer = document.querySelector('#dialog-article-help-notification-container');

        if(parent) {
          TweenMax.fromTo(dialogarticlehelpnotificationcontainer, 1, {ease:Elastic.easeOut, opacity: 0}, {ease:Elastic.easeOut, opacity: 1});
        }
      }
    });
  }

  closeArticleHelpNotificationDialog() {
    this.dialog.closeAll();
  }

  tinyMceArticleKeyupHandler(event: any): void {
    if(this.debug) {
      console.log('tree-dynamic: tinyMceArticleKeyupHandler: event: ', event);
    }
    this.formData['article'] = event;
    this.httpService.subjectImagePath.next(this.formData);
    if(this.debug) {
      console.log('tree-dynamic: tinyMceArticleKeyupHandler: this.formData: ', this.formData);
    }
  }

  openSnackBar(message: string, action: string) {
    const config = new MatSnackBarConfig();
    config.panelClass = ['custom-class'];
    config.duration = 5000;
    this.matSnackBar.open(message, action, config);
  }

  ngOnDestroy() {

    if (this.signupSubscription) {
      this.signupSubscription.unsubscribe();
    }

    if (this.editImageSubscription) {
      this.editImageSubscription.unsubscribe();
    }

  }

}
