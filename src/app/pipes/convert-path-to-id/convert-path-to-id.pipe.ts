import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'convertPathToId'
})
export class ConvertPathToIdPipe implements PipeTransform {

  transform(value: any, args?: any): any {
    let path = value.split('//');
    path = path.join('-').toLowerCase().trim();
    return path;
  }

}
