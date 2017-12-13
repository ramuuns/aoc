
var input = document.body.innerText.trim();

input = input.split("\n");

var scanners = [];

input.forEach( (line) => {
    var [layer, levels] = line.split(": ");
    scanners[layer] = levels;
} );

var severity = 0;

for ( var i = 0; i < scanners.length; i++ ) {
    if ( scanners[i] && ((i) % (scanners[i]*2-2) === 0 ) ) {
        severity+= i*scanners[i];
    }
}

console.log(severity);