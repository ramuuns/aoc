fn main() {

    let mut c = 0u32;

    loop {
        let mut b = c | 0x10000;
        c = 0x13154A;
    
        loop {

            let mut e = b & 0xff;   // = 0
            c = c+e ;       //+= 0
            c = c & 0xFFFFFF;
            c = c * 0x1016B;
            c = c & 0xFFFFFF;

            if b < 0x10 {
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
}