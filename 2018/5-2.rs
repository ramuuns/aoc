use std::fs::File;
use std::io::prelude::*;

const NEW_LINE : u8 = 10;

/*
    Read a file given by a filename and parse it to a vector of
    whatever we need given a line_transform function
*/
fn get_input<T>(filename : &str, line_transform : fn(Vec<u8>) -> T) -> Vec<T> {
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
                        //let s = String::from_utf8(vec_one_line.clone()).unwrap();
                        ret.push(line_transform(vec_one_line.clone()));
                    }
                    break;
                }

                for b in buf.iter() {
                    if *b == NEW_LINE {
                        //let s = String::from_utf8(vec_one_line.clone()).unwrap();
                        ret.push(line_transform(vec_one_line.clone()));
                        vec_one_line.clear();
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


fn do_reactions_skipping_letter( the_s: &Vec<u8>, c: u8) -> usize {
    
    let mut stack : [u8;50000] = [0;50000]; // we know the max input size, so what the hell, it won't be bigger than that
    let mut len : usize = 0;
    for i in 0..the_s.len() {
        // compare case insensitive 
        // essentially we first cast it to upper case (the & 0b01011111)
        // and then we compare it to our upper case character
        if the_s[i] & 0b01011111 == c {
            continue;
        }
        if len > 0 {
            let c = stack[len - 1];
            if c & 0b01011111 == the_s[i] & 0b01011111 && c != the_s[i] {
                len -= 1; // just decrement the stack pointer and don't bother with the actual value in the stack
            } else {
                stack[len] = the_s[i];
                len += 1;
            }
        } else {
            stack[len] = the_s[i];
            len += 1;
        }
    }
    return len;
}

fn main () {
    let input = get_input("input-5", |s| s);
    let mut min = input[0].len();
    // uppercase ascii charcodes...
    for c in 65u8..91 {
        let m = do_reactions_skipping_letter(&input[0], c);
        if m < min {
            min = m;
        }
    }


    println!("The result: {}", min );
}
