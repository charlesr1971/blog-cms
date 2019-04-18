import { Component, OnDestroy, AfterViewInit, EventEmitter, Input, Output, Renderer2, Inject } from '@angular/core';
import { DOCUMENT } from '@angular/common'; 
import { HttpClient, HttpRequest, HttpEventType, HttpResponse, HttpHeaders } from '@angular/common/http';
import { Subscription } from 'rxjs';
import { uriParse } from '../util/uriParse';
import { arrayInclude, arrayExclude } from '../util/arrayUtils';
import { getUriMatches } from '../util/regexUtils';

import { HttpService } from '../services/http/http.service';
import { CookieService } from 'ngx-cookie-service';

import { environment } from '../../environments/environment';

import 'tinymce/plugins/link';
import 'tinymce/plugins/paste';
import 'tinymce/plugins/table';
import 'tinymce/plugins/charmap';
import 'tinymce/plugins/searchreplace';
import 'tinymce/plugins/lists';
import 'tinymce/plugins/advlist';
import 'tinymce/plugins/textcolor';
import 'tinymce/plugins/colorpicker';
import 'tinymce/plugins/codesample';
import 'tinymce/plugins/image';
import 'tinymce/plugins/code';
import 'tinymce/plugins/contextmenu';
import 'tinymce/plugins/divider';
import 'tinymce/plugins/wordcount';
import 'tinymce/plugins/autolink';
import 'tinymce/plugins/autosave';
import { ParseSourceFile } from '@angular/compiler';

declare var tinymce: any;

@Component({
  selector: 'app-tinymce',
  templateUrl: './tinymce.component.html',
  styleUrls: ['./tinymce.component.css']
})
export class TinymceComponent implements AfterViewInit, OnDestroy {

  @Input() tinyMceArticleElementId: string;
  @Input() tinyMceArticleContent: string;
  @Input() fileImageId: number = 0;
  @Input() tinymceArticleImageCount: number = 0;
  @Input() tinymceArticleImages = [];
  @Input() isMobile: boolean;
  @Input() tinyMceArticleMaxWordCount: number = environment.tinymcearticlemaxwordcount;
  @Output() onEditorChange = new EventEmitter<any>();

  editor;
  apiUrl: string = '';
  restApiUrl: string = '';
  useRestApi: boolean = false;
  restApiUrlEndpoint: string = '';
  deleteImageSubscription: Subscription;
  tinymceArticleDeletedImages = [];
  tinymceArticleAddedImages = [];
  disableImageUpload: boolean = false;
  hasUnsavedChanges: boolean = false;
  tinymceArticle: string = '';
  
  debug: boolean = false;

  constructor(@Inject(DOCUMENT) document,
    private http: HttpClient, 
    private httpService: HttpService,
    private cookieService: CookieService,
    private renderer: Renderer2) { 

      if(environment.debugComponentLoadingOrder) {
        console.log('tinymce.component loaded');
      }

      this.useRestApi = environment.useRestApi;

      this.apiUrl = this.httpService.apiUrl;
      this.restApiUrl = this.httpService.restApiUrl;
      this.restApiUrlEndpoint = this.httpService.restApiUrlEndpoint;

  }

