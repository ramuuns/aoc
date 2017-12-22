var input = document.body.innerText.trim();

var map = new Map();

input = input.split("\n").reverse().map( l => l.split(""));

var l = input.length;
var offset = Math.floor(l/2);

for ( var i = 0; i < l; i++ ) {
    for ( var j = 0; j < l; j++ ) {
        if ( input[i][j] === '#' ) {
            map.set([i-offset,j-offset].join(","), 2);
        }
    }
}

var pos = [0,0];
var dir = [[1,0], [0,1], [-1,0], [0,-1]];
var cdir = 0;
var inf_count = 0;

for ( var i = 0; i < 10000000; i++ ) {
    var cnode = map.get(pos.join(",")) || 0;
    switch ( cnode ) {
        case 0:
            cdir = (cdir - 1 + dir.length)%dir.length;
            break;
        case 1:
            break;
        case 2:
            cdir = (cdir+1)%dir.length;
            break;
        case 3:
            cdir = (cdir+2)%dir.length;
            break;
    }
    cnode = (cnode+1)%4;
    if ( cnode === 2 ) {
        inf_count++;
    }
    map.set(pos.join(","), cnode);
    pos[0]+= dir[cdir][0];
    pos[1]+= dir[cdir][1];
}

console.log(inf_count);