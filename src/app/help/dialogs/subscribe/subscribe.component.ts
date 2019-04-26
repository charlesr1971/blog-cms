import { Component, OnInit, OnDestroy, Inject, ViewChild, ElementRef, Renderer2, HostListener } from '@angular/core';
import { FormGroup, FormControl, Validators } from '@angular/forms';
import { debounceTime, distinctUntilChanged } from 'rxjs/operators';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material';
import { MatSnackBar, MatSnackBarConfig } from '@angular/material';
import { DOCUMENT } from '@angular/common';
import { DeviceDetectorService } from 'ngx-device-detector';

import { HttpService } from '../../../services/http/http.service';

import { environment } from '../../../../environments/environment';
import { Subscription } from 'rxjs';

declare var TweenMax: any, TweenLite: any, Linear: any, Elastic: any;

@Component({
  selector: 'app-subscribe',
  templateUrl: './subscribe.component.html',
  styleUrls: ['./subscribe.component.css']
})
export class SubscribeComponent implements OnInit, OnDestroy {

  @ViewChild('dialogSubscribeNotificationText') dialogSubscribeNotificationText: ElementRef;

  subscribeForm: FormGroup;
  formData = {};

  email: FormControl;
  forename: FormControl;
  
  subscribeSubscription: Subscription;
  subscribeFormDisabled: boolean = true;

  isMobile: boolean = false;
  disableSubscribeTooltip: boolean = false;

  

  debug: boolean = false;

  constructor(@Inject(DOCUMENT) private documentBody: Document,
    private dialogRef: MatDialogRef<SubscribeComponent>,
    @Inject(MAT_DIALOG_DATA) data,
    public matSnackBar: MatSnackBar,
    private httpService: HttpService,
    private renderer: Renderer2,
    private deviceDetectorService: DeviceDetectorService) { 

      if(environment.debugComponentLoadingOrder) {
        console.log('SubscribeComponent.component loaded');
      }

      this.isMobile = this.deviceDetectorService.isMobile();

      if(this.isMobile) {
        this.disableSubscribeTooltip = true;
      }


    }

  ngOnInit() {

    if(environment.debugComponentLoadingOrder) {
      console.log('subscribeComponent.component init');
    }

    setTimeout( () => {

      this.httpService.subscribeDialogOpened.subscribe( (height: number) => {
        if(this.debug) {
          console.log('subscribeComponent.component: ngOnInit: height: ', height);
        }
        this.renderer.setStyle(this.dialogSubscribeNotificationText.nativeElement,'height',height + 'px');
        const parent = document.querySelector('#dialog-subscribe-notification-container');
        if(parent) {
          TweenMax.fromTo(parent, 1, {ease:Elastic.easeOut, opacity: 0}, {ease:Elastic.easeOut, opacity: 1});
        }
      });

      

    });

    this.createFormControls();
    this.createForm();
    this.monitorFormValueChanges();

  }

  @HostListener('mousedown', ['$event'])
  onMouseDown(event: MouseEvent) {
    this.disableSubscribeTooltip = true;
    if(this.debug) {
      console.log('subscribeComponent.component: mousedown: this.disableSubscribeTooltip: ',this.disableSubscribeTooltip);
    }
  }

  @HostListener('mouseup', ['$event'])
  onMouseUp(event: MouseEvent) {
    this.disableSubscribeTooltip = false;
    if(this.debug) {
      console.log('subscribeComponent.component: mouseup: this.disableSubscribeTooltip: ',this.disableSubscribeTooltip);
    }
  }

  subscribeFormSubmit(): void {
    const body = {
      email: this.email.value,
      firstname: this.forename.value
    };
    if(this.debug) {
      console.log('subscribeComponent.component: subscribeFormSubmit: body',body);
    }
    this.subscribeSubscription = this.httpService.addSubscription(body).do(this.processSubscribeData).subscribe();
  }

  private processSubscribeData = (data) => {
    if(this.debug) {
      console.log('subscribeComponent.component: processSubscribeData: data',data);
    }
    if(data) {
      if('error' in data && data['error'] === '') {
        const overshoot=5;
        const period=0.25;
        this.subscribeForm = null;
        this.createFormControls();
        this.createForm();
        this.monitorFormValueChanges();
        this.subscribeForm.reset();
        this.openSnackBar('Subscription successful', 'Success');
        /* const target = Array.prototype.slice.call(this.documentBody.querySelectorAll('.dialog-subscribe-notification-success'));
        if(Array.isArray(target) && target.length > 0 && !this.isMobile) { */
        const target = this.documentBody.getElementById('dialog-subscribe-notification-success');
        if(target && !this.isMobile) {
          /* TweenMax.to(el,0.5,{
            scale:0.25,
            opacity:1,
            onComplete:function(){
              TweenMax.to(el,1.4,{
                scale:1,
                ease:Elastic.easeOut,
                easeParams:[overshoot,period]
              })
            }
          }); */
          /* TweenMax.staggerFromTo('.dialog-subscribe-notification-success', 0.5, {scale: 0, opacity:0, ease:Elastic.easeOut, delay: 0}, {scale: 1, opacity:1, ease:Elastic.easeOut, delay: 0}, 0.25); */
          TweenLite.to(target, 1.25, {text:"Thank You<br>For<br>Joining!", padSpace:true, ease:Linear.easeNone});
        }
      }
      else{
        this.openSnackBar(data['error'], 'Error');
      }
    }
  }

  createForm(): void {
    this.subscribeForm = new FormGroup({
      email: this.email,
      forename: this.forename
    });
  }

  createFormControls(): void {
    const emailPattern = "^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]+$";
    this.email = new FormControl('', [
      Validators.required,
      Validators.pattern(emailPattern),
      Validators.minLength(1)
    ]);
    this.forename = new FormControl('', [
      Validators.required,
      Validators.minLength(1)
    ]);
  }

  monitorFormValueChanges(): void {
    if(this.subscribeForm) {
      this.email.valueChanges
      .pipe(
        debounceTime(400),
        distinctUntilChanged()
      )
      .subscribe(email => {
        if(this.debug) {
          console.log('subscribeComponent.component: monitorFormValueChanges: email: ',email);
        }
        this.formData['email'] = email;
        this.subscribeFormDisabledState();
      });
      this.forename.valueChanges
      .pipe(
        debounceTime(400),
        distinctUntilChanged()
      )
      .subscribe(forename => {
        if(this.debug) {
          console.log('subscribeComponent.component: monitorFormValueChanges: forename: ',forename);
        }
        this.formData['forename'] = forename;
        this.subscribeFormDisabledState();
      });
    }
  }

  subscribeFormDisabledState(): void {
    if(this.debug) {
      console.log('subscribeComponent.component: subscribeFormDisabledState: this.subscribeForm.invalid: ',this.subscribeForm.invalid);
    }
    this.subscribeFormDisabled = !this.subscribeForm.invalid ? false : true;
  }

  closeSubscribeNotificationDialog() {
    this.dialogRef.close();
  }

  openSnackBar(message: string, action: string) {
    const config = new MatSnackBarConfig();
    config.panelClass = action.toLowerCase() === 'error' ? ['custom-class-error'] : ['custom-class'];
    config.duration = 5000;
    this.matSnackBar.open(message, action, config);
  }

  ngOnDestroy() {

    if (this.subscribeSubscription) {
      this.subscribeSubscription.unsubscribe();
    }

  }

}