  ngAfterViewInit() {

    if(environment.debugComponentLoadingOrder) {
      console.log('tinymce.component afterViewInit');
    }

    if(this.debug) {
      console.log('tinymce.component: ngAfterViewInit: this.fileImageId 1: ', this.fileImageId);
    }

    this.httpService.articleDialogOpened.subscribe( (data: any) => {

      const height = data['height'];
      this.fileImageId = data['fileImageId'];

      if(this.debug) {
        console.log('tinymce.component: ngAfterViewInit: articleDialogOpened: height: ',height);
      }

      if(height > 0) {

        if(this.debug) {
          console.log('tinymce.component: ngAfterViewInit: this.fileImageId 2: ', this.fileImageId);
        }

        const that = this;
        var tinymce_config = {};
        const style_formats = [
          {title: 'Headers', items: [
            {title: 'Header 1', format: 'h1'},
            {title: 'Header 2', format: 'h2'},
            {title: 'Header 3', format: 'h3'},
            {title: 'Header 4', format: 'h4'},
            {title: 'Header 5', format: 'h5'},
            {title: 'Header 6', format: 'h6'}
          ]},
          {title: 'Inline', items: [
            {title: 'Bold', icon: 'bold', format: 'bold'},
            {title: 'Italic', icon: 'italic', format: 'italic'},
            {title: 'Underline', icon: 'underline', format: 'underline'},
            {title: 'Strikethrough', icon: 'strikethrough', format: 'strikethrough'},
            {title: 'Superscript', icon: 'superscript', format: 'superscript'},
            {title: 'Subscript', icon: 'subscript', format: 'subscript'},
            {title: 'Code', icon: 'code', format: 'code'}
          ]},
          {title: 'Blocks', items: [
            {title: 'Paragraph', format: 'p'},
            {title: 'Blockquote', format: 'blockquote'},
            {title: '...', block: 'div', classes: 'tinymce-divider-after-plugin'},
            {title: 'Div', format: 'div'},
            {title: 'Pre', format: 'pre'}
          ]},
          {title: 'Alignment', items: [
            {title: 'Left', icon: 'alignleft', format: 'alignleft'},
            {title: 'Center', icon: 'aligncenter', format: 'aligncenter'},
            {title: 'Right', icon: 'alignright', format: 'alignright'},
            {title: 'Justify', icon: 'alignjustify', format: 'alignjustify'}
          ]}
        ];

        tinymce.baseURL = 'assets/js/tinymce';

        if(that.isMobile) {
          tinymce_config = {
            selector: '#' + that.tinyMceArticleElementId,
            mobile: {
              height: height,
              end_container_on_empty_block: true,
              theme: 'mobile',
              plugins: ['lists'],
              skin: 'lightgray',
              content_css: 'assets/tinymce/css/custom-mobile.css',
              toolbar: 'undo redo | styleselect | bold italic | bullist numlist | link | unlink | forecolor | removeformat | image',
              style_formats: style_formats,
              preview_styles: false,
              setup: editor => {
                that.setup(editor);
              },
              init_instance_callback: function (editor) {
                that.init_instance_callback(editor);
              },
              images_upload_handler: function (blobInfo, success, failure) {
                that.images_upload_handler(blobInfo, success, failure);
              }
            }
          };
        }
        else{
          tinymce_config = {
            selector: '#' + that.tinyMceArticleElementId,
            height: height,
            end_container_on_empty_block: true,
            theme: 'modern',
            plugins: ['link','paste','table','charmap','searchreplace','lists','advlist','textcolor','colorpicker','codesample','code','contextmenu','wordcount','image'],
            skin: 'lightgray',
            content_css: 'assets/tinymce/css/custom.css',
            menubar: 'edit insert view format table tools',
            toolbar: 'undo redo | styleselect | bold italic blockquote | alignleft aligncenter alignright alignjustify | bullist numlist indent outdent | fontselect | fontsizeselect | forecolor | backcolor | removeformat | image ',
            style_formats: style_formats,
            preview_styles: false,
            resize: false,
            branding: false,
            browser_spellcheck: true,
            contextmenu: 'link image inserttable | cell row column deletetable | textcolor',
            contextmenu_never_use_native: true,
            setup: editor => {
              that.setup(editor);
            },
            init_instance_callback: function (editor) {
              that.init_instance_callback(editor);
            },
            images_upload_handler: function (blobInfo, success, failure) {
              that.images_upload_handler(blobInfo, success, failure);
            }
          }
        }

        tinymce.init(tinymce_config);
        
      }

    });
    
  }

  private processDeleteImageData = (data) => {
    if(this.debug) {
      console.log('tinymce.component: processDeleteImageData: data: ', data);
    }
    if(data) {
      if('error' in data && data['error'] === '') {
        const temp = this.tinymceArticleAddedImages.filter( (filename) => {
          const _filename = data['fileid'] + '/' + data['filename'];
          if(this.debug) {
            console.log('tinymce.component: processDeleteImageData: filename: ', filename);
            console.log('tinymce.component: processDeleteImageData: _filename: ', _filename);
          }
          return filename.toLowerCase() !== _filename.toLowerCase();
        });
        this.tinymceArticleAddedImages = temp;
        if(this.debug) {
          console.log('tinymce.component: processDeleteImageData: this.tinymceArticleAddedImages after: ',this.tinymceArticleAddedImages);
        }
      }
      else{
        if('jwtObj' in data) {
          this.httpService.jwtHandler(data['jwtObj']);
        }
      }
    }
  }

