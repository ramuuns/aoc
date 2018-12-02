use std::fs::File;
use std::io::prelude::*;
use std::collections::HashSet;
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
    let mut candidates = HashSet::new();
    let mut candidates_to_full = HashMap::new();
    let mut found = false;
    for string in input {
        let l = string.len();
        for i in 0..l {
            let left_slice = if i == 0 {
                "".to_string()
            } else {
                string.chars().take(i).collect()
            };
            let right_slice = if i == l-1 {
                "".to_string()
            } else {
                string.chars().skip(i+1).take(l-(i+1)).collect()
            };
            let hash_key = format!("{}{}", left_slice,right_slice);
            if candidates.contains(&hash_key) {
                if string.starts_with(candidates_to_full.get(&hash_key).unwrap()) {
                    //meh this is the same string, just with double letters
                } else {
                    println!("The common chars are: {}", hash_key);
                
                    found = true;
                    break;
                }
            }
            candidates.insert(hash_key.clone());
            candidates_to_full.insert(hash_key.clone(),string.clone());
        }
        if found {
            break;
        }
    }
}
