use std::fs::File;
use std::io::prelude::*;
//use std::collections::VecDeque;
use std::collections::HashSet;
use std::collections::HashMap;

const NEW_LINE : u8 = 10;

/*
    Read a file given by a filename and parse it to a vector of
    whatever we need given a line_transform function
*/
fn get_input<T>(filename : &str, line_transform : fn(String) -> T) -> Vec<T> {
    let mut file = File::open(filename).expect("Cannot open file");
    let mut ret : Vec<T> = Vec::new();
    let mut vec_one_line = Vec::new();
    loop {
        let mut buf = [0;512];
        let res = file.read(&mut buf);
        match res {
            Ok(n) => {
                if n == 0 {
                    // If the file doesn't end on a new line, we'll have stuff
                    // in our "current line" vector, thus we need to parse it as well
                    if vec_one_line.len() > 0 {
                        let s = String::from_utf8(vec_one_line.clone()).unwrap();
                        ret.push(line_transform(s));
                    }
                    break;
                }

                for b in buf.iter() {
                    if *b == NEW_LINE {
                        let s = String::from_utf8(vec_one_line.clone()).unwrap();
                        vec_one_line.clear();
                        ret.push(line_transform(s));
                    } else {
                        // deal with null bytes, that are in the buffer ('cause it's fixed size), when
                        // we're at the end of the file. Since we're reading a text file those shouldn't be in
                        // legitimate places, so they're safe to ignore
                        if *b > 0 {
                            vec_one_line.push(*b);
                        }
                    }
                }
            }
            _ => {
                break;
            }
        }
    }
    return ret;

}

fn manhattan_distance (x: usize, y :usize, ox: usize, oy: usize) -> usize {
    let xdiff = if x > ox { x - ox } else { ox - x };
    let ydiff = if y > oy { y - oy } else { oy - y };
    return xdiff + ydiff;
}

#[derive (Clone, Copy)]
struct Point {
    x : usize,
    y : usize,
}

fn line_to_coords(s :String ) -> Point {
    let coords : Vec<usize> = s.split(", ").map(|cs| cs.parse::<usize>().unwrap()).collect();
    return Point{ x: coords[0], y: coords[1] };
}

const FAKEID : usize = 1024;

fn main () {
    let input = get_input("input-6", line_to_coords);
    
    let mut minx = 1000usize;
    let mut maxx = 0usize;
    let mut miny = 1000usize;
    let mut maxy = 0usize;
    for point in &input {
        if point.x < minx {
            minx = point.x;
        }
        if point.x > maxx {
            maxx = point.x;
        }
        if point.y < miny {
            miny = point.y;
        }
        if point.y > maxy {
            maxy = point.y;
        }
    }

    let mut infinite = HashSet::new();
    let mut sizes_by_id : HashMap<usize,usize> = HashMap::new();

    for y in 0..maxy+1 {
        for x in 0..maxx+1 {
            let mut id = FAKEID;
            let mut min_d = 100000;
            for i in 0..input.len() {
                let pointx = input[i].x;
                let pointy = input[i].y;
                let d = manhattan_distance(x,y, pointx,pointy);
                if d < min_d {
                    min_d = d;
                    id = i;
                } else if d == min_d {
                    id = FAKEID;
                }
            }

            if id == FAKEID {
                continue;
            }
            
            if x == minx || y == miny || x == maxx || y == maxy {
                infinite.insert(id);
                sizes_by_id.remove(&id);
                continue;
            } else {
                if !infinite.contains(&id) {
                    let cnt = sizes_by_id.entry(id).or_insert(0);
                    *cnt += 1;
                }
            }

        }
    }

    let mut max = 0;
    for size in sizes_by_id.values() {
        if *size > max {
            max = *size;
        }
    }


    println!("The result: {}", max );
}
