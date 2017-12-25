var input = document.body.innerText.trim();
/*
input = `Begin in state A.
Perform a diagnostic checksum after 6 steps.

In state A:
  If the current value is 0:
    - Write the value 1.
    - Move one slot to the right.
    - Continue with state B.
  If the current value is 1:
    - Write the value 0.
    - Move one slot to the left.
    - Continue with state B.

In state B:
  If the current value is 0:
    - Write the value 1.
    - Move one slot to the left.
    - Continue with state A.
  If the current value is 1:
    - Write the value 1.
    - Move one slot to the right.
    - Continue with state A.`;
*/
var [init_text,...state_texts] = input.split("\n\n");

var [init_state_text, checksum_text] = init_text.split("\n");

var curr_state = init_state_text.replace("Begin in state ", "").replace(".","");
var max_steps = parseInt(checksum_text.match(/\d+/),10);

var tape = new Map();
var states = new Map();
var position = 0;
var steps = 0;

var step_func = function( descr ) {
    var [_1, false_write, false_move, false_next, _2, true_write, true_move, true_next] = descr;
    false_write = parseInt(false_write.match(/\d/),10);
    true_write =  parseInt(true_write.match(/\d/),10);
    var false_dir = false_move.match(/left/) ? -1 : 1;
    var true_dir = true_move.match(/left/) ? -1 : 1;
    false_next = false_next.match(/([A-Z])\.$/)[1];
    true_next = true_next.match(/([A-Z])\.$/)[1];
    return function(){
        var v = tape.get(position) || 0;
        if ( !v ) {
            tape.set(position, false_write);
            position+=false_dir;
            curr_state = false_next;
        } else {
            tape.set(position, true_write);
            position+=true_dir;
            curr_state = true_next;
        }
    }
}

for ( var st_text of state_texts ) {
    var [state_line, ...descr] = st_text.split("\n");
    var state = state_line.match(/([A-Z]):$/)[1];
    var fn = step_func(descr);
    states.set(state,fn);
}

do {
    steps++;
    states.get(curr_state)();
} while ( steps < max_steps );

console.log(Array.from( tape.values() ).reduce( (sum, c) => sum+c , 0 ));