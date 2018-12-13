use std::fs::File;
use std::io::prelude::*;
use std::collections::BTreeMap;

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

struct Cart {
    dirx : i8,
    diry : i8,
    state : u8,
}

impl Cart {
    fn new( dirx : i8, diry: i8) -> Cart {
        Cart {
            dirx,diry,state: 0
        }
    }

    fn intersection(&mut self) {
        if self.state == 0 {
            self.state = 1;
            if self.dirx == 0 {
                if self.diry == 1 {
                    self.dirx = 1;
                } else {
                    self.dirx = -1;
                }
                self.diry = 0;
            } else {
                if self.dirx == 1 {
                    self.diry = -1;
                } else {
                    self.diry = 1;
                }
                self.dirx = 0;
            }
        } else if self.state == 2 {
            self.state = 0;
            if self.dirx == 0 {
                if self.diry == 1 {
                    self.dirx = -1;
                } else {
                    self.dirx = 1;
                }
                self.diry = 0;
            } else {
                if self.dirx == 1 {
                    self.diry = 1;
                } else {
                    self.diry = -1;
                }
                self.dirx = 0;
            }
        } else {
            self.state = 2;
        }
    }
}

fn main () {
    let input = get_input("input-13", |s| s );

    let mut grid : Vec<Vec<char>> = Vec::new();
    let mut carts : BTreeMap<(usize,usize),Cart> = BTreeMap::new();

    let mut y : usize = 0;

    for line in input {
        let mut gridline : Vec<char> = Vec::new();
        let mut x : usize = 0;
        for ch in line.chars() {
            if ch == '<' {
                carts.insert((y,x), Cart::new(-1,0));
                gridline.push('-');
            } else if ch == '>' {
                carts.insert((y,x), Cart::new(1,0));
                gridline.push('-');
            } else if ch == '^' {
                carts.insert((y,x), Cart::new(0,-1));
                gridline.push('|');
            } else if ch == 'v' {
                carts.insert((y,x), Cart::new(0,1));
                gridline.push('|');
            } else {
                gridline.push(ch);
            }
            x+= 1;
        }
        grid.push(gridline);
        y += 1;
    }

    let mut lastx = 0;
    let mut lasty = 0;

    loop {
        let mut newcarts : BTreeMap<(usize,usize),Cart> = BTreeMap::new();
        for ((yy,xx), mut c) in carts {
            if newcarts.contains_key(&(yy,xx)) {
                newcarts.remove(&(yy,xx));
                continue;
            }
            let x = (xx as isize + c.dirx as isize) as usize;
            let y = (yy as isize + c.diry as isize) as usize;
            if newcarts.contains_key(&(y,x)) {
                newcarts.remove(&(y,x));
                continue;
            }
            let g = grid[y][x];
            if g == '/' {
                if c.dirx == 0 {
                    if c.diry == 1 {
                        c.dirx = -1;
                    } else {
                        c.dirx = 1;
                    }
                    c.diry = 0;
                } else {
                    if c.dirx == 1 {
                        c.diry = -1;
                    } else {
                        c.diry = 1;
                    }
                    c.dirx = 0;
                }
            } else if g == '\\' {
                if c.dirx == 0 {
                    if c.diry == 1 {
                        c.dirx = 1;
                    } else {
                        c.dirx = -1;
                    }
                    c.diry = 0;
                } else {
                    
                    if c.dirx == 1 {
                        c.diry = 1;
                    } else {
                        c.diry = -1;
                    }
                    c.dirx = 0;
                }
            } else if g == '+' {
                c.intersection();
            }
            newcarts.insert((y,x),c);
        }
        if newcarts.len() == 1 {
            for ((y,x), _) in newcarts {
                lastx = x;
                lasty = y;
            }
            break;
        }
        carts = newcarts;
        
    }
    
    println!("crash: {},{}", lastx,lasty);

}
