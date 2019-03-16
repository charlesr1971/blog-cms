import { Component, OnInit, OnDestroy, Inject, Renderer2, HostBinding } from '@angular/core';
import { Subscription } from 'rxjs';
import { uuid } from './util/uuid';
import { DOCUMENT } from '@angular/common';
import { Router, NavigationStart, NavigationEnd, Event, ActivatedRoute } from '@angular/router';
import { OverlayContainer } from '@angular/cdk/overlay';
import { capitalizeFirstLetter } from './util/capitalizeFirstLetter';
import { UtilsService } from './services/utils/utils.service';

import { HttpService } from './services/http/http.service';

import { CookieService } from 'ngx-cookie-service';

import { environment } from '../environments/environment';

export let browserRefresh = false;

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit, OnDestroy {

  title: string = environment.title;
  cssClassName: string = '';
  urlVars: any = {};
  refreshSubscription: Subscription;
  browserRefresh: boolean = true;
  userSubscription: Subscription;
  editThemeSubscription: Subscription;
  themeObj = {};
  theme: string = '';
  catalogRouterAliasLower: string = environment.catalogRouterAlias;
  uploadRouterAliasLower: string = environment.uploadRouterAlias;
  @HostBinding('class') componentCssClass;

  debug: boolean = false;

  constructor(public cookieService: CookieService,
    @Inject(DOCUMENT) document,
    private router: Router,
    private route: ActivatedRoute,
    private utilsService: UtilsService,
    private httpService: HttpService,
    public overlayContainer: OverlayContainer,
    private renderer: Renderer2) { 

    if(environment.debugComponentLoadingOrder) {
      console.log('app.component loaded');
    }

    this.themeObj = this.httpService.themeObj;

    this.title = this.httpService.websiteTitle !== '' ? this.httpService.websiteTitle : this.title;

    if(!this.cookieService.check('userToken') || (this.cookieService.check('userToken') && this.cookieService.get('userToken') === '')) {
      this.httpService.browserCacheCleared = true;
    }

    this.route.queryParams.subscribe(params => {
      if(params['browserRefresh']) {
        this.browserRefresh = params['browserRefresh'];
        if(this.debug) {
          console.log('app.component: this.browserRefresh ',this.browserRefresh);
        }
      }
    });

    this.router.events.subscribe((event: Event) => {
      if (event instanceof NavigationEnd) {
          if(this.debug) {
            console.log('app.component: NavigationEnd: (<NavigationEnd>event).url ',(<NavigationEnd>event).url);
            console.log('app.component: NavigationEnd: event.urlAfterRedirects ',event.urlAfterRedirects);
          }
          this.cssClassName = 'gallery';
          if('urlAfterRedirects'in event && event.urlAfterRedirects !== ''){
            this.cssClassName = this.buildCssClassName(event.urlAfterRedirects);
          }
          if(this.debug) {
            console.log('app.component: this.cssClassName ',this.cssClassName);
            console.log('app.component: this.buildPureRouteName(event.urlAfterRedirects) ',this.buildPureRouteName(event.urlAfterRedirects));
          }
          if(this.catalogRouterAliasLower === this.buildPureRouteName(event.urlAfterRedirects)) {
            this.renderer.setAttribute(document.body,'class','gallery');
          }
          else if(this.uploadRouterAliasLower === this.buildPureRouteName(event.urlAfterRedirects)) {
            this.renderer.setAttribute(document.body,'class','upload-photo');
          }
          else{
            this.renderer.setAttribute(document.body,'class',this.cssClassName);
          }
      }
      if (event instanceof NavigationStart) {
        browserRefresh = !router.navigated;
        if(!this.browserRefresh) {
          browserRefresh = false;
        }
        if('url'in (<NavigationEnd>event) && (<NavigationEnd>event).url !== ''){
          this.urlVars = this.getUrlVars((<NavigationEnd>event).url);
          if(this.debug) {
            console.log('app.component: this.urlVars ',this.urlVars);
          }
        }
        if(this.utilsService.isEmpty(this.urlVars)) {
          if(this.debug) {
            console.log('app.component: browserRefresh ',browserRefresh);
          }
          const pattern1 = new RegExp(this.catalogRouterAliasLower + '\/[0-9]+\/[a-zA-Z-]+', 'gi');
          const isGalleryDetailMatch = pattern1.test((<NavigationStart>event).url); 
          if(this.debug) {
            console.log('app.component: isGalleryDetailMatch ',isGalleryDetailMatch);
          }
          let id = '';
          let title = '';
          if(browserRefresh && isGalleryDetailMatch) {
            const pattern2 = new RegExp(this.catalogRouterAliasLower + '\/([0-9]+)\/[a-zA-Z-]+', 'gi');
            const pattern3 = new RegExp(this.catalogRouterAliasLower + '\/[0-9]+\/([a-zA-Z-]+)', 'gi');
            id = (<NavigationStart>event).url.replace(pattern2,'$1').replace(/^\//gi,'');
            title = (<NavigationStart>event).url.replace(pattern3,'$1').replace(/^\//gi,'');
            if(this.debug) {
              console.log('app.component: id ',id);
              console.log('app.component: title ',title);
            }
          }
          if(browserRefresh) {
            let port = environment.port;
            if(this.cookieService.check('port')) {
              port = this.cookieService.get('port');
              if(this.debug) {
                console.log('app.component: port ',port);
              }
            }
            if(id !== '' && title !== ''){
              location.href = environment.host + port + '/' + environment.cf_dir + '/index.cfm?id=' + id + '&title=' + title;
            }
            else{
              location.href = environment.host + port + '/' + environment.cf_dir + '/index.cfm';
            }
          }
        }
        else{
          if('port' in this.urlVars) {
            this.cookieService.set('port', this.urlVars['port']);
            if(this.debug) {
              console.log('app.component: this.cookieService.get("port") ',this.cookieService.get('port'));
            }
          }
          if('id' in this.urlVars && 'title' in this.urlVars && this.urlVars['id'] !== '' && this.urlVars['title'] !== '') {
            this.router.navigate([this.catalogRouterAliasLower,this.urlVars['id'], this.urlVars['title']],{queryParams:{browserRefresh:false}});
          }
        }
      }
    });

    if(!this.cookieService.check('userToken') || (this.cookieService.check('userToken') && this.cookieService.get('userToken') === '')) {
      const userTokenExpired = new Date();
      userTokenExpired.setDate(userTokenExpired.getDate() + 365);
      this.cookieService.set('userToken', uuid(), userTokenExpired);
      if(this.debug) {
        console.log('app.component: userToken: userTokenExpired: ',userTokenExpired);
        console.log('app.component: this.cookieService.get("userToken"): ',this.cookieService.get('userToken'));
      }
    }
    if(this.debug) {
      console.log('app.component: this.cookieService.get("userToken"): ',this.cookieService.get('userToken'));
    }

    const body = {
      userToken: this.cookieService.get('userToken'),
      userid: 0
    };
    this.userSubscription = this.httpService.fetchUser(body).do(this.httpService.processUserData).subscribe();

    if(!this.cookieService.check('theme') || (this.cookieService.check('theme') && this.cookieService.get('theme') === '')) {
      const themeExpired = new Date();
      themeExpired.setDate(themeExpired.getDate() + 365);
      this.cookieService.set('theme', this.themeObj['default'], themeExpired);
      if(this.debug) {
        console.log('app.component: theme: themeExpired 1: ',themeExpired);
        console.log('app.component: this.cookieService.get("theme") 1: ',this.cookieService.get('theme'));
      }
    }

    this.theme = this.cookieService.get('theme');

    if(this.debug) {
      console.log('app.component: this.cookieService.get("theme") 2: ',this.cookieService.get('theme'));
    }

    if(this.debug) {
      console.log('app.component: this.theme: ',this.theme);
    }

    this.overlayContainer.getContainerElement().classList.add(this.theme);
    this.componentCssClass = this.theme;

    this.httpService.themeType.subscribe( (type: string) => {
      this.theme = type;
      this.overlayContainer.getContainerElement().classList.add(this.theme);
      this.componentCssClass = this.theme;
      const themeExpired = new Date();
      themeExpired.setDate(themeExpired.getDate() + 365);
      this.cookieService.set('theme', type, themeExpired);
      if(this.debug) {
        console.log('app.component: theme: themeExpired 3',themeExpired);
        console.log('app.component: this.cookieService.get("theme") 3',this.cookieService.get('theme'));
      }
      if(this.debug) {
        console.log('app.component: this.cookieService.get("theme") 4: ',this.cookieService.get('theme'));
      }
    });

    const cookieAcceptance = this.cookieService.check('cookieAcceptance') ? parseInt(this.cookieService.get('cookieAcceptance')) : null;
    if(cookieAcceptance === null) {
      const cookieAcceptanceExpired = new Date();
      cookieAcceptanceExpired.setDate(cookieAcceptanceExpired.getDate() + 365);
      this.cookieService.set('cookieAcceptance', '0', cookieAcceptanceExpired);
      if(this.debug) {
        console.log('app.component: cookieAcceptance: cookieAcceptanceExpired: ',cookieAcceptanceExpired);
        console.log('app.component: this.cookieService.get("cookieAcceptance"): ',this.cookieService.get('cookieAcceptance'));
      }
    }
    if(this.debug) {
      console.log('app.component: this.cookieService.get("cookieAcceptance"): ',this.cookieService.get('cookieAcceptance'));
    }

  }

  ngOnInit(): void {

    if(environment.debugComponentLoadingOrder) {
      console.log('app.component init');
    }

  }

  private processEditThemeData = (data) => {
    if(this.debug) {
      console.log('processEditThemeData: data',data);
    }
    if(data) {
      if('error' in data && data['error'] === '') {
        
      }
    }
  }

  buildCssClassName(url: string): string {
    return url.replace(/(.*)\?.*/,'$1').replace(/(.*);.*/,'$1').replace(/^\//,'').replace(/\/$/,'').replace(/\//g,'_').trim();
  }

  buildPureRouteName(url: string): string {
    return url.replace(/\/(.*?)\/.*/,'$1').replace(/(.*)\?.*/,'$1').replace(/(.*);.*/,'$1').trim();
  }

  getUrlVars(url: string): any {
    if(this.debug) {
      console.log('app.component: getUrlVars: url ',url);
    }
    const urlVars = url.replace(/(.*)(\?)(.+)|(^.+$)()()/gm,'$3').trim();
    if(this.debug) {
      console.log('app.component: getUrlVars: urlVars ',urlVars);
    }
    const urlVarsArray = urlVars.split('&');
    const obj = {};
    if(Array.isArray(urlVarsArray) && urlVarsArray.length) {
      urlVarsArray.map( (urlVar) => {
        const urlVarArray = urlVar.split('=');
        if(Array.isArray(urlVarArray) && urlVarArray.length === 2) {
          obj[urlVarArray[0]] = urlVarArray[1];
        }
      });
    }
    return obj;
  }

  ngOnDestroy() {
    
    if (this.userSubscription) {
      this.userSubscription.unsubscribe();
    }

    if (this.editThemeSubscription) {
      this.editThemeSubscription.unsubscribe();
    }

  }

}
