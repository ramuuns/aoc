

var start = 109900;
var end = 126900;
var nonprimes = 0;
for ( var i = start; i <= end; i+= 17 ) {
    if ( !isPrime(i) ) {
        nonprimes++;
    }
}

console.log(nonprimes);

function isPrime(n) {
    for ( var i = 2; i < Math.sqrt(n); i++ ) {
        if ( n%i == 0 ) {
            return false;
        }
    }
    return true;
}