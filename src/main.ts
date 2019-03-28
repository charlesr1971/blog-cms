import { enableProdMode } from '@angular/core';
import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';

import { AppModule } from './app/app.module';
import { environment } from './environments/environment';

import './icons';

import 'gsap';

/* import 'waypoints'; */

if (environment.production) {
  enableProdMode();
}

if(environment.debugComponentLoadingOrder) {
  console.log('main.ts loaded');
}

platformBrowserDynamic().bootstrapModule(AppModule)
  .catch(err => console.log(err));
