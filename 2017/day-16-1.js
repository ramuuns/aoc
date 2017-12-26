var input = document.body.innerText.trim();

//input = `s1,x3/4,pe/b`;

var programs = [];
var programsMap = new Map();
var psize = 16;
for ( var i = 0; i< psize; i++ ) {
    var program = String.fromCharCode( 'a'.charCodeAt(0) + i );
    programs[i] = program;
    //programsMap.set(program,i);
}

input = input.split(",");
for ( instr of input ) {
    var [itype,...iarr] = instr.split("");
    switch ( itype ) {
        case 's' :
            var n = parseInt(iarr.join(""),10);
            while(n) {
                n--;
                programs.unshift(programs.pop());
            };
            break;
        case 'x' :
        
            var [apos,bpos] = iarr.join("").split("/").map((i) => parseInt(i,10));
            var t = programs[apos];
            programs[apos] = programs[bpos];
            programs[bpos] = t;
            break;
        case 'p' :
            var aprog = iarr[0], bprog = iarr[2];
            var apos = programs.indexOf(aprog), bpos = programs.indexOf(bprog);
            var t = programs[apos];
            programs[apos] = programs[bpos];
            programs[bpos] = t;
            break;
    }
    
}

console.log(programs.join(""));