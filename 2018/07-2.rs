use std::fs::File;
use std::io::prelude::*;
use std::collections::HashSet;
use std::collections::HashMap;
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


fn line_to_steps(s :String ) -> (char, char) {
    let mut chars = s.chars();
    let ret1 : char = chars.nth(5).unwrap();
    let ret2 : char = chars.nth(30).unwrap();
    return (ret1,ret2);
}


const CHAR_OFFSET: u16 = 4; //change to 4;
const WORKERS : usize = 5; //change to 5


fn main () {
    let input = get_input("input-7", line_to_steps);
    let mut all_steps : HashSet<char> = HashSet::new();
    let mut dependencies : HashMap<char, HashSet<char>> = HashMap::new();
    let mut dependents : HashMap<char, HashSet<char>> = HashMap::new();
    for (a,b) in input {
        //b depends on a
        let mut dep = dependencies.entry(b).or_insert(HashSet::new());
        dep.insert(a);
        let mut depen = dependents.entry(a).or_insert(HashSet::new());
        depen.insert(b);
        all_steps.insert(a);
        all_steps.insert(b);
    }

    let mut available_steps : BTreeSet<char> = BTreeSet::new();
    
    let mut done_steps : HashSet<char> = HashSet::new();
    let mut time : u16 = 0;
    let mut workers : BTreeSet<(u16, char)> = BTreeSet::new();
    
    for step in all_steps {
        if !dependencies.contains_key(&step) {
            available_steps.insert(step);
        }
    }

    loop  {
        if available_steps.is_empty() && workers.is_empty() {
            break;
        }

        for step in available_steps.clone().into_iter().take(WORKERS - workers.len()) {
            workers.insert((time + step as u16 - CHAR_OFFSET, step));
            available_steps.remove(&step);
        }

        if let Some((t, step)) = workers.iter().cloned().next() {
            time = t;
            workers.remove(&(t, step));
            done_steps.insert(step);
            if let Some(candidates) = dependents.get(&step) {
                for candidate in candidates {
                    if done_steps.is_superset(dependencies.get(&candidate).unwrap()) {
                        available_steps.insert(*candidate);
                    }
                }
            }
        }


    }

    
    println!("The result: {}", time );
}

