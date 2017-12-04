
function firstLargerThan(n) {
    var i = 1;
    var coords = new Map();
    coords.set([0,0].toString(),1);
    var x = 0;
    var y = 0;
    var dir = [1,0];
    while ( i <= n ) {
        x+=dir[0];
        y+=dir[1];
        i = sumNeighbours(x,y,coords);
        coords.set([x,y].toString(),i);
        var next_dir = nextDir(dir);
        if ( coords.get([x+next_dir[0],y+next_dir[1]].toString()) === undefined ) {
            dir = next_dir;
        }
    }
    return i;
}

function nextDir(dir) {
    if ( dir[0] == 1 && dir[1] == 0 ) {
        return [0,1];
    }
    if ( dir[0] == 0 && dir[1] == 1 ) {
        return [-1,0];
    }
    if ( dir[0] == -1 && dir[1] == 0 ) {
        return [0,-1];
    }
    return [1, 0];
}

function sumNeighbours(x, y, coords) {
    var sum = 0;
    for ( var i = x-1; i <= x+1; i++ ) {
        for ( var j = y-1; j <= y+1; j++ ) {
            var s = coords.get([i,j].toString());            
            sum += s ? s : 0;
        }
    }
    return sum;
}