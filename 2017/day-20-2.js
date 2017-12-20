var input = document.body.innerText.trim();

input = input.split("\n").map(line => {
    var [x,y,z,vx,vy,vz,ax,ay,az] = line.replace(/[^,\-0-9]/g,"").split(",").map(i => parseInt(i,10)); 
    return {
        position : { x,y,z },
        velocity : { x:vx, y:vy, z:vz },
        acceleration : { x:ax,y:ay, z:az }
    } 
} );

var left = input.length;
var max_iter = 100;
do {

    var iterations = 10000;
    for ( var i = 0; i < iterations; i++ ) {
        var positions = new Map();

        for ( var j = 0; j < input.length; j++ ) {
            var point = input[j];

            point.velocity.x += point.acceleration.x;
            point.velocity.y += point.acceleration.y;
            point.velocity.z += point.acceleration.z;

            point.position.x += point.velocity.x;
            point.position.y += point.velocity.y;
            point.position.z += point.velocity.z;
            var key = point.position.x + "," + point.position.y + "," + point.position.z;
            var p = positions.get(key) || [];
            p.push(j);
            positions.set(key, p)
            
        }

        if ( positions.size === input.length ) {
            continue;
        }

        var to_delete = [];
        for ( var indexes of positions.values() ) {
            if ( indexes.length > 1 ) {
                to_delete = to_delete.concat(indexes);
            }
        }

        to_delete = to_delete.sort( (a,b) => b-a );

        for ( var index of to_delete ) {
            input.splice(index,1);
        }
    }

    var input_size = input.length;

    max_iter--;
    if ( input_size == left ) {
        break;
    }
    left = input_size;

} while ( max_iter );

console.log(left);