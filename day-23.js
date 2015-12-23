var program = `jio a, +16
inc a
inc a
tpl a
tpl a
tpl a
inc a
inc a
tpl a
inc a
inc a
tpl a
tpl a
tpl a
inc a
jmp +23
tpl a
inc a
inc a
tpl a
inc a
inc a
tpl a
tpl a
inc a
inc a
tpl a
inc a
tpl a
inc a
tpl a
inc a
inc a
tpl a
inc a
tpl a
tpl a
inc a
jio a, +8
inc b
jie a, +4
tpl a
inc a
jmp +2
hlf a
jmp -7`.split("\n");

function run(program, reg, instr_pointer) {
	while ( program[instr_pointer] ) {
		var line = program[instr_pointer].split(/,? /);
		switch ( line[0] ) {
			case "inc":
				reg[line[1]]++;
				instr_pointer++;
				break;
			case "hlf":
				reg[line[1]]/=2; //spoilers - if you do division by left shifting, you'll get into negative numbers and then won't ever terminate
				instr_pointer++;
				break;
			case "tpl":
				reg[line[1]]*=3;
				instr_pointer++;
				break;
			case "jmp":
				instr_pointer += parseInt(line[1]);
				break;
			case "jie":
				if ( reg[line[1]]%2 === 0 ) {
					instr_pointer += parseInt(line[2]);
				} else {
					instr_pointer++;
				}
				break;
			case "jio":
				if ( reg[line[1]] === 1 ) {
					instr_pointer += parseInt(line[2]);
				} else {
					instr_pointer++;
				}
				break;
		}
	}
	return reg;
}

console.log("Answer 1", run(program,{a:0,b:0}, 0).b);
console.log("Answer 2", run(program,{a:1,b:0}, 0).b);