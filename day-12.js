function findSum(json, total, exclude_red) {
	if ( typeof json === "number" ) {
		return total + json;
	}
	if ( typeof json === "string" ) {
		return total;
	}
	if ( typeof json === "object"  ) {
		if ( json.constructor === Array ) {
			return json.reduce((p, c) => { return findSum(c,p, exclude_red); }, total);
		} else {
			if ( exclude_red && Object.keys(json).concat(Object.keys(json).reduce((p,c) => { p.push(json[c]); return p; },[])).some((v) => { return v === "red" }) ) {
				return total;
			} else {
				return Object.keys(json).reduce((p,c) => { return findSum(json[c], p, exclude_red) }, total);
			}
		}
	}
}

var data = JSON.parse(document.body.innerText);

console.log("Answer1", findSum(data, 0, false));
console.log("Answer2", findSum(data, 0, true));