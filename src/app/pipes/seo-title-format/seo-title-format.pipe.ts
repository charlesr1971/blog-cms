import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'seoTitleFormat'
})
export class SeoTitleFormatPipe implements PipeTransform {

  transform(value: any, args?: any): any {
    let title = value.toLowerCase().trim();
    title = title.replace(/[\s]+/gi,'-');
    return title;
  }

}
