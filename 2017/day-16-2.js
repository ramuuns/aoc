var input = document.body.innerText.trim();


var programs = [];
var psize = 16;
//we'll keep an array of ints, because of "faster" comparisons
for ( var i = 0; i< psize; i++ ) {
    var program = i;
    programs[i] = program;
}

//pre-parse the instuctions (so we don't have to do this every time)
input = input.split(",").map( (instr) => {
    var [itype,...iarr] = instr.split("");
    switch ( itype ) {
        case 's' :
            var n = parseInt(iarr.join(""),10);
            return { itype, n };
        case 'x' :
            var [apos,bpos] = iarr.join("").split("/").map((i) => parseInt(i,10));
            return {itype, apos, bpos};
        case 'p' :
            //since the arrays are ints convert these to ints
            var aprog = iarr[0].charCodeAt(0) - 'a'.charCodeAt(0), 
                bprog = iarr[2].charCodeAt(0) - 'a'.charCodeAt(0);
            return {itype, aprog, bprog}
    }
} );

var iterations = 1000000000;

var start_t = Date.now();
var total_s = 0;
var total_x = 0;
var total_p = 0;
var iter_map = new Map();
var iter_array = [];
for ( var i = 0; i < iterations; i++ ) {
    var g;
    if ( g = iter_map.get(programs.join(",")) ) {
        //there's a loop
        var size_of_loop = i-g;
        programs = iter_array[(iterations - g)%size_of_loop + g].split(",").map(i => parseInt(i,10));
        console.log(size_of_loop);
        break;
    }
    iter_map.set(programs.join(","),i);
    iter_array.push(programs.join(","));
    for ( instr of input ) {
        with (instr) {
            switch ( itype ) {
                case 's' :
                    programs = programs.splice(psize-n,n).concat(programs);
                    break;
                case 'x' :
                    var t = programs[apos];
                    programs[apos] = programs[bpos];
                    programs[bpos] = t;
                    break;
                case 'p' :
                    var apos = programs.indexOf(aprog), bpos = programs.indexOf(bprog);
                    var t = programs[apos];
                    programs[apos] = programs[bpos];
                    programs[bpos] = t;
                    break;
            }
        }
        
    }

}

console.log(programs.map( (i) => {return  String.fromCharCode( 'a'.charCodeAt(0) + i ) }).join(""));
