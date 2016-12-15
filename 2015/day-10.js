
function transform_say(input) {
	var res = [];
	var prev = "";
	var cnt = 0;
	for ( var chr of Array.from(input) ) {
		if ( chr !== prev ) {
			if ( prev !== "" ) {
				res.push(cnt);
				res.push(prev);
			}
			cnt = 1;
			prev = chr;
		} else {
			cnt++;
		}
	}
	res.push(cnt);
	res.push(prev);
	return res.join("");
}

var arr = [];
arr.length = 40;
arr.fill(1);
console.log("Answer1", arr.reduce((p)=>{ return transform_say(p); },"1113222113").length);
arr.length = 50;
arr.fill(1);
console.log("Answer2", arr.reduce((p)=>{ return transform_say(p); },"1113222113").length);