
var input = document.body.innerText.trim().split("\n");

var inputMap = new Map();

for ( line of input ) {
    var [pid, list_of_programs] = line.split(" <-> ");
    list_of_programs = list_of_programs.split(",").map( (i) => parseInt(i,10) );
    pid = parseInt(pid, 10);
    inputMap.set(pid,list_of_programs);
}

var groups = 0;

do {

    var first_pid = Array.from(inputMap.keys())[0];

    var setOfPrograms = new Set();
    var process_queue = [first_pid];
    setOfPrograms.add(first_pid);
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

    groups++;

    setOfPrograms.forEach((p) => {
        inputMap.delete(p);
    });

} while ( inputMap.size );

console.log(groups);