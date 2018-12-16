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
    let input = get_input("input-16-1", |s| s );

    let opcodes : HashMap<i8,fn([usize;4], [usize;3]) -> [usize;4]> = {
        let mut ocm : HashMap<i8, fn([usize;4], [usize;3]) -> [usize;4]> = HashMap::new();
        //addr
        ocm.insert(0,|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = reg[data[0]] + reg[data[1]]; newreg });
        //addi
        ocm.insert(1,|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = reg[data[0]] + data[1]; newreg });

        //mulr
        ocm.insert(2,|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = reg[data[0]] * reg[data[1]]; newreg });
        //muli
        ocm.insert(3,|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = reg[data[0]] * data[1]; newreg });

        //banr
        ocm.insert(4,|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = reg[data[0]] & reg[data[1]]; newreg });
        //bani
        ocm.insert(5,|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = reg[data[0]] & data[1]; newreg });

        //borr
        ocm.insert(6,|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = reg[data[0]] | reg[data[1]]; newreg });
        //bori
        ocm.insert(7,|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = reg[data[0]] | data[1]; newreg });

        //setr
        ocm.insert(8,|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = reg[data[0]]; newreg });
        //seti
        ocm.insert(9,|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = data[0]; newreg });

        //gtir
        ocm.insert(10,|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = if data[0] > reg[data[1]] { 1 } else { 0 }; newreg });
        //gtri
        ocm.insert(11,|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = if reg[data[0]] > data[1] { 1 } else { 0 }; newreg });
        //gtrr
        ocm.insert(12,|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = if reg[data[0]] > reg[data[1]] { 1 } else { 0 }; newreg });

        //eqir
        ocm.insert(13,|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = if data[0] == reg[data[1]] { 1 } else { 0 }; newreg });
        //eqri
        ocm.insert(14,|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = if reg[data[0]] == data[1] { 1 } else { 0 }; newreg });
        //eqrr
        ocm.insert(15,|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = if reg[data[0]] == reg[data[1]] { 1 } else { 0 }; newreg });

        ocm
    };

    
    let mut memory = [0usize;4];

    let mut data = [0usize;3];

    let mut cnt = 0;

    for line in input {
        if line.starts_with("Before") {
            let mut i:usize = 0;
            for ch in line.chars() {
                if ch.is_digit(10) {
                    memory[i] = (ch as u8 - '0' as u8) as usize;
                    i+=1;
                }
            }
            continue;
        }
        if line.starts_with("After") {
            let mut tgt_memory = [0usize;4];
            let mut i:usize = 0;
            for ch in line.chars() {
                if ch.is_digit(10) {
                    tgt_memory[i] = (ch as u8 - '0' as u8) as usize;
                    i+=1;
                }
            }
            let mut this_cnt = 0;
            for op in opcodes.values() {
                let res = op(memory,data);
                if res[0] == tgt_memory[0] && res[1] == tgt_memory[1] && res[2] == tgt_memory[2] && res[3] == tgt_memory[3] {
                    this_cnt+=1;
                }
                if this_cnt >= 3 {
                    break;
                }
            }
            if this_cnt >=3 {
                cnt += 1;
            }
            continue;
        } else {
            if line.len() > 2 {
                let d :Vec<usize> = line.split(" ").map(|n| n.parse::<usize>().unwrap() ).collect();
                data[0] = d[1];
                data[1] = d[2];
                data[2] = d[3];
            }
        }
    }

    println!("cnt: {}", cnt);

}

