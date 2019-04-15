import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { FormatEmailRendererComponent } from './format-email-renderer.component';

describe('FormatEmailRendererComponent', () => {
  let component: FormatEmailRendererComponent;
  let fixture: ComponentFixture<FormatEmailRendererComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ FormatEmailRendererComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(FormatEmailRendererComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
