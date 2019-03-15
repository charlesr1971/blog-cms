export function getMonthShortName(n: number): string {
  const array = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  const month = array.filter( (month,idx) => {
    return (n - 1) === idx
  });
  if(month.length === 1) {
    return month[0];
  }
  return '';
}
