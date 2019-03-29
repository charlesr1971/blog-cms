import { Directive, ElementRef, Input, HostListener, Renderer2, AfterViewInit } from '@angular/core';

import { environment } from '../../../environments/environment';

declare var TweenMax: any, Elastic: any;

@Directive({
  selector: '[appCharCount]'
})
export class CharCountDirective implements AfterViewInit {

  @Input() appCharCountDisplayId;

  debug: boolean = false;

  constructor(private el: ElementRef,
    private renderer: Renderer2) { 

  }

  ngAfterViewInit() {
    const el = document.getElementById(this.appCharCountDisplayId);
    if(el) {
      el.innerHTML = environment.maxCommentInputLength.toString();
    }
  }

  @HostListener('keyup', ['$event']) onkeyup(event) {
    const overshoot=5;
    const period=0.25;
    const length = this.el.nativeElement.value.length;
    const total = environment.maxCommentInputLength - length;
    if(this.debug) {
      console.log('charCountDirective.directive: total: ', total);
    }  
    if(this.debug) {
      console.log('charCountDirective.directive: this.appCharCountDisplayId: ', this.appCharCountDisplayId);
    }
    if(this.appCharCountDisplayId) {
      const el = document.getElementById(this.appCharCountDisplayId);
      if(this.debug) {
        console.log('charCountDirective.directive: el: ', el);
      }
      if(el) {
        if(total >= 0) {
          el.innerHTML = total.toString();
        }
        if(total < 20) {
          this.renderer.addClass(el,'char-counter-warn');
        }
        else{
          this.renderer.removeClass(el,'char-counter-warn')
        }
        if(total === 0) {
          TweenMax.to(el,0.5,{
            scale:0.25,
            onComplete:function(){
              TweenMax.to(el,1.4,{
                scale:1,
                ease:Elastic.easeOut,
                easeParams:[overshoot,period]
              })
            }
          });
        }
      }
    }
  }
  

}
