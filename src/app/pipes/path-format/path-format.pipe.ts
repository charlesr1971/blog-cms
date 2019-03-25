import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'pathFormat'
})
export class PathFormatPipe implements PipeTransform {

  transform(value: any, args?: any): any {
    let last = value.split('//');
    last = Array.isArray(last) ? last[last.length-1] : value;
    last = last.replace(/\^[0-9]$/,'').toLowerCase().trim();
    return last;
  }

}
