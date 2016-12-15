
var letters = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'];
var letters_map = new Map();
letters.forEach( (l,i) => {letters_map.set(l,i)});
var blacklisted_letters = {'i':true,'l':true,'o':true};

function next_string(str) { 
	var arr = Array.from(str); 
	arr.reverse(); 
	var i = 0;
	var inc_next = true;
	while ( inc_next ) {
		do {
			arr[i] = letters[(letters_map.get(arr[i])+1)%letters.length];
		} while ( blacklisted_letters[arr[i]] );
		if ( arr[i] === letters[0] ) {
			i++;
		} else {
			inc_next = false;
		}
	}
	return arr.reverse().join(""); 
}

function isValidPassword(str) {
	var pstr = ["","",""];
	var pair_str = ["",""];
	var first_valid = false;
	var num_pairs = 0;
	for ( var c of Array.from(str) ) {
		pstr.shift();
		pstr.push(c);
		pair_str.shift();
		pair_str.push(c);
		if ( letters_map.get(pstr[0]) !== void 0 ) {
			var ochar = letters_map.get(pstr[0]);
			if ( pstr[1] === letters[ochar+1] && pstr[2] === letters[ochar+2] ) {
				first_valid = true;
			}
		}
		if ( pair_str[0] === pair_str[1] ) {
			num_pairs++;
			pair_str[1] = "";
		}
	}
	if ( !first_valid || num_pairs < 2 ) {
		return false;
	}
	if ( str.match(/(i|o|l)/g) ) {
		return false;
	}
	return true;
}

var curr_password = "hxbxwxba";
do {
	curr_password = next_string(curr_password);
} while ( !isValidPassword(curr_password) );
console.log("Answer1",curr_password);

do {
	curr_password = next_string(curr_password);
} while ( !isValidPassword(curr_password) );
console.log("Answer2",curr_password);