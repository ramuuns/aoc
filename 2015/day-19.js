
var replacements = [];
var source = "";

var distinct_molecules = new Set();

document.body.textContent.trim().split("\n").forEach((str) => {
	if ( str.indexOf('=>') !== -1 ) {
		replacements.push(str.split(" => "));
	} else if ( str.length ) {
		source = str;
	}
});

for ( var repl of replacements ) {
	var i = -1;
	while ( source.indexOf(repl[0],i+1) !== -1 ) {
		i = source.indexOf(repl[0],i+1);
		var copy = Array.from(source);
		copy.splice(i,repl[0].length,repl[1]);
		distinct_molecules.add(copy.join(""));
	}
}

console.log("Answer1 ",  distinct_molecules.size);

var seen_strings = new Map();

function replace(str, steps, min) {
	if ( steps >= min ) {
		return min;
	}
	if ( str === "e" ) {
		return steps;
	}
	for ( var repl of replacements ) {
		var i = -1;
		var iter = 0;
		while ( str.indexOf(repl[1],i+1) !== -1 ) {
			i = str.indexOf(repl[1],i+1);
			var copy = Array.from(str);
			copy.splice(i,repl[1].length,repl[0]);
			var copy_str = copy.join("");
			var prev_steps = seen_strings.get(copy_str) || +Infinity;
			if ( steps < prev_steps ) {
				seen_strings.set(copy_str, steps);
				var new_min = Math.min(replace(copy_str, steps+1, min), min);
				if ( new_min < min ) {
					return new_min;
				}
			}
		}
	}
	return min;
}
//so for some reason it seems that actually searching for minimum takes forever,
//but the first result is good enough, so we just return that instead, as that is found in a decent time and stuff
console.log("Answer2 ", replace(source,0,+Infinity));

