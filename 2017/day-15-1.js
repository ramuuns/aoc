
var a = 634;
var b = 301;

const afact = 16807;
const bfact = 48271;
const modulo = 2147483647;


var count = 0;

for ( var i = 0; i < 40000000; i++  ) {
    a = (a*afact)%modulo;
    b = (b*bfact)%modulo;
    var abits = a & 65535;
    var bbits = b & 65535;
    if ( abits == bbits ) {
        count++;
    }
}

console.log(count);