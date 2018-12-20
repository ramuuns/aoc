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

fn main () {

    let input = get_input("input-20", |s| s );

    let mut maxlen = 0;
    let mut len = 0;
    let mut stack : Vec<u16> = Vec::new();
    let mut empty = false;
    let mut actual_max = 0;

    for c in input[0].chars() {
        if c == '^' || c== '$' {
            //meh
        } else if c == '(' {
            stack.push(len);
        } else if c == ')' {
            if empty {
                if maxlen > len {
                    let diff = (maxlen - len) / 2;
                    maxlen = len + diff;
                }
                if maxlen > actual_max {
                    actual_max = maxlen;
                }
            } else {
                if len > maxlen {
                    maxlen = len;
                }
                if maxlen > actual_max {
                    actual_max = maxlen;
                }
            }
            stack.pop();
        } else if c == '|' {
            empty = true;
            if len > maxlen {
                maxlen = len;
            }
            len = *stack.last().unwrap();
        } else {
            empty = false;
            len += 1;
            
        }
    }

    if len > maxlen {
        maxlen = len;
    }
    if maxlen > actual_max {
        actual_max = maxlen;
    }
    
    println!("max length: {}", actual_max);

}

