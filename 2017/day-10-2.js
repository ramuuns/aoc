var data = [];
var data_size = 256;
for ( var i = 0; i < data_size; i++ ) { data[i] = i; }

var input =  document.body.innerText.trim("");

input = input.split("").map((i) => i.charCodeAt(0));
input = input.concat([17,31,73,47,23]);

var skip = 0;
var head = 0;

for (var r = 0; r < 64; r++ ) {

    input.forEach((l) => {
        for ( var j = (head + l - 1), i = head; i < j; i++, j-- ) {
            var t = data[j%data_size];
            data[j%data_size] = data[i%data_size];
            data[i%data_size] = t;
        }
        head = (head + l + skip)%data_size;
        skip++;
        //console.log(data, head, skip);
    });

}

var dense_hash = [];
for (var i =0; i < 16; i++ ) {
    var n  = data[i*16+0] 
            ^ data[i*16+1]
            ^ data[i*16+2]
            ^ data[i*16+3]
            ^ data[i*16+4]
            ^ data[i*16+5]
            ^ data[i*16+6]
            ^ data[i*16+7]
            ^ data[i*16+8]
            ^ data[i*16+9]
            ^ data[i*16+10]
            ^ data[i*16+11]
            ^ data[i*16+12]
            ^ data[i*16+13]
            ^ data[i*16+14]
            ^ data[i*16+15];
    dense_hash[i] = n > 15 ? n.toString(16) : ("0" + n.toString(16));
}

console.log(dense_hash.join(""));

