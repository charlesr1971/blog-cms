import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { CookieAcceptanceSnackBarComponent } from './cookie-acceptance-snack-bar.component';

describe('CookieAcceptanceSnackBarComponent', () => {
  let component: CookieAcceptanceSnackBarComponent;
  let fixture: ComponentFixture<CookieAcceptanceSnackBarComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ CookieAcceptanceSnackBarComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(CookieAcceptanceSnackBarComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
