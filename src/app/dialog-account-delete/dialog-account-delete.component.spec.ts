import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { DialogAccountDeleteComponent } from './dialog-account-delete.component';

describe('DialogAccountDeleteComponent', () => {
  let component: DialogAccountDeleteComponent;
  let fixture: ComponentFixture<DialogAccountDeleteComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ DialogAccountDeleteComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(DialogAccountDeleteComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
