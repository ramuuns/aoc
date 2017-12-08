
var input = document.body.innerText.trim().split("\n");

var registers = new Map();
var max_ever = -Infinity;

input.forEach((line) => {
    var [tgt_reg, op, op_value, dont_care, cond_reg, cond, cond_value ] = line.split(/\s/);
    if ( evaluateCond(cond, cond_reg, parseInt(cond_value, 10)) ) {
        applyOp(tgt_reg, op, parseInt(op_value,10) );
    }
    var now_max = Math.max.apply(null, Array.from(registers.values() ) );
    max_ever = Math.max(now_max, max_ever);
    
});

function evaluateCond(cond, reg, value) {
    var reg_val = registers.get(reg) || 0;
    var cond_map = {
        '==' : (() => reg_val == value),
        '!=' : (() => reg_val != value),
        '>' : (() => reg_val > value),
        '<' : (() => reg_val < value),
        '<=' : (() => reg_val <= value),
        '>=' : (() => reg_val >= value),
    };
    var result = false;
    return cond_map[cond]();
}

function applyOp(reg, op, value) {
    var reg_val = registers.get(reg) || 0;
    var fn_map = {
        'inc' : (() => reg_val + value),
        'dec' : (() => reg_val - value )
    };
    registers.set(reg, fn_map[op]());
}

console.log( max_ever);