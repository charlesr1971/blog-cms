import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'convertIdToPath'
})
export class ConvertIdToPathPipe implements PipeTransform {

  transform(value: any, args?: any): any {
    let path = value.split('_');
    path = path.join('//').toLowerCase().trim();
    return path;
  }

}
