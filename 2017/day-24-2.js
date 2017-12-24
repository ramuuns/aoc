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

function bestBridge(key, sum, max_sum, bridge, used, len, max_len) {
    //console.log(key);
    var arr = parts.get(key) || [];


    for ( part of arr ) {
        var skey = [part.l,part.r].join("/");
        if ( used.has(skey) ) {
            continue;
        }
        var side = part.r == key ? "l" : "r";
        used.add(skey);
        var m =  bestBridge(part[side], sum + key + part[side], max_sum, [...bridge,part],used, len+1, max_len);
        max_sum = m[0];
        max_len = m[1];
        used.delete(skey);
    }
    if (max_len < len) {
        console.log(bridge, sum, len, max_len);
        return [sum, len];
    } else if ( max_len == len && max_sum < sum ) {
        console.log(bridge, sum, len, max_len);
        return [sum,len];
    } else {
        return [max_sum,max_len];
    }
}

console.log(bestBridge(0,0,0, [], new Set(), 0,0));