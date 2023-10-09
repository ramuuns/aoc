use std::fs::File;
use std::io::prelude::*;

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

    let mut points_in_region = 0;

    for y in 0..maxy-miny+1 {
        for x in 0..maxx-minx+1 {
            let mut sum_this_point = 0;
            for i in 0..input.len() {
                let pointx = input[i].x-minx;
                let pointy = input[i].y-miny;
                let d = manhattan_distance(x,y, pointx,pointy);
                sum_this_point += d;
                if sum_this_point > 10000 {
                    break;
                }
            }
            if sum_this_point < 10000 {
                points_in_region += 1;
            }
        }
    }

    println!("The result: {}", points_in_region );
}

/*
   y
   0 00000.22
   1 00000.22
   2 00033422
   3 00333422
   4 ..333442
   5 11.34444
   6 111.4444
   7 111.4445
   8 111.4455
     01234567 x 
     
     
     */