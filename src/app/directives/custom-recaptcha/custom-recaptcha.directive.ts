import { Directive, AfterViewInit, OnInit, Input, ElementRef, Renderer2, Inject } from '@angular/core';
import { DOCUMENT } from '@angular/common';

declare var TweenMax: any, Elastic: any, Linear: any;

@Directive({
  selector: '[appCustomRecaptcha]'
})
export class CustomRecaptchaDirective implements OnInit, AfterViewInit {

  @Input() appCustomRecaptchaRotationMax: number = 0;
  @Input() appCustomRecaptchaStrLength: number = 4;

  customRecaptchaMaxStrLength: number = 8;
  customRecaptchaMinStrLength: number = 3;

  constructor(@Inject(DOCUMENT) private documentBody: Document,
    private el: ElementRef,
    private renderer: Renderer2) { 

  }

  ngOnInit() {


  }

  ngAfterViewInit() {

    this.appCustomRecaptchaStrLength = this.appCustomRecaptchaStrLength > this.customRecaptchaMaxStrLength ? this.customRecaptchaMaxStrLength : this.appCustomRecaptchaStrLength;
    this.appCustomRecaptchaStrLength = this.appCustomRecaptchaStrLength < this.customRecaptchaMinStrLength ? this.customRecaptchaMinStrLength : this.appCustomRecaptchaStrLength;

    this.buildCustomCaptcha();
    
  }

  private buildCustomCaptcha(): void {

    const appcustomrecaptcha1 = this.documentBody.getElementById('app-custom-recaptcha-1');
    const appcustomrecaptcha2 = this.documentBody.getElementById('app-custom-recaptcha-2');

    if(appcustomrecaptcha1) {
      appcustomrecaptcha1.remove();
    }

    if(appcustomrecaptcha2) {
      appcustomrecaptcha2.remove();
    }

    const captcha = this.getRandomStr();

    const div1 = this.renderer.createElement('div');
    const span1 = this.renderer.createElement('span');
    this.renderer.setAttribute(span1,'id','app-custom-recaptcha-text-1');
    const text1 = this.renderer.createText(window.btoa(captcha));
    this.renderer.setAttribute(div1,'class','app-custom-recaptcha-1');
    this.renderer.setAttribute(div1,'id','app-custom-recaptcha-1');
    this.renderer.appendChild(span1,text1);
    this.renderer.appendChild(div1,span1);
    const div2 = this.renderer.createElement('div');
    this.renderer.setAttribute(div2,'class','app-custom-recaptcha-2');
    this.renderer.setAttribute(div2,'id','app-custom-recaptcha-2');

    const captchaArray = captcha.split('');
    if(captchaArray.length > 0) {
      for(var i = 0; i < captchaArray.length; i++) {
        const span2 = this.renderer.createElement('span');
        if(this.appCustomRecaptchaRotationMax > 0) {
          this.renderer.setStyle(span2,'transform','rotate(' + this.getRandomInt(0,this.appCustomRecaptchaRotationMax)  + 'deg)');
        }
        const text2 = this.renderer.createText(captchaArray[i]);
        this.renderer.appendChild(span2,text2);
        this.renderer.appendChild(div2,span2);
      }
    }
    this.renderer.appendChild(this.el.nativeElement,div1);
    this.renderer.appendChild(this.el.nativeElement,div2);

    TweenMax.staggerFromTo('.app-custom-recaptcha-2 span', 1, {scale: 0, opacity:0, ease:Elastic.easeOut, delay: 0}, {scale: 1, opacity:1, ease:Elastic.easeOut, delay: 0}, 0.25);

  }

  private getRandomInt(min: number = 1000000, max: number = 9999999): number {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min)) + min;
  }

  private getRandomStr(length: number = this.appCustomRecaptchaStrLength): string {
    const chars = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',1,2,3,4,5,6,7,8,9,0];
    let str = '';
    for(var i = 0; i < length; i++) {
      str += chars[this.getRandomInt(0,(chars.length-1))];
    }
    return str;
  }

  public resetCustomCaptcha(): void {

    this.buildCustomCaptcha();

  }

}