  private deleteImage(event: any, editor: any): void {
    if ((event.keyCode === 8 || event.keyCode === 46) && editor.selection) {
      const selectedNode = editor.selection.getNode();
      if (selectedNode && selectedNode.nodeName === 'IMG') {
          const filename = uriParse(selectedNode.src);
          this.tinymceArticleDeletedImages.push(filename);
          if(this.debug) {
            console.log('tinymce.component: delete image: this.tinymceArticleDeletedImages: ',this.tinymceArticleDeletedImages);
          }
          const deferDeleteItems = arrayInclude(this.tinymceArticleDeletedImages,this.tinymceArticleImages);
          if(deferDeleteItems.length) {
            this.httpService.tinymceArticleDeletedImages.next(deferDeleteItems);
          }
          if(this.debug) {
            console.log('tinymce.component: delete image: deferDeleteItems: ',deferDeleteItems);
          }
          if(this.debug) {
            console.log('tinymce.component: delete image: this.tinymceArticleAddedImages before: ',this.tinymceArticleAddedImages);
          }
          this.tinymceArticleAddedImages.map( (item) => {
            if(filename.toLowerCase() === item.toLowerCase()) {
              const filenameArray = item.split('/');
              let _filename = '';
              if(Array.isArray(filenameArray) && filenameArray.length) {
                _filename  = filenameArray[filenameArray.length - 1];
              }
              if(this.debug) {
                console.log('tinymce.component: delete image: this.fileImageId: ',this.fileImageId);
                console.log('tinymce.component: delete image: _filename: ',_filename);
              }
              const body = {
                fileid: this.fileImageId,
                filename: _filename
              };
              this.httpService.deleteTinymceArticleImage(body).do(this.processDeleteImageData).subscribe();
            }
          });
      }
    }
  }

  private processFetchImageData = (data) => {
    const editor = tinymce.activeEditor;
    if(this.debug) {
      console.log('tinymce.component: processFetchImageData: data: ', data);
    }
    if(data) {
      if('error' in data && data['error'] === '') {
        this.tinymceArticleImageCount = data['tinymceArticleImageCount'];
        this.tinymceArticleImages = data['tinymceArticleImages']; 
        this.tinymceArticle = data['tinymceArticle'];
        this.hasUnsavedChanges = this.unsavedChanges(this.tinymceArticle,editor.getContent());
        this.httpService.tinymceArticleHasUnsavedChanges.next(this.hasUnsavedChanges);
        if(this.debug) {
          console.log('tinymce.component: processFetchImageData: this.hasUnsavedChanges: ', this.hasUnsavedChanges);
        }
        this.imageButtonState();
      }
    }
  }

