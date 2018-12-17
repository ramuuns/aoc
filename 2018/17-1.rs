use std::fs::File;
use std::io::prelude::*;
use std::collections::HashMap;
use std::collections::HashSet;

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



fn main () {
    let input = get_input("input-17", |s| s );

    let mut clay: HashSet<(usize,usize)> = HashSet::new();
    let mut miny = 1000000usize;
    let mut maxy = 0usize;
    let mut minx = 1000000usize;
    let mut maxx = 0usize;


    for line in input {
        println!("parsing line: {}", line);
        let parts : Vec<&str> = line.split(", ").collect();
        let mut x;
        let mut y;
        if parts[0].starts_with("x=") {
            x = parts[0].split("=").last().unwrap().parse::<usize>().unwrap();
            let yparts : Vec<usize> = parts[1].split("=").last().unwrap().split("..").map(|s| s.parse::<usize>().unwrap() ).collect();
            for y in yparts[0]..=yparts[1] {
                clay.insert((y,x));
                if y < miny {
                    miny = y;
                }
                if y > maxy {
                    maxy = y;
                }
            }
            if x < minx {
                minx = x;
            }
            if x > maxx {
                maxx = x;
            }
        } else {
            y = parts[0].split("=").last().unwrap().parse::<usize>().unwrap();
            let xparts : Vec<usize> = parts[1].split("=").last().unwrap().split("..").map(|s| s.parse::<usize>().unwrap() ).collect();
            for x in xparts[0]..=xparts[1] {
                clay.insert((y,x));
                if x < minx {
                    minx = x;
                }
                if x > maxx {
                    maxx = x;
                }
            }
            if y < miny {
                miny = y;
            }
            if y > maxy {
                maxy = y;
            }
        }
    }

    println!("minx, maxx:  {},{}", minx,maxx);
    println!("miny, maxy:  {},{}", miny,maxy);

}

