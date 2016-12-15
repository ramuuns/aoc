var factors = [];

//stole this thing from stackoverflow - is pretty neat

function fill_sieve(n){
    for( var i = 1; i <= n; ++i ) {
        if (i & 1)
            factors[i] = [i, 1];
        else
            factors[i] = [2, i>>1];
    }
    for( var j = 3, j2 = 9; j2 <= n; ) {
        if (factors[j][1] == 1) {
            i = j;
            var ij = j2;
            while (ij <= n) {
                factors[ij] = [j, i];
                ++i;
                ij += j;
            }
        }
        j2 += (j + 1) << 2;
        j += 2;
    }
}

fill_sieve(10000000);

function rec_set(data) {
	var s = new Set();
	for (var i = 0; i < data.length; i++) {
		var c = data[i];
		for ( var it of Array.from(s) ) {
			s.add(c*it);
		}
		s.add(c);
	}
	return s;
}

function sum_factors( n, convert )
{
	var on = n;
	var res = [];
	do {
        res.push(factors[n][0]);
        n = factors[n][1];
    } while (n != 1);
	if ( !convert ) {
		//the sum of all factors can be calculated like this:
		//http://mathforum.org/library/drmath/view/71550.html
		//console.log(res);
		return res.sort((a,b) => a-b).reduce((p,c) => { 
			if ( p.length && c === p[p.length-1][0] ) {
				p[p.length-1][1]++;
			} else {
				p.push([c, 1]);
			}
			return p;
		}, []).reduce((p,c) => {
			var s = 1;
			for ( var j = 0; j < c[1]; j++ ) {
				s += Math.pow(c[0],j+1);
			}
			return p*s;
		}, 1);
	} else {
		//in this case we need the data to be in a different format
		//so that we can remove stuff from it with ease
		//so from e.g [2,2,3] to [1,2,3,4,6,12]
		var s = rec_set(res);
		s.add(1);
		var ss = Array.from(s);
		//console.log(ss);
		return ss.filter((i) => i >= on/50).reduce((p,c) => p+c,0);
	}
}

var i = 36;
do {
	i++;
	var sum1 = sum_factors(i);
} while ( sum1 *10 < 33100000 );
console.log("Answer1", i);


var i = 0;
do {
	i++;
	var sum = sum_factors(i, true);
} while ( sum *11 < 33100000 );
console.log("Answer2", i);
