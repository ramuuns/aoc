use std::fs::File;
use std::io::prelude::*;

//use std::collections::HashMap; 

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

#[derive(Clone, Copy)]
struct Point {
    x:i64,
    y:i64,
    z:i64,
    r:i64,
}

impl Point {
    fn new (x:i64,y:i64,z:i64,r:i64) -> Point {
        Point{x,y,z,r}
    }
}

fn distance(a:Point, b:Point) -> i64 {
    return (a.x - b.x).abs() + (a.y - b.y).abs() + (a.z - b.z).abs();
}

fn parse(s:String) -> Point {
    let parts : Vec<&str> = s.split(">, r=").collect();
    let r = parts[1].parse::<i64>().unwrap();
    let front : Vec<&str> = parts[0].split("<").collect();
    let xyz : Vec<i64> = front[1].split(",").map(|i| i.parse::<i64>().unwrap() ).collect();
    return Point::new(xyz[0],xyz[1],xyz[2],r);
}

fn main () {

    let input = get_input("input-23", parse );

    let mut maxr_point = Point::new(0,0,0,0);

    for point in input.clone() {
        if point.r > maxr_point.r {
            maxr_point = point;
        }
    }

    let mut cnt = 0;

    for point in input {
        if distance(point,maxr_point) <= maxr_point.r {
            cnt+=1;
        }
    }
    
    println!("nr rooms: {}", cnt);

}

