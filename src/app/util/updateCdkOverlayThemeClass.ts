export function updateCdkOverlayThemeClass(className1: string, className2: string): void {
    const debug = false;
    const cdkoverlaycontainerArray = Array.prototype.slice.call(document.querySelectorAll('.cdk-overlay-container'));
    if(Array.isArray(cdkoverlaycontainerArray) && cdkoverlaycontainerArray.length) {
        if(debug) {
            console.log('updateCdkOverlayThemeClass: cdkoverlaycontainerArray.length: ', cdkoverlaycontainerArray.length);
        }
        cdkoverlaycontainerArray.map( (element) => {
            element.classList.remove(className1);
            element.classList.add(className2);
        })
    }
}
