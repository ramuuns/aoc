
var data = {
	Frosting : {
		capacity : 4,
		durability : -2,
		flavor : 0,
		texture : 0,
		calories : 5
	},
	Candy: {
		capacity: 0, durability: 5, flavor: -1, texture: 0, calories: 8
	},
	Butterscotch: { 
		capacity: -1, durability: 0, flavor: 5, texture: 0, calories: 6 
	},
	Sugar: {
		capacity: 0, durability: 0, flavor: -2, texture: 2, calories: 1
	}
};

var properties = ["capacity","durability","flavor","texture"];

function score(d) {
	return properties.map(
		(p) => { 
			return Math.max(Object.keys(d).map(
				(k) => { 
					return d[k]*data[k][p]; 
				}).reduce(
				(pv,c) => { 
					return pv + c; 
				}, 0),0); 
			}).reduce((pv, c) => { return pv * c; }, 1);
}

function cscore(d) {
	return Object.keys(d).map((k) => { return data[k].calories * d[k]; } ).reduce((pv, c) => { return pv + c; }, 0);
}


var max = 0;
for ( var i = 0; i <= 100; i++ ) {
	for ( var j = 0; j <= 100 - i; j++ ) {
		for ( var k = 0; k <= 100 - (i+j); k++ ) {
			for ( var l = 1; l <= 100 - (i+j+k); l++ ) {
				if ( i+j+k+l === 100 ) {
					var m = score({Frosting: i, Candy: j, Butterscotch: k, Sugar : l});
					if ( m > max) {
						max = m;
					}
				}
			}
		}
	}
}
console.log("Solution1: " + max);

var max = 0;
for ( var i = 0; i <= 100; i++ ) {
	for ( var j = 0; j <= 100 - i; j++ ) {
		for ( var k = 0; k <= 100 - (i+j); k++ ) {
			for ( var l = 1; l <= 100 - (i+j+k); l++ ) {
				if ( i+j+k+l === 100 && cscore({Frosting: i, Candy: j, Butterscotch: k, Sugar : l}) === 500 ) {
					var m = score({Frosting: i, Candy: j, Butterscotch: k, Sugar : l});
					if ( m > max) {
						max = m;
					}
				}
			}
		}
	}
}

console.log("Solution2: " + max);