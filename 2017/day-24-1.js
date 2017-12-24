var input = document.body.innerText.trim();

/*input = `0/2
2/2
2/3
3/4
3/5
0/1
10/1
9/10`;*/

var parts = input.split("\n").reduce((map, item) => {
    var [l,r] = item.split("/").map( i => parseInt(i,10));
    var arrl = (map.get(l) || []);
    var arrr = (map.get(r) || []);
    var o = {r, l}
    arrl.push(o);
    arrr.push(o);
    map.set(l,arrl);
    map.set(r,arrr);
    return map;
}, new Map());

function bestBridge(key, sum, max_sum, bridge, used) {
    //console.log(key);
    var arr = parts.get(key) || [];


    for ( part of arr ) {
        var skey = [part.l,part.r].join("/");
        if ( used.has(skey) ) {
            continue;
        }
        var side = part.r == key ? "l" : "r";
        used.add(skey)
        max_sum = bestBridge(part[side], sum + key + part[side], max_sum, [...bridge,part],used);
        used.delete(skey);
    }
    if (max_sum < sum) {
        console.log(bridge, sum);
    }
    return Math.max(max_sum, sum);
}

console.log(bestBridge(0,0,0, [], new Set()));