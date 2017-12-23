var input = document.body.innerText.trim();

var registries = new Map();
var mul_count = 0;

input = input.split("\n").map((line) => {
    var [instr, reg, oper] = line.split(/\s+/);
    return { instr, reg, oper };
});

function decode(oper) {
    return oper.match(/[a-zA-Z]/) ? ( registries.get(oper) || 0 ) : parseInt(oper,10);
}

var instructions = {
    "set" : (reg,oper) => { registries.set(reg, decode(oper) ); },
    "sub" : (reg,oper) => { registries.set(reg, (registries.get(reg) || 0) - decode(oper) ); },
    "mul" : (reg,oper) => { registries.set(reg, (registries.get(reg) || 0) * decode(oper) ); mul_count++ },
    "jnz" : (reg,oper) => { if ( decode(reg) ) { idx+=( decode(oper) - 1 ) } }
};

var idx = 0;

while ( true ) {
    if ( input[idx] === void 0 ) {
        break;
    }
    with( input[idx] ) {
        instructions[instr](reg,oper);
    }
    idx++;
}

console.log(mul_count);