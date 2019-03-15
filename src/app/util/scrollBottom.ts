export function scrollBottom(): number {
    const w = window;
    const d = document;
    const e = d.documentElement;
    const g = d.getElementsByTagName('body')[0];
    const dHeight = e.clientHeight || g.clientHeight;
    const wHeight = w.innerHeight;
    const wScrollTop = e.scrollTop;
    const scrollBottom = dHeight - wHeight - wScrollTop;
    return scrollBottom;
}
