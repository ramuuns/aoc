
var input = document.body.innerText.trim().split("\n");

var registers = new Map();

input.forEach((line) => {
    var [tgt_reg, op, op_value, dont_care, cond_reg, cond, cond_value ] = line.split(/\s/);
    if ( evaluateCond(cond, cond_reg, parseInt(cond_value, 10)) ) {
        applyOp(tgt_reg, op, parseInt(op_value,10) );
    }
    console.log(registers);
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

console.log( Math.max.apply(null, Array.from(registers.values() ) ));