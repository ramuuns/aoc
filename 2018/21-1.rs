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

    let input = get_input("input-21", |s| s );

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
    let mut iter = 0;
    loop {
        let i = memory[ip];
        if i == 20 {
            memory[3] = memory[1] + 1;
        }
        if iter < 50 {
            println!("[{},{},{},{},{},{}]", memory[0], memory[1], memory[2], memory[3], memory[4], memory[5]);
            println!("[{:b},{:b},{:b},{:b},{:b},{:b}]", memory[0], memory[1], memory[2], memory[3], memory[4], memory[5]);
            iter+=1;
        } else {
            break;
        }
        if i == 29 {
            memory[0] = memory[2];
        }
        let the_fn = opcodes[&code[i].instr];
        memory = the_fn(memory,code[i].data);
        if memory[ip] + 1 >= code.len() {
            break;
        }
        memory[ip] += 1;
    }

    println!("zero: {}", memory[0]);

}

/*

#ip 5 ip = f
0 seti 123 0 2          c = 123 f++
1 bani 2 456 2          c &= 456 f++
2 eqri 2 72 2           c = c==72 ? 1 : 0 f++
3 addr 2 5 5            f += c
4 seti 0 0 5            f = 0
5 seti 0 9 2            c = 0

6 bori 2 65536 1        b = c | 0x10000
7 seti 1250634 6 2      c = 13154A
8 bani 1 255 4          e = b & 0xff
9 addr 2 4 2            c = c+e 
10 bani 2 16777215 2    c = c & 0xFFFFFF
11 muli 2 65899 2       c = c * 0x1016B
12 bani 2 16777215 2    c = c & 0xFFFFFF
13 gtir 256 1 4         e = 256 > b ? 1 : 0
14 addr 4 5 5           f+= e
15 addi 5 1 5           f+=1
16 seti 27 2 5          goto 28
17 seti 0 5 4           e = 0
    18 addi 4 1 3           d = e+1 
    19 muli 3 256 3         d = d*0x100
    20 gtrr 3 1 3           d = d > b ? 1 : 0
    21 addr 3 5 5           f += d
    22 addi 5 1 5           f += 1
    23 seti 25 5 5          goto 26
    24 addi 4 1 4           e+=1
    25 seti 17 2 5          goto 18

    c = 0;

    loop {
        b = c | 0x10000
        c = 13154A
    
        loop {

            e = b & 0xff;   // = 0
            c = c+e ;       //+= 0
            c = c & 0xFFFFFF;
            c = c * 0x1016B;
            c = c & 0xFFFFFF;

            if ( b < 0x10 ) {
                break;
            }

            e = b / 0x100;
            b = e; // == 0x100
        }
        println!("{}",c);
        break;
        /*if ( c == a ) {
            break;
        }*/
    }

    
26 setr 4 8 1           b = e
27 seti 7 6 5           goto 8
28 eqrr 2 0 4           e = c == a ? 1 : 0
29 addr 4 5 5           f += e (exit?)
30 seti 5 7 5           goto 6

*/