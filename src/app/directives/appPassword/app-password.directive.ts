import { Directive, ElementRef} from '@angular/core';

@Directive({
  selector: '[appPassword]'
})
export class AppPasswordDirective {

 private _shown = false;

  constructor(private el: ElementRef) {
    setTimeout( () => {
      this.setup();
    });
  }

  toggle(icon: HTMLElement): void {
    this._shown = !this._shown;
    if(icon) {
      if (this._shown) {
        this.el.nativeElement.setAttribute('type', 'text');
        icon.innerHTML = 'visibility_off';
      } else {
        this.el.nativeElement.setAttribute('type', 'password');
        icon.innerHTML = 'visibility';
      }
    }
  }

  setup(): void {
    const icon = document.getElementById('app-password');
    if(icon) {
      icon.addEventListener('click', (event) => {
        this.toggle(icon);
      });
    }
  }

}
