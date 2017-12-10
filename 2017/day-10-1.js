var data = [];
var data_size = 256;
for ( var i = 0; i < data_size; i++ ) { data[i] = i; }

var input = document.body.innerText.trim("");

input = input.split(/,\s?/).map((i) => parseInt(i,10));

var skip = 0;
var head = 0;

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

console.log(data[0]*data[1]);
