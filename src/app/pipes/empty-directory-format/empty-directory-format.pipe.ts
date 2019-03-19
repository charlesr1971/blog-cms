import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'emptyDirectoryFormat'
})
export class EmptyDirectoryFormatPipe implements PipeTransform {

  transform(value: any, args?: any): any {
    let last = value.split('//');
    last = Array.isArray(last) ? last[last.length-1] : value;
    last = last.replace(/.*\^/,'');
    return last;
  }

}
