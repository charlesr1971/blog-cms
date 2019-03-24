import { Component, OnInit, OnDestroy, ViewChild, TemplateRef } from '@angular/core';
import { Subscription, BehaviorSubject } from 'rxjs';
import { debounceTime, distinctUntilChanged } from 'rxjs/operators';
import { FormGroup, FormControl, Validators } from '@angular/forms';
import { DeviceDetectorService } from 'ngx-device-detector';
import { MatSnackBar, MatSnackBarConfig } from '@angular/material';
import { MatDialog } from '@angular/material';
import { CookiePolicyComponent } from '../cookie-policy/cookie-policy.component';
import { updateCdkOverlayThemeClass } from '../util/updateCdkOverlayThemeClass';

import { CookieService } from 'ngx-cookie-service';
import { HttpService } from '../services/http/http.service';
import { environment } from '../../environments/environment';

@Component({
  selector: 'app-cookie-acceptance-snack-bar',
  templateUrl: './cookie-acceptance-snack-bar.component.html',
  styleUrls: ['./cookie-acceptance-snack-bar.component.css']
})
export class CookieAcceptanceSnackBarComponent implements OnInit, OnDestroy {

  @ViewChild('cookieAcceptanceSnackBarTemplate') snackBarTemplate: TemplateRef<any>;

  cookieAcceptanceForm: FormGroup;
  cookieAcceptance: FormControl;

  formData = {};

  isMobile: boolean = false;
  cookieAcceptanceSubscription: Subscription;
  dialogcookiePolicyHeight: number = 0;
  themeRemove: string = '';
  themeAdd: string = '';

  debug: boolean = false;

  constructor(public matSnackBar: MatSnackBar,
    public dialog: MatDialog,
    private deviceDetectorService: DeviceDetectorService,
    public cookieService: CookieService,
    private httpService: HttpService) { 

    if(environment.debugComponentLoadingOrder) {
      console.log('cookieAcceptanceSnackBarComponent.component loaded');
    }

    const themeObj = this.httpService.themeObj;
    this.themeRemove = this.cookieService.check('theme') && this.cookieService.get('theme') === themeObj['light'] ? themeObj['dark'] : themeObj['light'];
    this.themeAdd = this.themeRemove === themeObj['light'] ? themeObj['dark'] : themeObj['light'];

    this.isMobile = this.deviceDetectorService.isMobile();

    this.createFormControls();
    this.createForm();
    this.monitorFormValueChanges();

    if(this.debug) {
      console.log('cookieAcceptanceSnackBarComponent.component: constructor: this.cookieService.check("cookieAcceptance") ',this.cookieService.check('cookieAcceptance'));
      if(this.cookieService.check('cookieAcceptance')) {
        console.log('cookieAcceptanceSnackBarComponent.component: constructor: this.cookieService.get("cookieAcceptance") ',this.cookieService.get('cookieAcceptance'));
      }
    }

    const cookieAcceptance = this.cookieService.check('cookieAcceptance') ? parseInt(this.cookieService.get('cookieAcceptance')) : null;

    if(this.debug) {
      console.log('cookieAcceptanceSnackBarComponent.component: constructor: cookieAcceptance 1 ',cookieAcceptance);
    }

    if(cookieAcceptance !== null && cookieAcceptance === 0) {
      if(this.debug) {
        console.log('cookieAcceptanceSnackBarComponent.component: constructor: cookieAcceptance 2 ',cookieAcceptance);
      }
      this.httpService.openCookieAcceptanceSnackBar.first().subscribe( (data) => {
        if(this.debug) {
          console.log('cookieAcceptanceSnackBarComponent.component: constructor: cookieAcceptance 3 ',cookieAcceptance);
        }
        this.openSnackBar();
      });
    }

  }

  ngOnInit() {

    if(environment.debugComponentLoadingOrder) {
      console.log('cookieAcceptanceSnackBarComponent.component init');
    }

  }

  createForm(): void {
    this.cookieAcceptanceForm = new FormGroup({
      cookieAcceptance: this.cookieAcceptance
    });
    if(this.debug) {
      console.log('cookieAcceptanceSnackBarComponent.component: createForm: this.cookieAcceptanceForm ',this.cookieAcceptanceForm);
    }
  }

  createFormControls(): void {
    this.cookieAcceptance = new FormControl();
  }

