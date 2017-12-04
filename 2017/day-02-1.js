// execute inside the console of the input page

console.log(
    document.body.innerText
        .trim()
        .split("\n")
        .map(r => { 
            var ints = r.split("\t").map(i => parseInt(i,10) ); 
            var min = Math.min.apply(null,ints); 
            var max = Math.max.apply(null,ints); 
            return max - min; 
        }).reduce((p,c) => p+c, 0)
    );