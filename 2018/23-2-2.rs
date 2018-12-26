use std::fs::File;
use std::io::prelude::*;
use std::cell::RefCell;

use std::collections::BTreeMap;
use std::collections::VecDeque;

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

#[derive(Clone, Copy)]
struct Circle {
    x:i64,
    y:i64,
    z:i64,
    r:i64,
}

impl Circle {
    fn new (x:i64,y:i64,z:i64,r:i64) -> Circle {
        Circle{x,y,z,r}
    }
}

fn distance(a:Circle, b:Circle) -> i64 {
    return (a.x - b.x).abs() + (a.y - b.y).abs() + (a.z - b.z).abs();
}

fn parse(s:String) -> Circle {
    let parts : Vec<&str> = s.split(">, r=").collect();
    let r = parts[1].parse::<i64>().unwrap();
    let front : Vec<&str> = parts[0].split("<").collect();
    let xyz : Vec<i64> = front[1].split(",").map(|i| i.parse::<i64>().unwrap() ).collect();
    return Circle::new(xyz[0],xyz[1],xyz[2],r);
}


struct PriorityQueue<T,P> where P: std::cmp::Ord + std::clone::Clone, T: std::clone::Clone {
    queues : BTreeMap<P,VecDeque<T>>
}

impl<T,P> PriorityQueue<T,P>
where P: std::cmp::Ord + std::clone::Clone, T: std::clone::Clone {
    fn new() -> PriorityQueue<T,P> {
        let queues : BTreeMap<P,VecDeque<T>> = BTreeMap::new();
        return PriorityQueue { queues };
    }

    fn push_back(&mut self, item : T, priority : P) {
        let q = self.queues.entry(priority).or_insert(VecDeque::new());
        q.push_back(item);
    }

    fn pop_front(&mut self) -> Option<T> {
        if self.queues.is_empty() {
            return None;
        }
        let ret : Option<T>;
        let mut can_remove = false;
        //let mut prio_to_remove : Option<&P> = None;
        unsafe { 
            //let prio : RefCell<P>;
            let ptr;
            //let queue : Option<VecDeque<T>>;
            //let mut clone = self.queues.clone();
            match self.queues.iter_mut().next() {
                None => { return None },
                Some((p,q)) => {
                    ret = q.pop_front();
                    //queue = Some(*q);
                    let prio = RefCell::new(p.clone());
                    ptr = prio.as_ptr();
                    if q.is_empty() {
                        can_remove = true;
                    }
                }
            }
            if can_remove {
                //let prio : P = *ptr;
                self.queues.remove(&*ptr);
            } /* else {
                self.queues.insert(prio.unwrap(), queue.unwrap());
            }*/
        }

        return ret;
    }
}

fn main () {

    let input = get_input("input-23", parse );

    //let mut maxr_point = Point::new(0,0,0,0);

    let home = Circle::new(0,0,0,0);

    //(Circle,num_areas,dist_from0),(-num_areas, dist_from0)
    let mut pq : PriorityQueue<(Circle,i16,i64),(i16,i64)> = PriorityQueue::new();

    for circle in &input {
        let mut newr : i64 = 1;
        while circle.r >= newr*2 {
            newr = newr*2;
        }
        for i in 0..8 {
            if  i % 4 == 0 {
                continue;
            }
            let sign = if i / 4 == 0 {
                1
            } else {
                -1
            };
            let x = if i % 4 == 1 { circle.x + sign * (circle.r - newr) } else { circle.x };
            let y = if i % 4 == 2 { circle.y + sign * (circle.r - newr) } else { circle.y };
            let z = if i % 4 == 3 { circle.z + sign * (circle.r - newr) } else { circle.z };
            //println!("newc: {}, {}, {}, {}, {}",x,y,z,newr, circle.r);
            let newc = Circle::new(x,y,z,newr);
            let mut cnt = 0;
            for cc in &input {
                if distance(newc,*cc) <= cc.r + newc.r {
                    cnt+=1;
                }
            }
            pq.push_back((newc,cnt, distance(home,newc) ), (-cnt, distance(home,newc)) );
        }
    }



    
    //let cnt : i16 = input.len() as i16;
    
    //pq.push_back((minx,miny,minz,dist,cnt,distance(home,Circle::new(minx,miny,minz,0))),(-cnt,distance(home,Circle::new(minx,miny,minz,0))));

    let mut iter = 0;

    while let Some((circle,num_areas,dist_from0)) = pq.pop_front() {
        if iter % 100000 == 0 || circle.r == 0 {
            println!("");
            println!("iter: {}", iter);
            println!("size: {}", circle.r);
            println!("point: {}, {}, {}", circle.x,circle.y, circle.z);
            println!("max {}", num_areas);
            println!("distance: {}", dist_from0);
        }
        iter+=1;
        if circle.r == 0 {
            break;
        }
        let newr : i64 = circle.r / 2;
        for i in 0..8 {
            if newr > 0 && i % 4 == 0 {
                continue;
            }
            if i == 4 {
                continue;
            }
            let sign = if i / 4 == 0 {
                1
            } else {
                -1
            };
            let x = if i % 4 == 1 { circle.x + sign * if newr > 0 { newr } else { 1 } } else { circle.x };
            let y = if i % 4 == 2 { circle.y + sign * if newr > 0 { newr } else { 1 } } else { circle.y };
            let z = if i % 4 == 3 { circle.z + sign * if newr > 0 { newr } else { 1 } } else { circle.z };
            let newc = Circle::new(x,y,z,newr);
            let mut cnt = 0;
            for cc in &input {
                if distance(newc,*cc) <= cc.r + newc.r {
                    cnt+=1;
                }
            }
            pq.push_back((newc,cnt, distance(home,newc) ), (-cnt, distance(home,newc)) );
        }
        
    }

}

