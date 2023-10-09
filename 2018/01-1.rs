use std::fs::File;
use std::io::prelude::*;

/*
    Read a file given by a filename and parse it to a vector of strings (one per line)
*/
fn get_input(filename : String) -> Vec<String> {
    let mut file = File::open(filename).expect("Cannot open file");
    let mut ret : Vec<String> = Vec::new();
    let mut vec_one_line = Vec::new();
    loop {
        let mut buf = [0;512];
        let res = file.read(&mut buf);
        match res {
            Ok(n) => {
                if n == 0 {
                    break;
                }

                for b in buf.iter() {
                    if *b == 10 {
                        let s = String::from_utf8(vec_one_line.clone()).unwrap();
                        vec_one_line.clear();
                        ret.push(s);
                    } else {
                        vec_one_line.push(*b);
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

fn main()  {
    let input = get_input("input-1".to_string());
    let mut sum = 0;
    for line in input {
        sum += line.parse::<i32>().unwrap();
    }
    println!("Sum: {}",sum);
}