import { uriParse } from './uriParse';

export function getUriMatches(string: string, regex: any, index: number): any {
    var index = index || (index = 1); // default to the first capturing group
    const matches = [];
    var match;
    while (match = regex.exec(string)) {
        matches.push(uriParse(match[index]));
    }
    return matches;
}
