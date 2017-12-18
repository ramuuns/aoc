var input = document.body.innerText.trim();

var registries = new Map();
var last_sound_played;
var rcv_success = false;

input = input.split("\n").map((line) => {
    var [instr, reg, oper] = line.split(/\s+/);
    return { instr, reg, oper };
});

function decode(oper) {
    return oper.match(/[a-zA-Z]/) ? ( registries.get(oper) || 0 ) : parseInt(oper,10);
}

var instructions = {
    "set" : (reg,oper) => { registries.set(reg, decode(oper) ); },
    "add" : (reg,oper) => { registries.set(reg, (registries.get(reg) || 0) + decode(oper) ); },
    "mul" : (reg,oper) => { registries.set(reg, (registries.get(reg) || 0) * decode(oper) ); },
    "mod" : (reg,oper) => { registries.set(reg, (registries.get(reg) || 0) % decode(oper) ); },
    "snd" : (reg) => { last_sound_played = registries.get(reg); },
    "rcv" : (reg) => { if ( registries.get(reg) ) { rcv_success = true; registries.set(reg,last_sound_played); } },
    "jgz" : (reg,oper) => { if ( decode(reg) > 0 ) { idx+=( decode(oper) - 1 ) } }
};

var idx = 0;

while ( true ) {
    if ( input[idx] === void 0 ) {
        break;
    }
    if ( rcv_success ) {
        break;
    }
    with( input[idx] ) {
        instructions[instr](reg,oper);
    }
    idx++;
}

console.log(last_sound_played);