import { Directive, ElementRef, Output, Input, HostListener, Renderer2, AfterViewInit, Inject, EventEmitter } from '@angular/core';
import { DOCUMENT } from '@angular/common';

import { environment } from '../../../environments/environment';

@Directive({
  selector: '[elementsOverlap]'
})

export class ElementsOverlapDirective {

  @Output() isOverlapping: EventEmitter<any> = new EventEmitter();
  @Input()
  elementOverlapperId;

  _isOverlapping:boolean = false;

  debug: boolean = false;

  constructor(@Inject(DOCUMENT) private documentBody: Document,
    private el: ElementRef,
    private renderer: Renderer2) { 

    }


  ngAfterViewInit() {
    setTimeout(() => {
      this.emitValue();
    });
  }

  @HostListener('window:resize', ['$event'])
  onResize(event) {
    this.emitValue();
  }

  private emitValue(): void {
    if(this.debug) {
      console.log('elementsOverlapDirective.directive: this.elementOverlapperId: ', this.elementOverlapperId);
    }
    const el: HTMLElement = this.documentBody.querySelector('#' + this.elementOverlapperId);
    if(this.debug) {
      console.log('elementsOverlapDirective.directive: this.el.nativeElement: ', this.el.nativeElement,' el: ', el);
    }
    if(el && this.el.nativeElement){
      this._isOverlapping = this.overlaps(this.el.nativeElement,el);
      this.isOverlapping.emit(this._isOverlapping);
      if(this.debug) {
        console.log('elementsOverlapDirective.directive: this._isOverlapping: ', this._isOverlapping);
      }
    }
  }

  private overlaps(e1: HTMLElement, e2: HTMLElement): boolean {
    const element1: HTMLElement| null = e1;
    const element2: HTMLElement| null = e2;
    const rect1 = element1.getBoundingClientRect();
    const rect2 = element2.getBoundingClientRect();
    if(this.debug) {
      console.log('elementsOverlapDirective.directive: rect1: ', rect1,' rect2: ', rect2 );
    }
    let overlap = false;
    if( rect1 && rect2 && rect2.width > 0 && rect2.height > 0 ){
      overlap = !(
          rect1.right < rect2.left || 
          rect1.left > rect2.right || 
          rect1.bottom < rect2.top || 
          rect1.top > rect2.bottom
        )
        return overlap;
    } 
    return overlap;
  }

}
