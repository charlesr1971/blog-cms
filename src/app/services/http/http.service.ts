import { Injectable } from '@angular/core';
import { Subject } from 'rxjs/Subject';
import { Observable, throwError } from 'rxjs';
import { HttpClient, HttpHeaders, HttpRequest, HttpErrorResponse } from '@angular/common/http';
import { catchError } from 'rxjs/operators';
import { getUrlParameter } from '../../util/getUrlParameter';

import { User } from '../../user/user.model';
import { UserService } from '../../user/user.service';

import { CookieService } from 'ngx-cookie-service';

import { environment } from '../../../environments/environment';

@Injectable()
export class HttpService { 
  
  websiteTitle: string = environment.title;
  port: string = '';
  signUpValidated: number = 0;
  viewCommentid: number = 0;
  cfid: number = 0;
  cftoken: string = '';
  commentToken: string = '';
  themeObj = {};
  apiUrl: string = '';
  restApiUrl: string = '';
  useRestApi: boolean = false;
  restApiURLReWrite: boolean = false;
  restApiUrlEndpoint: string = '/index.cfm';
  categoryImagesUrl: string = '';
  maxcontentlength: number = 500000;
  tinymcearticlemaximages: number = 2;
  currentUserAuthenticated: number = 0;
  isSignUpValidated: number = 0;
  subjectImagePath: Subject<any> = new Subject<any>();
  scrollCallbackImagesData: Subject<any> = new Subject<any>();
  galleryPage: Subject<any> = new Subject<any>();
  galleryAuthor: Subject<any> = new Subject<any>();
  galleryCategory: Subject<any> = new Subject<any>();
  galleryDate: Subject<any> = new Subject<any>();
  searchDo: Subject<any> = new Subject<any>();
  searchReset: Subject<any> = new Subject<any>();
  userId: Subject<any> = new Subject<any>();
  deleteImageId: Subject<any> = new Subject<any>();
  chooseImageButtonText: Subject<any> = new Subject<any>();
  pageTagsDo: Subject<any> = new Subject<any>();
  galleryIsActive: Subject<any> = new Subject<any>();
  commentAdded: Subject<any> = new Subject<any>();
  commentView: Subject<any> = new Subject<any>();
  viewCommentData: Subject<any> = new Subject<any>();
  commentsDialogOpened: Subject<any> = new Subject<any>();
  articleDialogOpened: Subject<any> = new Subject<any>();
  cookiePolicyDialogOpened: Subject<any> = new Subject<any>();
  tinymceArticleDeletedImages: Subject<any> = new Subject<any>();
  tinymceArticleOnChange: Subject<any> = new Subject<any>();
  tinymceArticleHasUnsavedChanges: Subject<any> = new Subject<any>();
  tinymceArticleMetaData: Subject<any> = new Subject<any>();
  openSnackBar: Subject<any> = new Subject<any>();
  openCookieAcceptanceSnackBar: Subject<any> = new Subject<any>();
  logout: Subject<any> = new Subject<any>();
  login: Subject<any> = new Subject<any>();
  themeType: Subject<any> = new Subject<any>();
  galleryImageAdded: Subject<any> = new Subject<any>();
  browserCacheCleared: boolean = false;
  isLoggedIn: boolean = false;

  debug: boolean = false;

  constructor(private http: HttpClient,
    private userService: UserService,
    private cookieService: CookieService) {

    if(environment.debugComponentLoadingOrder) {
      console.log('http.service loaded');
    }

    this.useRestApi = environment.useRestApi;
    this.restApiURLReWrite = environment.restApiURLReWrite;

    if(this.restApiURLReWrite) {
      this.restApiUrlEndpoint = '';
    }

    const websiteTitle = getUrlParameter('websiteTitle');

    if(websiteTitle !== '0' || websiteTitle !== '') {
      this.websiteTitle = websiteTitle;
    }

    const port = getUrlParameter('port');
    if(port > 0) {
      this.port = port;
    }
    if(this.cookieService.check('port') && this.port === '0') {
      this.port = this.cookieService.get('port');
    }
    this.apiUrl = environment.host + this.port + '/' + environment.cf_dir + '/api';
    this.restApiUrl = environment.host + this.port + '/' + environment.cf_dir + '/rest/api/v1';
    this.categoryImagesUrl = environment.host + this.port + '/' + environment.cf_dir;
    this.cfid = getUrlParameter('cfid');
    this.cftoken = getUrlParameter('cftoken');
    this.maxcontentlength = getUrlParameter('maxcontentlength');
    this.tinymcearticlemaximages = getUrlParameter('tinymcearticlemaximages');
    this.commentToken = getUrlParameter('commenttoken');
    if(this.debug) {
      console.log('http.service: getUrlParameter("theme") ',getUrlParameter('theme'));
    }
    this.themeObj = this.createTheme(getUrlParameter('theme'));
    this.isSignUpValidated = getUrlParameter('signUpValidated') !== '' ? parseInt(getUrlParameter('signUpValidated').toString()) : 0;
    if(this.debug) {
      console.log('http.service: this.port ',this.port);
      console.log('http.service: this.apiUrl ',this.apiUrl);
      console.log('http.service: this.cfid ',this.cfid);
      console.log('http.service: this.cftoken ',this.cftoken);
      console.log('http.service: this.commentToken ',this.commentToken);
      console.log('http.service: this.themeObj ',this.themeObj);
      console.log('http.service: this.isSignUpValidated ',this.isSignUpValidated);
    }

    this.userService.currentUser.subscribe( (user: User) => {
      if(user){
        this.currentUserAuthenticated = user['authenticated'];
        if(this.debug) {
          console.log('http.service: this.currentUserAuthenticated ',this.currentUserAuthenticated);
        }
      }
    });

    this.viewCommentData.subscribe( (data: any) => {
      this.viewCommentid =  data['commentid'];
      if(this.debug) {
        console.log('http.service: this.viewCommentid ',this.viewCommentid);
      }
    });

    this.login.subscribe( (data: any) => {
      this.isLoggedIn = data;
    });
    
  }

