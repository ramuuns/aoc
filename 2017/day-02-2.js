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
                    if ( ( ints[i] / divisor ) < 2 ) {
                        // in this case if the current number / divisor < 2 that means
                        // that there's only one case where we can have a divisor/dividend === integer
                        // that's if there's a number that equals to the divisor in the array
                        // since the array is sorted then that number has to be the first number in there
                        // so if it's there we say we found it, otherwise we need to take the next candidate
                        // divisor anyway
                        if ( ints[0] === divisor ) {
                            dividend = ints[0];
                            found = true;
                        }
                        break;
                    }
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