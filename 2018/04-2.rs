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

const EV_GUARD_CHANGE :u8  = 0;
const EV_SLEEP : u8 = 1;
const EV_WAKE_UP : u8 = 2;

struct Event {
    timestamp : String,
    event_type : u8, // one of EV constants
    guard_id : u16, 
    minute : u16,
}

fn string_to_event(s: String) -> Event {
    let len = s.len();
    let mut ev = Event { timestamp: "".to_string(), event_type: 0, guard_id: 0, minute :0 };
    let ts = s.chars().skip(1).take(16).collect();
    ev.timestamp = ts;
    let minute_str : String = s.chars().skip(15).take(2).collect();
    let minute : u16 = minute_str.parse::<u16>().unwrap();
    ev.minute = minute;
    let ev_str : String = s.chars().skip(19).take(len-19).collect();
    if ev_str.starts_with("Guard") {
        ev.event_type = EV_GUARD_CHANGE;
        let parts: Vec<&str> = ev_str.split(" ").collect();
        let gn_len = parts[1].to_string().len();
        let gn_str : String =  parts[1].to_string().chars().skip(1).take(gn_len-1).collect();
        let gn = gn_str.parse::<u16>().unwrap();
        ev.guard_id = gn;
    } else if ev_str.starts_with("falls") {
        ev.event_type = EV_SLEEP;
    } else {
        ev.event_type = EV_WAKE_UP;
    }
    return ev;
}

struct Guard {
    total_sleep: u16,
    sleep_times : [u16;60],
}

impl Guard {
    fn new() -> Guard {
        Guard {
            total_sleep : 0,
            sleep_times : [0;60],
        }
    }

    fn add_sleep(&mut self, start :u16, end: u16 ) {
        for i in start..end {
            self.sleep_times[i as usize] += 1;
        }
        self.total_sleep += end - start;
    }
}

#[derive (Clone, Copy)]
struct GuardSleep {
    id : u16,
    times : u16,
}


fn main () {
    let mut input = get_input("input-4", string_to_event);
    input.sort_unstable_by(|a,b| a.timestamp.cmp(&b.timestamp));
    let mut current_guard_id = 0;
    let mut prev_min = 0;
    let mut gs = [GuardSleep { id : 0, times : 0 };60];
    

    let mut guards : HashMap<u16,Guard> = HashMap::new();
    for event in input {
        if event.event_type == EV_GUARD_CHANGE {
            current_guard_id = event.guard_id;
        } else if event.event_type == EV_SLEEP {
            prev_min = event.minute;
        } else {
            let current_guard = guards.entry(current_guard_id).or_insert(Guard::new());
            current_guard.add_sleep(prev_min, event.minute);
            for i in prev_min..event.minute {
                if current_guard.sleep_times[i as usize] > gs[i as usize].times {
                    gs[i as usize].times = current_guard.sleep_times[i as usize];
                    gs[i as usize].id = current_guard_id;
                }
            }
        }
    }
    let mut max_id = 0;
    let mut max_sleeps = 0;
    let mut max_minute = 0;
    for i in 0..60 {
        if gs[i].times > max_sleeps {
            max_sleeps = gs[i].times;
            max_id = gs[i].id;
            max_minute = i as u16;
        }
    }
    println!("The result: {}", max_minute * max_id);
}
