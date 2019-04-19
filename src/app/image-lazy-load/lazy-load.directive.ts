import { AfterViewInit, Directive, ElementRef, HostBinding, Input } from '@angular/core';

declare var TweenMax: any, Elastic: any, Linear: any;

@Directive({
  selector: 'img[appLazyLoad]'
})
export class LazyLoadDirective implements AfterViewInit {
  
  @HostBinding('attr.src') srcAttr = null;
  @Input() src: string;

  debug: boolean = false;

  constructor(private el: ElementRef) {}

  ngAfterViewInit(): void {
    this.canLazyLoad() ? this.lazyLoadImage() : this.loadImage();
  }

  private canLazyLoad(): any {
    return window && 'IntersectionObserver' in window;
  }

  private lazyLoadImage(): void {
    const obs = new IntersectionObserver(entries => {
      entries.forEach(({ isIntersecting }) => {
        if (isIntersecting) {
          this.loadImage();
          obs.unobserve(this.el.nativeElement);
        }
      });
    });
    obs.observe(this.el.nativeElement);
  }

  private loadImage(): void {
    this.srcAttr = this.src;
    TweenMax.fromTo(this.el.nativeElement, 1.5, {ease:Linear.easeNone, opacity: 0}, {ease:Linear.easeNone, opacity: 1});
    if(this.debug) {
      console.log('loadImage: this.srcAttr', this.srcAttr);
    }
  }

}
