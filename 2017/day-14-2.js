
var input = "oundnydw";

var grid = [];
for ( var i = 0; i<128; i++ ) {
    grid.push(knot_hash_one_bits_count(input+"-"+i));
}

group_count = 0;
for ( var i = 0; i<128; i++ ) {
    for (var j = 0; j < 128; j++ ) {
        if ( grid[i][j] ) {
            bfs_remove_group(i,j);
            group_count++;
        }
    }
}

console.log(group_count);

function bfs_remove_group(x,y) {
    var visited = new Set();
    var to_visit = [[x,y]];
    do {
        var [posx,posy] = to_visit.pop();
        visited.add([posx,posy].join(","));
        grid[posx][posy] = 0;
        [[-1,0],[1,0],[0,-1],[0,1]].forEach(([dx,dy]) => {
            if ( grid[posx+dx] && grid[posx+dx][posy+dy] ) {
                if ( !visited.has([posx+dx,posy+dy].join(",")) ) {
                    to_visit.push([posx+dx, posy+dy]);
                }
            }
        } );
    } while ( to_visit.length );
    
}

function knot_hash_one_bits_count(input) {

    var data = [];
    var data_size = 256;
    for ( var i = 0; i < data_size; i++ ) { data[i] = i; }

    input = input.split("").map((i) => i.charCodeAt(0));
    input = input.concat([17,31,73,47,23]);
    
    var skip = 0;
    var head = 0;
    
    for (var r = 0; r < 64; r++ ) {
    
        input.forEach((l) => {
            for ( var j = (head + l - 1), i = head; i < j; i++, j-- ) {
                var t = data[j%data_size];
                data[j%data_size] = data[i%data_size];
                data[i%data_size] = t;
            }
            head = (head + l + skip)%data_size;
            skip++;
        });
    
    }
    
    var cnt = 0;
    var bin_arr = [];
    for (var i =0; i < 16; i++ ) {
        var n  = data[i*16+0] 
                ^ data[i*16+1]
                ^ data[i*16+2]
                ^ data[i*16+3]
                ^ data[i*16+4]
                ^ data[i*16+5]
                ^ data[i*16+6]
                ^ data[i*16+7]
                ^ data[i*16+8]
                ^ data[i*16+9]
                ^ data[i*16+10]
                ^ data[i*16+11]
                ^ data[i*16+12]
                ^ data[i*16+13]
                ^ data[i*16+14]
                ^ data[i*16+15];
        [128,64,32,16,8,4,2,1].forEach((b) => {
            if ( n & b ) {
                bin_arr.push(1);
            } else {
                bin_arr.push(0);
            }
        });
    }
    return bin_arr;
}