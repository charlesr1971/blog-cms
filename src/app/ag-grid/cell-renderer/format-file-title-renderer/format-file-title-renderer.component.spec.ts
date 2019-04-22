import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { FormatFileTitleRendererComponent } from './format-file-title-renderer.component';

describe('FormatFileTitleRendererComponent', () => {
  let component: FormatFileTitleRendererComponent;
  let fixture: ComponentFixture<FormatFileTitleRendererComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ FormatFileTitleRendererComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(FormatFileTitleRendererComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
