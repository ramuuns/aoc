var input = document.body.innerText;//.trim();

/*input = 
`     |          
     |  +--+    
     A  |  C    
 F---|----E|--+ 
     |  |  |  D 
     +B-+  +--+ 
`;*/

input = input.split("\n").map(line => line.split("").map( c => c.trim() ));

var pos = [0,input[0].indexOf("|")];
var dir = [1,0];
var steps = 0;

do {
    pos[0] += dir[0];
    pos[1] += dir[1];
    switch ( input[pos[0]][pos[1]] ) {
        case '+' :
            if ( dir[0] ) {
                dir[0] = 0;
                dir[1] = !input[pos[0]][pos[1] - 1] ? 1 : -1;
            } else {
                dir[1] = 0;
                dir[0] = !input[pos[0]-1] || !input[pos[0]-1][pos[1]] ? 1 : -1;
            }
            break;
        case '|':
        case '-':
            break;
        case '': 
            break;
        default:
            
    
    }
   steps++;
} while ( input[pos[0]][pos[1]] );

console.log(steps);