
var input = [0,3,0,-3]; //document.body.innerText.trim().split("\n");
var steps = 0;
var i = 0;
var length = input.length;

do {
    var jmp = input[i];
    input[i]++;
    i+=jmp;
    steps++;
    console.log(steps,i,jmp);
} while ( i >= 0 && i < length );

console.log(steps);