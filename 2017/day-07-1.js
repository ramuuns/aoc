var input = document.body.innerText.trim().split("\n");

input = input.map( line => {
    var [name_and_weight, list_of_children] = line.split(" -> ");
    var [name, weight] = name_and_weight.split(" (");
    var children = [];
    if ( list_of_children ) {
        children = list_of_children.split(", ");
    }
    return {
        name,
        weight : parseInt(weight,10),
        children
    };
});

var programs = new Map();

input.forEach( (p) => { programs.set(p.name,1);  } );

input.forEach( (p) => {
    p.children.forEach( (n) => { 
        programs.delete(n);
    } );
} );

console.log(Array.from(programs.keys())[0]);

