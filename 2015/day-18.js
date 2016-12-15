//game of life baby

var size = {
	w:100,
	h:100
};

var grid = []; 

function coord(x,y) {
	return y*size.w + x;
}

function i_to_coord(i) {
	return {
		x : i%size.h,
		y : Math.floor(i/size.w)
	};
}

function on_neighbours(node) {
	var x = node.x;
	var y = node.y;
	var ret = [];
	if ( x - 1 >= 0 ) {
		if ( y - 1 >= 0 ) {
			ret.push(grid[coord(x-1, y-1)]);
		}
		if ( y + 1 < size.h ) {
			ret.push(grid[coord(x-1, y+1)]);
		}
		ret.push(grid[coord(x-1, y)]);
	}
	if ( x + 1  < size.w ) {
		if ( y - 1 >= 0 ) {
			ret.push(grid[coord(x+1, y-1)]);
		}
		if ( y + 1 < size.h ) {
			ret.push(grid[coord(x+1, y+1)]);
		}
		ret.push(grid[coord(x+1, y)]);
	}
	if ( y - 1 >= 0 ) {
		ret.push(grid[coord(x, y-1)]);
	}
	if ( y + 1 < size.h ) {
		ret.push(grid[coord(x, y+1)]);
	}
	return ret.reduce((p,c) => { return p + (c.prev_state ? 1 : 0); }, 0);
}

function next_state(node, stuck) {
	if ( stuck && (node.x === 0 && node.y === 0 ||
		node.x === 0 && node.y === size.h - 1 ||
		node.x === size.w - 1 && node.y === 0 ||
		node.x === size.w - 1 && node.y === size.h - 1
	 ) ) {
		return true;
	}
	var cnt_on = on_neighbours(node);
	if ( node.prev_state ) { //it's currently on
		if ( cnt_on === 2 || cnt_on === 3 ) {
			return true;
		} else {
			return false;
		}
	} else {
		if ( cnt_on === 3 ) {
			return true;
		} else {
			return false;
		}
	}
}

function tick(stuck) {
	for ( var node of grid ) {
		node.next_state = next_state(node, stuck);
	}
	for ( var node of grid ) {
		node.prev_state = node.next_state;
	}
}

grid = Array.from(document.body.innerText.trim())
			.filter((i) => { return i === "." || i === "#"; })
			.map((state, i) => {
				var coords = i_to_coord(i);
				return {
					x : coords.x,
					y : coords.y,
					prev_state : state === "#" 
				}
			});

var steps = 100;
do {
	tick(false);
} while ( --steps );

console.log("Answer1", grid.reduce((p,c) => { return p + (c.prev_state ? 1 : 0); }, 0));

grid = Array.from(document.body.innerText.trim())
			.filter((i) => { return i === "." || i === "#"; })
			.map((state, i) => {
				var coords = i_to_coord(i);
				return {
					x : coords.x,
					y : coords.y,
					prev_state : state === "#" 
				}
			});

var steps = 100;
do {
	tick(true);
} while ( --steps );

console.log("Answer2", grid.reduce((p,c) => { return p + (c.prev_state ? 1 : 0); }, 0));