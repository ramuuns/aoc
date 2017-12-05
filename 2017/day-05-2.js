
var input = document.body.innerText.trim().split("\n").map(i => parseInt(i,10));
var steps = 0;
var i = 0;
var length = input.length;

do {
    var jmp = input[i];
    if ( input[i] < 3 ) {
        input[i]++;
    } else {
        input[i]--;
    }
    i+=jmp;
    steps++;
    if ( steps % 1000 === 0 ) 
        console.log(steps,i,jmp);
} while ( i >= 0 && i < length );

console.log(steps);