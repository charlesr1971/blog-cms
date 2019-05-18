import { Component, OnInit, AfterViewInit, OnDestroy, ElementRef, ViewChild, Renderer2, Input, Inject, TemplateRef, NgZone } from '@angular/core';
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
import { FormatEmailRenderer } from '../../ag-grid/cell-renderer/format-email-renderer/format-email-renderer.component';
import { FormatFileTitleRenderer } from '../../ag-grid/cell-renderer/format-file-title-renderer/format-file-title-renderer.component';
import { CustomEditHeader } from '../../ag-grid/header/custom-edit-header/custom-edit-header.component';
import { NgbTooltip } from '@ng-bootstrap/ng-bootstrap';
import * as am4core from "@amcharts/amcharts4/core";
import * as am4charts from "@amcharts/amcharts4/charts";
import am4themes_animated from "@amcharts/amcharts4/themes/animated";
import { styler } from '../../util/styler';
import { rgbToHex } from '../../util/colorUtils';

import { UploadService } from '../../upload/upload.service';
import { HttpService } from '../../services/http/http.service';

import { Image } from '../../image/image.model';
import { User } from '../../user/user.model';
import { UserService } from '../../user/user.service';
import { JwtService } from '../../services/jwt/jwt.service';

import { environment } from '../../../environments/environment';
import { max } from 'moment';

declare var Waypoint: any;
declare var TweenMax: any, Elastic: any, Linear: any;

export enum userAdminUnselectedChangesOptionsStatus {
  'Let the system select the rows automatically and continue with the submission?' = 1 ,
  'Let the system select the rows where the changes were made and allow you to make the submission manually?' = 2,
  'Continue with the submission?' = 3
}

