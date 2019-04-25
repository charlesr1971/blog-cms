import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { WebsiteHelpComponent } from './website-help.component';

describe('WebsiteHelpComponent', () => {
  let component: WebsiteHelpComponent;
  let fixture: ComponentFixture<WebsiteHelpComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ WebsiteHelpComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(WebsiteHelpComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
