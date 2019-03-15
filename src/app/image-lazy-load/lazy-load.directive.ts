import { AfterViewInit, Directive, ElementRef, HostBinding, Input } from '@angular/core';

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
    if(this.debug) {
      console.log('loadImage: this.srcAttr', this.srcAttr);
    }
  }

}
