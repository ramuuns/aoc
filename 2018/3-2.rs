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

struct ClothBox {
    id : u16,
    x : u16,
    y : u16,
    w : u16,
    h : u16,
}

fn string_to_cloth_box(s: String) -> ClothBox {
    let mut buf = Vec::new();
    let mut state = 0;
    let mut ret = ClothBox { id: 0, x: 0, y: 0, w :0, h: 0};
    for c in s.chars() {
        if state == 0 {
            if c == '@' {
                let id : String = buf.iter().collect();
                ret.id = id.parse::<u16>().unwrap();
                buf.clear();
                state += 1;
            } else {
                if c.is_digit(10) {
                    buf.push(c);
                }
            }
            continue;
        }
        if state == 1 {
            if c == ',' {
                let xstr : String = buf.iter().collect();
                ret.x = xstr.trim().parse::<u16>().unwrap();
                buf.clear();
                state += 1;
            } else {
                buf.push(c);
            }
            continue;
        }
        if state == 2 {
            if c == ':' {
                let ystr : String = buf.iter().collect();
                ret.y = ystr.trim().parse::<u16>().unwrap();
                buf.clear();
                state += 1;
            } else {
                buf.push(c);
            }
            continue;
        }
        if state == 3 { 
            if c == 'x' {
                let wstr : String = buf.iter().collect();
                ret.w = wstr.trim().parse::<u16>().unwrap();
                buf.clear();
                state += 1;
            } else {
                buf.push(c);
            }
            continue;
        }
        if state == 4 {
            buf.push(c);
        }
    }
    let hstr : String = buf.iter().collect();
    ret.h = hstr.trim().parse::<u16>().unwrap();
    return ret;
}

fn main () {
    let input = get_input("input-3", string_to_cloth_box);
    let mut field = HashMap::new();
    let mut non_overlapping = HashSet::new();
    let mut field_to_id = HashMap::new();
    for cbox in input {
        let mut none_overlap = true;
        for x in cbox.x..cbox.x+cbox.w {
            for y in cbox.y..cbox.y+cbox.h {
                let hash_key = format!("{}x{}",x,y);
                let cnt = if field.contains_key(&hash_key) {
                    field.get(&hash_key).unwrap() + 1
                } else { 
                    1
                };
                if cnt > 1 {
                    none_overlap = false;
                    let other_id = field_to_id.get(&hash_key).unwrap();
                    non_overlapping.remove(other_id);
                }
                field.insert(hash_key.clone(),cnt);
                field_to_id.insert(hash_key.clone(), cbox.id);
            }
        }
        if none_overlap {
            non_overlapping.insert(cbox.id);
        }
    }
    for id in non_overlapping {
        println!("Don't overlap: {}", id);
    }
}
