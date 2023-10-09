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

const STATE_READ_HEADER_CHILDREN : u8 = 0;
const STATE_READ_HEADER_META :u8 = 1;
const STATE_READ_DATA :u8 = 2;

fn main () {
    let input = get_input("input-8", |s| s);
    let data : Vec<u16> = input[0].split(" ").map(|s| s.parse::<u16>().unwrap()).collect();

    let mut stack : Vec<(u16,u16)> = Vec::new();
    let mut state = STATE_READ_HEADER_CHILDREN;
    let mut children : u16 = 0;
    let mut meta : u16 = 0;
    let mut sum : u16 = 0;

    for i in data {
        //println!("State: {}", state);
        if state == STATE_READ_HEADER_CHILDREN {
            children = i;
            state = STATE_READ_HEADER_META;
        } else if state == STATE_READ_HEADER_META {
            meta = i;
            if children > 0 {
                state = STATE_READ_HEADER_CHILDREN;
                stack.push((children,meta));
                //println!("Pushed: C:{} M:{}", children, meta);
            } else {
                state = STATE_READ_DATA;
            }
        } else {
            //state == STATE_READ_DATA
            sum += i;
            //println!("Adding: {}",i);
            meta -= 1;
            while meta == 0 {
                if stack.len() > 0 {
                    let (popchildren,popmeta) = stack.pop().unwrap();
                    meta = popmeta;
                    children = popchildren;
                    children -= 1;
                    //println!("After pop and decrement: C:{} M:{}", children, meta);
                    if children > 0 {
                        stack.push((children,meta));
                        state = STATE_READ_HEADER_CHILDREN;
                        break;
                    } else {
                        if meta > 0 {
                            break;
                        }
                    }
                } else {
                    break;
                }
            }
        }
    }

    println!("The result: {}", sum );
}

