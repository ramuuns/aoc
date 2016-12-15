use std::io::prelude::*;
use std::fs::File;
use std::io::Error;

fn main(){
    notmain().unwrap();
}

fn notmain() -> Result<(), Error> {
    let mut f = try!(File::open("day-01-1.input"));
    let mut input_str = String::new();
    try!(f.read_to_string(&mut input_str));
    println!("input is: {}", input_str);
    let directions = input_str.split(", ");
    let mut xpos:i32 = 0;
    let mut ypos:i32 = 0;
    let mut dir = [0,1];
    for direction in directions {
        println!("{} is the order", direction);
        if direction.len() == 0 {
            continue;
        }
        let (d, am_str) = direction.split_at(1);
        let am = am_str.parse::<i32>().unwrap();
        if d == "R" {
            if dir[0] == 0 {
                dir[0] = -dir[1];
                dir[1] = 0;
            } else {
                dir[1] = dir[0];
                dir[0] = 0;
            }
        } else {
            if dir[0] == 0 {
                dir[0] = dir[1];
                dir[1] = 0;
            } else {
                dir[1] = -dir[0];
                dir[0] = 0;
            }
        }
        println!("{} am {} direction {};{}", am, d, dir[0], dir[1]);
        xpos+= am * dir[0];
        ypos+= am * dir[1];
    }
    println! ("{} blocks", xpos.abs() + ypos.abs());
    Ok(())
}