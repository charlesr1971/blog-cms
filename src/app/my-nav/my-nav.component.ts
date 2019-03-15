import { Component, OnInit, OnDestroy, ElementRef, ViewChild, Renderer2 } from '@angular/core';
import { Router } from '@angular/router';
import { BreakpointObserver, Breakpoints } from '@angular/cdk/layout';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { addImage } from '../util/addImage';
import { capitalizeFirstLetter } from '../util/capitalizeFirstLetter';
import { getMonthShortName } from '../util/getMonthShortName';

import { HttpService } from '../services/http/http.service';
import { UtilsService } from '../services/utils/utils.service';
import { MatSidenav } from '@angular/material/sidenav';

import { User } from '../user/user.model';
import { UserService } from '../user/user.service';
import { environment } from '../../environments/environment';


declare var ease, TweenMax, Elastic: any;

@Component({
  selector: 'app-my-nav',
  templateUrl: './my-nav.component.html',
  styleUrls: ['./my-nav.component.css']
})
export class MyNavComponent implements OnInit, OnDestroy {

  @ViewChild('avatarNavContainer') avatarNavContainer;
  @ViewChild('drawer') drawer: MatSidenav;

  title = environment.title;
  pages = [];
  authors = [];
  categories = [];
  dates = [];
  tags = [];
  userid: number = 0;
  angularLogoAnimationHasRun: boolean = false;
  drawerOpened: boolean = false;
  logoAnimationHasRun: boolean = false;
  logoSrc = environment.logoSrc;
  galleryIsActive: boolean = false;
  gallerySectionsIsActive: boolean = false;
  catalogRouterAliasUpper: string = capitalizeFirstLetter(environment.catalogRouterAlias);
  catalogRouterAliasLower: string = environment.catalogRouterAlias;

  isHandset$: Observable<boolean> = this.breakpointObserver.observe(Breakpoints.Handset)
  .pipe(
    map(result => result.matches)
  );

  isTablet$: Observable<boolean> = this.breakpointObserver.observe(Breakpoints.Tablet)
  .pipe(
    map(result => result.matches)
  );

  isLarge$: Observable<boolean> = this.breakpointObserver.observe(Breakpoints.Large)
  .pipe(
    map(result => result.matches)
  );

  isMedium$: Observable<boolean> = this.breakpointObserver.observe(Breakpoints.Medium)
  .pipe(
    map(result => result.matches)
  );

  isSmall$: Observable<boolean> = this.breakpointObserver.observe(Breakpoints.Small)
  .pipe(
    map(result => result.matches)
  );

  currentUser: User;

  debug: boolean = false;
    
  constructor(private breakpointObserver: BreakpointObserver,
    private renderer: Renderer2,
    public el: ElementRef,
    private httpService: HttpService,
    private utilsService: UtilsService,
    private userService: UserService,
    private router: Router) {

      if(environment.debugComponentLoadingOrder) {
        console.log('my-nav.component loaded');
      }

      this.title = this.httpService.websiteTitle !== '' ? this.httpService.websiteTitle : this.title;

      this.fetchData();
      this.fetchAuthors();
      this.fetchCategories();
      this.fetchDates();
      this.fetchTags();
      this.httpService.userId.subscribe( (data: any) => {
        if(this.debug) {
          console.log('my-nav.component: userId: data: ',data);
        }
        this.userid = data;
      });

      setTimeout( () => {

        this.userService.currentUser.subscribe( (user: User) => {
          if(user) {
            addImage(TweenMax, this.renderer, this.avatarNavContainer, user['avatarSrc'], 'avatarNavImage');
          }
        });

      });

      setTimeout( () => {
        this.httpService.searchReset.subscribe( (data) => {
          if(this.debug) {
            console.log('my-nav.component: searchReset');
          }
          this.router.navigateByUrl('/upload-photo', {skipLocationChange: true}).then(()=>
          this.router.navigate([this.catalogRouterAliasLower]));
        });
      });

      this.httpService.galleryIsActive.subscribe( (data) => {
        this.galleryIsActive = data;
      });

  }

