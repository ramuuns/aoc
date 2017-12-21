

function rotate( arr ) {
    arr = transpose(arr);
    arr = flip(arr);
    return arr;
}

function flip (arr) {
    for ( var j = 0, l = arr.length; j<l; j++ ) {
        arr[j] = arr[j].reverse();
    }
    return arr;
}

function transpose(arr) {
    for ( var i = 0, l = arr.length; i<l; i++ ) {
        for ( var j = i, k = arr[i].length; j<k; j++) {
            var t = arr[i][j];
            arr[i][j] = arr[j][i];
            arr[j][i] = t;
        }
    }
    return arr;
}

function mAsString(arr) {
    return arr.reduce((p,c) => { return p + c.join(""); },"");
}

function subArray(arr, i, j, size) {
    var ret = new Array(size);
    for ( var k = 0; k < size; k++ ) {
        ret[k] = new Array(size);
        for (var l = 0; l < size; l++) {
            ret[k][l] = arr[i+k][j+l];
        }
    }
    return ret;
}

var input = document.body.innerText.trim();

//input = `../.# => ##./#../...
//.#./..#/### => #..#/..../..../#..#`;

var rules = new Map();

input.split("\n").forEach((line) => {
    var [ina, out] = line.split(" => ");
    out = out.split("/").map(l => l.split(""));
    ina = ina.split("/").map(l => l.split(""));
    rules.set(mAsString(ina), out);
    for ( var i = 0; i <3; i++ ) {
        ina = rotate(ina);
        rules.set(mAsString(ina), out);
    }
    ina = flip(ina);
    rules.set(mAsString(ina), out);
    for ( var i = 0; i <3; i++ ) {
        ina = rotate(ina);
        rules.set(mAsString(ina), out);
    }
});

var image = `.#.
..#
###`.split("\n").map( l => l.split(""));

for ( var it =0 ; it < 5; it++ ) {
    var new_image;

    if ( image.length % 2 === 0 ) {
        var new_size = image.length + image.length/2;
        new_image = new Array(new_size);
        for ( var i = 0; i < new_image.length; i++ ) {
            new_image[i] = new Array(new_size);
        }
        for ( var i = 0; i < image.length / 2; i++ ) {
            for ( var j = 0; j < image.length / 2; j++ ) {
                var sub_arr = subArray(image,i*2,j*2,2);
                var new_sub = rules.get(mAsString(sub_arr));
                for ( var k = 0; k < 3; k++ ) {
                    for ( var l = 0; l < 3; l++ ) {
                        new_image[i*3+k][j*3+l] = new_sub[k][l];
                    }
                }
            }
        }

    } else if ( image.length % 3 === 0 ) {
        var new_size = image.length + image.length/3;
        new_image = new Array(new_size);
        for ( var i = 0; i < new_image.length; i++ ) {
            new_image[i] = new Array(new_size);
        }
        for ( var i = 0; i < image.length / 3; i++ ) {
            for ( var j = 0; j < image.length / 3; j++ ) {
                var sub_arr = subArray(image,i*3,j*3,3);
                var new_sub = rules.get(mAsString(sub_arr));
                for ( var k = 0; k < 4; k++ ) {
                    for ( var l = 0; l < 4; l++ ) {
                        new_image[i*4+k][j*4+l] = new_sub[k][l];
                    }
                }
            }
        }
    }

    image = new_image;

}

console.log(image.reduce( (p,c) => { return p + c.reduce((pp,cc) => { return pp + (cc == "#" ? 1 : 0); }, 0); },0 ));