  // utils

  public createTheme(theme: string): any {
    theme = theme.toString() === '0' ? '' : theme;
    const result = {
      default: 'theme-1-dark',
      id: 1,
      stem: 'theme-1',
      light: 'theme-1-light',
      dark: 'theme-1-dark'
    };
    if(this.debug) {
      console.log('http.service: createTheme(): theme ',theme);
    }
    if(theme !== '') {
      result['default'] = theme;
      let themeArray = theme.split('-');
      if(Array.isArray(themeArray) && themeArray.length === 3){
        result['id'] = parseInt(themeArray[1]);
        themeArray.pop();
        let _theme = themeArray.join('-');
        result['stem'] = _theme;
        result['light'] = _theme + '-light';
        result['dark'] = _theme + '-dark';
      }
    }
    if(this.debug) {
      console.log('http.service: createTheme(): result ',result);
    }
    return result;
  }

  public jwtHandler(data: any): void {
    if('jwtAuthenticated' in data && !data['jwtAuthenticated']) {
      const snackBar = {
        message: data['jwtError'],
        action: 'Logout'
      };
      this.openSnackBar.next(snackBar);
      this.logout.next(true);
    }
  }

  // intermediate data methods

  public fetchJwtData(): void {
    this.fetchJwt(this.cookieService.get('userToken')).do(this.processJwtData).subscribe();
  }

  // process data

  public processUserData = (data) => {
    if(this.debug) {
      console.log('http.service: processUserData: data ',data);
    }
    if(data) {
      if('error' in data && data['error'] === '') {
        const user: User = new User({
          userid: data['userid'],
          email: data['email'],
          salt: data['salt'],
          password: data['password'],
          forename: data['forename'],
          surname: data['surname'],
          userToken: data['usertoken'],
          signUpToken: data['signuptoken'],
          signUpValidated: data['signUpValidated'],
          createdAt: data['createdat'],
          emailNotification: data['emailNotification'],
          keeploggedin: data['keeploggedin'],
          submitArticleNotification: data['submitArticleNotification'],
          cookieAcceptance: data['cookieAcceptance'],
          theme: data['theme']
        });
        if(this.commentToken === '' && data['keeploggedin'] === 1 && data['userid'] > 0) {
          user['authenticated'] = data['userid'];
          user['avatarSrc'] = data['avatarSrc'];
        }
        if(this.debug) {
          console.log('http.service: processUserData: user ',user);
        }
        this.userService.setCurrentUser(user);
        if(this.commentToken === '' && data['keeploggedin'] === 1 && data['userid'] > 0) {
          this.userId.next(data['userid']);
        }
        const cookieAcceptance = this.cookieService.check('cookieAcceptance') ? parseInt(this.cookieService.get('cookieAcceptance')) : null;
        if((cookieAcceptance === null || (cookieAcceptance !== null && cookieAcceptance === 0)) && data['cookieAcceptance'] === 1) {
          const expired = new Date();
          expired.setDate(expired.getDate() + 365);
          this.cookieService.set('cookieAcceptance', '1', expired);
          if(this.debug) {
            console.log('http.service: expired',expired);
            console.log('http.service: this.cookieService.get("cookieAcceptance")',this.cookieService.get('cookieAcceptance'));
          }
        }
        if(this.debug) {
          console.log('http.service: this.cookieService.get("cookieAcceptance")',this.cookieService.get('cookieAcceptance'));
        }
        const expired = new Date();
        expired.setDate(expired.getDate() + 365);
        this.cookieService.set('theme', data['theme'], expired);
        if(this.debug) {
          console.log('http.service: expired: ',expired);
          console.log('http.service: this.cookieService.get("theme"): ',this.cookieService.get('theme'));
        }
      }
      if(this.debug) {
        console.log('http.service: processUserData: data ',data);
      }
    }
  }

