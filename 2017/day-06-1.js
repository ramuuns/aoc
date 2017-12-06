var input = document.body.innerText.trim().split(/\s+/).map((i) => parseInt(i,10));

var steps = 0;
var seenConfigs = new Map();
var len = input.length;

do {
    steps++;
    var index = 0;
    var max = -Infinity;
    input.forEach( (i, idx) => { if (i > max ) { index = idx; max = i; } } );
    input[index] = 0;
    do {
        index = (index+1)%len;
        input[index]++;
        max--;
    } while (max);
    if ( seenConfigs.get(input.join(",")) ) {
        break;
    }
    seenConfigs.set(input.join(","),1);
} while ( true  );

console.log(steps);