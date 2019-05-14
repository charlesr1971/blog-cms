import { Component, OnInit, OnDestroy, Input, Inject, ElementRef, Renderer2 } from '@angular/core';
import { Subscription } from 'rxjs';
import { DeviceDetectorService } from 'ngx-device-detector';
import { Router } from '@angular/router';
import { DOCUMENT } from '@angular/common';
import { SeoTitleFormatPipe } from '../pipes/seo-title-format/seo-title-format.pipe';

import { HttpService } from '../services/http/http.service';

import { environment } from '../../environments/environment';

import { Image } from '../image/image.model';

@Component({
  selector: 'app-image-related-content',
  templateUrl: './image-related-content.component.html',
  styleUrls: ['./image-related-content.component.css'],
  providers: [
    SeoTitleFormatPipe
  ],
})
export class ImageRelatedContentComponent implements OnInit, OnDestroy {

  @Input() image: Image;
  @Input() currentImageId: string;
  @Input() currentFileId: string;

  isMobile: boolean = false;
  images: Array<any> = [];

  imageRelatedContentSubscription: Subscription;
  catalogRouterAliasLower: string = environment.catalogRouterAlias;
  uploadRouterAliasLower: string = environment.uploadRouterAlias;
  categoryImagesUrl: string = '';

  debug: boolean = false;

  constructor(@Inject(DOCUMENT) private documentBody: Document,
    private httpService: HttpService,
    private deviceDetectorService: DeviceDetectorService,
    private router: Router,
    private renderer: Renderer2,
    public el: ElementRef,
    private seoTitleFormatPipe: SeoTitleFormatPipe,) { 

    if(environment.debugComponentLoadingOrder) {
      console.log('images.component loaded');
    }

    this.isMobile = this.deviceDetectorService.isMobile();

    this.categoryImagesUrl = this.httpService.categoryImagesUrl;

  }

  ngOnInit() {

    if(this.image && 'id' in this.image) {
      this.imageRelatedContentSubscription = this.httpService.fetchImageRelatedContent(this.image['id'],100).do(this.processRelatedContentData).subscribe();
    }

  }

  private processRelatedContentData = (data) => {
    if(data && Array.isArray(data) && data.length > 0) {
      if(this.debug) {
        console.log('imageRelatedContentComponent.component: processRelatedContentData: data',data);
      }
      data.map( (item: any) => {
        const image = new Image({
          id: item['fileUuid'],
          fileid: item['fileid'],
          userid: item['userid'],
          category: item['category'],
          src: this.categoryImagesUrl + '/' + item['src'],
          author: item['author'],
          title: item['title'],
          description: item['description'],
          article: item['article'],
          size: item['size'],
          likes: item['likes'],
          tags: item['tags'],
          publishArticleDate: item['publishArticleDate'],
          approved: item['approved'],
          createdAt: item['createdAt'],
          avatarSrc: item['avatarSrc']
        });
        this.images.push(image);
      });
      this.sortImages();
      setTimeout( () => {
        if(this.isMobile) {
          const imagerelatedcontentlist = this.documentBody.querySelector('#image-related-content-list');
          if(this.debug) {
            console.log('imageRelatedContentComponent.component: processRelatedContentData: imagerelatedcontentlist: ', imagerelatedcontentlist);
          }
          if(imagerelatedcontentlist && this.images.length) {
            let width = this.images.length * 75;
            if(this.debug) {
              console.log('imageRelatedContentComponent.component: processRelatedContentData: width: ', width);
            }
            if(this.debug) {
              console.log('imageRelatedContentComponent.component: processRelatedContentData: window.innerWidth: ', window.innerWidth);
            }
            if(width > window.innerWidth) {
              this.renderer.setStyle(imagerelatedcontentlist,'width',width + 'px');
              const imagerelatedcontentlistitemimageimg = this.documentBody.querySelector('#image-related-content-list-item-image-img-' + this.currentFileId);
              if(imagerelatedcontentlistitemimageimg) {
                imagerelatedcontentlistitemimageimg.scrollIntoView();
              }
            }
          }
        }
      });
      if(this.debug) {
        console.log('imageRelatedContentComponent.component: processRelatedContentData: this.images: ', this.images);
      }
    }
  }

  sortImages(): void {
    this.images.sort(function(a, b) {
      const dateA: any = new Date(a.createdAt), dateB: any = new Date(b.createdAt);
      return dateB - dateA;
    });
  }

  navigateToArticle(event: any, fileid: number, title: string): void {
    if(this.debug) {
      console.log('imageRelatedContentComponent.component: navigateToArticle: fileid: ', fileid);
      console.log('imageRelatedContentComponent.component: navigateToArticle: title: ', title);
    }
    this.router.navigateByUrl('/' + this.uploadRouterAliasLower, {skipLocationChange: true}).then(()=>
          this.router.navigate([this.catalogRouterAliasLower,fileid,this.seoTitleFormatPipe.transform(title)]));
  }

  ngOnDestroy() {

    if (this.imageRelatedContentSubscription) {
      this.imageRelatedContentSubscription.unsubscribe();
    }

  }

}
