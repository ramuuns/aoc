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

struct Point {
    x: i32,
    y: i32,
    dx : i32,
    dy : i32,
}

fn line_to_points(s :String ) -> Point {
    let parts : Vec<String> = s.split("> ").map(| ss | ss.split("=<").skip(1).take(1).last().unwrap().to_string() ).collect();
    println!("getting pos");
    let pos : Vec<i32> = parts[0].split(", ").map(|i| i.trim().parse::<i32>().unwrap() ).collect();
    let d : Vec<String> = parts[1].split(", ").map(|ss| ss.to_string() ).collect();
    let mut dy = d[1].clone();
    dy = dy.chars().skip(0).take(dy.len() - 1).collect();
    println!("getting delta: dx:'{}' dy:'{}'", d[0], dy );
    return Point {
        x : pos[0],
        y : pos[1],
        dx : d[0].trim().parse::<i32>().unwrap(),
        dy : dy.trim().parse::<i32>().unwrap()
    };
}

fn main () {
    let input = get_input("input-10", line_to_points);
    let mut candidate_iter = 0;
    let mut min_dy = 100000;
    for i in 10000..12000 {
        let mut miny = 11111111;
        let mut maxy = -1111111;

        for p in &input {
            let y = p.y + p.dy * i;
            if y < miny {
                miny = y;
            }
            if y > maxy {
                maxy = y;
            }
            
        }
        if (maxy - miny) < min_dy {
            min_dy = maxy - miny;
            candidate_iter = i;
        }
    }

    for i in candidate_iter..candidate_iter+1 {
        let mut points : BTreeSet<(i32, i32)> = BTreeSet::new();
        let mut minx = 11111111;
        
        for p in &input {
            let x = p.x + p.dx * i;
            let y = p.y + p.dy * i;
            points.insert((y , x ));
            if x < minx {
                minx = x;
            }
        }

        let mut prevy = -1111111;
        let mut prevx = minx;
        println!("\n-------------------------------------------------------------------------------------\n");
        for (y,x) in points {
            if prevy < y {
                if prevy != -1111111 {
                    for _ in prevy..y {
                        println!("");
                    }
                } 
                prevy = y;
                for _ in minx..x-1 {
                    print!(" ");
                }
                print!("#");
                prevx = x;
            } else {
                for _ in prevx..x-1 {
                    print!(" ");
                }
                print!("#");
                prevx = x;
            }
        }
    }
    
    println!("candidate_iter: {}", candidate_iter);

}

