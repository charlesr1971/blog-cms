
export function getUrlParameter(sParam: any): any {
    const debug = false;
    if(debug) {
      console.log('iframe src: ',decodeURIComponent(window.location.search.substring(1)));
    }
    return decodeURIComponent(window.location.search.substring(1)).split('&')
     .map((v) => { 
        return v.split('='); 
      })
     .filter((v) => { 
        return (v[0] === sParam) ? true : false; 
      })
     .reduce((acc:any,curr:any) => { 
        return curr[1]; 
      },0);
  }