  private getMetaData(): any {
      const editor = tinymce.activeEditor;
      const body = editor.getBody();
      const text = tinymce.trim(body.innerText || body.textContent);
      const obj = {
        chars: text.length,
        words: text.split(/[\w\u2019\'-]+/).length
      };
      if(this.debug) {
        console.log('tinymce.component: getStats: obj: ', obj);
      }
      return obj;
  }

  private unsavedChanges(article1: string, article2: string): boolean {
    const regex = new RegExp(environment.ajax_dir,'ig')
    const _article1 = article1.replace(/[\s]+/ig,'').replace(regex,'').replace(/assets\/cfm/ig,'').toLowerCase().trim();
    const _article2 = article2.replace(/[\s]+/ig,'').replace(regex,'').replace(/assets\/cfm/ig,'').toLowerCase().trim();
    if(this.debug) {
      console.log('tinymce.component: unsavedChanges: _article1: ', _article1);
      console.log('tinymce.component: unsavedChanges: _article2: ', _article2);
    }
    return _article1 !== _article2;
  }

  private setup(editor: any): void {
    editor.on('init', (event) => {
      if(!this.isMobile) {
        const body = {
          fileid: this.fileImageId
        };
        this.httpService.fetchTinymceArticleImageData(body).do(this.processFetchImageData).subscribe();
      }
      if(this.debug) {
        console.log('tinymce.component: setup: init');
        console.log('tinymce.component: setup: this.fileImageId: ', this.fileImageId);
      }
    });
    editor.on('keyup keydown change', (event) => {
      const content = editor.getContent();
      const metaData = this.getMetaData();
      this.httpService.tinymceArticleOnChange.next(content);
      const backSpaceKey = 8;
      if(event.keyCode !== backSpaceKey) {
        if('words' in metaData && !isNaN(metaData['words']) && this.tinyMceArticleMaxWordCount > 0) {
          if(metaData['words'] > this.tinyMceArticleMaxWordCount) {
            this.httpService.tinymceArticleMetaData.next(metaData);
            return false;
          }
        }
      }
      this.deleteImage(event,editor);
      this.hasUnsavedChanges = this.unsavedChanges(this.tinymceArticle,content);
      this.httpService.tinymceArticleHasUnsavedChanges.next(this.hasUnsavedChanges);
      if(this.debug) {
        console.log('tinymce.component: setup: keyup keydown change: this.hasUnsavedChanges: ', this.hasUnsavedChanges);
      }
      if(this.debug) {
        console.log('tinymce.component: setup: keyup keydown change');
      }
    });
    if(this.isMobile) {
      editor.on('focus', (event) => {
        const body = {
          fileid: this.fileImageId
        };
        this.httpService.fetchTinymceArticleImageData(body).do(this.processFetchImageData).subscribe();
        if(this.debug) {
          console.log('tinymce.component: setup: focus');
        }
      });
    }
    if(this.isMobile) {
      editor.on('blur', (event) => {
        if(this.debug) {
          console.log('tinymce.component: setup: blur');
        }
        this.closeNotificationManager();
      });
    }
  }

  private imageButtonState(disabled: boolean = this.tinymceArticleImageCount > this.httpService.tinymcearticlemaximages): void {
    const toolbarItems = tinymce.activeEditor.theme && tinymce.activeEditor.theme.panel ? tinymce.activeEditor.theme.panel.find('toolbar *') : null;
    if(this.debug && toolbarItems) {
      console.log('tinymce.component: imageButtonState: tinymce.activeEditor.theme: ', tinymce.activeEditor.theme);
      console.log('tinymce.component: imageButtonState: toolbarItems: ', toolbarItems);
    }
    if(toolbarItems && toolbarItems.length) {
      const imageButton = toolbarItems[toolbarItems.length-1];
      if(imageButton) {
        imageButton.disabled(disabled);
      }
      if(this.debug) {
        console.log('tinymce.component: imageButtonState: this.tinymceArticleImageCount: desktop: ', this.tinymceArticleImageCount);
        console.log('tinymce.component: imageButtonState: this.httpService.tinymcearticlemaximages: desktop: ', this.httpService.tinymcearticlemaximages);
        console.log('tinymce.component: imageButtonState: this.tinymceArticleImages: desktop: ', this.tinymceArticleImages);
        console.log('tinymce.component: imageButtonState: imageButton: desktop: ', imageButton);
        console.log('tinymce.component: imageButtonState: disableImageButton: desktop: ', disabled);
      }
    }
    else{
      const imageButton = document.querySelector('.tinymce-mobile-icon-image');
      if(imageButton) {
        if(disabled) {
          this.renderer.setStyle(imageButton,'display','none');
        }
        else {
          this.renderer.setStyle(imageButton,'display','flex');
        }
      }
      if(this.debug) {
        console.log('tinymce.component: imageButtonState: this.tinymceArticleImageCount: mobile: ', this.tinymceArticleImageCount);
        console.log('tinymce.component: imageButtonState: this.httpService.tinymcearticlemaximages: mobile: ', this.httpService.tinymcearticlemaximages);
        console.log('tinymce.component: imageButtonState: this.tinymceArticleImages: mobile: ', this.tinymceArticleImages);
        console.log('tinymce.component: imageButtonState: imageButton: mobile: ', imageButton);
        console.log('tinymce.component: imageButtonState: disableImageButton: mobile: ', disabled);
      }
    }
    if(disabled) {
      const maximages = Number(this.httpService.tinymcearticlemaximages) + 1;
      const message = 'Maximum of ' + (maximages) + ' images per article only.';
      const timeout = 10000;
      if(toolbarItems && toolbarItems.length) {
        tinymce.activeEditor.notificationManager.open({
          text: message,
          type: 'warning',
          timeout: timeout,
          closeButton: true
        });
      }
      else{
        this.openNotificationManager(message,timeout);
      }
    }
  }

  private openNotificationManager(message: string, timeout: number = 0): void {
    const editor = tinymce.activeEditor;
    const uniqueID1 = editor.dom.uniqueId();
    const uniqueID2 = editor.dom.uniqueId();
    if(this.debug) {
      console.log('tinymce.component: openNotificationManager: uniqueID1: mobile: ', uniqueID1);
    }
    editor.insertContent('<div id="' + uniqueID1  + '" class="mce-notification-custom mce-notification-warning-custom" style="opacity:1;"><div class="mce-notification-inner-custom">' + message + '</div><button id="' + uniqueID2  + '" type="button" class="mce-close-custom" style="opacity:1;">×</button></div>');
    const closeButton = editor.dom.select('button#' + uniqueID2)[0];
    if(this.debug) {
      console.log('tinymce.component: openNotificationManager: closeButton: mobile: ', closeButton);
    }
    if(closeButton) {
      closeButton.addEventListener('click', this.closeNotificationManager.bind(this),false);
      if(timeout > 0) {
        setTimeout( () => {
          if(this.debug) {
            console.log('tinymce.component: openNotificationManager: timeout: mobile: ', timeout);
          }
          this.closeNotificationManager();
        }, timeout);
      }
    }
  }

  private closeNotificationManager(): void {
    const editor = tinymce.activeEditor;
    const nodes =  editor.dom.select('.mce-notification-custom');
    if(this.debug) {
      console.log('tinymce.component: closeNotificationManager: nodes: mobile: ', nodes);
    }
    if(nodes.length) {
      tinymce.each(nodes,function(obj,ind) {
        this.renderer.setStyle(obj,'opacity',0);
        obj.remove();
      }.bind(this));
    }
  }
  
  private init_instance_callback(editor: any): void {
    const that = this;
    editor.on('nodeChange', function (event) {
      const selectedNode = editor.selection.getNode();
      const hasClass = editor.dom.hasClass(selectedNode,'tinymce-divider-after-plugin');
      if (selectedNode && selectedNode.nodeName === 'DIV' && hasClass) {
        if(that.debug) {
          console.log('tinymce.component: nodeChange: selectedNode: ', selectedNode);
        }
        const uniqueID = editor.dom.uniqueId();
        const paragraph = document.createElement('p');
        paragraph.setAttribute('id',uniqueID);
        paragraph.innerHTML = '&nbsp;';
        editor.dom.insertAfter(paragraph,selectedNode);
        const newParagraph = editor.dom.select('p#' + uniqueID)[0];
        editor.selection.setCursorLocation(newParagraph);
      }
    });
  }

  private images_upload_handler(blobInfo: any, success: any, failure: any): void {
    let req = null;
    let headers = null;
    if(this.useRestApi) {
      const fileid = this.fileImageId ? this.fileImageId : 0;
      const filename = blobInfo.filename() !== '' ? blobInfo.filename() : 'empty';
      headers = {
        reportProgress: false,
        headers: new HttpHeaders({
          'filename': filename || '',
          'userToken': this.cookieService.get('userToken') || ''
        })
      };
      req = new HttpRequest('POST', this.restApiUrl + this.restApiUrlEndpoint + '/tinymcearticleimage/' + this.fileImageId, blobInfo.blob(), headers);
      if(this.debug) {
        console.log('tinymce.component: images_upload_handler: headers ',headers);
      }
    }
    else{
      req = new HttpRequest('POST', this.apiUrl + '/tinymce-article-image.cfm?filename=' + encodeURIComponent(blobInfo.filename()) + '&fileid=' + this.fileImageId, blobInfo.blob());

    }
    this.http.request(req)
    .subscribe(event => {
      if(this.debug) {
        console.log('tinymce.component: images_upload_handler: event: ',event);
      }
      if (event instanceof HttpResponse) {
        if('error' in event.body && event.body['error'] !== '') {
          if('jwtObj' in event.body && !event.body['jwtObj']['jwtAuthenticated']) {
            this.httpService.jwtHandler(event.body['jwtObj']);
            return;
          }
          else {
            failure('HTTP Error: ' + event.body['error']);
            return;
          }
        }
        else{
          if('location' in event.body && event.body['location'] !== '') {
            success(event.body['location']);
            const filename = uriParse(event.body['location']);
            this.tinymceArticleAddedImages.push(filename);
            if(this.debug) {
              console.log('tinymce.component: images_upload_handler: this.tinymceArticleAddedImages: ', this.tinymceArticleAddedImages);
            }
          }
          if('disableImageUpload' in event.body) {
            this.imageButtonState(!!+event.body['disableImageUpload']);
          }
        }
      }
    });
  }

  ngOnDestroy() {

    tinymce.remove(this.editor);

    if (this.deleteImageSubscription) {
      this.deleteImageSubscription.unsubscribe();
    }

  }
  
}
