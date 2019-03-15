export function arrayInclude(array1: any, array2: any): any {
		const array = array1.filter( (item) => {
			return array2.includes(item);
		});
		return array;
	}
	
export function arrayExclude(array1: any, array2: any): any {
		const array = array1.filter( (item) => {
			return !array2.includes(item);
		});
		return array;
}