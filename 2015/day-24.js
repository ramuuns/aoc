var input = `
1
3
5
11
13
17
19
23
29
31
41
43
47
53
59
61
67
71
73
79
83
89
97
101
103
107
109
113
`;
/*
var input = `
1
2
3
4
5
7
8
9
10
11
`;*/ 

const parsedInput = input.split("\n").filter(l => l).map(n => parseInt(n,10));
const target = parsedInput.reduce((c,a) => c+a, 0)/3;

function distributions(arr, tgt) {
    let ret = [];
    let recurse_gather = function(i, _arr) {
        for ( let k = i + 1; k < arr.length; k++ ) {
            if ( [..._arr, arr[k]].sum() < tgt ) {
                recurse_gather(k, [..._arr, arr[k] ]);
            } else if ( [..._arr, arr[k]].sum() === tgt ) { 
                ret.push([..._arr, arr[k]]);
            }
        }
    }
    for ( let i = 0; i < arr.length; i++ ) {
        recurse_gather(i,[ arr[i] ]);
    }
    return ret;
}

Array.prototype.sum = function() {
    let s = 0;
    for ( i = 0; i < this.length; i++ ) {
        s+= this[i];
    }
    return s;
}

Array.prototype.qe = function() {
    let qe = 1;
    for ( i = 0; i < this.length; i++ ) {
        qe *= this[i];
    }
    return qe;
}

Array.prototype.isWorse = function(b) {
    return this.length == 0 || this.length > b.length || (this.length == b.length && this.qe() > b.qe()); 
}

Array.prototype.intersectIsEmpty = function(b) {
    for ( it of b ) {
        if ( this.includes(it) ) {
            return false;
        }
    }
    return true;
}

let candidates = distributions(parsedInput,target).sort((a, b) => a.length - b.length);

//console.log(candidates);

let best = [];

for ( let i = 0; i < candidates.length; i++ ) {
    if ( best.isWorse(candidates[i]) ) {
        let found = false;
        for ( let k = i+1; k < candidates.length; k++ ) {
            for ( let j = k+1; j < candidates.length; j++ ) {
                if ( candidates[i].length + candidates[k].length + candidates[j].length === parsedInput.length &&
                     candidates[i].intersectIsEmpty(candidates[k]) &&
                     candidates[i].intersectIsEmpty(candidates[j]) &&
                     candidates[j].intersectIsEmpty(candidates[k])
                ) {
                    best = candidates[i];
                    found = true;
                    break;
                }
            }
            if ( found ) {
                break;
            }
        }
    }
    if ( best.length > 0 && candidates[i].length > best.length ){
        break;
    }
}

console.log("part 1:", best.qe());

best = [];

Array.prototype.complement = function() {
    let r = [];
    for ( let i = 0; i < parsedInput.length; i++ ) {
        if ( !this.includes(parsedInput[i]) ) {
            r.push(parsedInput[i]);
        }
    }
    return r;
}

const target2 = parsedInput.reduce((c,a) => c+a, 0)/4;
//candidates = distributions(parsedInput,target2).sort((a, b) => a.length - b.length);
//console.log(candidates);

let dist2 = distributions(parsedInput,target2*2).sort((a, b) => a.length - b.length);
console.log("got dist2");

let seen = new Set();
best = [];
for ( let i = 0; i < dist2.length; i++ ) {
    if ( seen.has(dist2[i].join(",")) ) {
        continue;
    }
    seen.add(dist2[i].complement().join(","));
    let d1 = distributions( dist2[i], target2 );
    if ( d1.length ) {
        let d2 = distributions( dist2[i].complement(), target2 );
        if ( d2.length ) {
            for ( let d of [...d1, ...d2] ) {
                if ( !seen.has(d.join(",")) ) {
                    seen.add(d.join(","));
                    if ( best.isWorse(d) ) {
                        console.log("new candidate", d);
                        best = d;
                    }
                }
            }
        }
    }
}

console.log("newalog who dis", best.qe());

//best = [];
/*
//console.log(distributions(parsedInput,target2*2).sort((a, b) => a.length - b.length));
//console.log(distributions(parsedInput,target2*2).length);
for ( let i = 0; i < candidates.length; i++ ) {
    if ( best.isWorse(candidates[i]) ) {
        let found = false;
        for ( let k = i+1; k < candidates.length; k++ ) {
            for ( let j = k+1; j < candidates.length; j++ ) {
                for ( let l = j +1; l < candidates.length; l++ ) {
                    if ( candidates[i].length + candidates[k].length + candidates[j].length + candidates[l].length === parsedInput.length &&
                         candidates[i].intersectIsEmpty(candidates[k]) &&
                         candidates[i].intersectIsEmpty(candidates[j]) &&
                         candidates[i].intersectIsEmpty(candidates[l]) &&
                         candidates[j].intersectIsEmpty(candidates[k]) &&
                         candidates[j].intersectIsEmpty(candidates[l]) &&
                         candidates[k].intersectIsEmpty(candidates[l])
                    ) {
                        best = candidates[i];
                        found = true;
                        break;
                    }
                }
                if ( found ) {
                    break;
                }
            }
            if ( found ) {
                break;
            }
        }
    }
    if ( best.length > 0 && candidates[i].length > best.length ){
        break;
    }
}

console.log("part 2: ", best.qe());
*/