  monitorFormValueChanges(): void {
    if(this.cookieAcceptanceForm) {
      this.cookieAcceptance.valueChanges
      .pipe(
        debounceTime(400),
        distinctUntilChanged()
      )
      .subscribe(cookieAcceptance => {
        if(this.debug) {
          console.log('cookieAcceptanceSnackBarComponent.component: monitorFormValueChanges: cookieAcceptance: ',cookieAcceptance);
        }
        this.formData['cookieAcceptance'] = cookieAcceptance ? 1 : 0;
        if(this.formData['cookieAcceptance'] === 1) {
          this.cookieAcceptanceSubscription = this.httpService.addCookieAcceptance().do(this.cookieAcceptanceData).subscribe();
          this.dismissSnackbar(null);
        }
      });;
    }
  }

  private cookieAcceptanceData = (data) => {
    if(this.debug) {
      console.log('cookieAcceptanceSnackBarComponent.component: cookieAcceptanceData: data',data);
    }
    if(data) {
      if('error' in data && data['error'] === '') {
      }
    }
    const cookieAcceptance = this.cookieService.check('cookieAcceptance') ? parseInt(this.cookieService.get('cookieAcceptance')) : null;
    if(cookieAcceptance === null || (cookieAcceptance !== null && cookieAcceptance === 0)) {
      const expired = new Date();
      expired.setDate(expired.getDate() + 365);
      this.cookieService.set('cookieAcceptance', '1', expired);
      if(this.debug) {
        console.log('cookieAcceptanceSnackBarComponent.component: expired',expired);
        console.log('cookieAcceptanceSnackBarComponent.component: this.cookieService.get("cookieAcceptance")',this.cookieService.get('cookieAcceptance'));
      }
    }
    if(this.debug) {
      console.log('cookieAcceptanceSnackBarComponent.component: this.cookieService.get("cookieAcceptance")',this.cookieService.get('cookieAcceptance'));
    }
  }

  openSnackBar(): void {
    const config = new MatSnackBarConfig();
    config.panelClass = ['custom-class'];
    config.duration = 100000;
    this.matSnackBar.openFromTemplate(this.snackBarTemplate,config);
    if(this.debug) {
      console.log('cookieAcceptanceSnackBarComponent.component: openSnackBar');
    }
  }

  dismissSnackbar(event: any): void {
    this.matSnackBar.dismiss();
    if(this.debug) {
      console.log('cookieAcceptanceSnackBarComponent.component: dismissSnackbar: event ',event);
    }
    if(event) {
      event.stopPropagation();
    }
  }

  openCookiePolicyDialog(): void {
    const dialogRef = this.dialog.open(CookiePolicyComponent, {
      width: this.isMobile ? '100%' :'50%',
      height: this.isMobile ? '100%' :'90%',
      maxWidth: 740,
      id: 'cookie-policy-dialog'
    });
    updateCdkOverlayThemeClass(this.themeRemove,this.themeAdd);
    dialogRef.beforeClose().subscribe(result => {
      if(this.debug) {
        console.log('cookieAcceptanceSnackBarComponent.component: dialog cookie policy: before close');
      }
      if(result) {
        if(this.debug) {
          console.log('cookieAcceptanceSnackBarComponent.component: dialog cookie policy: before close: result: ', result);
        }
      }
    });
    dialogRef.afterOpen().subscribe( () => {
      if(this.debug) {
        console.log('cookieAcceptanceSnackBarComponent.component: dialog cookie policy: after open');
      }
      if(this.isMobile) {
        const parent = document.querySelector('#cookie-policy-dialog');
        let height = parent.clientHeight ? parent.clientHeight : 0;
        const offsetHeight = 150;
        if(!isNaN(height) && (height - offsetHeight) > 0) {
          height = height - offsetHeight;
        }
        if(height > 0 ) {
          this.dialogcookiePolicyHeight = height;
          this.httpService.cookiePolicyDialogOpened.next(this.dialogcookiePolicyHeight);
        }
        if(this.debug) {
          console.log('cookieAcceptanceSnackBarComponent.component: dialog: this.dialogcookiePolicyHeight: ', this.dialogcookiePolicyHeight);
        }
      }

    });
  }

  ngOnDestroy() {

    if (this.cookieAcceptanceSubscription) {
      this.cookieAcceptanceSubscription.unsubscribe();
    }

  }

}
