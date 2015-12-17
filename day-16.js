
var tgtsue = {
	children: 3,
	cats: 7,
	samoyeds: 2,
	pomeranians: 3,
	akitas: 0,
	vizslas: 0,
	goldfish: 5,
	trees: 3,
	cars: 2,
	perfumes: 1,
};

var candidate_sues = document.body.innerText.trim().split("\n").map((str, i) => {
	var props = str.substr(str.indexOf(": ")+2).split(", ").map((p) => { return p.split(": "); }).reduce((obj, curr) => {
		if ( curr[0] ) {
			obj[curr[0]] = parseInt(curr[1]);
		}
		return obj;
	}, {});
	return {
		idx : i+1,
		props
	};
});

var sue = candidate_sues.find((p) => {
	return Object.keys(p.props).reduce((pv, k) => {
		return pv && p.props[k] === tgtsue[k];
	}, true);
});

console.log("Answer1:", sue.idx);

var gtprops = {
	"cats" : true,
	"trees" : true
};

var ltprops = {
	"pomeranians" : true,
	"goldfish" : true
};

sue = candidate_sues.find((p) => {
	return Object.keys(p.props).reduce((pv, k) => {
		return pv && (gtprops[k] ? p.props[k] > tgtsue[k] : (ltprops[k] ? (p.props[k] < tgtsue[k]) : (p.props[k] === tgtsue[k])));
	}, true);
});

console.log("Answer2:", sue.idx);