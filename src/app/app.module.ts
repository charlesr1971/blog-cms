import { BrowserModule, Title } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { HttpClientModule, HttpClientJsonpModule } from '@angular/common/http';
import { ReactiveFormsModule, FormsModule } from '@angular/forms';
import { DeviceDetectorModule } from 'ngx-device-detector';
import { ImageLazyLoadModule } from './image-lazy-load/image-lazy-load.module';
import { LightboxModule } from 'angular2-lightbox';
import { UploadModule } from './upload/upload.module';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { LayoutModule } from '@angular/cdk/layout';
import { MatSnackBarModule, MatToolbarModule, MatButtonModule, MatSidenavModule, MatIconModule, MatListModule, MatGridListModule, MatCardModule, MatMenuModule, MatTableModule, MatPaginatorModule, MatSortModule, MatTreeModule, MatProgressBarModule, MatInputModule, MatSelectModule, MatDialogModule, MatAutocompleteModule, MatCheckboxModule, MatTooltipModule, MatDatepickerModule, MatNativeDateModule, MatProgressSpinnerModule } from '@angular/material';
import { CdkTreeModule } from '@angular/cdk/tree';
import { FontAwesomeModule } from '@fortawesome/angular-fontawesome';
import { ShareButtonsModule } from '@ngx-share/buttons';
import { NgbModule } from '@ng-bootstrap/ng-bootstrap';
import { TagInputModule } from 'ngx-chips';
import { EditorModule } from '@tinymce/tinymce-angular';
import { OverlayContainer, OverlayModule } from '@angular/cdk/overlay';

import { AppComponent } from './app.component';
import { MyNavComponent } from './my-nav/my-nav.component';
import { MyDashboardComponent } from './my-dashboard/my-dashboard.component';
import { MyTableComponent } from './my-table/my-table.component';
import { GalleryComponent } from './routes/gallery/gallery.component';
import { ProfileComponent } from './routes/profile/profile.component';
import { UploadPhotoComponent } from './routes/upload-photo/upload-photo.component';
import { DialogComponent } from './upload/dialog/dialog.component';
import { ImagesComponent } from './images/images.component';
import { ImageComponent } from './image/image.component';
import { DialogAccountDeleteComponent } from './dialog-account-delete/dialog-account-delete.component';

import { HttpService } from './services/http/http.service';
import { UtilsService } from './services/utils/utils.service';
import { CookieService } from 'ngx-cookie-service';
import { UserService } from './user/user.service';
import { SnackbarService } from './services/snackbar/snackbar.service';

import { RouterModule, Routes } from '@angular/router';
import { TreeDynamic } from './trees/tree-dynamic/tree-dynamic';
import { TreeCategoryEdit } from './trees/tree-category-edit/tree-category-edit';
import { PathFormatPipe } from './pipes/path-format/path-format.pipe';
import { FileSizePipe } from './pipes/file-size/file-size.pipe';
import { SeoTitleFormatPipe } from './pipes/seo-title-format/seo-title-format.pipe';
import { InfiniteScrollerDirective } from './directives/infinite-scroller/infinite-scroller.directive';
import { PageNotFoundComponent } from './page-not-found/page-not-found.component';
import { AppPasswordDirective } from './directives/appPassword/app-password.directive';
import { LocationStrategy, PathLocationStrategy } from '@angular/common';
import { RefreshComponent } from './refresh/refresh.component';
import { EscapeHtmlPipe } from './pipes/keep-html/keep-html.pipe';
import { TinymceComponent } from './tinymce/tinymce.component';
import { GalleryDetailComponent } from './routes/gallery-detail/gallery-detail.component';
import { CommentsComponent } from './comments/comments.component';
import { ToolbarComponent } from './toolbar/toolbar.component';
import { HttpInterceptorProviders } from './http-interceptors';
import { MyFooterComponent } from './my-footer/my-footer.component';
import { CookieAcceptanceSnackBarComponent } from './cookie-acceptance-snack-bar/cookie-acceptance-snack-bar.component';
import { CookiePolicyComponent } from './cookie-policy/cookie-policy.component';
import { CategoryEditComponent } from './help/dialogs/category-edit/category-edit.component';

