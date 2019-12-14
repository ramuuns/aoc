use std::fs::File;
use std::io::prelude::*;
use std::collections::HashMap;
//use std::collections::VecDeque;
use std::collections::HashSet;
use std::time::{Duration, Instant};

const NEW_LINE : u8 = 10;

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

fn recurse_fill_prod_vec(prod_vec :&mut Vec<usize>, seen :&mut HashSet<usize>, chem_vec : &Vec<(u64, Vec<(usize, u64)>)>, idx_start : usize, idx_ore : usize) {
    if idx_start == idx_ore {
        return;
    }
    seen.insert(idx_start);
    for (name, _) in &chem_vec[idx_start].1 {
        if !seen.contains(name) {
            recurse_fill_prod_vec(prod_vec, seen, chem_vec, *name, idx_ore);
        }
    }
    prod_vec.push(idx_start);
}

fn main() {
    let now = Instant::now();
    let input = get_input("input-14", |s| s );
    println!("read the file in {}",  now.elapsed().as_micros());
    let mut chem_map : HashMap<String, (u64, Vec<(String, u64)>)> = HashMap::new();
    let mut chem_names_to_index : HashMap<String, usize> = HashMap::new();
    let mut index :usize = 0;
    let mut idx_fuel :usize = 0;
    for line in input {
        let mut reqs : Vec<(String, u64)> = Vec::new();
        let mut name : String = String::from("");
        let mut num : u64 = 0;
        let mut state = 0;
        for ch in line.chars() {
            if ch == ' ' {
                if state == 0 {
                    state = 1;
                } else if state == 1 {
                    state = 3;
                } else if state == 2 {
                    state = 0;
                }
            } else if ch == ',' {
                reqs.push((name.clone(), num));
                name = String::from("");
                num = 0;
                state = 2;
            } else if ch == '=' {
                continue;
            } else if ch == '>' {
                reqs.push((name.clone(), num));
                name = String::from("");
                num = 0;
                state = 2;
            } else {
                if state == 0 {
                    num*=10;
                    num+= ch as u64 - '0' as u64 ;
                } else {
                    name.push(ch);
                }
            }
        }
        chem_map.insert(name.clone(),(num,reqs.clone()));
        if name == String::from("FUEL") {
            idx_fuel = index;
        }
        chem_names_to_index.insert(name.clone(), index);
        index+=1;
    }
    println!("input parsed in {}",  now.elapsed().as_micros());
    let idx_ore :usize = index;
    chem_names_to_index.insert(String::from("ORE"), idx_ore);
    let mut chem_vec : Vec<(u64, Vec<(usize, u64)>)> = Vec::with_capacity(index);
    for _ in 0..index {
        chem_vec.push((0, Vec::new()));
    }
    for (name, req) in chem_map {
        let idx : usize = *chem_names_to_index.get(&name).unwrap();
        let mut req_map : Vec<(usize, u64)> = Vec::with_capacity(req.1.len());
        for (cname, cval) in req.1 {
            let cidx : usize = *chem_names_to_index.get(&cname).unwrap();
            req_map.push((cidx,cval));
        }
        chem_vec[idx] = (req.0, req_map);
    }

    let mut prod_vec : Vec<usize> = Vec::with_capacity(index+1);
    let mut seen : HashSet<usize> = HashSet::new();
    recurse_fill_prod_vec(&mut prod_vec,&mut seen,&chem_vec,idx_fuel,idx_ore);

    println!("setup ready: {}", now.elapsed().as_micros());

    let mut max :u64 = 10000000;
    let mut min :u64 = 0;
    while max > min {
        let mut i : u64 = ((max - min) >> 1) + min;
        if i == min {
            i = max;
        }
        let mut produced_map : Vec<u64> = Vec::with_capacity(index+1);
        for _ in 0..index+1 {
            produced_map.push(0);
        }
        produced_map[idx_fuel] = i;
        for k in (0..prod_vec.len()).rev() {
            let name = prod_vec[k];
            let chem = &chem_vec[name];
            for (c_name, c_amount) in &chem.1 {
                let ttr : u64 = (produced_map[name] + chem.0 - 1 )/ chem.0;
                let p = &mut produced_map[*c_name];
                *p += c_amount * ttr;
            }
            //println!("{}",name);
            //println!("{:?}", produced_map);
        }
        let produced = produced_map[idx_ore];
        if produced > 1000000000000 {
            max = i - 1;
        } else {
            min = i;
        }
    }

    println!("main stuff done after {}", now.elapsed().as_micros());

    println!("{}", max);
}
