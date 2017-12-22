var input = document.body.innerText.trim();

var map = new Map();

input = input.split("\n").reverse().map( l => l.split(""));

var l = input.length;
var offset = Math.floor(l/2);

for ( var i = 0; i < l; i++ ) {
    for ( var j = 0; j < l; j++ ) {
        if ( input[i][j] === '#' ) {
            map.set([i-offset,j-offset].join(","), 1);
        }
    }
}

var pos = [0,0];
var dir = [[1,0], [0,1], [-1,0], [0,-1]];
var cdir = 0;
var inf_count = 0;

for ( var i = 0; i < 10000; i++ ) {
    var cnode = map.get(pos.join(",")) || 0;
    if ( cnode ) {
        cdir = (cdir+1)%dir.length;
    } else {
        cdir = (cdir - 1 + dir.length)%dir.length;
    }
    if ( cnode ) {
        map.set(pos.join(","),0);
    } else {
        map.set(pos.join(","),1);
        inf_count++;
    }
    pos[0]+= dir[cdir][0];
    pos[1]+= dir[cdir][1];
}

console.log(inf_count);