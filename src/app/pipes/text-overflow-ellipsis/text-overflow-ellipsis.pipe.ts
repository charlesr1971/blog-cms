import { Pipe, PipeTransform } from '@angular/core';

import { environment } from '../../../environments/environment';

@Pipe({
  name: 'textOverflowEllipsis'
})
export class TextOverflowEllipsisPipe implements PipeTransform {

  transform(value: any, length: number): any {
    return value.substring(0,length) + '...';
  }

}
