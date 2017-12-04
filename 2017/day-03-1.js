
function distance(num) {
    var level = 0;
    var side = 1;
    var i = 1;
    while ( i < num ) {
        i+=side*4+4;
        level++;
        side+=2;
    }
    var corner = i;
    while ( corner > num ) {
        corner -= (side-1);
    }
    
    var center = corner + (side-1)/2;
    return level + Math.abs(num-center);
}

console.log(distance(1))