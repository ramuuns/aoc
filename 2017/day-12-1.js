
var input = document.body.innerText.trim().split("\n");

var inputMap = new Map();

for ( line of input ) {
    var [pid, list_of_programs] = line.split(" <-> ");
    list_of_programs = list_of_programs.split(",").map( (i) => parseInt(i,10) );
    pid = parseInt(pid, 10);
    inputMap.set(pid,list_of_programs);
}

var setOfPrograms = new Set();
var process_queue = [0];
setOfPrograms.add(0);
do {
    var pid = process_queue.shift();
    var programs = inputMap.get(pid);
    for ( var p of programs ) {
        if ( setOfPrograms.has(p) ) {
            continue;
        }
        setOfPrograms.add(p);
        process_queue.push(p);
    }
} while (process_queue.length);

console.log(setOfPrograms.size);