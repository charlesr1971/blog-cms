import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { CustomEditHeaderComponent } from './custom-edit-header.component';

describe('CustomEditHeaderComponent', () => {
  let component: CustomEditHeaderComponent;
  let fixture: ComponentFixture<CustomEditHeaderComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ CustomEditHeaderComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(CustomEditHeaderComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
