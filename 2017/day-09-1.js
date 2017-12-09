
var input = document.body.innerText.trim().split("");

var score = 0;
var level = 0;

var is_escaping = false;
var is_in_garbage = false;

for ( var c of input ) {
    if ( is_in_garbage ) {
        if ( is_escaping ) {
            is_escaping = false;
            continue;
        }
        if ( c == '!' ) {
            is_escaping = true;
            continue;
        }
        if ( c == '>' ) {
            is_in_garbage = false;
            continue;
        }
        continue;
    }
    if ( c == '<' ) {
        is_in_garbage = true;
        continue;
    }
    if ( c == ',' ) {
        continue;
    }
    if ( c == '{' ) {
        level++;
        score+= level;
        continue;
    }
    if ( c == '}' ) {
        level--;
    }
}

console.log(score);