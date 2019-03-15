export function uriParse(url: string): string {
	const debug = false;
	let uri = '';
	let urlArray = url.split('/');
	if(debug) {
		console.log('urlArray before splice: ',urlArray);
	}
	if(Array.isArray(urlArray) && urlArray.length >= 2) {
		urlArray = urlArray.splice(urlArray.length - 2, 2);
		if(debug) {
			console.log('urlArray after splice: ',urlArray);
		}
		uri = urlArray.join('/').trim();
		const pattern = new RegExp('^[0-9]+\/[a-zA-Z0-9-_]+\.(png|gif|jpg|jpeg)+$','ig');
		
		if(!pattern.test(uri)) {
			uri = '';
		}
		if(debug) {
			console.log('uri: ',uri);
		}
	}
	return uri;
}