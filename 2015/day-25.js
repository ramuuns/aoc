
const start = 20151125;

const tgtx = 3075;
const tgty = 2981;

let num = start;
let done = false;
for ( let d = 2; d <= tgtx + tgty; d++ ) {
    for ( x = 1, y = d; y > 0; x++, y-- ) {
        num = (num*252533)%33554393;
//        console.log(x,y, num);
        if ( x === tgtx && y === tgty ) {
            done = true;
            break;
        }
    }
    if ( done ) {
        break;
    }
}

console.log(num);

