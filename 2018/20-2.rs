use std::fs::File;
use std::io::prelude::*;

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
fn main () {

    let input = get_input("input-20", |s| s );

    let mut distances : HashMap<(i32,i32),u16> = HashMap::new();
    let mut stack : Vec<(i32,i32)> = Vec::new();
    let mut x = 0i32;
    let mut y = 0i32;
    distances.insert((0,0),0);
    

    for c in input[0].chars() {
        if c == '^' || c== '$' {
            //meh
        } else if c == '(' {
            stack.push((x,y));
        } else if c == ')' {
            let (x1,y1) = stack.pop().unwrap();
            x = x1;
            y = y1;
        } else if c == '|' {
            let (x1,y1) = *stack.last().unwrap();
            x = x1;
            y = y1;
        } else {
            let d = *distances.get(&(x,y)).unwrap();
            if c == 'N' {
                y+=1;
            } else if c == 'S' {
                y-=1;
            } else if c == 'E' {
                x+=1;
            } else {
                x-=1;
            }
            let nd = distances.entry((x,y)).or_insert(d+1);
            if *nd > d+1 {
                *nd = d+1;
            } 
        }
    }

    let mut rooms_cnt = 0;
    for v in distances.values() {
        if *v >= 1000 {
            rooms_cnt+=1;
        }
    }

    
    println!("nr rooms: {}", rooms_cnt);

}

