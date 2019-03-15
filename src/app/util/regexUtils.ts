import { uriParse } from './uriParse';

export function getUriMatches(string: string, regex: any, index: number): any {
    index || (index = 1); // default to the first capturing group
    var matches = [];
    var match;
    while (match = regex.exec(string)) {
        matches.push(uriParse(match[index]));
    }
    return matches;
}
  