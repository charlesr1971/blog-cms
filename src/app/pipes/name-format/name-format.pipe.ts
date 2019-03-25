import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'nameFormat'
})
export class NameFormatPipe implements PipeTransform {

  transform(value: any, args?: any): any {
    let last = value.split('//');
    last = Array.isArray(last) ? last[last.length-1] : value;
    last = last.replace(/[.,\/\\#!$%\^&\*;:{}=_'"`~()]/g,'').replace(/[0-9]+/g,'').replace(/[-]+/g,' ').replace(/[\s]+/g,' ').toLowerCase().trim();
    return last;
  }

}
