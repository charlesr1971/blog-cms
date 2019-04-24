import { Pipe, PipeTransform } from '@angular/core';

import { environment } from '../../../environments/environment';

@Pipe({
  name: 'convertImageNameSuffix'
})
export class ConvertImageNameSuffixPipe implements PipeTransform {

  transform(value: string, suffix: string = environment.imageMediumSuffix): any {
    let result = value;
    let array = value.split('/');
    if(Array.isArray(array) && array.length > 0) {
      let arrayCopy = Array.from(Object.create(array));
      arrayCopy.pop();
      const newImageName = array[array.length - 1];
      const newImageNameArray = newImageName.split('.');
      if(Array.isArray(newImageNameArray) && newImageNameArray.length === 2) {
        const newImageExt = newImageNameArray[1];
        const newImageNameNoExt = newImageNameArray[0];
        result = arrayCopy.join('/') + '/' + newImageNameNoExt + '-' + suffix + '.' + newImageExt;
      }
    }
    return result;
  }

}