import { CharCountDirective } from './directives/char-count/char-count.directive';
import { DialogDraggableTitleDirective } from './directives/dialog-draggable-title/dialog-draggable-title.directive';

import { EmptyDirectoryFormatPipe } from './pipes/empty-directory-format/empty-directory-format.pipe';
import { ConvertPathToIdPipe } from './pipes/convert-path-to-id/convert-path-to-id.pipe';
import { ConvertIdToPathPipe } from './pipes/convert-id-to-path/convert-id-to-path.pipe';

import { ModalPositionCache } from './directives/dialog-draggable-title/modal-position.cache';

import { environment } from '../environments/environment';



const appRoutes: Routes = [
  { path: environment.catalogRouterAlias, component: GalleryComponent },
  { path: environment.catalogRouterAlias + '/:id/:title', component: GalleryDetailComponent },
  { path: environment.uploadRouterAlias, component: UploadPhotoComponent },
  { path: 'profile', component: ProfileComponent },
  { path: '',   redirectTo: '/' + environment.catalogRouterAlias, pathMatch: 'prefix' },
  { path: '**', component: PageNotFoundComponent }
];

@NgModule({
  declarations: [
    AppComponent,
    MyNavComponent,
    MyDashboardComponent,
    MyTableComponent,
    GalleryComponent,
    ProfileComponent,
    UploadPhotoComponent,
    TreeDynamic,
    TreeCategoryEdit,
    PathFormatPipe,
    ImagesComponent,
    ImageComponent,
    FileSizePipe,
    InfiniteScrollerDirective,
    PageNotFoundComponent,
    AppPasswordDirective,
    DialogAccountDeleteComponent,
    RefreshComponent,
    EscapeHtmlPipe,
    TinymceComponent,
    GalleryDetailComponent,
    SeoTitleFormatPipe,
    CommentsComponent,
    ToolbarComponent,
    MyFooterComponent,
    CookieAcceptanceSnackBarComponent,
    CookiePolicyComponent,
    CharCountDirective,
    EmptyDirectoryFormatPipe,
    ConvertPathToIdPipe,
    ConvertIdToPathPipe,
    DialogDraggableTitleDirective,
    CategoryEditComponent
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    HttpClientModule,
    HttpClientJsonpModule,
    LayoutModule,
    MatSnackBarModule,
    MatToolbarModule,
    MatButtonModule,
    MatSidenavModule,
    MatIconModule,
    MatListModule,
    MatGridListModule,
    MatCardModule,
    MatMenuModule,
    MatTableModule,
    MatPaginatorModule,
    MatSortModule,
    RouterModule.forRoot(
      appRoutes/* ,
      { enableTracing: true }
      ,{  onSameUrlNavigation: 'reload' } */
    ),
    CdkTreeModule,
    MatTreeModule,
    MatProgressBarModule,
    UploadModule,
    MatInputModule,
    MatSelectModule,
    MatDialogModule,
    MatAutocompleteModule,
    MatCheckboxModule,
    MatTooltipModule,
    MatDatepickerModule,
    MatNativeDateModule,
    MatProgressSpinnerModule,
    FormsModule, 
    ReactiveFormsModule,
    DeviceDetectorModule.forRoot(),
    ImageLazyLoadModule,
    LightboxModule,
    FontAwesomeModule,
    ShareButtonsModule.forRoot(),
    TagInputModule,
    EditorModule,
    OverlayModule,
    NgbModule
  ],
  entryComponents: [DialogComponent,DialogAccountDeleteComponent,CookiePolicyComponent,CategoryEditComponent], // Add the DialogComponent as entry component
  providers: [
    Title,
    HttpService,
    UtilsService,
    CookieService,
    UserService,
    SnackbarService,
    HttpInterceptorProviders,
    ConvertIdToPathPipe,
    ModalPositionCache,
    {provide: LocationStrategy, useClass: PathLocationStrategy}
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
