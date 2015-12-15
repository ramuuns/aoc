//run this in the console of the input data page

function findBestHappyness(stack,best) {
	if ( stack.length === Object.keys(data).length ) {
		var sum = 0;
		sum = stack.reduce((sum, guy, pos) => {
			return sum + data[guy][stack[(pos+1)%stack.length]] + data[guy][stack[(pos+stack.length-1)%stack.length]];
		},0);
		return Math.max(best, sum);
	}
	for ( var dude of Object.keys(data).filter((d) => { return !stack.find((i)=> { return i === d; }); }) ) {
		stack.push(dude);
		best = Math.max(findBestHappyness(stack, best), best);
		stack.pop(dude);
	}
	return best;
}

var data = {};
function parseItem(str) {
	var parts = str.split(" happiness units by sitting next to ");
	var tgt = parts[1].split("").reverse().join("").substr(1).split("").reverse().join("");
	parts = parts[0].split(" would ");
	var src = parts[0];
	parts = parts[1].split(" ");
	var value = parseInt(parts[1])*(parts[0]==="lose"?-1:1);
	if ( !data[src] ) {
		data[src] = {};
	}
	data[src][tgt] = value;
}
document.body.innerText.split("\n").filter((a)=>{ return a !== ""; }).forEach(parseItem);

console.log("Answer 1", findBestHappyness([],0));
data.me = {};
for ( var dude of Object.keys(data) ) {
	data.me[dude] = 0;
	data[dude]["me"] = 0;
}
console.log("Answer 2", findBestHappyness([],0));