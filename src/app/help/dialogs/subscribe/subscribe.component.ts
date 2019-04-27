import { Component, OnInit, AfterViewInit, OnDestroy, Inject, ViewChild, ElementRef, Renderer2, HostListener } from '@angular/core';
import { FormGroup, FormControl, Validators } from '@angular/forms';
import { debounceTime, distinctUntilChanged } from 'rxjs/operators';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material';
import { MatSnackBar, MatSnackBarConfig } from '@angular/material';
import { DOCUMENT } from '@angular/common';
import { DeviceDetectorService } from 'ngx-device-detector';

import { HttpService } from '../../../services/http/http.service';

import { environment } from '../../../../environments/environment';
import { Subscription } from 'rxjs';

declare var TweenMax: any, TimelineMax: any, CustomWiggle: any, Elastic: any;

@Component({
  selector: 'app-subscribe',
  templateUrl: './subscribe.component.html',
  styleUrls: ['./subscribe.component.css']
})
export class SubscribeComponent implements OnInit, AfterViewInit, OnDestroy {

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

  ngAfterViewInit() {
    
  }

  playSound(): void  {
    const audio = <HTMLAudioElement>this.documentBody.getElementById('dialogSubscribeNotificationSound');
    if(audio) {
      if(this.debug) {
        console.log('subscribeComponent.component: playSound: audio: ',audio);
      }
      audio.volume = 1;
      audio.play();
    }
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
      console.log('subscribeComponent.component: processSubscribeData: data ',data);
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
        const subscribeAnimationContainer = this.documentBody.getElementById('subscribe-animation-container');
        const bubbleWrapArray = Array.prototype.slice.call(this.documentBody.querySelectorAll('.bubble-wrap'));
        if(subscribeAnimationContainer && Array.isArray(bubbleWrapArray) && bubbleWrapArray.length === 0) {
          let subscribeAnimationContainerHeight = 0;
          if(this.isMobile){
            const screenHeight = window.innerHeight;
            const offset = 402;
            if(!isNaN(screenHeight) && screenHeight > offset) {
              subscribeAnimationContainerHeight = screenHeight - offset;
              subscribeAnimationContainer.style.height = subscribeAnimationContainerHeight + 'px';
            }
          }
          const subscribeAnimationContainerRect = subscribeAnimationContainer.getBoundingClientRect();
          const subscribeAnimationContainerWidth = subscribeAnimationContainerRect.width;
          if(!this.isMobile){
            subscribeAnimationContainerHeight = subscribeAnimationContainerRect.height;
          }
          if(this.debug) {
            console.log('subscribeComponent.component: processSubscribeData: subscribeAnimationContainerWidth: ',subscribeAnimationContainerWidth);
            console.log('subscribeComponent.component: processSubscribeData: subscribeAnimationContainerHeight: ',subscribeAnimationContainerHeight);
          }
          const executeAnimation = (this.isMobile && subscribeAnimationContainerHeight >= 215) || !this.isMobile ? true : false;
          if(executeAnimation) {
            const bubbleWrap = this.renderer.createElement('div');
            this.renderer.setAttribute(bubbleWrap,'class','bubble-wrap');
            this.renderer.setStyle(bubbleWrap,'width',subscribeAnimationContainerWidth + 'px');
            this.renderer.setStyle(bubbleWrap,'height',subscribeAnimationContainerHeight + 'px');
            for (let index = 0; index < 100; index++) {
              const bubble = this.renderer.createElement('div');
              this.renderer.setAttribute(bubble,'class','bubble');
              bubbleWrap.appendChild(bubble);
            }
            subscribeAnimationContainer.appendChild(bubbleWrap);
            const bubbleRing = this.renderer.createElement('div');
            this.renderer.setAttribute(bubbleRing,'class','bubble-ring');
            subscribeAnimationContainer.appendChild(bubbleRing);
            const bubbleBell = this.renderer.createElement('i');
            this.renderer.setAttribute(bubbleBell,'class','fa fa-bell bubble-bell');
            subscribeAnimationContainer.appendChild(bubbleBell);
            if(this.debug) {
              console.log('subscribeComponent.component: processSubscribeData: this.httpService.isSafari1: ',this.httpService.isSafari1);
              console.log('subscribeComponent.component: processSubscribeData: this.httpService.isSafari2: ',this.httpService.isSafari2);
            }
            var that = this;
            setTimeout( () => {
              const bubbleRingArray = Array.prototype.slice.call(this.documentBody.querySelectorAll('.bubble-ring'));
              const bubbleBellArray = Array.prototype.slice.call(this.documentBody.querySelectorAll('.bubble-bell'));
              this.removeBubbles();
              if(Array.isArray(bubbleRingArray) && bubbleRingArray.length > 0) {
                bubbleRingArray.map( (element) => {
                  TweenMax.fromTo(element, 1, {scale:0, ease:Elastic.easeOut, opacity: 0, delay: 1}, {scale:1, ease:Elastic.easeOut, opacity: 1, delay: 1}, 0.25);
                });
              }
              if(Array.isArray(bubbleBellArray) && bubbleBellArray.length > 0) {
                bubbleBellArray.map( (element) => {
                  setTimeout( () => {
                    this.playSound();
                  },1000);
                  TweenMax.fromTo(element, 1, {scale:0, ease:Elastic.easeOut, opacity: 0, delay: 1.5}, {scale:1, ease:Elastic.easeOut, opacity: 1, delay: 1.5, onComplete: function(){
                    
                  }}, 0.25);
                });
              }
            })
          }
        }
      }
      else{
        this.openSnackBar(data['error'], 'Error');
      }
    }
  }

  removeBubbles(): void {
    const bubbleArray = Array.prototype.slice.call(this.documentBody.querySelectorAll('.bubble'));
    if(Array.isArray(bubbleArray) && bubbleArray.length > 0) {
      setTimeout( () => {
        bubbleArray[0].remove();
        this.removeBubbles();
      });
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
    const bubbleWrapArray = Array.prototype.slice.call(this.documentBody.querySelectorAll('.bubble-wrap'));
    if(Array.isArray(bubbleWrapArray) && bubbleWrapArray.length > 0) {
      bubbleWrapArray.map( (element) => {
        element.remove();
      });
    }
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
