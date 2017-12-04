// execute inside the console of the input page

console.log(
    document.body.innerText
        .trim()
        .split("\n")
        .map(r => { 
            var ints = r.split("\t").map(i => parseInt(i,10) );
            ints = ints.sort(function(a,b){ return a-b; });
            var found = false;
            var divisor;
            var dividend;
            do {
                divisor = ints.shift();
                for ( var i = ints.length - 1; i >= 0; i-- ) {
                    if ( ints[i] % divisor === 0 ) {
                        found = true;
                        dividend = ints[i];
                        break;
                    }
                }
            } while (!found && ints.length);
            if ( dividend && divisor ) {
                return dividend/divisor;
            }
            return 0;
        }).reduce((p,c) => p+c, 0)
    );