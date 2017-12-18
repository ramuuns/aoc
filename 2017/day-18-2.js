var input = document.body.innerText.trim();

var p1_sends = 0;

input = input.split("\n").map((line) => {
    var [instr, reg, oper] = line.split(/\s+/);
    return { instr, reg, oper };
});

var send_queue = [[],[]];

function program( id ) {

    var registries = new Map();
    registries.set("p", id);

    function decode(oper) {
        return oper.match(/[a-zA-Z]/) ? ( registries.get(oper) || 0 ) : parseInt(oper,10);
    }

    var instructions = {
        "set" : (reg,oper) => { registries.set(reg, decode(oper) ); },
        "add" : (reg,oper) => { registries.set(reg, (registries.get(reg) || 0) + decode(oper) ); },
        "mul" : (reg,oper) => { registries.set(reg, (registries.get(reg) || 0) * decode(oper) ); },
        "mod" : (reg,oper) => { registries.set(reg, (registries.get(reg) || 0) % decode(oper) ); },
        "snd" : (oper) => { send_queue[(id+1)%2].push(decode(oper)); if ( id == 1 ) { p1_sends++; } },
        "rcv" : (reg) => { if ( send_queue[id].length ) { this.isWaiting = false; registries.set(reg, send_queue[id].shift()) } else { this.isWaiting = true; } },
        "jgz" : (reg,oper) => { if ( decode(reg) > 0 ) { idx+=( decode(oper) - 1 ) } }
    };

    var idx = 0;

    this.isWaiting = false;

    this.isDone = function() {
        return input[idx] === void 0;
    }

    this.step = function() {
        if ( this.isDone() ) {
            return;
        }
        with( input[idx] ) {
            instructions[instr](reg,oper);
        }
        if ( ! this.isWaiting ) {
            idx++;
        }
    }


}

var p0 = new program(0);
var p1 = new program(1);

var maybe_terminate = false;

while ( true ) {
    do {
        p0.step();
    } while ( !p0.isDone() && !p0.isWaiting );
    do {
        p1.step();
    } while ( !p1.isDone() && !p1.isWaiting );

    if ( p0.isDone() && p1.isDone() ) {
        break;
    }
    if ( p0.isDone() && p1.isWaiting ) {
        break;
    }
    if ( p1.isDone() && p0.isWaiting ) {
        break;
    }
    if ( p0.isWaiting && p1.isWaiting && send_queue[0].length == 0 && send_queue[1].length == 0 ) {
        if ( maybe_terminate ) {
            break;
        } else {
            maybe_terminate = true;
        }
    }
}

console.log(p1_sends);