am4core.useTheme(am4themes_animated);

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
    trigger('profileUserSuspendEditFadeInOutAnimation', [
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
    trigger('profileUserPasswordEditFadeInOutAnimation', [
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
    trigger('profileUserApprovedEditFadeInOutAnimation', [
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
    trigger('profileSystemUserEditFadeInOutAnimation', [
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
    trigger('profileAdminDashboardFadeInOutAnimation', [
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
    ]),,
  ],
  providers: [SafePipe]
})
export class ProfileComponent implements OnInit, AfterViewInit, OnDestroy {

  @ViewChild('avatarContainer') avatarContainer;
  @ViewChild('modal') modal;
  @ViewChild('unapprovedImagesSelect') unapprovedImagesSelect;
  @ViewChild('approvedImagesSelect') approvedImagesSelect;
  @ViewChild('dialogEditCategoriesHelpNotification') private dialogEditCategoriesHelpNotificationTpl: TemplateRef<any>;
  @ViewChild('dialogEmail') private dialogEmailTpl: TemplateRef<any>;
  @ViewChild('dialogUserAdminNotification') private dialogUserAdminNotificationTpl: TemplateRef<any>;
  @ViewChild('dialogEditCategoriesHelpNotificationText') dialogEditCategoriesHelpNotificationText: ElementRef;
  @ViewChild('userArchivePagesSelect') userArchivePagesSelect;
  @ViewChild('userSuspendPagesSelect') userSuspendPagesSelect;
  @ViewChild('userApprovedPagesSelect') userApprovedPagesSelect;
  @ViewChild('systemUserSelect') systemUserSelect;
  @ViewChild('agGridUserArchive') agGridUserArchive: AgGridNg2;
  @ViewChild('agGridUserSuspend') agGridUserSuspend: AgGridNg2;
  @ViewChild('agGridUserPassword') agGridUserPassword: AgGridNg2;
  @ViewChild('agGridUserApproved') agGridUserApproved: AgGridNg2;

  @ViewChild('ngbTooltipUserArchiveRemoveHighlight') ngbTooltipUserArchiveRemoveHighlight: NgbTooltip;
  @ViewChild('ngbTooltipUserSuspendRemoveHighlight') ngbTooltipUserSuspendRemoveHighlight: NgbTooltip;
  @ViewChild('ngbTooltipUserPasswordRemoveHighlight') ngbTooltipUserPasswordRemoveHighlight: NgbTooltip;
  @ViewChild('ngbTooltipUserApprovedRemoveHighlight') ngbTooltipUserApprovedRemoveHighlight: NgbTooltip;

  @Input() profileApiDashboardState: string = 'out';
  @Input() profileAdminDashboardState: string = 'in';
  @Input() profileCategoryEditState: string = 'out';

  @Input() profileUserArchiveEditState: string = 'out';
  @Input() profileUserSuspendEditState: string = 'out';
  @Input() profileUserPasswordEditState: string = 'out';
  @Input() profileUserApprovedEditState: string = 'out';
  
  @Input() profileSystemUserEditState: string = 'out';

  themeObj = {};
  themeRemove: string = '';
  themeAdd: string = '';
  themeType: string = '';

  themeSwatch = {};

  imagesUnapproved: Array<any> = [];
  pageCacheUnapproved = {};
  pagesUnapproved = [];
  currentPageUnapproved: number = 1;

  imagesApproved: Array<any> = [];
  pageCacheApproved = {};
  pagesApproved = [];
  currentPageApproved: number = 1;
  
  editProfileForm: FormGroup;
  emailForm: FormGroup;

  forename: FormControl;
  surname: FormControl;
  displayName: FormControl;
  password: FormControl;
  emailNotification: FormControl;
  replyNotification: FormControl;
  threadNotification: FormControl;
  theme: FormControl;
  jwtToken: FormControl;
  userToken: FormControl;
  useridFC: FormControl;
  apiDocumentation: FormControl;
  apiEndpoint: FormControl;

  email: FormControl;
  message: FormControl;

  emailNotificationChecked = false;
  replyNotificationChecked = false;
  threadNotificationChecked = false;
  themeChecked = false;
  
  formProfileData = {};
  formEmailData = {};
  apiUrl: string = '';

  userArchivePages = [];
  userSuspendPages = [];
  userPasswordPages = [];
  userApprovedPages = [];

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
  usersSuspendGetSubscription: Subscription;
  usersPasswordGetSubscription: Subscription;
  usersApprovedGetSubscription: Subscription;
  systemUserGetSubscription: Subscription;
  usersArchivePostSubscription: Subscription;
  usersSuspendPostSubscription: Subscription;
  usersPasswordPostSubscription: Subscription;
  usersApprovedPostSubscription: Subscription;
  usersEmailPostSubscription: Subscription;
  adminDashboardAmchartUserfileGetSubscription: Subscription;
  currentUser: User;
  closeResult: string;
  categoryImagesUrl: string = '';
  userid: number = 0;
  disableCommentGeneralTooltip: boolean = false;
  tooltipAddIcon: string = 'open/close panel';
  tooltipFullscreenIcon: string = 'expand/contract panel';
  tooltipQuestionmarkSpan: string = 'help';
  uploadRouterAliasLower: string = environment.uploadRouterAlias;
  dialogEditCategoriesHeight: number = 0;
  dialogEmailHeight: number = 0;
  emailPattern: string = "^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]+$";
  emailFormDisabled: boolean = false;
  emailTemplateStartSalutation: string = '';
  emailTemplateEndSalutation: string = '';
  emailTemplateDate: string = '';
  emailTemplateCredit: string = '';
  userAdminUnselectedChanges: string = '';
  userAdminUnselectedChangesOptions: string[] = ['Let the system select the rows automatically and continue with the submission?', 'Let the system select the rows where the changes were made and allow you to make the submission manually?', 'Continue with the submission?'];
  ngbTooltipContentRemoveHighlightText: string = 'Remove cell hover highlight';
  contenteditable: boolean = true;

  currentUserArchivePage: number = 1;
  currentUserSuspendPage: number = 1;
  currentUserPasswordPage: number = 1;
  currentUserApprovedPage: number = 1;

  ngbTooltipRemoveHighlightTimeout: number = 5000;
  addRemoveHighlightWaypoints: boolean = environment.addRemoveHighlightWaypoints

  agGridPaginationPageSize: number = environment.agGridPaginationPageSize;
  agGridRowHeight: number = environment.agGridRowHeight;

  userAccountDeleteSchema: number = 2;
  userArchiveHasNoData: boolean = false;
  contextUserArchive;
  frameworkComponentsUserArchive;
  gridApiUserArchive;
  gridColumnApiUserArchive;
  userArchiveColumnDefs = [];
  userArchiveRowData = [];
  userArchiveDefaultColDef =  {};
  userArchiveThemeIsLight: boolean = true;
  userArchiveDomLayout: string = '';
  defaultColDefUserArchive;
  overlayLoadingTemplateUserArchive;
  overlayNoRowsTemplateUserArchive;
  userArchiveSubmitDisabled: boolean = true;

  userSuspendHasNoData: boolean = false;
  contextUserSuspend;
  frameworkComponentsUserSuspend;
  gridApiUserSuspend;
  gridColumnApiUserSuspend;
  userSuspendColumnDefs = [];
  userSuspendRowData = [];
  userSuspendDefaultColDef =  {};
  userSuspendThemeIsLight: boolean = true;
  userSuspendDomLayout: string = '';
  defaultColDefUserSuspend;
  overlayLoadingTemplateUserSuspend;
  overlayNoRowsTemplateUserSuspend;
  cachedNodeDataUserSuspend = [];
  userSuspendSubmitDisabled: boolean = true;

  userPasswordHasNoData: boolean = false;
  contextUserPassword;
  frameworkComponentsUserPassword;
  gridApiUserPassword;
  gridColumnApiUserPassword;
  userPasswordColumnDefs = [];
  userPasswordRowData = [];
  userPasswordDefaultColDef =  {};
  userPasswordThemeIsLight: boolean = true;
  userPasswordDomLayout: string = '';
  defaultColDefUserPassword;
  overlayLoadingTemplateUserPassword;
  overlayNoRowsTemplateUserPassword;
  cachedNodeDataUserPassword = [];
  userPasswordSubmitDisabled: boolean = true;

  userApprovedHasNoData: boolean = false;
  systemUserHasNoData: boolean = false;
  systemUserData: string = '';
  systemUserDataLang:string[] = ['json'];
  contextUserApproved;
  frameworkComponentsUserApproved;
  gridApiUserApproved;
  gridColumnApiUserApproved;
  userApprovedColumnDefs = [];
  userApprovedRowData = [];
  userApprovedDefaultColDef =  {};
  userApprovedThemeIsLight: boolean = true;
  userApprovedDomLayout: string = '';
  defaultColDefUserApproved;
  overlayLoadingTemplateUserApproved;
  overlayNoRowsTemplateUserApproved;
  cachedNodeDataUserApproved = [];
  userApprovedSubmitDisabled: boolean = true;

  components;

  adminDashboardAmchartUserfile: am4charts.XYChart;
  
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
    private zone: NgZone,
    public dialog: MatDialog) { 

      if(environment.debugComponentLoadingOrder) {
        console.log('profile.component loaded');
      }

      this.userAccountDeleteSchema = this.httpService.userAccountDeleteSchema;

      this.themeObj = this.httpService.themeObj;
      this.themeRemove = this.cookieService.check('theme') && this.cookieService.get('theme') === this.themeObj['light'] ? this.themeObj['dark'] : this.themeObj['light'];
      this.themeAdd = this.themeRemove === this.themeObj['light'] ? this.themeObj['dark'] : this.themeObj['light'];

      this.themeType = this.cookieService.check('theme') && this.cookieService.get('theme') === this.themeObj['light'] ? 'light' : 'dark';

      this.userArchiveThemeIsLight = this.cookieService.check('theme') && this.cookieService.get('theme') === this.themeObj['light'] ? true : false;

      this.userSuspendThemeIsLight = this.cookieService.check('theme') && this.cookieService.get('theme') === this.themeObj['light'] ? true : false;

      this.userPasswordThemeIsLight = this.cookieService.check('theme') && this.cookieService.get('theme') === this.themeObj['light'] ? true : false;

      this.userApprovedThemeIsLight = this.cookieService.check('theme') && this.cookieService.get('theme') === this.themeObj['light'] ? true : false;

      if(this.httpService.currentUserAuthenticated > 0) {
        this.httpService.fetchJwtData();
      }

      this.isMobile = this.deviceDetectorService.isMobile();

      this.fetchPagesUserArchive();
      this.fetchPagesUserSuspend();
      this.fetchPagesUserPassword();
      this.fetchPagesUserApproved();

      if(this.isMobile) {
        this.disableCommentGeneralTooltip = true;
      }

      this.categoryImagesUrl = this.httpService.categoryImagesUrl;
      this.fetchPagesUnapproved();
      this.fetchPagesApproved();

      this.userService.currentUser.subscribe( (user: User) => {
        this.currentUser = user;
        this.userid = this.currentUser['userid'];
        this.createProfileFormControls();
        this.createProfileForm();
        this.monitorProfileFormValueChanges();
        setTimeout( () => {
          this.forename.patchValue(this.currentUser['forename']);
          this.surname.patchValue(this.currentUser['surname']);
          this.displayName.patchValue(this.currentUser['displayName']);
          this.emailNotification.patchValue(!!+this.currentUser['emailNotification']);
          this.replyNotification.patchValue(!!+this.currentUser['replyNotification']);
          this.threadNotification.patchValue(!!+this.currentUser['threadNotification']);
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
        this.createEmailFormControls();
        this.createEmailForm();
        this.monitorEmailFormValueChanges();
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

      // ag-grid user archive

      this.contextUserArchive = {
        componentParent: this
      };
      this.frameworkComponentsUserArchive = {
        formatEmailRenderer: FormatEmailRenderer,
        agColumnHeader: CustomEditHeader
      };

      this.defaultColDefUserArchive = {
        resizable: true,
        suppressMenu: true,
        sortable: true,
        filter: true
      };

      this.overlayLoadingTemplateUserArchive =
      '<span class="ag-overlay-loading-center"><svg class="custom-mat-progress-spinner" width="50" height="50" viewbox="-7.5 -7.5 25 25"><circle class="path" cx="5" cy="5" r="5" fill="none" stroke-width="1.5" stroke-miterlimit="0" /></svg></span>';
      this.overlayNoRowsTemplateUserArchive =
      '<span class="ag-overlay-loading-center"><svg class="custom-mat-progress-spinner" width="50" height="50" viewbox="-7.5 -7.5 25 25"><circle class="path" cx="5" cy="5" r="5" fill="none" stroke-width="1.5" stroke-miterlimit="0" /></svg></span>';
      
      this.usersArchiveGetSubscription = this.httpService.fetchUsersArchive(this.currentUserArchivePage).do(this.processUsersArchiveGetData).subscribe();

      // ag-grid user suspend

      this.components = { numericCellEditor: this.getTinyintCellEditor() };

      this.contextUserSuspend = {
        componentParent: this
      };
      this.frameworkComponentsUserSuspend = {
        formatEmailRenderer: FormatEmailRenderer,
        agColumnHeader: CustomEditHeader
      };

      this.defaultColDefUserSuspend = {
        enableCellChangeFlash: true,
        resizable: true,
        suppressMenu: true,
        sortable: true,
        filter: true
      };

      this.overlayLoadingTemplateUserSuspend =
      '<span class="ag-overlay-loading-center"><svg class="custom-mat-progress-spinner" width="50" height="50" viewbox="-7.5 -7.5 25 25"><circle class="path" cx="5" cy="5" r="5" fill="none" stroke-width="1.5" stroke-miterlimit="0" /></svg></span>';
      this.overlayNoRowsTemplateUserSuspend =
      '<span class="ag-overlay-loading-center"><svg class="custom-mat-progress-spinner" width="50" height="50" viewbox="-7.5 -7.5 25 25"><circle class="path" cx="5" cy="5" r="5" fill="none" stroke-width="1.5" stroke-miterlimit="0" /></svg></span>';

      this.usersSuspendGetSubscription = this.httpService.fetchUsersAdmin('suspend',this.currentUserSuspendPage).do(this.processUsersSuspendGetData).subscribe();

      // ag-grid user password

      this.contextUserPassword = {
        componentParent: this
      };
      this.frameworkComponentsUserPassword = {
        formatEmailRenderer: FormatEmailRenderer,
        agColumnHeader: CustomEditHeader
      };

      this.defaultColDefUserPassword = {
        enableCellChangeFlash: true,
        resizable: true,
        suppressMenu: true,
        sortable: true,
        filter: true
      };

      this.overlayLoadingTemplateUserPassword =
      '<span class="ag-overlay-loading-center"><svg class="custom-mat-progress-spinner" width="50" height="50" viewbox="-7.5 -7.5 25 25"><circle class="path" cx="5" cy="5" r="5" fill="none" stroke-width="1.5" stroke-miterlimit="0" /></svg></span>';
      this.overlayNoRowsTemplateUserPassword =
      '<span class="ag-overlay-loading-center"><svg class="custom-mat-progress-spinner" width="50" height="50" viewbox="-7.5 -7.5 25 25"><circle class="path" cx="5" cy="5" r="5" fill="none" stroke-width="1.5" stroke-miterlimit="0" /></svg></span>';

      this.usersPasswordGetSubscription = this.httpService.fetchUsersAdmin('password',this.currentUserPasswordPage).do(this.processUsersPasswordGetData).subscribe();

      // ag-grid user approved

      this.components = { numericCellEditor: this.getTinyintCellEditor() };

      this.contextUserApproved = {
        componentParent: this
      };
      this.frameworkComponentsUserApproved = {
        formatEmailRenderer: FormatEmailRenderer,
        formatFileTitleRenderer: FormatFileTitleRenderer,
        agColumnHeader: CustomEditHeader
      };

      this.defaultColDefUserApproved = {
        enableCellChangeFlash: true,
        resizable: true,
        suppressMenu: true,
        sortable: true,
        filter: true
      };

      this.overlayLoadingTemplateUserApproved =
      '<span class="ag-overlay-loading-center"><svg class="custom-mat-progress-spinner" width="50" height="50" viewbox="-7.5 -7.5 25 25"><circle class="path" cx="5" cy="5" r="5" fill="none" stroke-width="1.5" stroke-miterlimit="0" /></svg></span>';
      this.overlayNoRowsTemplateUserApproved =
      '<span class="ag-overlay-loading-center"><svg class="custom-mat-progress-spinner" width="50" height="50" viewbox="-7.5 -7.5 25 25"><circle class="path" cx="5" cy="5" r="5" fill="none" stroke-width="1.5" stroke-miterlimit="0" /></svg></span>';

      this.usersApprovedGetSubscription = this.httpService.fetchUsersAdmin('approved',this.currentUserApprovedPage).do(this.processUsersApprovedGetData).subscribe();

      // amchart user file

      this.adminDashboardAmchartUserfileGetSubscription = this.httpService.fetchAmCharts('userFile',1).do(this.adminDashboardAmchartUserfileGetData).subscribe();

  }

  ngOnInit() {

    if(environment.debugComponentLoadingOrder) {
      console.log('profile.component init');
    }

    this.documentBody.querySelector('#mat-sidenav-content').addEventListener('scroll', this.onMatSidenavContentScroll.bind(this));

  }

  ngAfterViewInit() {

    if(this.isMobile && this.addRemoveHighlightWaypoints) {
      this.createWaypoints();
    }

    this.createThemeSwatch();

    setTimeout( () => {
      if(!this.utilsService.isEmpty(this.themeSwatch)) {
        this.themeType === 'light' ? am4core.useTheme(this.am4themes_lightTheme) : am4core.useTheme(this.am4themes_darkTheme);
      }
    });

  }

  // waypoint methods

  createWaypoints(): void {

    var that = this;

    const usersArchiveWaypoint1 = new Waypoint({
      element: document.getElementById('ag-grid-user-archive-remove-highlight-icon'),
      handler: function (direction) {
        if(this.debug) {
          console.log('profile.component: usersArchiveWaypoint1: waypoint detected: that.ngbTooltipUserArchiveRemoveHighlight', that.ngbTooltipUserArchiveRemoveHighlight);
        }
        that.ngbTooltipUserArchiveRemoveHighlight.open();
        setTimeout( () => {
          that.ngbTooltipUserArchiveRemoveHighlight.close();
        },that.ngbTooltipRemoveHighlightTimeout);
        this.destroy();
      },
      context: this.documentBody.getElementById('mat-sidenav-content'),
      offset: '75%'
    });

    const usersSuspendWaypoint1 = new Waypoint({
      element: document.getElementById('ag-grid-user-suspend-remove-highlight-icon'),
      handler: function (direction) {
        if(this.debug) {
          console.log('profile.component: usersSuspendWaypoint1: waypoint detected: that.ngbTooltipUserSuspendRemoveHighlight', that.ngbTooltipUserSuspendRemoveHighlight);
        }
        that.ngbTooltipUserSuspendRemoveHighlight.open();
        setTimeout( () => {
          that.ngbTooltipUserSuspendRemoveHighlight.close();
        },that.ngbTooltipRemoveHighlightTimeout);
        this.destroy();
      },
      context: this.documentBody.getElementById('mat-sidenav-content'),
      offset: '50%'
    });

    const usersPasswordWaypoint1 = new Waypoint({
      element: document.getElementById('ag-grid-user-password-remove-highlight-icon'),
      handler: function (direction) {
        if(this.debug) {
          console.log('profile.component: usersPasswordWaypoint1: waypoint detected: that.ngbTooltipUserPasswordRemoveHighlight', that.ngbTooltipUserPasswordRemoveHighlight);
        }
        that.ngbTooltipUserPasswordRemoveHighlight.open();
        setTimeout( () => {
          that.ngbTooltipUserPasswordRemoveHighlight.close();
        },that.ngbTooltipRemoveHighlightTimeout);
        this.destroy();
      },
      context: this.documentBody.getElementById('mat-sidenav-content'),
      offset: '50%'
    });

    const usersApprovedWaypoint1 = new Waypoint({
      element: document.getElementById('ag-grid-user-approved-remove-highlight-icon'),
      handler: function (direction) {
        if(this.debug) {
          console.log('profile.component: usersApprovedWaypoint1: waypoint detected: that.ngbTooltipUserApprovedRemoveHighlight', that.ngbTooltipUserApprovedRemoveHighlight);
        }
        that.ngbTooltipUserApprovedRemoveHighlight.open();
        setTimeout( () => {
          that.ngbTooltipUserApprovedRemoveHighlight.close();
        },that.ngbTooltipRemoveHighlightTimeout);
        this.destroy();
      },
      context: this.documentBody.getElementById('mat-sidenav-content'),
      offset: '50%'
    });

  }

  // api methods

  fetchPagesUserArchive(): void {
    this.httpService.fetchPagesUsers('userarchive').subscribe( (data) => {
      if(this.debug) {
        console.log('profile.component: fetchPagesUserArchive: data: ',data);
      }
      if(data) {
        if(!this.utilsService.isEmpty(data) && 'pagessurnames' in data && Array.isArray(data['pagessurnames']) && data['pagessurnames'].length) {
          for(var i = 0; i < data['pagessurnames'].length; i++) {
            const obj = {};
            obj['surname'] = data['pagessurnames'][i];
            this.userArchivePages.push(obj);
          }
        }
      }
    });
  }

  fetchPagesUserSuspend(): void {
    this.httpService.fetchPagesUsers('user').subscribe( (data) => {
      if(this.debug) {
        console.log('profile.component: fetchPagesUserSuspend: data: ',data);
      }
      if(data) {
        if(!this.utilsService.isEmpty(data) && 'pagessurnames' in data && Array.isArray(data['pagessurnames']) && data['pagessurnames'].length) {
          for(var i = 0; i < data['pagessurnames'].length; i++) {
            const obj = {};
            obj['surname'] = data['pagessurnames'][i];
            this.userSuspendPages.push(obj);
          }
        }
      }
    });
  }

  fetchPagesUserPassword(): void {
    this.httpService.fetchPagesUsers('user').subscribe( (data) => {
      if(this.debug) {
        console.log('profile.component: fetchPagesUserPassword: data: ',data);
      }
      if(data) {
        if(!this.utilsService.isEmpty(data) && 'pagessurnames' in data && Array.isArray(data['pagessurnames']) && data['pagessurnames'].length) {
          for(var i = 0; i < data['pagessurnames'].length; i++) {
            const obj = {};
            obj['surname'] = data['pagessurnames'][i];
            this.userPasswordPages.push(obj);
          }
        }
      }
    });
  }

  fetchPagesUserApproved(): void {
    this.httpService.fetchPagesUsers('user_join_file').subscribe( (data) => {
      if(this.debug) {
        console.log('profile.component: fetchPagesUserApproved: data: ',data);
      }
      if(data) {
        if(!this.utilsService.isEmpty(data) && 'pagessurnames' in data && Array.isArray(data['pagessurnames']) && data['pagessurnames'].length) {
          for(var i = 0; i < data['pagessurnames'].length; i++) {
            const obj = {};
            obj['surname'] = data['pagessurnames'][i];
            this.userApprovedPages.push(obj);
          }
        }
      }
    });
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
      displayName: this.displayName.value,
      password: this.password.value ? this.password.value : '',
      emailNotification: this.emailNotification.value,
      replyNotification: this.replyNotification.value,
      threadNotification: this.threadNotification.value,
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
        this.refreshAgGrid(this.gridApiUserArchive,'ag-grid-user-archive-updated-icon','ag-grid-user-archive-remove-highlight-icon');
        this.userArchiveSubmitDisabled = true;
      }
      else{
        if('jwtObj' in data && !data['jwtObj']['jwtAuthenticated']) {
          this.httpService.jwtHandler(data['jwtObj']);
        }
        else{
          this.userArchiveHasNoData = true;
        }
      }
    }
  }

  private processUsersSuspendGetData = (data) => {
    if(this.debug) {
      console.log('profile.component: processUsersSuspendGetData: data',data);
    }
    if(data) {
      if('error' in data && data['error'] === '' && 'columnDefs' in data && Array.isArray(data['columnDefs']) && data['columnDefs'].length > 0 && 'rowData' in data && Array.isArray(data['rowData']) && data['rowData'].length > 0) {
        this.cachedNodeDataUserSuspend = [];
        this.userSuspendColumnDefs = data['columnDefs'];
        this.userSuspendRowData = data['rowData'];
      }
      else{
        if('jwtObj' in data && !data['jwtObj']['jwtAuthenticated']) {
          this.httpService.jwtHandler(data['jwtObj']);
        }
        else{
          this.userSuspendHasNoData = true;
        }
      }
    }
  }

  private processUsersSuspendPostData = (data) => {
    if(this.debug) {
      console.log('profile.component: processUsersSuspendPostData: data',data);
    }
    if(data) {
      if('error' in data && data['error'] === '' && 'columnDefs' in data && Array.isArray(data['columnDefs']) && data['columnDefs'].length > 0 && 'rowData' in data && Array.isArray(data['rowData']) && data['rowData'].length > 0) {
        this.cachedNodeDataUserSuspend = [];
        this.userSuspendColumnDefs = data['columnDefs'];
        this.userSuspendRowData = data['rowData'];
        this.refreshAgGrid(this.gridApiUserSuspend,'ag-grid-user-suspend-updated-icon','ag-grid-user-suspend-remove-highlight-icon');
        this.userSuspendSubmitDisabled = true;
      }
      else{
        if('jwtObj' in data && !data['jwtObj']['jwtAuthenticated']) {
          this.httpService.jwtHandler(data['jwtObj']);
        }
        else{
          this.userSuspendHasNoData = true;
        }
      }
    }
  }

  private processUsersPasswordGetData = (data) => {
    if(this.debug) {
      console.log('profile.component: processUsersPasswordGetData: data',data);
    }
    if(data) {
      if('error' in data && data['error'] === '' && 'columnDefs' in data && Array.isArray(data['columnDefs']) && data['columnDefs'].length > 0 && 'rowData' in data && Array.isArray(data['rowData']) && data['rowData'].length > 0) {
        this.cachedNodeDataUserPassword = [];
        this.userPasswordColumnDefs = data['columnDefs'];
        this.userPasswordRowData = data['rowData'];
      }
      else{
        if('jwtObj' in data && !data['jwtObj']['jwtAuthenticated']) {
          this.httpService.jwtHandler(data['jwtObj']);
        }
        else{
          this.userPasswordHasNoData = true;
        }
      }
    }
  }

  private processUsersPasswordPostData = (data) => {
    if(this.debug) {
      console.log('profile.component: processUsersPasswordPostData: data',data);
    }
    if(data) {
      if('error' in data && data['error'] === '' && 'columnDefs' in data && Array.isArray(data['columnDefs']) && data['columnDefs'].length > 0 && 'rowData' in data && Array.isArray(data['rowData']) && data['rowData'].length > 0) {
        this.cachedNodeDataUserPassword = [];
        this.userPasswordColumnDefs = data['columnDefs'];
        this.userPasswordRowData = data['rowData'];
        this.refreshAgGrid(this.gridApiUserPassword,'ag-grid-user-password-updated-icon','ag-grid-user-password-remove-highlight-icon');
        this.userPasswordSubmitDisabled = true;
      }
      else{
        if('jwtObj' in data && !data['jwtObj']['jwtAuthenticated']) {
          this.httpService.jwtHandler(data['jwtObj']);
        }
        else{
          this.userPasswordHasNoData = true;
        }
      }
    }
  }

  private processUsersApprovedGetData = (data) => {
    if(this.debug) {
      console.log('profile.component: processUsersApprovedGetData: data',data);
    }
    if(data) {
      if('error' in data && data['error'] === '' && 'columnDefs' in data && Array.isArray(data['columnDefs']) && data['columnDefs'].length > 0 && 'rowData' in data && Array.isArray(data['rowData']) && data['rowData'].length > 0) {
        this.cachedNodeDataUserApproved = [];
        this.userApprovedColumnDefs = data['columnDefs'];
        this.userApprovedRowData = data['rowData'];
      }
      else{
        if('jwtObj' in data && !data['jwtObj']['jwtAuthenticated']) {
          this.httpService.jwtHandler(data['jwtObj']);
        }
        else{
          this.userApprovedHasNoData = true;
        }
      }
    }
  }

  private processSystemUserGetData = (data) => {
    if(this.debug) {
      console.log('profile.component: processSystemUserGetData: data',data);
    }
    if(data) {
      if('error' in data && data['error'] === '' && 'systemUsers' in data && Array.isArray(data['systemUsers']) && data['systemUsers'].length > 0) {
        this.systemUserHasNoData = false;
        this.systemUserData = JSON.stringify(data['systemUsers'],undefined,2);
      }
      else{
        if('jwtObj' in data && !data['jwtObj']['jwtAuthenticated']) {
          this.httpService.jwtHandler(data['jwtObj']);
        }
        else{
          this.systemUserHasNoData = true;
        }
      }
    }
  }

  private processUsersApprovedPostData = (data) => {
    if(this.debug) {
      console.log('profile.component: processUsersApprovedPostData: data',data);
    }
    if(data) {
      if('error' in data && data['error'] === '' && 'columnDefs' in data && Array.isArray(data['columnDefs']) && data['columnDefs'].length > 0 && 'rowData' in data && Array.isArray(data['rowData']) && data['rowData'].length > 0) {
        this.cachedNodeDataUserApproved = [];
        this.userApprovedColumnDefs = data['columnDefs'];
        this.userApprovedRowData = data['rowData'];
        this.refreshAgGrid(this.gridApiUserApproved,'ag-grid-user-approved-updated-icon','ag-grid-user-approved-remove-highlight-icon');
        this.userApprovedSubmitDisabled = true;
      }
      else{
        if('jwtObj' in data && !data['jwtObj']['jwtAuthenticated']) {
          this.httpService.jwtHandler(data['jwtObj']);
        }
        else{
          this.userApprovedHasNoData = true;
        }
      }
    }
  }

  private processUsersEmailPostData = (data) => {
    if(this.debug) {
      console.log('profile.component: processUsersEmailPostData: data',data);
    }
    if(data) {
      if('error' in data && data['error'] === '') {
        this.openSnackBar('E-mail sent successfully', 'Success');
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
          roleid: data['roleid'],
          displayName: data['displayName'],
          replyNotification: data['replyNotification'],
          threadNotification: data['threadNotification']
        });
        this.userService.setCurrentUser(user);
        this.currentUser['authenticated'] = this.userid;
        this.emailNotificationChecked = !!+this.currentUser['emailNotification'];
        this.replyNotificationChecked = !!+this.currentUser['replyNotification'];
        this.threadNotificationChecked = !!+this.currentUser['threadNotification'];
        this.themeChecked = this.currentUser['theme'] === this.themeObj['dark'] ? false : true;
        const themeType = data['theme'] === this.themeObj['light'] ? this.themeObj['light'] : this.themeObj['dark'];
        this.httpService.themeType.next(themeType);
        this.themeRemove = this.cookieService.check('theme') && this.cookieService.get('theme') === this.themeObj['light'] ? this.themeObj['dark'] : this.themeObj['light'];
        this.themeAdd = this.themeRemove === this.themeObj['light'] ? this.themeObj['dark'] : this.themeObj['light'];
        this.userArchiveThemeIsLight = this.cookieService.check('theme') && this.cookieService.get('theme') === this.themeObj['light'] ? true : false;
        this.userSuspendThemeIsLight = this.cookieService.check('theme') && this.cookieService.get('theme') === this.themeObj['light'] ? true : false;
        this.userPasswordThemeIsLight = this.cookieService.check('theme') && this.cookieService.get('theme') === this.themeObj['light'] ? true : false;
        this.userApprovedThemeIsLight = this.cookieService.check('theme') && this.cookieService.get('theme') === this.themeObj['light'] ? true : false;
        this.openSnackBar('Changes have been submitted', 'Success');
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
          createdAt: item['createdAt'],
          avatarSrc: item['avatarSrc'],
          imageAccreditation: item['imageAccreditation'],
          imageOrientation: item['imageOrientation']
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
          createdAt: item['createdAt'],
          avatarSrc: item['avatarSrc'],
          imageAccreditation: item['imageAccreditation'],
          imageOrientation: item['imageOrientation']
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

  am4themes_lightTheme(target): void {
    if (target instanceof am4core.InterfaceColorSet) {
      target.setFor("background", am4core.color("#ffffff"));
      target.setFor("grid", am4core.color("#000000"));
      target.setFor("text", am4core.color("#000000"));
    }
    if (target instanceof am4core.ColorSet) {
      target.list = [
        am4core.color(this.themeSwatch['matColorSwatchPrimary2']),
        am4core.color(this.themeSwatch['matColorSwatchAccent1'])
      ];
    }
  }

  am4themes_darkTheme(target): void {
    if (target instanceof am4core.InterfaceColorSet) {
      target.setFor("background", am4core.color("#000000"));
      target.setFor("grid", am4core.color("#ffffff"));
      target.setFor("text", am4core.color("#ffffff"));
    }
    if (target instanceof am4core.ColorSet) {
      target.list = [
        am4core.color(this.themeSwatch['matColorSwatchPrimary2']),
        am4core.color(this.themeSwatch['matColorSwatchAccent1'])
      ];
    }
  }

  private adminDashboardAmchartUserfileGetData = (data) => {
    if(this.debug) {
      console.log('profile.component: adminDashboardAmchartUserfileGetData: data',data);
    }
    if(data && 'rowData' in data) {
      this.zone.runOutsideAngular(() => {
        const chart = am4core.create("admin-dashboard-amchart-userfile", am4charts.XYChart);
        // Add data
        chart.data = data['rowData'];
        // Create axes
        const categoryAxis = chart.xAxes.push(new am4charts.CategoryAxis());
        categoryAxis.dataFields.category = "name";
        categoryAxis.title.text = "Approved/unapproved articles";
        categoryAxis.renderer.grid.template.location = 0;
        categoryAxis.renderer.minGridDistance = 20;
        categoryAxis.renderer.cellStartLocation = 0.1;
        categoryAxis.renderer.cellEndLocation = 0.9;
        const  valueAxis = chart.yAxes.push(new am4charts.ValueAxis());
        valueAxis.min = 0;
        valueAxis.title.text = "Number of images";
        // Create series
        function createSeries(field, name, stacked) {
          const series = chart.series.push(new am4charts.ColumnSeries());
          series.dataFields.valueY = field;
          series.dataFields.categoryX = "name";
          series.name = name;
          series.columns.template.tooltipText = "{name}: [bold]{valueY}[/]";
          series.stacked = stacked;
          series.columns.template.width = am4core.percent(95);
        }
        createSeries("approved", "Approved", true);
        createSeries("unapproved", "Unapproved", true);
        // Add legend
        chart.legend = new am4charts.Legend();
      });
    }
  }

  // form methods

  createProfileForm(): void {
    this.editProfileForm = new FormGroup({
      forename: this.forename,
      surname: this.surname,
      displayName: this.displayName,
      password: this.password,
      emailNotification: this.emailNotification,
      replyNotification: this.replyNotification,
      threadNotification: this.threadNotification,
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

  createProfileFormControls(): void {
    this.forename = new FormControl('', [
      Validators.required,
      Validators.minLength(1)
    ]);
    this.surname = new FormControl('', [
      Validators.required,
      Validators.minLength(1)
    ]);
    this.displayName = new FormControl();
    this.password = new FormControl();
    this.emailNotification = new FormControl();
    this.replyNotification = new FormControl();
    this.threadNotification = new FormControl();
    this.theme = new FormControl(); 
    this.jwtToken = new FormControl();
    this.userToken = new FormControl();
    this.useridFC = new FormControl();
    this.apiDocumentation = new FormControl(); 
    this.apiEndpoint = new FormControl(); 
  }

  monitorProfileFormValueChanges(): void {
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
        this.formProfileData['forename'] = forename;
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
        this.formProfileData['surname'] = surname;
        this.isEditProfileValid = this.isEditProfileFormValid();
      });
      this.displayName.valueChanges
      .pipe(
        debounceTime(400),
        distinctUntilChanged()
      )
      .subscribe(displayName => {
        if(this.debug) {
          console.log('profile.component: displayName: ',displayName);
        }
        this.formProfileData['displayName'] = displayName;
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
        this.formProfileData['password'] = password;
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
        this.formProfileData['emailNotification'] = emailNotification ? 1 : 0;
      });
      this.replyNotification.valueChanges
      .pipe(
        debounceTime(400),
        distinctUntilChanged()
      )
      .subscribe(replyNotification => {
        if(this.debug) {
          console.log('profile.component: replyNotification: ',replyNotification);
        }
        this.formProfileData['replyNotification'] = replyNotification ? 1 : 0;
      });
      this.threadNotification.valueChanges
      .pipe(
        debounceTime(400),
        distinctUntilChanged()
      )
      .subscribe(threadNotification => {
        if(this.debug) {
          console.log('profile.component: threadNotification: ',threadNotification);
        }
        this.formProfileData['threadNotification'] = threadNotification ? 1 : 0;
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

  isEditProfileFormValid(): boolean {
    return this.forename.value !== '' && this.surname.value !== '' ? true : false;
  }

  createEmailForm(): void {
    this.emailForm = new FormGroup({
      email: this.email,
      message: this.message
    });
    if(this.debug) {
      console.log('profile.component: this.emailForm ',this.emailForm);
    }
  }

  createEmailFormControls(): void {
    const emailPattern = "^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]+$";
    this.email = new FormControl('', [
      Validators.required,
      Validators.pattern(emailPattern),
      Validators.minLength(1)
    ]);
    this.message = new FormControl('', [
      Validators.required,
      Validators.minLength(1)
    ]);
  }

  monitorEmailFormValueChanges(): void {
    this.message.valueChanges
    .pipe(
      debounceTime(400),
      distinctUntilChanged()
    )
    .subscribe(message => {
      if(this.debug) {
        console.log('profile.component: monitorEmailFormValueChanges: message: ',message);
      }
      this.formEmailData['message'] = message;
    });
  }

  // cache methods

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

  // event methods

  onUserArchivePagesChange(event): void {
    let page = event.value;
    if(this.debug) {
      console.log('onUserArchivePagesChange: page: ', page);
    }
    this.currentUserArchivePage = page;
    if(this.debug) {
      console.log('onUserArchivePagesChange: this.currentUserArchivePage: ', this.currentUserArchivePage);
    }
    this.usersArchiveGetSubscription = this.httpService.fetchUsersArchive(this.currentUserArchivePage).do(this.processUsersArchiveGetData).subscribe();
  }

  onUserSuspendPagesChange(event): void {
    let page = event.value;
    if(this.debug) {
      console.log('onUserSuspendPagesChange: page: ', page);
    }
    this.currentUserSuspendPage = page;
    if(this.debug) {
      console.log('onUserSuspendPagesChange: this.currentUserSuspendPage: ', this.currentUserSuspendPage);
    }
    this.usersSuspendGetSubscription = this.httpService.fetchUsersAdmin('suspend',this.currentUserSuspendPage).do(this.processUsersSuspendGetData).subscribe();
  }

  onUserPasswordPagesChange(event): void {
    let page = event.value;
    if(this.debug) {
      console.log('onUserPasswordPagesChange: page: ', page);
    }
    this.currentUserPasswordPage = page;
    if(this.debug) {
      console.log('onUserPasswordPagesChange: this.currentUserPasswordPage: ', this.currentUserPasswordPage);
    }
    this.usersPasswordGetSubscription = this.httpService.fetchUsersAdmin('password',this.currentUserPasswordPage).do(this.processUsersPasswordGetData).subscribe();
  }

  onUserApprovedPagesChange(event): void {
    let page = event.value;
    if(this.debug) {
      console.log('onUserApprovedPagesChange: page: ', page);
    }
    this.currentUserApprovedPage = page;
    if(this.debug) {
      console.log('onUserApprovedPagesChange: this.currentUserApprovedPage: ', this.currentUserApprovedPage);
    }
    this.usersApprovedGetSubscription = this.httpService.fetchUsersAdmin('approved',this.currentUserApprovedPage).do(this.processUsersApprovedGetData).subscribe();
  }

  onSystemUserChange(event): void {
    let quantity = event.value;
    if(this.debug) {
      console.log('onSystemUserChange: quantity: ', quantity);
    }
    this.systemUserGetSubscription = this.httpService.addSystemUser(quantity).do(this.processSystemUserGetData).subscribe();
  }

  onMatSidenavContentScroll(): void {
    if(this.pagesUnapproved.length > 0) {
      this.unapprovedImagesSelect.close();
    }
    if(this.pagesApproved.length > 0) {
      this.approvedImagesSelect.close();
    }
    this.systemUserSelect.close();
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

  // toggle methods

  toggleError(error: string): void {
    this.safeHtml = this.sanitizer.bypassSecurityTrustHtml(error);
    this.hasError = error !== '' ? true : false;
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

  // animation methods 

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

  // animation state methods

  openProfileApiDashboard(event: any): void {
    this.profileApiDashboardState = this.profileApiDashboardState === 'in' ? 'out' : 'in';
    event.stopPropagation();
  }

  openProfileAdminDashboard(event: any): void {
    this.profileAdminDashboardState = this.profileAdminDashboardState === 'in' ? 'out' : 'in';
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

  openProfileUserSuspendEdit(event: any): void {
    this.profileUserSuspendEditState = this.profileUserSuspendEditState === 'in' ? 'out' : 'in';
    event.stopPropagation();
  }

  openProfileUserPasswordEdit(event: any): void {
    this.profileUserPasswordEditState = this.profileUserPasswordEditState === 'in' ? 'out' : 'in';
    event.stopPropagation();
  }

  openProfileUserApprovedEdit(event: any): void {
    this.profileUserApprovedEditState = this.profileUserApprovedEditState === 'in' ? 'out' : 'in';
    event.stopPropagation();
  }

  openSystemUserEdit(event: any): void {
    this.profileSystemUserEditState = this.profileSystemUserEditState === 'in' ? 'out' : 'in';
    event.stopPropagation();
  }

  // location methods

  goToApiDocumentation(event: any): void {
    window.open(environment.apiDocumentationUrl,'_blank');
    event.stopPropagation();
  }

  // array methods

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

  // dialog methods

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
      console.log('profile.component: dialog edit categories help notification: before close: this.themeRemove: ', this.themeRemove);
      console.log('profile.component: dialog edit categories help notification: before close: this.themeAdd: ', this.themeAdd);
    }
    updateCdkOverlayThemeClass(this.themeRemove,this.themeAdd);
    dialogRef.beforeClose().subscribe(result => {
      if(this.debug) {
        console.log('profile.component: dialog edit categories help notification: before close');
      }
      if(result) {
        if(this.debug) {
          console.log('profile.component: dialog edit categories help notification: before close: result: ', result);
        }
      }
    });
    dialogRef.afterOpen().subscribe( () => {
      if(this.debug) {
        console.log('profile.component: dialog edit categories help notification: after open');
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
        console.log('profile.component: dialog edit categories help notification: this.dialogEditCategoriesHeight: ', this.dialogEditCategoriesHeight);
      }
    });
  }

  deleteProfileFormSubmit(): void {
    this.openDialog();
  }

  // snackbar methods

  openSnackBar(message: string, action: string): void {
    const config = new MatSnackBarConfig();
    config.panelClass = action.toLowerCase() === 'error' ? ['custom-class-error'] : ['custom-class'];
    config.duration = 5000;
    this.matSnackBar.open(message, action, config);
  }

  // specific user archive ag-grid functions

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
    const selectedDataStringPresentation = selectedData.map( node => node.user_id).join(',');
    if(this.debug) {
      console.log('profile.component: getUserArchiveSelectedRows: selectedDataStringPresentation: ', selectedDataStringPresentation);
    }
    this.usersArchivePostSubscription = this.httpService.addUsersFromArchive(selectedDataStringPresentation,this.currentUserArchivePage).do(this.processUsersArchivePostData).subscribe();
  }

  refreshUserArchive(): void {
    var params = {force:true};
    this.gridApiUserArchive.refreshCells(params);
  }

  onUserArchiveSelectionChanged(event: any): void {
    var rowCount = event.api.getSelectedNodes().length;
    this.userArchiveSubmitDisabled = rowCount ? false : true;
  }

  // specific user suspend ag-grid functions

  userSuspendAutoSizeAll(): void {
    var allColumnIds = [];
    this.gridColumnApiUserSuspend.getAllColumns().forEach(function(column) {
      allColumnIds.push(column.colId);
    });
    this.gridColumnApiUserSuspend.autoSizeColumns(allColumnIds);
  }

  onUserSuspendGridReady(params): void {
    this.gridApiUserSuspend = params.api;
    this.gridColumnApiUserSuspend = params.columnApi;
    this.gridApiUserSuspend.setDomLayout("autoHeight");
    if(this.debug) {
      console.log('profile.component: onUserSuspendGridReady');
    }
    setTimeout( () => {
      this.userSuspendAutoSizeAll();
    });
  }

  getUserSuspendSelectedRows(): void {
    const selectedNodes = this.agGridUserSuspend.api.getSelectedNodes();
    const selectedData = selectedNodes.map( node => node.data );
    const changesArray = this.getChangesArray(this.cachedNodeDataUserSuspend,this.agGridUserSuspend.api.getRenderedNodes(),'user_id');
    const changesSelectedArray = changesArray['selected'];
    const changesUnselectedArray = changesArray['unselected'];
    if(this.debug) {
      console.log('profile.component: getUserSuspendSelectedRows: changesSelectedArray: ', changesSelectedArray);
      console.log('profile.component: getUserSuspendSelectedRows: changesUnselectedArray: ', changesUnselectedArray);
    }
    if(changesUnselectedArray.length) {
      this.openUserAdminNotificationDialog(changesSelectedArray,changesUnselectedArray,this.agGridUserSuspend.api.getRenderedNodes(),this.agGridUserSuspend.api,'suspend','user_id');
    }
    else{
      this.postUserAdmin(this.agGridUserSuspend.api,'suspend');
    }
  }

  onUserSuspendRowValueChanged(event): void {
    const data = this.getAllUserSuspendData();
    if(this.debug) {
      console.log('profile.component: onUserSuspendRowValueChanged: data: ', data);
    }
  }

  getAllUserSuspendData(): any {
    let rowData = [];
    this.agGridUserSuspend.api.forEachNode((node) => {
      return rowData.push(node.data);
    });
    return rowData;  
  }

  onFlashUserSuspendColumns(columns: string[]): void {
    this.agGridUserSuspend.api.flashCells({
      columns: columns
    });
  }

  onUserSuspendSelectionChanged(event: any): void {
    var rowCount = event.api.getSelectedNodes().length;
    this.userSuspendSubmitDisabled = rowCount ? false : true;
    if(this.cachedNodeDataUserSuspend.length === 0) {
      const temp = [];
      this.agGridUserSuspend.api.forEachNode((node) => {
        const obj = {};
        for(const key in node.data) {
          obj[key] = node.data[key];
        }
        temp.push(obj);
      });
      this.cachedNodeDataUserSuspend = Array.from(Object.create(temp));
      if(this.debug) {
        console.log('profile.component: onUserSuspendSelectionChanged: this.cachedNodeDataUserSuspend: ', this.cachedNodeDataUserSuspend);
      }
    }
  }

  // specific user password ag-grid functions

  userPasswordAutoSizeAll(): void {
    var allColumnIds = [];
    this.gridColumnApiUserPassword.getAllColumns().forEach(function(column) {
      allColumnIds.push(column.colId);
    });
    this.gridColumnApiUserPassword.autoSizeColumns(allColumnIds);
  }

  onUserPasswordGridReady(params): void {
    this.gridApiUserPassword = params.api;
    this.gridColumnApiUserPassword = params.columnApi;
    this.gridApiUserPassword.setDomLayout("autoHeight");
    if(this.debug) {
      console.log('profile.component: onUserPasswordGridReady');
    }
    setTimeout( () => {
      this.userPasswordAutoSizeAll();
    });
  }

  getUserPasswordSelectedRows(): void {
    const selectedNodes = this.agGridUserPassword.api.getSelectedNodes();
    const selectedData = selectedNodes.map( node => node.data );
    const changesArray = this.getChangesArray(this.cachedNodeDataUserPassword,this.agGridUserPassword.api.getRenderedNodes(),'user_id');
    const changesSelectedArray = changesArray['selected'];
    const changesUnselectedArray = changesArray['unselected'];
    if(this.debug) {
      console.log('profile.component: getUserPasswordSelectedRows: changesSelectedArray: ', changesSelectedArray);
      console.log('profile.component: getUserPasswordSelectedRows: changesUnselectedArray: ', changesUnselectedArray);
    }
    if(changesUnselectedArray.length) {
      this.openUserAdminNotificationDialog(changesSelectedArray,changesUnselectedArray,this.agGridUserPassword.api.getRenderedNodes(),this.agGridUserPassword.api,'password','user_id');
    }
    else{
      this.postUserAdmin(this.agGridUserPassword.api,'password');
    }
  }

  onUserPasswordRowValueChanged(event): void {
    const data = this.getAllUserPasswordData();
    if(this.debug) {
      console.log('profile.component: onUserPasswordRowValueChanged: data: ', data);
    }
  }

  getAllUserPasswordData(): any {
    let rowData = [];
    this.agGridUserPassword.api.forEachNode((node) => {
      return rowData.push(node.data);
    });
    return rowData;  
  }

  onFlashUserPasswordColumns(columns: string[]): void {
    this.agGridUserPassword.api.flashCells({
      columns: columns
    });
  }

  onUserPasswordSelectionChanged(event: any): void {
    var rowCount = event.api.getSelectedNodes().length;
    this.userPasswordSubmitDisabled = rowCount ? false : true;
    if(this.cachedNodeDataUserPassword.length === 0) {
      const temp = [];
      this.agGridUserPassword.api.forEachNode((node) => {
        const obj = {};
        for(const key in node.data) {
          obj[key] = node.data[key];
        }
        temp.push(obj);
      });
      this.cachedNodeDataUserPassword = Array.from(Object.create(temp));
      if(this.debug) {
        console.log('profile.component: onUserPasswordSelectionChanged: this.cachedNodeDataUserPassword: ', this.cachedNodeDataUserPassword);
      }
    }
  }

  // specific user approved ag-grid functions

  userApprovedAutoSizeAll(): void {
    var allColumnIds = [];
    this.gridColumnApiUserApproved.getAllColumns().forEach(function(column) {
      allColumnIds.push(column.colId);
    });
    this.gridColumnApiUserApproved.autoSizeColumns(allColumnIds);
  }

  onUserApprovedGridReady(params): void {
    this.gridApiUserApproved = params.api;
    this.gridColumnApiUserApproved = params.columnApi;
    this.gridApiUserApproved.setDomLayout("autoHeight");
    if(this.debug) {
      console.log('profile.component: onUserApprovedGridReady');
    }
    setTimeout( () => {
      this.userApprovedAutoSizeAll();
    });
  }

  getUserApprovedSelectedRows(): void {
    const selectedNodes = this.agGridUserApproved.api.getSelectedNodes();
    const selectedData = selectedNodes.map( node => node.data );
    const changesArray = this.getChangesArray(this.cachedNodeDataUserApproved,this.agGridUserApproved.api.getRenderedNodes(),'file_id');
    const changesSelectedArray = changesArray['selected'];
    const changesUnselectedArray = changesArray['unselected'];
    if(this.debug) {
      console.log('profile.component: getUserApprovedSelectedRows: changesSelectedArray: ', changesSelectedArray);
      console.log('profile.component: getUserApprovedSelectedRows: changesUnselectedArray: ', changesUnselectedArray);
    }
    if(changesUnselectedArray.length) {
      this.openUserAdminNotificationDialog(changesSelectedArray,changesUnselectedArray,this.agGridUserApproved.api.getRenderedNodes(),this.agGridUserApproved.api,'approved','file_id');
    }
    else{
      this.postUserAdmin(this.agGridUserApproved.api,'approved');
    }
  }

  onUserApprovedRowValueChanged(event): void {
    const data = this.getAllUserApprovedData();
    if(this.debug) {
      console.log('profile.component: onUserApprovedRowValueChanged: data: ', data);
    }
  }

  getAllUserApprovedData(): any {
    let rowData = [];
    this.agGridUserApproved.api.forEachNode((node) => {
      return rowData.push(node.data);
    });
    return rowData;  
  }

  onFlashUserApprovedColumns(columns: string[]): void {
    this.agGridUserApproved.api.flashCells({
      columns: columns
    });
  }

  onUserApprovedSelectionChanged(event: any): void {
    var rowCount = event.api.getSelectedNodes().length;
    this.userApprovedSubmitDisabled = rowCount ? false : true;
    if(this.cachedNodeDataUserApproved.length === 0) {
      const temp = [];
      this.agGridUserApproved.api.forEachNode((node) => {
        const obj = {};
        for(const key in node.data) {
          obj[key] = node.data[key];
        }
        temp.push(obj);
      });
      this.cachedNodeDataUserApproved = Array.from(Object.create(temp));
      if(this.debug) {
        console.log('profile.component: onUserApprovedSelectionChanged: this.cachedNodeDataUserApproved: ', this.cachedNodeDataUserApproved);
      }
    }
  }

  // general ag-grid functions

  getTinyintCellEditor(): any {
    function isCharNumeric(charStr) {
      return !!/[01]{1,1}/.test(charStr);
    }
    function isKeyPressedNumeric(event) {
      var charCode = getCharCodeFromEvent(event);
      var charStr = String.fromCharCode(charCode);
      return isCharNumeric(charStr);
    }
    function getCharCodeFromEvent(event) {
      event = event || window.event;
      return typeof event.which === "undefined" ? event.keyCode : event.which;
    }
    function NumericCellEditor() {}
    NumericCellEditor.prototype.init = function(params) {
      this.focusAfterAttached = params.cellStartedEdit;
      this.eInput = document.createElement("input");
      this.eInput.style.width = "100%";
      this.eInput.style.height = "100%";
      this.eInput.value = isCharNumeric(params.charPress) ? params.charPress : params.value;
      var that = this;
      this.eInput.addEventListener("keypress", function(event) {
        if (!isKeyPressedNumeric(event)) {
          that.eInput.focus();
          if (event.preventDefault) event.preventDefault();
        }
      });
    };
    NumericCellEditor.prototype.getGui = function() {
      return this.eInput;
    };
    NumericCellEditor.prototype.afterGuiAttached = function() {
      if (this.focusAfterAttached) {
        this.eInput.focus();
        this.eInput.select();
      }
    };
    NumericCellEditor.prototype.isCancelBeforeStart = function() {
      return this.cancelBeforeStart;
    };
    NumericCellEditor.prototype.isCancelAfterEnd = function() {};
    NumericCellEditor.prototype.getValue = function() {
      return this.eInput.value;
    };
    NumericCellEditor.prototype.focusIn = function() {
      var eInput = this.getGui();
      eInput.focus();
      eInput.select();
      console.log("NumericCellEditor.focusIn()");
    };
    NumericCellEditor.prototype.focusOut = function() {
      console.log("NumericCellEditor.focusOut()");
    };
    return NumericCellEditor;
  }
  
  refreshAgGrid(grid: any, id1: string, id2: string): void {
    const overshoot=5;
    const period=0.25;
    const params = {force:true};
    grid.refreshCells(params);
    const aggridusertaskupdatedicon = this.documentBody.getElementById(id1);
    const aggridusertaskremovehighlighticon = this.documentBody.getElementById(id2);
    const that = this;
    if(aggridusertaskupdatedicon && aggridusertaskremovehighlighticon) {
      this.renderer.setStyle(aggridusertaskremovehighlighticon,'opacity',0);
      TweenMax.to(aggridusertaskupdatedicon,0.5,{
        scale:0.25,
        opacity:0.25,
        onComplete:function(){
          TweenMax.to(aggridusertaskupdatedicon,1.4,{
            scale:1,
            opacity:1,
            ease:Elastic.easeOut,
            easeParams:[overshoot,period],
            onComplete:function(){
              TweenMax.delayedCall(5,tweenFunc);
            }
          })
        }
      });
      var tweenFunc = function() {
        TweenMax.to(aggridusertaskupdatedicon,1,{
          opacity:0,
          ease:Linear.easeNone,
          onComplete:function(){
            that.renderer.setStyle(aggridusertaskremovehighlighticon,'opacity',1);
          }
        })
      }
    }
  }

  getChangesArray(cachedArray: any[], renderedArray: any[], identifier: string): any {
    const selectedChanges = [];
    const unselectedChanges = [];
    if(this.debug) {
      console.log('profile.component: getChangesArray: cachedArray: ', cachedArray);
      console.log('profile.component: getChangesArray: renderedArray: ', renderedArray);
      console.log('profile.component: getChangesArray: identifier: ', identifier);
    }
    const cachedArrayPage = [];
    cachedArray.map( (node) => {
      renderedArray.map( (obj) => {
        const data = obj.data;
        if(data[identifier] === node[identifier]) {
          cachedArrayPage.push(node);
        }
      });
    });
    if(this.debug) {
      console.log('profile.component: getChangesArray: cachedArrayPage: ', cachedArrayPage);
    }
    cachedArrayPage.map( (node) => {
      renderedArray.map( (obj) => {
        const data = obj.data;
        if(data[identifier] === node[identifier] && obj.isSelected()) {
          let changedSelected = false;
          for(const key in data) {
            let data1 = data[key];
            data1 = key === ('suspend' || 'approved') ? parseInt(data1) : data1;
            let data2 = node[key];
            data2 = key === ('suspend' || 'approved') ? parseInt(data2) : data2;
            if(data1 !== data2) {
              if(this.debug) {
                console.log('profile.component: getChangesArray: selected: data[key]: ', data[key],' node[key]: ',node[key]);
                console.log('profile.component: getChangesArray: selected: data1: ', data1,' data2: ',data2);
              }
              changedSelected = true;
              break;
            }
          }
          if(changedSelected) {
            selectedChanges.push(node);
          }
        }
        if(data[identifier] === node[identifier] && !obj.isSelected()) {
          let changedUnselected = false;
          for(const key in data) {
            let data1 = data[key];
            data1 = key === ('suspend' || 'approved') ? parseInt(data1) : data1;
            let data2 = node[key];
            data2 = key === ('suspend' || 'approved') ? parseInt(data2) : data2;
            if(data1 !== data2) {
              if(this.debug) {
                console.log('profile.component: getChangesArray: unselected: data[key]: ', data[key],' node[key]: ',node[key]);
                console.log('profile.component: getChangesArray: unselected: data1: ', data1,' data2: ',data2);
              }
              changedUnselected = true;
              break;
            }
          }
          if(changedUnselected) {
            unselectedChanges.push(node);
          }
        }
      });
    });
    const changesObj = {
      selected: selectedChanges,
      unselected: unselectedChanges,
    };
    if(this.debug) {
      console.log('profile.component: getChangesArray: changesObj: ', changesObj);
    }
    return changesObj;
  }

  // user admin dialog methods

  openUserAdminNotificationDialog(changesSelectedArray: any[], changesUnselectedArray: any[], renderedArray: any[], grid: any, type: string, identifier: string): void {
    const dialogRef = this.dialog.open(this.dialogUserAdminNotificationTpl, {
      width: this.isMobile ? '100%' :'50%',
      height: this.isMobile ? '100%' :'50%',
      maxWidth: this.isMobile ? '100%' :'50%',
      id: 'dialog-user-admin-notification'
    });
    updateCdkOverlayThemeClass(this.themeRemove,this.themeAdd);
    dialogRef.afterClosed().subscribe(result => {
      if(this.debug) {
        console.log('profile.component: openUserAdminNotificationDialog(): The dialog was closed');
      }
      if(result) {
        if(this.debug) {
          console.log('profile.component: openUserAdminNotificationDialog(): The action was approved: userAdminUnselectedChanges: ', 
          this.userAdminUnselectedChanges);
        }
        const value = userAdminUnselectedChangesOptionsStatus[this.userAdminUnselectedChanges];
        switch(value) {
          case 1:
            this.userAdminSelectRows(changesSelectedArray,changesUnselectedArray,renderedArray,identifier);
            this.postUserAdmin(grid,type);
            break;
          case 2:
            this.userAdminSelectAndHighlightRows(changesSelectedArray,changesUnselectedArray,renderedArray,identifier);
            break;
          default:
          this.postUserAdmin(grid,type);
        }
      }
    });
  }

  removeHighlightedCells(event: any, selector: string): void {
    const agGridDOM = Array.prototype.slice.call(this.documentBody.querySelectorAll(selector));
    if(agGridDOM.length > 0) {
      if(this.debug) {
        console.log('profile.component: removeHighlightedCells: agGridDOM: ',agGridDOM);
      }
      agGridDOM.map( (element) => {
        if(element.classList.contains('ag-row-hover')) {
          if(this.debug) {
            console.log('profile.component: removeHighlightedCells: selector',selector);
            console.log('profile.component: removeHighlightedCells: element.classList.contains(\'ag-row-hover\')',element.classList.contains('ag-row-hover'));
          }
          element.classList.remove('ag-row-hover')
        }
      });
    }
  }

  // user admin methods

  userAdminSelectRows(changesSelectedArray: any[], changesUnselectedArray: any[], renderedArray: any[], identifier: string): void {
    changesSelectedArray.map((node) => {
      renderedArray.map( (obj) => {
        const data = obj.data;
        if(data[identifier] === node[identifier]) {
          obj.setSelected(true);
        }
      });
    });
    changesUnselectedArray.map((node) => {
      renderedArray.map( (obj) => {
        const data = obj.data;
        if(data[identifier] === node[identifier]) {
          obj.setSelected(true);
        }
      });
    });
  }

  userAdminSelectAndHighlightRows(changesSelectedArray: any[], changesUnselectedArray: any[], renderedArray: any[], identifier: string): void {
    changesSelectedArray.map((node) => {
      renderedArray.map( (obj) => {
        const data = obj.data;
        if(data[identifier] === node[identifier]) {
          obj.setSelected(true);
        }
      });
    });
    changesUnselectedArray.map((node) => {
      renderedArray.map( (obj) => {
        const data = obj.data;
        if(data[identifier] === node[identifier]) {
          obj.setSelected(true);
        }
      });
    });
  }

  postUserAdmin(grid: any, type: string): void {
    const selectedNodes = grid.getSelectedNodes();
    const selectedData = selectedNodes.map( node => node.data );
    const data = [];
    switch(type) {
      case 'suspend':
        selectedData.map( (node) => {
          const obj = {};
          obj['id'] = node.user_id;
          obj['suspend'] = node.suspend;
          data.push(obj);
        });
        if(this.debug) {
          console.log('profile.component: postUserAdmin: suspend: data: ', data);
        }
        const objSuspend = {
          users: data,
          task: 'suspend'
        };
        this.usersSuspendPostSubscription = this.httpService.editUserAdmin(objSuspend,this.currentUserSuspendPage).do(this.processUsersSuspendPostData).subscribe();
        break;
      case 'password':
        selectedData.map( (node) => {
          const obj = {};
          obj['id'] = node.user_id;
          obj['password'] = node.password;
          data.push(obj);
        });
        if(this.debug) {
          console.log('profile.component: postUserAdmin: password: data: ', data);
        }
        const objPassword = {
          users: data,
          task: 'password'
        };
        this.usersPasswordPostSubscription = this.httpService.editUserAdmin(objPassword,this.currentUserPasswordPage).do(this.processUsersPasswordPostData).subscribe();
        break;
      case 'approved':
        selectedData.map( (node) => {
          const obj = {};
          obj['id'] = node.user_id;
          obj['fileid'] = node.file_id;
          obj['approved'] = node.approved;
          data.push(obj);
        });
        if(this.debug) {
          console.log('profile.component: postUserAdmin: approved: data: ', data);
        }
        const objApproved = {
          users: data,
          task: 'approved'
        };
        this.usersApprovedPostSubscription = this.httpService.editUserAdmin(objApproved,this.currentUserApprovedPage).do(this.processUsersApprovedPostData).subscribe();
        break;
    }
  }

  // router methods

  previewArticle(params): void {
    if(this.debug) {
      console.log('profile.component: previewArticle: params: ', params);
    }
    if(this.debug) {
      console.log('profile.component: previewArticle: this.currentUser[\'userid\']: ', this.currentUser['userid']);
    }
    this.router.navigate([this.uploadRouterAliasLower, {fileid: params.data.file_uuid, userid: this.currentUser['userid']}]);
  }

  // e-mail methods

  openEmailDialog(params): void {
    if(this.debug) {
      console.log('profile.component: openEmailDialog: params: ', params);
    }
    const dialogRef = this.dialog.open(this.dialogEmailTpl, {
      width: this.isMobile ? '100%' : '75%',
      height: this.isMobile ? '100%' :'90%',
      maxWidth: 1278,
      id: 'dialog-email'
    });
    updateCdkOverlayThemeClass(this.themeRemove,this.themeAdd);
    dialogRef.beforeClose().subscribe(result => {
      if(this.debug) {
        console.log('profile.component: dialog e-mail: before close');
      }
      if(result) {
        if(this.debug) {
          console.log('profile.component: dialog e-mail: before close: result: ', result);
        }
      }
    });
    dialogRef.afterOpen().subscribe( () => {
      if(this.debug) {
        console.log('profile.component: dialog e-mail: after open');
      }
      this.email.patchValue(params.data.e_mail);
      this.formEmailData['email'] = params.data.e_mail;
      const parent = this.documentBody.querySelector('#dialog-email');
      const child = this.documentBody.querySelector('#message');
      let height = parent.clientHeight ? parent.clientHeight : 0;
      const offsetHeight = 504;
      if(!isNaN(height) && (height - offsetHeight) > 0) {
        height = height - offsetHeight;
      }
      if(height > 0 ) {
        this.dialogEmailHeight = height;
      }
      if(child) {
        this.renderer.setStyle(child,'height',height + 'px');
      }
      const emailForm = this.documentBody.querySelector('#emailForm');
      if(emailForm) {
        TweenMax.fromTo(emailForm, 1, {ease:Elastic.easeOut, opacity: 0}, {ease:Elastic.easeOut, opacity: 1});
      }
      this.emailFormDisabled = true;
      if(this.debug) {
        console.log('profile.component: dialog: this.dialogEmailHeight: ', this.dialogEmailHeight);
      }
      this.emailTemplateStartSalutation = 'Hi ' + params.data.forename;
      this.emailTemplateEndSalutation = 'Yours sincerely';
      this.emailTemplateDate = ' ' + new Date().toString().replace(/[\s]+[0-9]{2,2}\:.*/ig,'');
      this.emailTemplateCredit = environment.title;
    });
  }

  closeEmailDialog(): void {
    this.dialog.closeAll();
  }

  sendEmail(): void {
    const data = [];
    const dataObj = {};
    dataObj['id'] = this.email.value;
    dataObj['email'] = this.email.value;
    dataObj['startSalutation'] = this.emailTemplateStartSalutation;
    dataObj['endSalutation'] = this.emailTemplateEndSalutation;
    dataObj['credit'] = this.emailTemplateCredit;
    const message = this.message.value.replace(/(?:\r\n|\r|\n)/g, '<br />');
    dataObj['message'] = message;
    data.push(dataObj);
    if(this.debug) {
      console.log('profile.component: sendEmail: data: ', data);
    }
    const obj = {
      users: data,
      task: 'email'
    };
    this.email.patchValue('');
    this.message.patchValue('');
    this.emailTemplateStartSalutation = '';
    this.emailTemplateEndSalutation = '';
    this.emailTemplateDate = '';
    this.emailTemplateCredit = '';
    this.formEmailData = {};
    this.dialog.closeAll();
    this.usersEmailPostSubscription = this.httpService.editUserAdmin(obj).do(this.processUsersEmailPostData).subscribe();
  }

  // other methods

  createThemeSwatch(): void {
    const matColorSwatchPrimary1 = styler('#mat-color-swatch-primary-1').get(['background']);
    const colorSwatchPrimary1 = matColorSwatchPrimary1['background'].replace(/rgb\(/ig,'').replace(/\).*/g,'').replace(/[\s]+/g,'').split(',');
    const matColorSwatchPrimary2 = styler('#mat-color-swatch-primary-2').get(['background']);
    const colorSwatchPrimary2 = matColorSwatchPrimary2['background'].replace(/rgb\(/ig,'').replace(/\).*/g,'').replace(/[\s]+/g,'').split(',');
    const matColorSwatchPrimary3 = styler('#mat-color-swatch-primary-3').get(['background']);
    const colorSwatchPrimary3 = matColorSwatchPrimary3['background'].replace(/rgb\(/ig,'').replace(/\).*/g,'').replace(/[\s]+/g,'').split(',');
    const matColorSwatchAccent1 = styler('#mat-color-swatch-accent-1').get(['background']);
    const colorSwatchAccent1 = matColorSwatchAccent1['background'].replace(/rgb\(/ig,'').replace(/\).*/g,'').replace(/[\s]+/g,'').split(',');
    const matColorSwatchAccent2 = styler('#mat-color-swatch-accent-2').get(['background']);
    const colorSwatchAccent2 = matColorSwatchAccent2['background'].replace(/rgb\(/ig,'').replace(/\).*/g,'').replace(/[\s]+/g,'').split(',');
    const matColorSwatchAccent3 = styler('#mat-color-swatch-accent-3').get(['background']);
    const colorSwatchAccent3 = matColorSwatchAccent3['background'].replace(/rgb\(/ig,'').replace(/\).*/g,'').replace(/[\s]+/g,'').split(',');
    const matColorSwatchWarn1 = styler('#mat-color-swatch-warn-1').get(['background']);
    const colorSwatchWarn1 = matColorSwatchWarn1['background'].replace(/rgb\(/ig,'').replace(/\).*/g,'').replace(/[\s]+/g,'').split(',');
    this.themeSwatch = {
      matColorSwatchPrimary1: rgbToHex(parseInt(colorSwatchPrimary1[0]),parseInt(colorSwatchPrimary1[1]),parseInt(colorSwatchPrimary1[2])),
      matColorSwatchPrimary2: rgbToHex(parseInt(colorSwatchPrimary2[0]),parseInt(colorSwatchPrimary2[1]),parseInt(colorSwatchPrimary2[2])),
      matColorSwatchPrimary3: rgbToHex(parseInt(colorSwatchPrimary3[0]),parseInt(colorSwatchPrimary3[1]),parseInt(colorSwatchPrimary3[2])),
      matColorSwatchAccent1: rgbToHex(parseInt(colorSwatchAccent1[0]),parseInt(colorSwatchAccent1[1]),parseInt(colorSwatchAccent1[2])),
      matColorSwatchAccent2: rgbToHex(parseInt(colorSwatchAccent2[0]),parseInt(colorSwatchAccent2[1]),parseInt(colorSwatchAccent2[2])),
      matColorSwatchAccent3: rgbToHex(parseInt(colorSwatchAccent3[0]),parseInt(colorSwatchAccent3[1]),parseInt(colorSwatchAccent3[2])),
      matColorSwatchWarn1: rgbToHex(parseInt(colorSwatchWarn1[0]),parseInt(colorSwatchWarn1[1]),parseInt(colorSwatchWarn1[2]))
    };
    //if(this.debug) {
      console.log('profile.component: createThemeSwatch: this.themeSwatch: ', this.themeSwatch);
    //}
  }

  togglePanelWidth(event: any): void {
    const target = event.target.parentElement.parentElement;
    if(this.debug) {
      console.log('profile.component: togglePanelWidth: target: ', target);
      console.log('profile.component: togglePanelWidth: target.classList.contains(\'panel\'): ', target.classList.contains('panel'));
      console.log('profile.component: togglePanelWidth: target.classList.contains(\'expand\'): ', target.classList.contains('expand'));
    }
    if(target && target.classList.contains('panel')) {
      target.classList.toggle('expand',!target.classList.contains('expand'));
    }
  }

  refreshGrid(event: any, type: string = ''): void {
    switch(type) {
      case 'userSuspend':
        this.usersSuspendGetSubscription = this.httpService.fetchUsersAdmin('suspend',1).do(this.processUsersSuspendGetData).subscribe();
        break;
      case 'userPassword':
        this.usersPasswordGetSubscription = this.httpService.fetchUsersAdmin('password',1).do(this.processUsersPasswordGetData).subscribe();
        break;  
      default:
        // code block
    }
  }

  editFile(id: string): void {
    if(this.debug) {
      console.log('profile.component: editFile: this.currentUser[\'userid\']: ', this.currentUser['userid']);
    }
    this.router.navigate([this.uploadRouterAliasLower, {fileid: id, userid: this.currentUser['userid']}]);
  }

  ngOnDestroy() {

    this.zone.runOutsideAngular(() => {
      if (this.adminDashboardAmchartUserfile) {
        this.adminDashboardAmchartUserfile.dispose();
      }
    });

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

    if(this.usersSuspendGetSubscription) {
      this.usersSuspendGetSubscription.unsubscribe();
    }

    if(this.usersPasswordGetSubscription) {
      this.usersPasswordGetSubscription.unsubscribe();
    }

    if(this.usersApprovedGetSubscription) {
      this.usersApprovedGetSubscription.unsubscribe();
    }

    if(this.systemUserGetSubscription) {
      this.systemUserGetSubscription.unsubscribe();
    }

    if(this.usersArchivePostSubscription) {
      this.usersArchivePostSubscription.unsubscribe();
    }

    if(this.usersSuspendPostSubscription) {
      this.usersSuspendPostSubscription.unsubscribe();
    }

    if(this.usersPasswordPostSubscription) {
      this.usersPasswordPostSubscription.unsubscribe();
    }

    if(this.usersApprovedPostSubscription) {
      this.usersApprovedPostSubscription.unsubscribe();
    }

    if(this.usersEmailPostSubscription) {
      this.usersEmailPostSubscription.unsubscribe();
    }

  }

}
