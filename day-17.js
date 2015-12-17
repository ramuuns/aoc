var input = [
	43,
	3,
	4,
	10,
	21,
	44,
	4,
	6,
	47,
	41,
	34,
	17,
	17,
	44,
	36,
	31,
	46,
	9,
	27,
	38,
];

var tgt_sum = 150;

function count_sets(input, stack, cnt) {
	var stacksum = stack.reduce((p, c) => { return p+c }, 0);
	if ( stacksum > tgt_sum ) {
		return cnt;
	}
	if ( stacksum === tgt_sum ) {
		return cnt+1;
	}
	if ( input.length ) {
		do {
			var next = input.pop();
			cnt = count_sets(Array.from(input), stack.concat([next]), cnt);
		} while (input.length);
	}
	return cnt;
}

console.log("Answer 1:", count_sets(Array.from(input), [], 0));

function count_sets2(input, stack, cnt, minsize) {
	var stacksum = stack.reduce((p, c) => { return p+c }, 0);
	if ( stack.length > minsize ) {
		return [cnt, minsize];
	}
	if ( stacksum > tgt_sum ) {
		return [cnt, minsize];
	}
	if ( stacksum === tgt_sum ) {
		if ( stack.length < minsize ) {
			return [1, stack.length];
		} else {
			return [cnt+1, minsize];
		}
	}
	if ( input.length ) {
		do {
			var next = input.pop();
			var arr = count_sets2(Array.from(input), stack.concat([next]), cnt, minsize);
			cnt = arr[0];
			minsize = arr[1];
		} while (input.length);
	}
	return [cnt, minsize];
}

console.log("Answer 2:", count_sets2(Array.from(input), [], 0, +Infinity)[0]);