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

struct Instr {
    data : [usize;3],
    instr: String,
}

impl Instr {
    fn new(instr : String, data : [usize;3]) -> Instr {
        Instr { data, instr }
    }
}

fn main () {

    let opcodes : HashMap<String,fn([usize;6], [usize;3]) -> [usize;6]> = {
        let mut ocm : HashMap<String, fn([usize;6], [usize;3]) -> [usize;6]> = HashMap::new();
        //addr
        ocm.insert("addr".to_string(),|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = reg[data[0]] + reg[data[1]]; newreg });
        //addi
        ocm.insert("addi".to_string(),|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = reg[data[0]] + data[1]; newreg });

        //mulr
        ocm.insert("mulr".to_string(),|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = reg[data[0]] * reg[data[1]]; newreg });
        //muli
        ocm.insert("muli".to_string(),|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = reg[data[0]] * data[1]; newreg });

        //banr
        ocm.insert("banr".to_string(),|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = reg[data[0]] & reg[data[1]]; newreg });
        //bani
        ocm.insert("bani".to_string(),|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = reg[data[0]] & data[1]; newreg });

        //borr
        ocm.insert("borr".to_string(),|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = reg[data[0]] | reg[data[1]]; newreg });
        //bori
        ocm.insert("bori".to_string(),|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = reg[data[0]] | data[1]; newreg });

        //setr
        ocm.insert("setr".to_string(),|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = reg[data[0]]; newreg });
        //seti
        ocm.insert("seti".to_string(),|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = data[0]; newreg });

        //gtir
        ocm.insert("gtir".to_string(),|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = if data[0] > reg[data[1]] { 1 } else { 0 }; newreg });
        //gtri
        ocm.insert("gtri".to_string(),|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = if reg[data[0]] > data[1] { 1 } else { 0 }; newreg });
        //gtrr
        ocm.insert("gtrr".to_string(),|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = if reg[data[0]] > reg[data[1]] { 1 } else { 0 }; newreg });

        //eqir
        ocm.insert("eqir".to_string(),|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = if data[0] == reg[data[1]] { 1 } else { 0 }; newreg });
        //eqri
        ocm.insert("eqri".to_string(),|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = if reg[data[0]] == data[1] { 1 } else { 0 }; newreg });
        //eqrr
        ocm.insert("eqrr".to_string(),|reg, data| { let mut newreg = reg.clone(); newreg[data[2]] = if reg[data[0]] == reg[data[1]] { 1 } else { 0 }; newreg });

        ocm
    };

    let input = get_input("input-19", |s| s );

    let mut has_ip = false;
    let mut ip = 0usize;
    let mut code : Vec<Instr> = Vec::new();
    for line in input {
        if has_ip {
            let parts : Vec<&str> = line.split(" ").collect();
            let mut data = [0;3];
            let instr = parts[0].to_string();
            for i in 0..3 {
                data[i] = parts[i+1].parse::<usize>().unwrap();
            }
            code.push(Instr::new(instr,data));
        } else {
            let parts : Vec<&str> = line.split(" ").collect();
            ip = parts[1].parse::<usize>().unwrap();
            has_ip = true;
        }
    }

    
    let mut memory = [0usize;6];
    loop {
        let i = memory[ip];
        let the_fn = opcodes[&code[i].instr];
        memory = the_fn(memory,code[i].data);
        if memory[ip] + 1 >= code.len() {
            break;
        }
        memory[ip] += 1;
    }

    println!("zero: {}", memory[0]);

}

