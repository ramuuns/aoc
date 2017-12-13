
var input = document.body.innerText.trim();

input = input.split("\n");

var scanners = [];

input.forEach( (line) => {
    var [layer, levels] = line.split(": ");
    scanners[layer] = levels;
} );


var caught = false;
var delay = -1;

do {
    caught = false;
    delay++;

    for ( var i = 0; i < scanners.length; i++ ) {
        if ( scanners[i] && ((i+delay) % (scanners[i]*2-2) === 0 ) ) {
            caught = true;
        }
    }

} while(caught);

console.log(delay);