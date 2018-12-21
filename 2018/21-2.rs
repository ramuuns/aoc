use std::collections::HashSet;

fn main() {

    let mut c = 0u32;
    let mut prevc = 0u32;
    let mut seen : HashSet<u32> = HashSet::new();

    loop {
        let mut b = c | 0x10000;
        c = 0x13154A;
    
        loop {

            let e = b & 0xff;   // = 0
            c = c+e ;       //+= 0
            c = c & 0xFFFFFF;
            c = c * 0x1016B;
            c = c & 0xFFFFFF;

            if b < 0x100 {
                break;
            }

            b = b / 0x100;
        }
        if seen.contains(&c) {
            //println!("{}", c);
            println!("{}",prevc);
            break;
        } else {
            seen.insert(c);
            prevc = c;
        }
    }
}