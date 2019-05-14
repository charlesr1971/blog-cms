import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { ImageRelatedContentComponent } from './image-related-content.component';

describe('ImageRelatedContentComponent', () => {
  let component: ImageRelatedContentComponent;
  let fixture: ComponentFixture<ImageRelatedContentComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ ImageRelatedContentComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(ImageRelatedContentComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
