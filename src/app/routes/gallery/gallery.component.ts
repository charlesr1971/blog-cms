import { Component, OnInit } from '@angular/core';
import { Router, ActivatedRoute, Params } from '@angular/router';
import { Subscription } from 'rxjs/Subscription';
import { MatSnackBar, MatSnackBarConfig, MatDialog } from '@angular/material';

import { User } from '../../user/user.model';
import { UserService } from '../../user/user.service';

import { CookieService } from 'ngx-cookie-service';
import { UtilsService } from '../../services/utils/utils.service';
import { SnackbarService } from '../../services/snackbar/snackbar.service';
import { HttpService } from '../../services/http/http.service';
import { environment } from '../../../environments/environment';

@Component({
  selector: 'app-gallery',
  templateUrl: './gallery.component.html',
  styleUrls: ['./gallery.component.css']
})
export class GalleryComponent implements OnInit {

  private port: string;
  private cfid: string;
  private cftoken: string;
  private ngdomid: string;
  private sub: Subscription;

  uploadRouterAliasLower: string = environment.uploadRouterAlias;

  currentUser: User;

  debug: boolean = false;

  constructor(private httpService: HttpService,
    public matSnackBar: MatSnackBar,
    private router: Router,
    private snackbarService: SnackbarService,
    private userService: UserService,
    private cookieService: CookieService,
    private utilsService: UtilsService,
    private route: ActivatedRoute) {

    if(environment.debugComponentLoadingOrder) {
      console.log('gallery.component loaded');
    }

    if(this.httpService.currentUserAuthenticated > 0) {
      this.httpService.fetchJwtData();
    }

    this.sub = this.route.queryParams.subscribe((params: Params) => {
      if(this.debug) {
        console.log('gallery.component: params: ', params);
      }
      this.port = params['port'];
      this.cfid = params['cfid'];
      this.cftoken = params['cftoken'];
      this.ngdomid = params['ngdomid'];
      if(this.debug) {
        console.log('gallery.component: url variables: ', this.port, this.cfid, this.cftoken, this.ngdomid);
      }
    });

    this.httpService.galleryIsActive.next(true);

  }

  ngOnInit() {

    if(environment.debugComponentLoadingOrder) {
      console.log('gallery.component init');
    }

    setTimeout( () => {

      this.route.params.subscribe( (params) => {
        if(this.debug) {
          console.log('gallery.component: this.route.params.subscribe ',params);
        }
        if (params['formType'] && params['formType'] === 'search') { 
          this.httpService.searchDo.next(true);
        }
      });

      this.httpService.openSnackBar.subscribe( (data) => {
        this.openSnackBar(data['message'], data['action']);
      });

      this.httpService.logout.subscribe( (data) => {
        this.router.navigate([this.uploadRouterAliasLower, {formType: 'logout'}]);
      });

      if(this.debug) {
        console.log('gallery.component: this.httpService.isSignUpValidated: ', this.httpService.isSignUpValidated);
        console.log('gallery.component: this.httpService.isSignUpValidated: is data type number: ', (typeof this.httpService.isSignUpValidated === 'number'));
      }
  
      if(this.httpService.isSignUpValidated === 1) {
        this.httpService.isSignUpValidated = 0;
        this.openSnackBar('E-mail address has been successfully validated', 'Success');
        this.router.navigate([this.uploadRouterAliasLower, {formType: 'login'}]);
      }

      this.userService.currentUser.subscribe( (user: User) => {
        if(user) {
          this.currentUser = user;
          if(this.currentUser['authenticated']) {
            this.httpService.fetchImagesApprovedByUserid().do(this.processImagesApprovedByUseridData).subscribe();
          }
        }
      });

      this.httpService.openCookieAcceptanceSnackBar.next(true);

    });

  }

  private processImagesApprovedByUseridData = (data) => {
    if(this.debug) {
      console.log('gallery.component: processImageData: data: ', data);
    }
    if(data) {
      if(!this.utilsService.isEmpty(data) && 'approved' in data) {
        if(!data['approved']){
          const imagesApproved = this.cookieService.check('imagesApproved') ? parseInt(this.cookieService.get('imagesApproved')) : 1;
          if(this.debug) {
            console.log('images.component: imagesApproved: ',imagesApproved);
          }
          if(imagesApproved === 1){
            this.openSnackBar('Images awaiting approval','Alert');
            const imagesApprovedExpired = new Date();
            imagesApprovedExpired.setDate(imagesApprovedExpired.getDate() + 1);
            this.cookieService.set('imagesApproved', '0', imagesApprovedExpired);
            if(this.debug) {
              console.log('images.component: imagesApproved: imagesApprovedExpired: ',imagesApprovedExpired);
              console.log('images.component: this.cookieService.get("imagesApproved"): ',this.cookieService.get('imagesApproved'));
            }
          }
          if(this.debug) {
            console.log('images.component: this.cookieService.get("imagesApproved"): ',this.cookieService.get('imagesApproved'));
          }
        }
      }
    }
  }

  openSnackBar(message: string, action: string) {
    const config = new MatSnackBarConfig();
    config.panelClass = ['custom-class'];
    config.duration = 5000;
    this.matSnackBar.open(message, action, config);
  }

}
