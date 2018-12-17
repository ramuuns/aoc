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

fn print_state(clay : HashSet<(usize,usize)>, water: HashSet<(usize,usize)>, still_water : HashSet<(usize,usize)>, minx: usize, miny :usize, maxx :usize, maxy: usize ) {
    for y in miny..=maxy {
        for x in minx..=maxx {
            let c = if clay.contains(&(y,x)) { '#' } else if still_water.contains(&(y,x)) { '~' } else if water.contains(&(y,x)) { '|' } else { '.' };
            print!("{}",c);
        }
        println!("");
    }

    println!("");
}

fn main () {
    let input = get_input("input-17", |s| s );

    let mut clay: HashSet<(usize,usize)> = HashSet::new();
    let mut miny = 1000000usize;
    let mut maxy = 0usize;
    let mut minx = 1000000usize;
    let mut maxx = 0usize;

    for line in input {
        //println!("parsing line: {}", line);
        let parts : Vec<&str> = line.split(", ").collect();
        let mut x;
        let mut y;
        if parts[0].starts_with("x=") {
            x = parts[0].split("=").last().unwrap().parse::<usize>().unwrap();
            let yparts : Vec<usize> = parts[1].split("=").last().unwrap().split("..").map(|s| s.parse::<usize>().unwrap() ).collect();
            for y in yparts[0]..=yparts[1] {
                clay.insert((y,x));
                if y < miny {
                    miny = y;
                }
                if y > maxy {
                    maxy = y;
                }
            }
            if x < minx {
                minx = x;
            }
            if x > maxx {
                maxx = x;
            }
        } else {
            y = parts[0].split("=").last().unwrap().parse::<usize>().unwrap();
            let xparts : Vec<usize> = parts[1].split("=").last().unwrap().split("..").map(|s| s.parse::<usize>().unwrap() ).collect();
            for x in xparts[0]..=xparts[1] {
                clay.insert((y,x));
                if x < minx {
                    minx = x;
                }
                if x > maxx {
                    maxx = x;
                }
            }
            if y < miny {
                miny = y;
            }
            if y > maxy {
                maxy = y;
            }
        }
    }

    let mut water_set : HashSet<(usize,usize)> = HashSet::new();
    let mut still_water_set : HashSet<(usize,usize)> = HashSet::new();

    let mut water_stack : Vec<(usize,usize)> = Vec::new();

    water_stack.push((0,500));
    
    let mut need_to_pop_because_maxy = false;

    let mut iterations = 0;

    let mut ws_minx = 100000usize;
    let mut ws_maxx = 0usize;
    let mut ws_miny = 100000usize;
    let mut ws_maxy = 0usize;
    
    loop {
        
        /*if water_set.len() > 0 {
        //    if iterations > 1000 && (iterations %100 == 99 || iterations %100 == 98 || iterations %100 == 97) {
                println!("iter: {}", iterations);
                print_state(clay.clone(), water_set.clone(), still_water_set.clone(),ws_minx-1,ws_miny-1,ws_maxx+1,ws_maxy+1);
                let mut cstack = water_stack.clone();
                print!("stack: ");
                for i in 0..4 {
                    if let Some((x,y)) = cstack.pop() {
                        print!("{},{} ",x,y);
                    }
                }
                println!("");
        //    }
        }
        iterations += 1;
        if iterations > 5000 {
            break;
        }*/
        let mut done = false;
        if need_to_pop_because_maxy {
            loop {
                let (y,x) = water_stack.pop().unwrap();
                if y < miny {
                    done = true;
                    break;
                }
                if y+1 <= maxy && !clay.contains(&(y+1,x)) && ! water_set.contains(&(y+1,x)) {
                    water_stack.push((y,x));
                    need_to_pop_because_maxy = false;
                    break;
                }
            }
        }
        if done {
            break;
        }

        let clone = water_stack.clone();
        let (y,x) = clone.last().unwrap();
        if clay.contains(&(y+1,*x)) || water_set.contains(&(y+1,*x)) {
            let mut did_overflow = false;
            if water_set.contains(&(y+1,*x)) {
                //check for overflow
                let mut x1 = *x;
                loop {
                    x1 -= 1;
                    if clay.contains(&(*y,x1)) {
                        break;
                    }
                    if !clay.contains(&(y+1, x1)) && !water_set.contains(&(y+1,x1)) {
                        did_overflow = true;
                        break;
                    }
                }
                if did_overflow {
                    need_to_pop_because_maxy = true;
                    continue;
                }
                x1 = *x;
                loop {
                    x1 += 1;
                    if clay.contains(&(*y,x1)) {
                        break;
                    }
                    if !clay.contains(&(y+1, x1)) && !water_set.contains(&(y+1,x1)) {
                        did_overflow = true;
                        break;
                    }
                }
                if did_overflow {
                    need_to_pop_because_maxy = true;
                    continue;
                }
                
            }

            loop {
                let (y,x) = water_stack.pop().unwrap();
                let mut x1 = x;
                let mut r_minx = x;
                let mut r_maxx = x;
                
                loop {
                    if clay.contains(&(y,x1)) {
                        break;
                    }
                    water_set.insert((y,x1));
                    still_water_set.insert((y,x1));
                    if y < ws_miny {
                        ws_miny = y;
                    }
                    if y > ws_maxy {
                        ws_maxy = y;
                    }
                    if x1 < ws_minx {
                        ws_minx = x1;
                    }
                    if x1 > ws_maxx {
                        ws_maxx = x1;
                    }
                    if !clay.contains(&(y+1, x1)) && !water_set.contains(&(y+1,x1)) {
                        water_stack.push((y,x1));
                        did_overflow = true;
                        break;
                    }
                    x1 -= 1;
                    r_minx-=1;
                    
                }
                x1 = x;
                loop {
                    
                    if clay.contains(&(y,x1)) {
                        break;
                    }
                    water_set.insert((y,x1));
                    still_water_set.insert((y,x1));
                    if y < ws_miny {
                        ws_miny = y;
                    }
                    if y > ws_maxy {
                        ws_maxy = y;
                    }
                    if x1 < ws_minx {
                        ws_minx = x1;
                    }
                    if x1 > ws_maxx {
                        ws_maxx = x1;
                    }
                    if !clay.contains(&(y+1, x1)) && !water_set.contains(&(y+1,x1)) {
                        water_stack.push((y,x1));
                        did_overflow = true;
                        break;
                    }
                    x1 += 1;
                    r_maxx+=1;
                }

                if did_overflow {
                    for xx in r_minx..=r_maxx {
                        still_water_set.remove(&(y,xx));
                    }
                    break;
                }
            }
        } else {
            water_stack.push((y+1,*x));
            if y+1 >= miny {
                if y+1 <= maxy {
                    water_set.insert((y+1,*x));
                    if y+1 < ws_miny {
                        ws_miny = y+1;
                    }
                    if y+1 > ws_maxy {
                        ws_maxy = y+1;
                    }
                    if *x < ws_minx {
                        ws_minx = *x;
                    }
                    if *x > ws_maxx {
                        ws_maxx = *x;
                    }
                } else {
                    need_to_pop_because_maxy = true;
                    continue;
                }
            } else {
                //meh
            }
        }
    }

    println!("water set size: {}", still_water_set.len());

    println!("minx, maxx:  {},{}", minx,maxx);
    println!("miny, maxy:  {},{}", miny,maxy);

}

