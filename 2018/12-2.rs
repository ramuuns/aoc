use std::fs::File;
use std::io::prelude::*;
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


fn main () {
    let input = get_input("input-12", |s| s );

    let mut rules = vec![0;32];
    let mut state: BTreeSet<i64> = BTreeSet::new();
    let mut min = 0;
    let mut max = 0;

    let mut idx : i64 = 0;
    for c in input[0].chars() {
        if c == '#' {
            state.insert(idx);
            max = idx;
        }
        idx += 1;
    }

    for i in 2..34 {
        let mut b = 16;
        let mut state = 0;
        let mut idx = 0;
        let mut val = 0;
        for c in input[i].chars() {
            if state == 0 {
                if c == '#' {
                    idx += b;
                } else if c == ' ' {
                    state += 1;
                }
                b >>= 1;
            } else if state == 1 {
                if c == ' ' {
                    state += 1;
                }
            } else {
                if c == '#' {
                    val = 1;
                }
            }
        }
        rules[idx] = val;
    }

    let maxgen:u64 = 50000000000;

    let mut prevsum : i128 = 0;

    for g in 0..maxgen {
        if g > 120 {
            prevsum += (maxgen as i128 - g as i128)*42;;
            break;
        }
        let mut newstate : BTreeSet<i64> = BTreeSet::new();
        let mut rule = 0;
        let mut prev_idx = min - 5;

        for idx in state {
            
            let d = idx - prev_idx;
            for i in 1..d {
                rule <<= 1;
                rule &= 0b11111;
                if rule == 0 {
                    break;
                }
                if rules[rule] == 1 {
                    //println!("_adding at: {} ", prev_idx +i - 2);
                    newstate.insert(prev_idx +i - 2);
                    if prev_idx + i -2 < min {
                        min = prev_idx + i -2;
                    }
                    if prev_idx + i -2 > max {
                        max = prev_idx + i -2;
                    }
                }
            }
            rule <<=1;
            rule &= 0b11111;
            rule |= 1;
            if rules[rule] == 1 {
                //println!("adding at: {} ", idx - 2);
                newstate.insert(idx - 2);
                if idx - 2 < min {
                    min = idx - 2;
                }
                if idx -2 > max {
                    max = idx - 2;
                }
            }
            prev_idx = idx;
        }

        for idx in prev_idx+1..prev_idx+6 {
            rule <<= 1;
            rule &= 0b11111;
            if rules[rule] == 1 {
                //println!("adding at_: {} ", idx - 2);
                newstate.insert(idx - 2);
                if idx - 2 < min {
                    min = idx - 2;
                }
                if idx - 2 > max {
                    max = idx - 2;
                }
            }
        }

        //println!("min: {}, max: {}", min, max);

        let mut s = 0;
        for k in newstate.clone() {
            s += k;
        }
        
        //println!("gen : {} diff: {}", g, s - prevsum);
        prevsum = s as i128;
        
        state = newstate;
    }
    
    
    println!("index sum: {}", prevsum);

}

/*

.#..#.#..##......###...###....
.#...#....#.....#..#..#..#....
.##..##...##....#..#..#..##....
.#.#...#..#.#....#..#..#...#....
..#.#..#...#.#...#..#..##..##....
...#...##...#.#..#..#...#...#....
...##.#.#....#...#..##..##..##....
..#..###.#...##..#...#...#...#....

..#....##.#.#.#..##..##..##..##.......
..#.....#.#.#.#..##..##..##..##....
..##.....#####....#...#...#...#....
.#.#....#.#..#....##..##..##..##....
..#.#....#...##..#.#...#...#...#....
...#.#...##.#.#...#.#..##..##..##....
....#.#.#..###.#...#....#...#...#....
.....###......#.#..##...##..##..##....
....#..#.......#....#..#.#...#...#....
....#..##......##...#...#.#..##..##....
....#...#.....#.#...##...#....#...#....
....##..##.....#.#.#.#...##...##..##....
...#.#...#......#####.#.#.#..#.#...#....


    ..
 1: ..
 2: ..
 3: .
 4: .
 5: .
 6: .
 7: ..
 8: .
 9: ...##..#..#####....#...#...#...#.......
10: ..#.#..#...#.##....##..##..##..##......
11: ...#...##...#.#...#.#...#...#...#......
12: ...##.#.#....#.#...#.#..##..##..##.....
13: ..#..###.#....#.#...#....#...#...#.....
14: ..#....##.#....#.#..##...##..##..##....
15: ..##..#..#.#....#....#..#.#...#...#....
16: .#.#..#...#.#...##...#...#.#..##..##...
17: ..#...##...#.#.#.#...##...#....#...#...
18: ..##.#.#....#####.#.#.#...##...##..##..
19: .#..###.#..#.#.#######.#.#.#..#.#...#..
20: .#....##....#####...#######....#.#..##.

*/