  ngOnInit() {

    if(environment.debugComponentLoadingOrder) {
      console.log('my-nav.component init');
    }

    if(!this.angularLogoAnimationHasRun && !this.isHandset$) {
      TweenMax.staggerFromTo('.angular-logos', 1, {opacity:0, scale: 0, delay: 2}, {opacity:1, scale: 1, ease:Elastic.easeOut, delay: 2}, 0.2);
      this.angularLogoAnimationHasRun = true;
    }

    if(!this.logoAnimationHasRun) {
      TweenMax.from('#logo', 1, {opacity:0, scale: 0, ease:Elastic.easeOut, delay: 1}, {opacity:1, scale: 10, ease:Elastic.easeOut, delay: 1}, 0.2);
      this.logoAnimationHasRun = true;
    }
  
  }

  onSideNavOpenedChange(): void {
    if(this.debug) {
      console.log('my-nav.component: this.drawer.opened: ',this.drawer.opened);
    }
    if(!this.angularLogoAnimationHasRun && this.isHandset$) {
      TweenMax.staggerFromTo('.angular-logos', 1, {opacity:0, scale: 0, delay: 2}, {opacity:1, scale: 1, ease:Elastic.easeOut, delay: 2}, 0.2);
      this.angularLogoAnimationHasRun = true;
    }
  }

  onSideNavClosedStart(): void {
    if(this.debug) {
      console.log('my-nav.component: this.drawer.closedStart: ',this.drawer.closedStart);
    }
  }

  fetchData(): void {
    this.httpService.fetchPages().subscribe( (data) => {
      if(data) {
        if(!this.utilsService.isEmpty(data)) {
          for(var i = 0; i < data['pages']; i++) {
            const obj = {};
            obj['title'] = 'Page ' + (i + 1);
            this.pages.push(obj);
          }
        }
      }
    });
  }

  fetchAuthors(): void {
    this.httpService.fetchAuthors().subscribe( (data) => {
      if(data) {
        if(!this.utilsService.isEmpty(data)) {
          if(this.debug) {
            console.log('my-nav.component: fetchAuthors: data: ', data);
          }
          for(var i = 0; i < data['authors'].length; i++) {
              const pages = [];
              for(var ii = 0; ii < data['authors'][i]['pages']; ii++) {
                const obj = {};
                obj['title'] = 'Page ' + (ii + 1);
                pages.push(obj);
              }
              const obj = {};
              obj['userid'] = data['authors'][i]['userid'];
              obj['title'] = data['authors'][i]['surname'] + ', ' + data['authors'][i]['forename'];
              obj['createdAt'] = data['authors'][i]['createdAt'];
              obj['pages'] = pages;
              this.authors.push(obj);
          }
          if(this.debug) {
            console.log('my-nav.component: fetchAuthors: this.authors: ', this.authors);
          }
        }
      }
    });
  }

  fetchCategories(): void {
    this.httpService.fetchCategories().subscribe( (data) => {
      if(data) {
        if(!this.utilsService.isEmpty(data)) {
          if(this.debug) {
            console.log('my-nav.component: fetchCategories: data: ', data);
          }
          for(var i = 0; i < data['categories'].length; i++) {
              const pages = [];
              for(var ii = 0; ii < data['categories'][i]['pages']; ii++) {
                const obj = {};
                obj['title'] = 'Page ' + (ii + 1);
                pages.push(obj);
              }
              const obj = {};
              obj['category'] = data['categories'][i]['category'];
              obj['title'] = capitalizeFirstLetter(data['categories'][i]['category']);
              obj['createdAt'] = data['categories'][i]['createdAt'];
              obj['pages'] = pages;
              this.categories.push(obj);
          }
          if(this.debug) {
            console.log('my-nav.component: fetchCategories: this.categories: ', this.categories);
          }
        }
      }
    });
  }