  private processJwtData = (data) => {
    if(data) {
      if('jwtObj' in data) {
        this.jwtHandler(data['jwtObj']);
      }
    }
  }

  // POST

  addComment(data: any): Observable<any> {
    let req = null;
    let headers = null;
    if(this.useRestApi) {
      headers = {
        reportProgress: false,
        headers: new HttpHeaders({
          'fileUuid': data['fileUuid'] || '',
          'userid': '' + data['userid'] + '' || '0',
          'comment': data['comment'] || '',
          'replyToCommentid': '' + data['replyToCommentid'] + '' || '0',
          'userToken': this.cookieService.get('userToken') || ''
        })
      };
      req = new HttpRequest('POST', this.restApiUrl + this.restApiUrlEndpoint + '/comment/0', '', headers);
      if(this.debug) {
        console.log('http.service: addComment: headers ',headers);
      }
    }
    else{
      const body = {
        fileUuid: data['fileUuid'],
        userid: data['userid'],
        comment: data['comment'],
        replyToCommentid: data['replyToCommentid']
      };
      const requestHeaders = new HttpHeaders().set('Content-Type', 'application/json');
      headers = {
        headers: requestHeaders
      };
      req = new HttpRequest('POST', this.apiUrl + '/add-comment.cfm', body, headers);
      if(this.debug) {
        console.log('http.service: addComment: body ',body);
        console.log('http.service: addComment: headers ',headers);
      }
    }
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  fetchSignUp(formData: any): Observable<any> {
    let req = null;
    let headers = null;
    const cookieAcceptance = this.cookieService.check('cookieAcceptance') ? parseInt(this.cookieService.get('cookieAcceptance')) : 0;
    if(this.useRestApi) {
      headers = {
        reportProgress: false,
        headers: new HttpHeaders({
          'forename': formData['forename'] || '',
          'surname': formData['surname'] || '',
          'email': formData['email'] || '',
          'password': formData['password'] || '',
          'cfid': '' + this.cfid + '' || '0',
          'cftoken': this.cftoken || '',
          'testEmail': 'false',
          'cookieAcceptance': '' + cookieAcceptance + ''
        })
      };
      const userToken = formData['userToken'] !== '' ? formData['userToken'] : 'empty';
      req = new HttpRequest('POST', this.restApiUrl + this.restApiUrlEndpoint + '/user/' + userToken, '', headers);
      if(this.debug) {
        console.log('http.service: fetchSignUp: headers ',headers);
      }
    }
    else{
      const body = {
        forename: formData['forename'],
        surname: formData['surname'],
        email: formData['email'],
        password: formData['password'],
        userToken: formData['userToken'],
        cfid: this.cfid,
        cftoken: this.cftoken,
        cookieAcceptance: cookieAcceptance
      };
      const requestHeaders = new HttpHeaders().set('Content-Type', 'application/json');
      headers = {
        headers: requestHeaders
      };
      req = new HttpRequest('POST', this.apiUrl + '/sign-up.cfm', body, headers);
      if(this.debug) {
        console.log('http.service: fetchSignUp: body ',body);
        console.log('http.service: fetchSignUp: headers ',headers);
      }
    }
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  addCookieAcceptance(): Observable<any> {
    let req = null;
    let headers = null;
    if(this.useRestApi) {
      headers = {
        reportProgress: false,
        headers: new HttpHeaders({
          'X-HTTP-METHOD-OVERRIDE': 'PUT'
        })
      };
      const userToken = this.cookieService.get('userToken') !== '' ? this.cookieService.get('userToken') : 'empty';
      req = new HttpRequest('POST', this.restApiUrl + this.restApiUrlEndpoint + '/cookie/acceptance/' + userToken, '', headers);
      if(this.debug) {
        console.log('http.service: addCookieAcceptance: headers ',headers);
      }
    }
    else{
      const requestHeaders = new HttpHeaders().set('Content-Type', 'application/json');
      headers = {
        headers: requestHeaders
      };
      const userToken = this.cookieService.get('userToken') !== '' ? this.cookieService.get('userToken') : 'empty';
      req = new HttpRequest('POST', this.apiUrl + '/cookie-acceptance.cfm?userToken=' + userToken, '', headers);
      if(this.debug) {
        console.log('http.service: addCookieAcceptance: headers ',headers);
      }
    }
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  editUser(formData: any): Observable<any> {
    let req = null;
    let headers = null;
    if(this.useRestApi) {
      headers = {
        reportProgress: false,
        headers: new HttpHeaders({
          'forename': formData['forename'] || '',
          'surname': formData['surname'] || '',
          'password': formData['password'] || '',
          'emailNotification': '' + formData['emailNotification'] + '' || '0',
          'theme': formData['theme'] || '',
          'userid': '' + formData['userid'] + '' || '0',
          'X-HTTP-METHOD-OVERRIDE': 'PUT'
        })
      };
      const userToken = this.cookieService.get('userToken') !== '' ? this.cookieService.get('userToken') : 'empty';
      req = new HttpRequest('POST', this.restApiUrl + this.restApiUrlEndpoint + '/user/' + userToken, '', headers);
      if(this.debug) {
        console.log('http.service: editUser: headers ',headers);
      }
    }
    else{
      const body = {
        forename: formData['forename'],
        surname: formData['surname'],
        password: formData['password'],
        emailNotification: formData['emailNotification'],
        theme: formData['theme'],
        userid: formData['userid']
      };
      const requestHeaders = new HttpHeaders().set('Content-Type', 'application/json');
      headers = {
        headers: requestHeaders
      };
      req = new HttpRequest('POST', this.apiUrl + '/edit-user.cfm', body, headers);
      if(this.debug) {
        console.log('http.service: editUser: body ',body);
        console.log('http.service: editUser: headers ',headers);
      }
    }
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  deleteUser(formData: any): Observable<any> {
    let req = null;
    let headers = null;
    if(this.useRestApi) {
      headers = {
        reportProgress: false,
        headers: new HttpHeaders({
          'userid': '' + formData['userid'] + '' || '0',
          'X-HTTP-METHOD-OVERRIDE': 'DELETE'
        })
      };
      const userToken = this.cookieService.get('userToken') !== '' ? this.cookieService.get('userToken') : 'empty';
      req = new HttpRequest('POST', this.restApiUrl + this.restApiUrlEndpoint + '/user/' + userToken, '', headers);
      if(this.debug) {
        console.log('http.service: deleteUser: headers ',headers);
      }
    }
    else{
      const body = {
        userid: formData['userid']
      };
      const requestHeaders = new HttpHeaders().set('Content-Type', 'application/json');
      headers = {
        headers: requestHeaders
      };
      req = new HttpRequest('POST', this.apiUrl + '/delete-user.cfm', body, headers);
      if(this.debug) {
        console.log('http.service: deleteUser: body ',body);
        console.log('http.service: deleteUser: headers ',headers);
      }
    }
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  fetchUser(data: any): Observable<any> {
    let req = null;
    let headers = null;
    if(this.useRestApi) {
      const userToken = data['userToken'] !== '' ? data['userToken'] : 'empty';
      req = new HttpRequest('GET', this.restApiUrl + this.restApiUrlEndpoint + '/user/' + userToken + '?userid=' + data['userid']);
    }
    else{
      const body = {
        userToken: data['userToken'],
        userid: data['userid'],
      };
      const requestHeaders = new HttpHeaders().set('Content-Type', 'application/json');
      headers = {
        headers: requestHeaders
      };
      req = new HttpRequest('POST', this.apiUrl + '/user.cfm', body, headers);
      if(this.debug) {
        console.log('http.service: fetchUser: body ',body);
        console.log('http.service: fetchUser: headers ',headers);
      }
    }
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  fetchLogin(formData: any): Observable<any> {
    let req = null;
    let headers = null;
    const keeploggedin = formData['keeploggedin'] ? 1 : 0;
    if(this.useRestApi) {
      headers = {
        reportProgress: false,
        headers: new HttpHeaders({
          'email': formData['email'] || '',
          'password': formData['password'] || '',
          'commentToken': formData['commentToken'] || '',
          'theme': formData['theme'] || ''
        })
      };
      const userToken = formData['userToken'] !== '' ? formData['userToken'] : 'empty';
      req = new HttpRequest('POST', this.restApiUrl + this.restApiUrlEndpoint + '/oauth/' + userToken + '/' + keeploggedin, '', headers);
      if(this.debug) {
        console.log('http.service: fetchLogin: headers ',headers);
      }
    }
    else{
      const body = {
        email: formData['email'],
        password: formData['password'],
        userToken: formData['userToken'],
        commentToken: formData['commentToken'],
        keeploggedin: keeploggedin,
        theme: formData['theme']
      };
      const requestHeaders = new HttpHeaders().set('Content-Type', 'application/json');
      headers = {
        headers: requestHeaders
      };
      req = new HttpRequest('POST', this.apiUrl + '/oauth.cfm', body, headers);
      if(this.debug) {
        console.log('http.service: fetchLogin: body: ',body);
        console.log('http.service: fetchLogin: headers ',headers);
      }
    }
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  fetchLikes(id: any, add: any = 0, userToken: string = '', allowMultipleLikesPerUser: number = 0): Observable<any> {
    let req = null;
    let headers = null;
    if(this.useRestApi) {
      headers = {
        reportProgress: false,
        headers: new HttpHeaders({
          'userToken': userToken || ''
        })
      };
      const _id = id !== '' ? id : 'empty';
      req = new HttpRequest('POST', this.restApiUrl + this.restApiUrlEndpoint + '/like/' + _id + '/' + add + '/' + allowMultipleLikesPerUser, '', headers);
      if(this.debug) {
        console.log('http.service: fetchLikes: headers ',headers);
      }
    }
    else{
      const body = {
        id: id,
        add: add,
        userToken: userToken,
        allowMultipleLikesPerUser: allowMultipleLikesPerUser
      };
      const requestHeaders = new HttpHeaders().set('Content-Type', 'application/json');
      headers = {
        headers: requestHeaders
      };
      req = new HttpRequest('POST', this.apiUrl + '/likes.cfm', body, headers);
      if(this.debug) {
        console.log('http.service: fetchLikes: body: ',body);
        console.log('http.service: fetchLikes: headers ',headers);
      }
    }
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  fetchImageTitles(term: string = '', page: number = 1): Observable<any> {
    let req = null;
    let headers = null;
    if(this.useRestApi) {
      headers = {
        reportProgress: false,
        headers: new HttpHeaders({
          'term': term || ''
        })
      };
      req = new HttpRequest('GET', this.restApiUrl + this.restApiUrlEndpoint + '/search/' + page, '', headers);
      if(this.debug) {
        console.log('http.service: fetchImageTitles: headers ',headers);
      }
    }
    else{
      const body = {
        term: term,
        page: page
      };
      const requestHeaders = new HttpHeaders().set('Content-Type', 'application/json');
      headers = {
        headers: requestHeaders
      };
      req = new HttpRequest('POST', this.apiUrl + '/search.cfm', body, headers);
      if(this.debug) {
        console.log('http.service: fetchImageTitles: body: ',body);
        console.log('http.service: fetchImageTitles: headers ',headers);
      }
    }
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  editImage(data: any): Observable<any> {
    let req = null;
    let headers = null;
    let body = null;
    if(this.useRestApi) {
      body = {
        article: data['article']
      };
      headers = {
        reportProgress: false,
        headers: new HttpHeaders({
          'imagePath': data['imagePath'] || '',
          'name': data['name'] || '',
          'title': data['title'] || '',
          'description': data['description'] || '',
          'tags': JSON.stringify(data['tags']) || '',
          'publishArticleDate': JSON.stringify(data['publishArticleDate']) || '',
          'tinymceArticleDeletedImages': JSON.stringify(data['tinymceArticleDeletedImages']) || '',
          'submitArticleNotification': '' + data['submitArticleNotification'] + '' || '0',
          'userToken': this.cookieService.get('userToken') || '',
          'X-HTTP-METHOD-OVERRIDE': 'PUT'
        })
      };
      req = new HttpRequest('POST', this.restApiUrl + this.restApiUrlEndpoint + '/image/' + data['fileUuid'], body, headers);
      if(this.debug) {
        console.log('http.service: editImage: body ',body);
        console.log('http.service: editImage: headers ',headers);
      }
    }
    else{
      body = {
        fileUuid: data['fileUuid'],
        imagePath: data['imagePath'],
        name: data['name'],
        title: data['title'],
        description: data['description'],
        article: data['article'],
        tags: JSON.stringify(data['tags']),
        publishArticleDate: data['publishArticleDate'],
        tinymceArticleDeletedImages: JSON.stringify(data['tinymceArticleDeletedImages']),
        submitArticleNotification: data['submitArticleNotification']
      };
      const requestHeaders = new HttpHeaders().set('Content-Type', 'application/json');
      headers = {
        headers: requestHeaders
      };
      req = new HttpRequest('POST', this.apiUrl + '/edit-image.cfm', body, headers);
      if(this.debug) {
        console.log('http.service: editImage: body: ',body);
        console.log('http.service: editImage: headers ',headers);
      }
    }
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  editTheme(theme: string): Observable<any> {
    let req = null;
    let headers = null;
    const userToken = this.cookieService.get('userToken') !== '' ? this.cookieService.get('userToken') : 'empty';
    if(this.useRestApi) {
      headers = {
        reportProgress: false,
        headers: new HttpHeaders({
          'theme': theme || '',
          'X-HTTP-METHOD-OVERRIDE': 'PUT'
        })
      };
      req = new HttpRequest('POST', this.restApiUrl + this.restApiUrlEndpoint + '/theme/' + userToken, '', headers);
      if(this.debug) {
        console.log('http.service: editImage: headers ',headers);
      }
    }
    else{
      const requestHeaders = new HttpHeaders().set('Content-Type', 'application/json').set('theme', theme);
      headers = {
        headers: requestHeaders
      };
      req = new HttpRequest('POST', this.apiUrl + '/edit-theme.cfm?userToken=' + userToken, '', headers);
      if(this.debug) {
        console.log('http.service: editImage: headers ',headers);
      }
    }
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  deleteImage(data: any): Observable<any> {
    let req = null;
    let headers = null;
    if(this.useRestApi) {
      headers = {
        reportProgress: false,
        headers: new HttpHeaders({
          'filename': encodeURIComponent(data['filename']) || '',
          'userToken': this.cookieService.get('userToken') || '',
          'X-HTTP-METHOD-OVERRIDE': 'DELETE'
        })
      };
      req = new HttpRequest('POST', this.restApiUrl + this.restApiUrlEndpoint + '/image/' + data['fileUuid'],'',headers);
      if(this.debug) {
        console.log('http.service: deleteImage: headers: ',headers);
      }
    }
    else{
      const body = {
        fileUuid: data['fileUuid']
      };
      const requestHeaders = new HttpHeaders().set('Content-Type', 'application/json');
      headers = {
        headers: requestHeaders
      };
      req = new HttpRequest('POST', this.apiUrl + '/delete-image.cfm', body, headers);
      if(this.debug) {
        console.log('http.service: deleteImage: body: ',body);
        console.log('http.service: deleteImage: headers ',headers);
      }
    }
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  deleteTinymceArticleImage(data: any): Observable<any> {
    let req = null;
    let headers = null;
    if(this.useRestApi) {
      const fileid = data['fileid'] !== '' ? data['fileid'] : 'empty';
      headers = {
        reportProgress: false,
        headers: new HttpHeaders({
          'filename': encodeURIComponent(data['filename']) || '',
          'userToken': this.cookieService.get('userToken') || '',
          'X-HTTP-METHOD-OVERRIDE': 'DELETE'
        })
      };
      req = new HttpRequest('POST', this.restApiUrl + this.restApiUrlEndpoint + '/tinymcearticleimage/' + fileid,'',headers);
      if(this.debug) {
        console.log('http.service: deleteTinymceArticleImage: headers ',headers);
      }
    }
    else{
      const body = {
        fileid: data['fileid'],
        filename: data['filename']
      };
      const requestHeaders = new HttpHeaders().set('Content-Type', 'application/json');
      headers = {
        headers: requestHeaders
      };
      req = new HttpRequest('POST', this.apiUrl + '/tinymce-article-delete-image.cfm', body, headers);
      if(this.debug) {
        console.log('http.service: deleteTinymceArticleImage: body: ',body);
        console.log('http.service: deleteTinymceArticleImage: headers ',headers);
      }
    }
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  fetchTinymceArticleImageData(data: any): Observable<any> {
    let req = null;
    let headers = null;
    if(this.useRestApi) {
      const fileid = data['fileid'] !== '' ? data['fileid'] : 'empty';
      req = new HttpRequest('GET', this.restApiUrl + this.restApiUrlEndpoint + '/tinymcearticleimage/' + fileid);
    }
    else{
      const body = {
        fileid: data['fileid']
      };
      const requestHeaders = new HttpHeaders().set('Content-Type', 'application/json');
      headers = {
        headers: requestHeaders
      };
      req = new HttpRequest('POST', this.apiUrl + '/tinymce-article-get-image-data.cfm', body, headers);
      if(this.debug) {
        console.log('http.service: fetchTinymceArticleImageData: body: ',body);
        console.log('http.service: fetchTinymceArticleImageData: headers ',headers);
      }
    }
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  deleteComment(data: any): Observable<any> {
    let req = null;
    let headers = null;
    if(this.useRestApi) {
      headers = {
        reportProgress: false,
        headers: new HttpHeaders({
          'X-HTTP-METHOD-OVERRIDE': 'DELETE',
          'userToken': this.cookieService.get('userToken') || ''
        })
      };
      req = new HttpRequest('POST', this.restApiUrl + this.restApiUrlEndpoint + '/comment/' + data['commentid'], '', headers);
      if(this.debug) {
        console.log('http.service: deleteComment: headers ',headers);
      }
    }
    else{
      const body = {
        commentid: data['commentid']
      };
      headers = {
        reportProgress: false,
        headers: new HttpHeaders({
          'Content-Type': 'application/json'
        })
      };
      req = new HttpRequest('POST', this.apiUrl + '/delete-comment.cfm', body, headers);
      if(this.debug) {
        console.log('http.service: deleteComment: body: ',body);
        console.log('http.service: deleteComment: headers ',headers);
      }
    }
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  // GET

  fetchDirectoryTree(): Observable<any> {
    const req = this.useRestApi ? new HttpRequest('GET', this.restApiUrl + this.restApiUrlEndpoint + '/category') : new HttpRequest('GET', this.apiUrl + '/category.cfm');
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  fetchImages(page: number = 1): Observable<any> {
    const req = this.useRestApi ? new HttpRequest('GET', this.restApiUrl + this.restApiUrlEndpoint + '/images/' + page) : new HttpRequest('GET', this.apiUrl + '/images.cfm?page=' + page);
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  fetchImagesByUserid(userid: number = 0, page: number = 1): Observable<any> {
    const req = this.useRestApi ? new HttpRequest('GET', this.restApiUrl + this.restApiUrlEndpoint + '/images/userid/' + userid + '/' + page) : new HttpRequest('GET', this.apiUrl + '/images-by-userid.cfm?userid=' + userid + '&page=' + page);
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  fetchImagesApprovedByUserid(): Observable<any> {
    const req = this.useRestApi ? new HttpRequest('GET', this.restApiUrl + this.restApiUrlEndpoint + '/images/approved/userid') : new HttpRequest('GET', this.apiUrl + '/images-approved-by-userid.cfm');
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  fetchImagesUnapprovedByUserid(page: number = 1): Observable<any> {
    const req = this.useRestApi ? new HttpRequest('GET', this.restApiUrl + this.restApiUrlEndpoint + '/images/unapproved/' + page) : new HttpRequest('GET', this.apiUrl + '/images-unapproved-by-userid.cfm?page=' + page);
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  fetchImagesApproved(page: number = 1): Observable<any> {
    const req = this.useRestApi ? new HttpRequest('GET', this.restApiUrl + this.restApiUrlEndpoint + '/images/approved/' + page) : new HttpRequest('GET', this.apiUrl + '/images-approved.cfm?page=' + page);
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  fetchImagesByCategory(category: string = '', page: number = 1): Observable<any> {
    const req = this.useRestApi ? new HttpRequest('GET', this.restApiUrl + this.restApiUrlEndpoint + '/images/category/' + encodeURIComponent(category) + '/' + page) : new HttpRequest('GET', this.apiUrl + '/images-by-category.cfm?category=' + encodeURIComponent(category) + '&page=' + page);
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  fetchImagesByDate(year: number = 0, month: number = 0, page: number = 1): Observable<any> {
    const req = this.useRestApi ? new HttpRequest('GET', this.restApiUrl + this.restApiUrlEndpoint + '/images/date/' + year + '/' + month + '/'  + page) : new HttpRequest('GET', this.apiUrl + '/images-by-date.cfm?year=' + year + '&month=' + month + '&page=' + page);
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  fetchTags(tag: string = '', page: number = 1): Observable<any> {
    const req = this.useRestApi ? new HttpRequest('GET', this.restApiUrl + this.restApiUrlEndpoint + '/images/tag/' + tag + '/'  + page) : new HttpRequest('GET', this.apiUrl + '/images-by-tag.cfm?tag=' + tag + '&page=' + page);
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  fetchImage(id: string, commentid: number = 0, fileid: number = 0): Observable<any> {
    const _id = id !== '' ? id : 'empty';
    const req = this.useRestApi ? new HttpRequest('GET', this.restApiUrl + this.restApiUrlEndpoint + '/image/' + _id + '?commentid=' + commentid + '&fileid=' + fileid) : new HttpRequest('GET', this.apiUrl + '/image.cfm?id=' + _id + '&commentid=' + commentid + '&fileid=' + fileid);
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  fetchImageNextPrevious(id: string, direction: string = '', userid: number = 0): Observable<any> {
    const req = this.useRestApi ? new HttpRequest('GET', this.restApiUrl + this.restApiUrlEndpoint + '/image/adjacent/' + id + '/' + userid + '/' + direction) : new HttpRequest('GET', this.apiUrl + '/image-next-previous.cfm?id=' + id + '&direction=' + direction + '&userid=' + userid);
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  fetchPages(): Observable<any> {
    const req = this.useRestApi ? new HttpRequest('GET', this.restApiUrl + this.restApiUrlEndpoint + '/pages') : new HttpRequest('GET', this.apiUrl + '/pages.cfm');
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  fetchPagesTitles(): Observable<any> {
    const req = this.useRestApi ? new HttpRequest('GET', this.restApiUrl + this.restApiUrlEndpoint + '/pages/title') : new HttpRequest('GET', this.apiUrl + '/pages-titles.cfm');
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  fetchPagesUnapproved(): Observable<any> {
    const userToken = this.cookieService.get('userToken') !== '' ? this.cookieService.get('userToken') : 'empty';
    const req = this.useRestApi ? new HttpRequest('GET', this.restApiUrl + this.restApiUrlEndpoint + '/pages/unapproved/userid/' + userToken) : new HttpRequest('GET', this.apiUrl + '/pages-unapproved.cfm');
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  fetchPagesApproved(): Observable<any> {
    const userToken = this.cookieService.get('userToken') !== '' ? this.cookieService.get('userToken') : 'empty';
    const req = this.useRestApi ? new HttpRequest('GET', this.restApiUrl + this.restApiUrlEndpoint + '/pages/approved/userid/' + userToken) : new HttpRequest('GET', this.apiUrl + '/pages-approved.cfm');
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  fetchPagesTags(tag: string): Observable<any> {
    const req = this.useRestApi ? new HttpRequest('GET', this.restApiUrl + this.restApiUrlEndpoint + '/pages/tag/' + encodeURIComponent(tag)) : new HttpRequest('GET', this.apiUrl + '/pages-tags.cfm?tag=' + encodeURIComponent(tag));
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  fetchAuthors(): Observable<any> {
    const req = this.useRestApi ? new HttpRequest('GET', this.restApiUrl + this.restApiUrlEndpoint + '/authors') : new HttpRequest('GET', this.apiUrl + '/authors.cfm');
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  fetchCategories(): Observable<any> {
    const req = this.useRestApi ? new HttpRequest('GET', this.restApiUrl + this.restApiUrlEndpoint + '/categories') : new HttpRequest('GET', this.apiUrl + '/categories.cfm');
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  fetchDates(): Observable<any> {
    const req = this.useRestApi ? new HttpRequest('GET', this.restApiUrl + this.restApiUrlEndpoint + '/dates') : new HttpRequest('GET', this.apiUrl + '/dates.cfm');
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  fetchAutocompleteItems = (text: string, useTerm: boolean = true): Observable<any> => {
    const term = text !== '' ? text : '0';
    const req = this.useRestApi ? new HttpRequest('GET', this.restApiUrl + this.restApiUrlEndpoint + '/autocompleteTags/' + encodeURIComponent(term) + '/' + useTerm) : new HttpRequest('GET', this.apiUrl + '/autocomplete-tags.cfm?term=' + encodeURIComponent(term) + '&useTerm=' + useTerm);
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  };

  fetchAutocompleteItemsObservable = (text: string, useTerm: boolean = true): Observable<any> => {
    return this.http.get(this.apiUrl + '/autocomplete-tags.cfm?term=' + text + '&useTerm=' + useTerm)
    .pipe(
      catchError(this.handleError)
    );
  };

  fetchComments = (page: number = 1, fileuuid: string, commentid: number = 0): Observable<any> => {
    let req = null;
    if(commentid > 0) {
      req = this.useRestApi ? new HttpRequest('GET', this.restApiUrl + this.restApiUrlEndpoint + '/comment/' + commentid) : new HttpRequest('GET', this.apiUrl + '/comments.cfm?page=' + page + '&fileuuid=' + fileuuid + '&commentid=' + commentid);
    }
    else{
      req = this.useRestApi ? new HttpRequest('GET', this.restApiUrl + this.restApiUrlEndpoint + '/comments/' + fileuuid + '/' + page) : new HttpRequest('GET', this.apiUrl + '/comments.cfm?page=' + page + '&fileuuid=' + fileuuid + '&commentid=' + commentid);
    }
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  };

  fetchJwt(userToken: string): Observable<any> {
    let req = null;
    if(this.useRestApi) {
      const _userToken = userToken !== '' ? userToken : 'empty';
      req = new HttpRequest('GET', this.restApiUrl + this.restApiUrlEndpoint + '/jwt/' + _userToken);
    }
    else{
      req = new HttpRequest('GET', this.apiUrl + '/jwt.cfm?userToken=' + userToken);
    }
    return this.http.request(req)
    .map( (data) => {
      return 'body' in data ? data['body'] : null;
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  // error handling

  private handleError(error: HttpErrorResponse) {
    if (error.error instanceof ErrorEvent) {
      // A client-side or network error occurred. Handle it accordingly.
      console.error('An client-side or network error occurred: ', error.error.message);
    } else {
      // The backend returned an unsuccessful response code.
      // The response body may contain clues as to what went wrong,
      console.error(
        `Backend returned code ${error.status}, ` +
        `body was: ${error.error}`);
    }
    // return an observable with a user-facing error message
    return throwError(
      'Something bad happened. Please try again later...');
  };

  
}
