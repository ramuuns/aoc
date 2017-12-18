
var steps = 50000000;
var ring_size = 359;

var index = 0;
var max_value = 0;

for ( var i = 1; i <= steps; i++ ) {
    index = (index+ring_size) % i;
    if ( index === 0 ) {
        max_value = i;
    }
    index++;
}


console.log(max_value);
