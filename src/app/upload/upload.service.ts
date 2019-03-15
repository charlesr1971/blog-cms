
import { Injectable } from '@angular/core';
import { HttpClient, HttpRequest, HttpEventType, HttpResponse, HttpHeaders } from '@angular/common/http';
import { Subject } from 'rxjs/Subject';
import { Observable } from 'rxjs/Observable';

import { HttpService } from '../services/http/http.service';

import { environment } from '../../environments/environment';

@Injectable()
export class UploadService {

  imagePath: string;
  name: string;
  title: string;
  description: string;
  article: string;
  tags: any;
  publishArticleDate: any;
  tinymceArticleDeletedImages: any;
  userToken: string = '';
  cfid: string = '';
  cftoken: string = '';
  uploadType: string = '';
  apiUrl: string = '';
  restApiUrl: string = '';
  useRestApi: boolean = false;
  restApiUrlEndpoint: string = '';
  categoryImagesUrl: string = '';

  subscriptionImageError: Subject<any> = new Subject<any>();
  subscriptionImageUrl: Subject<any> = new Subject<any>();

  debug: boolean = false;

  constructor(private http: HttpClient, 
    private httpService: HttpService) {

    if(environment.debugComponentLoadingOrder) {
      console.log('upload.service loaded');
    }

    this.useRestApi = environment.useRestApi;

    this.apiUrl = this.httpService.apiUrl;
    this.restApiUrl = this.httpService.restApiUrl;
    this.restApiUrlEndpoint = this.httpService.restApiUrlEndpoint;
    this.categoryImagesUrl = this.httpService.categoryImagesUrl;

    this.httpService.subjectImagePath.subscribe( (data: any) => {
      if(this.debug) {
        console.log('upload.service: data: ',data);
      }
      this.imagePath = data['imagePath'];
      this.name = data['name'];
      this.title = data['title'];
      this.description = data['description'];
      this.article = data['article'];
      this.tags = JSON.stringify(data['tags']);
      this.publishArticleDate = data['publishArticleDate'];
      this.tinymceArticleDeletedImages = JSON.stringify(data['tinymceArticleDeletedImages']);
      this.userToken = data['userToken'];
      this.uploadType = data['uploadType'];
    });

    this.cfid = '' + this.httpService.cfid + '';
    this.cftoken = this.httpService.cftoken;

  }

  public upload(files: Set<File>): {[key:string]:Observable<number>} {
    // this will be the our resulting map
    const status = {};

    files.forEach(file => {
      // create a new multipart-form for every file
      const formData: FormData = new FormData();
      formData.append('file', file, file.name);

      if(this.debug) {
        console.log('upload: file ',file);
      }

      let fileExtension: any = file.type.split('/');
      fileExtension = Array.isArray(fileExtension) ? fileExtension[fileExtension.length-1] : '';

      if(this.debug) {
        console.log('upload: fileExtension ',fileExtension);
        console.log('upload: this.name ',this.name);
        console.log('upload: this.title ',this.title);
        console.log('upload: fileExtension ',fileExtension);
        console.log('upload: this.description ',this.description);
        console.log('upload: this.article ',this.article);
        console.log('upload: this.tags ',this.tags);
        console.log('upload: this.publishArticleDate ',this.publishArticleDate);
        console.log('upload: this.tinymceArticleDeletedImages ',this.tinymceArticleDeletedImages);
        console.log('upload: this.userToken ',this.userToken);
      }

      const httpOptions = {
        reportProgress: true,
        headers: new HttpHeaders({
          'File-Name': file.name || '',
          'Image-Path': this.imagePath || '',
          'Name': this.name || '',
          'Title': this.title || '',
          'Description': this.description || '',
          'Article': this.article || '',
          'Tags': this.tags || '',
          'Publish-article-date': this.publishArticleDate || '',
          'Tinymce-article-deleted-images': this.tinymceArticleDeletedImages || '',
          'File-Extension': fileExtension || '',
          'User-Token': this.userToken || '',
          'Cfid': this.cfid || '',
          'Cftoken': this.cftoken || '',
          'Upload-Type': this.uploadType || ''
        })
      };

      if(this.debug) {
        console.log('upload: httpOptions ',httpOptions);
      }

      // create a http-post request and pass the form
      // tell it to report the upload progress

      let req = null;

      if(this.useRestApi) {
        req = new HttpRequest('POST', this.restApiUrl + this.restApiUrlEndpoint + '/image/empty', file, httpOptions);
      }
      else{
        req = new HttpRequest('POST', this.apiUrl + '/upload-image.cfm', file, httpOptions);
      }

      // create a new progress-subject for every file
      const progress = new Subject<number>();

      // send the http-request and subscribe for progress-updates
      this.http.request(req).subscribe(event => {

        if (event.type === HttpEventType.UploadProgress) {

          // calculate the progress percentage
          const percentDone = Math.round(100 * event.loaded / event.total);

          // pass the percentage into the progress-stream
          progress.next(percentDone);
        } else if (event instanceof HttpResponse) {

          // Close the progress-stream if we get an answer form the API
          // The upload is complete
          if(this.debug) {
            console.log('upload: event ',event);
          }

          if('error' in event.body && event.body['error'] !== '') {
            if('jwtObj' in event.body && !event.body['jwtObj']['jwtAuthenticated']) {
              this.httpService.jwtHandler(event.body['jwtObj']);
            }
            else{
              this.subscriptionImageError.next(event.body['error']);
            }
          }
          else{
            if('imagePath' in event.body && event.body['imagePath'] !== '') {
              const data = {
                uploadType: 'gallery',
                imageUrl: this.categoryImagesUrl + '/' + event.body['imagePath']
              };
              this.subscriptionImageUrl.next(data);
            }
            if('uploadType' in event.body && event.body['uploadType'] === 'avatar') {
              const data = {
                uploadType: 'avatar',
                imageUrl: event.body['avatarSrc']
              };
              this.subscriptionImageUrl.next(data);
            }
          }

          progress.complete();

        }
        
      });

      // Save every progress-observable in a map of all observables
      status[file.name] = {
        progress: progress.asObservable()
      };
    });

    // return the map of progress.observables
    return status;
  }

}