  fetchDates(): void {
    this.httpService.fetchDates().subscribe( (data) => {
      if(data) {
        if(!this.utilsService.isEmpty(data)) {
          if(this.debug) {
            console.log('my-nav.component: fetchDates: data: ', data);
          }
          for(var i = 0; i < data['dates'].length; i++) {
              const pages = [];
              for(var ii = 0; ii < data['dates'][i]['pages']; ii++) {
                const obj = {};
                obj['title'] = 'Page ' + (ii + 1);
                pages.push(obj);
              }
              const obj = {};
              obj['title'] = capitalizeFirstLetter(getMonthShortName(data['dates'][i]['month'])) + ' ' + data['dates'][i]['year'];
              obj['year'] = data['dates'][i]['year'];
              obj['month'] = data['dates'][i]['month'];
              obj['pages'] = pages;
              this.dates.push(obj);
          }
          if(this.debug) {
            console.log('my-nav.component: fetchCategories: this.dates: ', this.dates);
          }
        }
      }
    });
  }

  fetchTags(): void {
    this.httpService.fetchAutocompleteItems('',false).subscribe( (data) => {
      if(data) {
        if(Array.isArray(data) && data.length) {
          if(this.debug) {
            console.log('my-nav.component: fetchTags: data: ', data);
          }
          for(var i = 0; i < data.length; i++) {
              const obj = {};
              obj['value'] = data[i]['value'].toLowerCase();
              obj['title'] = '#' + data[i]['value'].toLowerCase();
              this.tags.push(obj);
          }
          if(this.debug) {
            console.log('my-nav.component: fetchCategories: this.tags: ', this.tags);
          }
        }
      }
    });
  }

  onChange(event): void {
    const page = event.source.value;
    if(this.debug) {
      console.log('my-nav.component: onChange: page: ', page);
    }
    this.httpService.galleryPage.next(page);
  }

  onChangeAuthor(event): void {
    const data = event.source.value;
    if(this.debug) {
      console.log('my-nav.component: onChangeAuthor: data: ', data);
    }
    let userid = 0;
    let page = 0;
    if(data !== '') {
      const array = data.split('_');
      if(array.length > 1) {
        userid = array[0];
        page = array[1];
        const data = {
          userid: userid,
          page: page
        }
        this.httpService.galleryAuthor.next(data);
      }
    }
  }

  onChangeCategory(event): void {
    const data = event.source.value;
    if(this.debug) {
      console.log('my-nav.component: onChangeCategory: data: ', data);
    }
    let category = '';
    let page = 0;
    if(data !== '') {
      const array = data.split('_');
      if(array.length > 1) {
        category = array[0];
        page = array[1];
        const data = {
          category: category,
          page: page
        }
        this.httpService.galleryCategory.next(data);
      }
    }
  }

  onChangeDate(event): void {
    const data = event.source.value;
    if(this.debug) {
      console.log('my-nav.component: onChangeDate: data: ', data);
    }
    let year = 0;
    let month = 0;
    let page = 0;
    if(data !== '') {
      const array = data.split('_');
      if(array.length > 2) {
        year = array[0];
        month = array[1];
        page = array[2];
        const data = {
          year: year,
          month: month,
          page: page
        }
        this.httpService.galleryDate.next(data);
      }
    }
  }

  onChangeTag(event): void {
    if(this.debug) {
      console.log('my-nav.component: onChangeTag: event: ', event);
    }
    this.httpService.pageTagsDo.next(event.source.value);
  }

  toGallery(): void {
    this.router.navigateByUrl('/upload-photo', {skipLocationChange: true}).then(()=>
          this.router.navigate([this.catalogRouterAliasLower]));
  }

  toggleGallerySections(): void {
    this.galleryIsActive = true;
    this.gallerySectionsIsActive = !this.gallerySectionsIsActive;
  }

  search(): void {
    this.galleryIsActive = true;
    this.router.navigate([this.catalogRouterAliasLower, {formType: 'search'}]);
  }

  toUploadPhoto(): void {
    this.galleryIsActive = false;
    this.router.navigate(['upload-photo', {formType: 'uploadPhoto'}]);
  }

  toProfile(): void {
    this.galleryIsActive = false;
    this.router.navigate(['profile']);
  }

  login(): void {
    this.galleryIsActive = false;
    this.router.navigate(['upload-photo', {formType: 'login'}]);
  }

  logout(): void {
    this.galleryIsActive = false;
    this.router.navigateByUrl('/' + this.catalogRouterAliasLower, {skipLocationChange: true}).then(()=>
          this.router.navigate(['upload-photo', {formType: 'logout'}]));
  }

  ngOnDestroy() {

  }
  
}
