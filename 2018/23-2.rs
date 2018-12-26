use std::fs::File;
use std::io::prelude::*;

use std::collections::BTreeSet; 

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
struct Circle {
    x:i64,
    y:i64,
    z:i64,
    r:i64,
}

impl Circle {
    fn new (x:i64,y:i64,z:i64,r:i64) -> Circle {
        Circle{x,y,z,r}
    }
}

fn distance(a:Circle, b:Circle) -> i64 {
    return (a.x - b.x).abs() + (a.y - b.y).abs() + (a.z - b.z).abs();
}

fn parse(s:String) -> Circle {
    let parts : Vec<&str> = s.split(">, r=").collect();
    let r = parts[1].parse::<i64>().unwrap();
    let front : Vec<&str> = parts[0].split("<").collect();
    let xyz : Vec<i64> = front[1].split(",").map(|i| i.parse::<i64>().unwrap() ).collect();
    return Circle::new(xyz[0],xyz[1],xyz[2],r);
}

fn main () {

    let input = get_input("input-23", parse );

    //let mut maxr_point = Point::new(0,0,0,0);

    
    let home = Circle::new(0,0,0,0);
    let mut minx = 0i64;
    let mut maxx = 0i64;
    let mut miny = 0i64;
    let mut maxy = 0i64;
    let mut minz = 0i64;
    let mut maxz = 0i64;

    let mut dist = 1i64;

    for circle in input.clone() {
        if circle.x < minx {
            minx = circle.x;
        }
        if circle.x > maxx {
            maxx = circle.x;
        }
        if circle.y < miny {
            miny = circle.y;
        }
        if circle.y > maxy {
            maxy = circle.y;
        }
        if circle.z < minz {
            minz = circle.z;
        }
        if circle.z > maxz {
            maxz = circle.z;
        }
    }

    while dist < maxx - minx {
        dist = dist *2;
    }

    let mut maxd = 0;

    loop {
        let mut maxcnt = 0;
        let mut best = Circle::new(0,0,0,0);
        let mut bestd = 0i64;
        let mut x = minx;
        loop {
            if x > maxx {
                break;
            }
            let mut y = miny;
            loop {
                if y > maxy {
                    break;
                }
                let mut z = minz;
                loop {
                    if z > maxz {
                        break;
                    }
                    let mut cnt = 0;
                    let p = Circle::new(x,y,z,0);
                    for circle in input.clone() {
                        let d = distance(p, circle);
                        if circle.r >= d {
                            cnt+=1;
                        }
                    }
                    if cnt > maxcnt {
                        maxcnt = cnt;
                        best = p;
                        bestd = distance(p,home);
                    } else if cnt == maxcnt {
                        let d = distance(p,home);
                        if d < bestd {
                            best = p;
                            bestd = d;
                        }
                    }
                    z+= dist;
                }
                y+= dist;
            }
            x+= dist;
        }
        if dist == 1 {
            println!("point: {}, {}, {}", best.x, best.y, best.z);
            println!("max count: {}", maxcnt);
            maxd = bestd;
            break;
        } else {
            
            minx = best.x - dist;
            maxx = best.x + dist;
            miny = best.y - dist;
            maxy = best.y + dist;
            minz = best.z - dist;
            maxz = best.z + dist;

            dist = dist / 2;
        }
    }

    println!("targt d: {}", maxd);

}

