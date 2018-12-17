fn main () {
    //540391
    let input = vec![5u8,4,0,3,9,1];
    let ilen = 6;
    let mut bitstr : u32 = 0;
    let mut mask = 0;
    for it in input {
        bitstr <<= 4;
        bitstr |= it as u32;
        mask <<= 4;
        mask |= 15;
    }
    let mut arr :Vec<u8> = Vec::new();
    let mut res_bitstr : u32 = 0;
    arr.push(3);
    arr.push(7);
    let mut e1 : usize = 0;
    let mut e2 : usize = 1;
    let mut len : usize = 2;
    let mut res : usize  = 0;
    //println!("Bitstr: {:#b}", bitstr);
    //print!("3,7");
    loop {
        //println!("len : {}", arr.len());
        let rec = arr[e1] + arr[e2];
        if rec >= 10 {
            arr.push(1);
            res_bitstr <<= 4;
            res_bitstr |= 1;
            res_bitstr &= mask;
            //println!("resbitstr: {:#b}", res_bitstr);
            len += 1;
            if res_bitstr == bitstr {
                res = len - ilen; 
                break;
            }
            
        }
        arr.push(rec%10);
        res_bitstr <<= 4;
        res_bitstr |= (rec%10) as u32;
        res_bitstr &= mask;
        //println!("resbitstr: {:#b}", res_bitstr);
        len += 1;
        if res_bitstr == bitstr {
            res = len - ilen; 
            break;
        }
        
        e1 = (e1 + arr[e1] as usize + 1 ) % len;
        e2 = (e2 + arr[e2] as usize + 1 ) % len;
       // println!("");
       // println!("picked indexes: {} {} ", e1, e2 );
    }
    
    //println!("");

    println!("{}", res);
}