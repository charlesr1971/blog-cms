import { Directive, AfterViewInit, OnInit, Input, ElementRef, Renderer2, Inject } from '@angular/core';
import { DOCUMENT } from '@angular/common';

@Directive({
  selector: '[appCustomRecaptcha]'
})
export class CustomRecaptchaDirective implements OnInit, AfterViewInit {

  constructor(@Inject(DOCUMENT) private documentBody: Document,
  private el: ElementRef,
  private renderer: Renderer2,) { }

  ngOnInit() {

  }

  ngAfterViewInit() {

    const div = this.renderer.createElement('div');
    const span = this.renderer.createElement('span');
    this.renderer.setAttribute(span,'id','app-custom-recaptcha-text');
    const text = this.renderer.createText(this.getRandomStr());
    this.renderer.setAttribute(div,'class','app-custom-recaptcha');
    this.renderer.setAttribute(div,'id','app-custom-recaptcha');

    this.renderer.appendChild(span,text);
    this.renderer.appendChild(div,span);

    this.renderer.appendChild(this.el.nativeElement,div);

  }

  getRandomInt(min: number = 1000000, max: number = 9999999): number {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min)) + min;
  }

  getRandomStr(length: number = 4): string {
    const chars = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',1,2,3,4,5,6,7,8,9,0];
    let str = '';
    for(var i = 0; i < length; i++) {
      str += chars[this.getRandomInt(0,(chars.length-1))];
    }
    return str;
  }

}
