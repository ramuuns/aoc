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
    let mut state: BTreeSet<i32> = BTreeSet::new();
    let mut min = 0;
    let mut max = 0;

    let mut idx : i32 = 0;
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


    for _ in 0..2 {
        let mut newstate : BTreeSet<i32> = BTreeSet::new();
        let mut rule = 0;
        
        for i in min-3..=max+2 {
            rule <<= 1;
            rule &= 0b11111;
            if state.contains(&(i+2)) {
                rule |= 1;
            }
            if rules[rule] == 1 {
                println!("adding at: {}", i);
                newstate.insert(i);
                if i < min {
                    min = i;
                }
                if i > max {
                    max = i;
                }
            }
        }

        println!("min: {}, max: {}", min, max);
        state = newstate;
    }
    
    let mut s = 0;
    for k in state {
        s += k;
    }
    
    println!("index sum: {}", s);

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