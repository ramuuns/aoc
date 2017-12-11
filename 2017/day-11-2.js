var input = document.body.innerText.trim();
//var input = "nw,n,n,se,ne,ne,ne,s,s,se,se,nw,se,s,s,s,se,se,s,s,s,s";

input = input.split(",");

var xpos = 0;
var ypos = 0;

var max_diff = -Infinity;

for ( dir of input ) {
    if ( dir.match(/n/) ) {
        if ( dir == 'n' ) {
            ypos+=1;
        } else {
            ypos+=0.5;
        }
    }
    if ( dir.match(/s/) ) {
        if ( dir == 's' ) {
            ypos-=1;
        } else {
            ypos-=0.5;
        }
    }
    if ( dir.match(/e/) ) {
        xpos+=1;
    }
    if ( dir.match(/w/) ) {
        xpos-=1;
    }

    var absy = Math.abs(ypos);
    var absx = Math.abs(xpos);

    var diff_y = Math.ceil(absy - absx/2);
    var diff;
    if ( diff_y > 0 ) {
        diff =absx + diff_y;
    } else {
        diff =absx;
    }

    max_diff = Math.max(diff,max_diff);
}

console.log(max_diff);
