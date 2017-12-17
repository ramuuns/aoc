
var steps = 2017;
var ring_size = 359;

var buffer = [0];
var index = 0;

for ( var i = 1; i <= steps; i++ ) {
    index = (index+ring_size) % buffer.length;
    if ( index == buffer.length - 1 ) {
        buffer.push(i);
    } else {
        buffer.splice(index+1,0,i);
    }
    index++;
}

console.log(buffer[(index+1)%buffer.length]);
