
function isValidPassPhrase(phrase) {
    var words = phrase.split(/\s+/);
    var map = new Map();
    for ( var word of words ) {
        var aword = word.split("");
        aword = aword.sort();
        if ( map.get(aword.join("")) ) {
            return false;
        }
        map.set(aword.join(""),1);
    }
    return true;
}

document.body.innerText.trim().split("\n").reduce((p,c) => { return p+= isValidPassPhrase(c) ? 1 : 0 },0);