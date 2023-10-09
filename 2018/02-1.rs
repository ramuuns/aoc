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
    let input = get_input("input-2", |s| s );
    let mut threes = 0;
    let mut twos = 0;
    for string in input {
        let chars = string.chars();
        let mut char_count = HashMap::new();
        for c in chars {
            let cnt = if char_count.contains_key(&c) {
                 char_count.get(&c).unwrap() + 1
             } else { 
                 1
             };
            char_count.insert(c,cnt);
        }
        let mut has_two = false;
        let mut has_three = false;
        for val in char_count.values() {
            if *val == 2 {
                has_two = true;
            }
            if *val == 3 {
                has_three = true;
            }
        }
        if has_two {
            twos += 1;
        }
        if has_three {
            threes += 1;
        }
    }
    let res = twos * threes;
    println!("Result: {}", res);
}