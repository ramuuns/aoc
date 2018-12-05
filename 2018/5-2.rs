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


fn do_reactions_skipping_letter( s: &String, c: char) -> usize {
    let mut the_s : Vec<char> = s.chars().collect();
    let mut len = the_s.len();
    let mut i : usize = 0;
    loop {
        if i == len {
            break;
        }
        if the_s[i].to_ascii_lowercase() == c {
            the_s.remove(i);
            len -= 1;
        } else {
            i += 1;
        }
    }
    let mut still_can_remove = true;
    while still_can_remove {
        
        let mut did_remove = false;
        let mut i : usize = 1;
        loop {
            if i == len {
                break;
            }
            if i > 0 && the_s[i-1].to_ascii_lowercase() == the_s[i].to_ascii_lowercase() && the_s[i-1] != the_s[i] {
                the_s.remove(i);
                the_s.remove(i-1);
                i -= 1;
                len -= 2;
                did_remove = true;
            } else {
                i += 1;
            }
        }
        if !did_remove {
            still_can_remove = false;
        }
    }
    return len;
}

fn main () {
    let input = get_input("input-5", |s| s);
    let mut min = input[0].len();
    // lowercase ascii charcodes...
    for c in 97u8..123 {
        let m = do_reactions_skipping_letter(&input[0], c as char);
        if m < min {
            println!("New min: {}", m);
            min = m;
        }
    }


    println!("The result: {}", min );
}
