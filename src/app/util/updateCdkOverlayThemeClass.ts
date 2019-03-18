export function updateCdkOverlayThemeClass(className: string): void {
    const debug = true;
    const cdkoverlaycontainerArray = Array.prototype.slice.call(document.querySelectorAll('.cdk-overlay-container'));
    if(Array.isArray(cdkoverlaycontainerArray) && cdkoverlaycontainerArray.length) {
        if(debug) {
            console.log('updateCdkOverlayThemeClass: cdkoverlaycontainerArray.length: ', cdkoverlaycontainerArray.length);
        }
        cdkoverlaycontainerArray.map( (element) => {
            element.classList.remove(className);
        })
    }
}