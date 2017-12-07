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

var root_program = Array.from(programs.keys())[0];

input.forEach( (p) => { programs.set(p.name,p);  } );

var tree = buildTree(root_program);

function buildTree ( root_program ) {
    var p = programs.get(root_program);

    return {
        name : root_program,
        weight : p.weight,
        children : p.children.map(buildTree)
    }
}

var bad_found = false;

findWrongWeight(tree);

function findWrongWeight(tree) {
    var child_weights = tree.children.map(findWrongWeight);
    var sum = 0;
    var counts_of_weights = new Map();
    child_weights.forEach((weight, index) => {
        sum+= weight;
        var i = counts_of_weights.get(weight) || 0;
        counts_of_weights.set(weight,i+1);
    });
    if ( ! bad_found ) {
        var distinct_weights = Array.from(counts_of_weights.keys());
        if ( distinct_weights.length > 1 ) {
            var good_weight;
            var bad_weight;
            
            distinct_weights.forEach((w) => {
                if ( counts_of_weights.get(w) === 1 ) {
                    bad_weight = w;
                } else {
                    good_weight = w;
                }
            } );
            
            var delta = good_weight - bad_weight;
            var index = child_weights.indexOf(bad_weight);
            
            console.log("Bad weight is " + tree.children[index].weight + ". It should be " + ( tree.children[index].weight+ delta ) + ". The name of the bad node is " + tree.children[index].name ) ;
            bad_found = true;
        }
    }
    
    return tree.weight + sum;
}