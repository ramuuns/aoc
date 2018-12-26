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

    let input : Vec<Vec<i32>> = get_input("input-25", |s| s.split(",").map(|i| i.parse::<i32>().unwrap()).collect() );

    println!("parsed input");

    let mut near_points : Vec<Vec<i32>> = Vec::new();
    for x in -3i32..=3 {
        for y in -3i32..=3 {
            for z in -3i32..=3 {
                for k in -3i32..=3 {
                    if x.abs() + y.abs() + z.abs() + k.abs() <= 3 {
                        near_points.push(vec![x as i32,y as i32,z as i32,k as i32]);
                    }
                }
            }
        }
    }

    let mut set_id = 0u16;

    let mut points_to_set : HashMap<(i32,i32,i32,i32),u16> = HashMap::new();
    let mut set_to_points : HashMap<u16,Vec<(i32,i32,i32,i32)>> = HashMap::new();

    for points in &input {
        let mut sets_this_point = HashSet::new();
        
        for p in &near_points {
            let x = points[0] + p[0];
            let y = points[1] + p[1];
            let z = points[2] + p[2];
            let k = points[3] + p[3];
            if points_to_set.contains_key(&(x,y,z,k)) {
                sets_this_point.insert(*points_to_set.get(&(x,y,z,k)).unwrap());
            }
        }
        if sets_this_point.len() > 0 {
            if sets_this_point.len() == 1 {
                //join an existing set
                for set in sets_this_point {
                    points_to_set.insert((points[0],points[1],points[2],points[3]), set);
                    let the_set = set_to_points.entry(set).or_insert(vec![]);
                    the_set.push((points[0],points[1],points[2],points[3]));
                }
            } else {
                //merge sets
                let mut new_points = Vec::new();
                for set in sets_this_point {
                    //println!("mergint set {}", set);
                    let old_points = set_to_points.get(&set).unwrap().clone();
                    for point in old_points {
                        new_points.push(point);
                        points_to_set.insert(point,set_id);
                    }
                    set_to_points.remove(&set);
                }
                new_points.push((points[0],points[1],points[2],points[3]));
                points_to_set.insert((points[0],points[1],points[2],points[3]), set_id);
                set_to_points.insert(set_id, new_points);
                set_id+=1;
            }
        } else {
            points_to_set.insert((points[0],points[1],points[2],points[3]), set_id);
            set_to_points.insert(set_id, vec![(points[0],points[1],points[2],points[3])]);
            set_id+=1;
        }
    }

    println!("nr of sets: {}", set_to_points.len() );

}

