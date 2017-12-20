var input = document.body.innerText.trim();

input = input.split("\n").map(line => {
    var [x,y,z,vx,vy,vz,ax,ay,az] = line.replace(/[^,\-0-9]/g,"").split(",").map(i => parseInt(i,10)); 
    return {
        position : { x,y,z },
        velocity : { x:vx, y:vy, z:vz },
        acceleration : { x:ax,y:ay, z:az }
    } 
} );

var the_closest_index;
var max_iter = 10;

do {

    var iterations = 1000;
    for ( var i = 0; i < iterations; i++ ) {
        for ( var point of input ) {
            point.velocity.x += point.acceleration.x;
            point.velocity.y += point.acceleration.y;
            point.velocity.z += point.acceleration.z;

            point.position.x += point.velocity.x;
            point.position.y += point.velocity.y;
            point.position.z += point.velocity.z;
        }
    }


    var closest = -1;
    var min_pos = Infinity;
    input.forEach((value, index) => {
        var old_min = min_pos;
        min_pos = Math.min(min_pos, Math.abs(value.position.x) + Math.abs(value.position.y) + Math.abs(value.position.z));
        if ( old_min != min_pos ) {
            closest = index;
        }
    });

    max_iter--;
    if ( the_closest_index == closest ) {
        break;
    }
    the_closest_index = closest;

} while ( max_iter );

console.log(the_closest_index);