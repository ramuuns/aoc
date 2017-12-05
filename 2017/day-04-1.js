
function isValidPassPhrase(phrase) {
    var words = phrase.split(/\s+/);
    var map = new Map();
    for ( var word of words ) {
        if ( map.get(word) ) {
            return false;
        }
        map.set(word,1);
    }
    return true;
}

document.body.innerText.trim().split("\n").reduce((p,c) => { return p+= isValidPassPhrase(c) ? 1 : 0 },0);