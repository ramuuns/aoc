
var a = 634;
var b = 301;

var afact = 16807;
var bfact = 48271;
var modulo = 2147483647;

var amod = 4;
var bmod = 8;

var count = 0;

for ( var i = 0; i < 5000000; i++  ) {
    do {
        a = (a*afact)%modulo;
    } while ( a % amod );
    do {
        b = (b*bfact)%modulo;
    } while ( b % bmod );
    var abits = a & 65535;
    var bbits = b & 65535;
    if ( abits == bbits ) {
        count++;
    }
}

console.log(count);