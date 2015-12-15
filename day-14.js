//this runs by copy pasting this stuff in the console of the input data page
var data = document.body.innerText.split("\n").filter((i)=>{ return i !== "";}).map((str) => {
	var parts = str.split(" ");
	return {
		name : parts[0],
		spd : parseInt(parts[3]),
		spd_time : parseInt(parts[6]),
		rst_time : parseInt(parts[13]),
		dst: 0,
		action: "spd",
		rem_time : parseInt(parts[6]),
		pnts : 0
	};
});


function tick() {
	for ( var dude of data ) {
		if ( dude.action === "spd" ) {
			dude.dst += dude.spd; 
		}
		dude.rem_time--;
		if ( dude.rem_time === 0 ) {
			dude.rem_time = dude.action === "spd" ? dude.rst_time : dude.spd_time;
			dude.action = dude.action === "spd" ? "rst" : "spd";
		}
	}
	var idx = [], max = 0;
	for ( var i = 0; i < data.length; i++ ) {
		(function(i){
			if ( data[i].dst >= max ) {
				if ( data[i].dst === max ) {
					idx.push(i);
				} else {
					idx = [i];
				}
				max = data[i].dst;
			}
		})(i);
	}
	for ( var ii of idx ) {
		data[ii].pnts++;
	}
}

for ( var i = 0; i < 2503; i++ ) {
	tick();
}

console.log("Answer1 ", data.reduce((p,c) => { return Math.max(c.dst, p); },0));
console.log("Answer2 ", data.reduce((p,c) => { return Math.max(c.pnts, p); },0));