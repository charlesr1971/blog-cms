// This file can be replaced during build by using the `fileReplacements` array.
// `ng build ---prod` replaces `environment.ts` with `environment.prod.ts`.
// The list of file replacements can be found in `angular.json`.

export const environment = {
  production: false,
  ajax_dir: 'http://localhost:8500/community.establishmindfulness/material/ngMat02/src/assets/cfm',
  host: 'http://localhost:',
  cf_dir: 'community.establishmindfulness/material/ngMat02/src/assets/cfm',
  allowMultipleLikesPerUser: 0,
  title: 'Establish Mindfulness',
  htmlTitle: 'Establish Mindfulness S.P.A',
  logoSrc: 'assets/images/logo.png',
  debugComponentLoadingOrder: false,
  port: '8500',
  maxcontentlength: 500000,
  tinymcearticlemaximages: 2,
  tinymcearticlemaxwordcount: 250,
  openToolbarCommentsPanel: true,
  useRestApi: true,
  restApiURLReWrite: false,
  apiDocumentationUrl: 'http://localhost:8500/community.establishmindfulness/material/ngMat02/src/assets/cfm/components/restAPiService.cfm',
  apiEndpointUrl: 'http://localhost:8500/community.establishmindfulness/material/ngMat02/src/assets/cfm/rest/api/v1/index.cfm',
  maxCommentInputLength: 140,
  catalogRouterAlias: 'stories',
  uploadRouterAlias: 'upload-story',
  maxcategoryeditnamelength: 30
};

/*
 * In development mode, to ignore zone related error stack frames such as
 * `zone.run`, `zoneDelegate.invokeTask` for easier debugging, you can
 * import the following file, but please comment it out in production mode
 * because it will have performance impact when throw error
 */
// import 'zone.js/dist/zone-error';  // Included with Angular CLI.
