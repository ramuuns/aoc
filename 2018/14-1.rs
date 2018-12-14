fn main () {
    let input = 540391;
    let mut arr :Vec<u8> = Vec::with_capacity(input + 11);
    let mut res_arr = [0u8;10];
    arr.push(3);
    arr.push(7);
    let mut e1 : usize = 0;
    let mut e2 : usize = 1;
    let mut len : usize = 2;
    //print!("3,7");
    loop {
        let rec = arr[e1] + arr[e2];
        if rec >= 10 {
           // print!(",1");
            arr.push(1);
            if len >= input {
                res_arr[len - input] = 1;
            }
            len += 1;
            if len >= input + 10 {
                break;
            }
        }
        //print!(",{}", rec%10);
        arr.push(rec%10);
        if len >= input {
            res_arr[len - input] = rec%10;
        }
        len += 1;
        if len >= input + 10 {
            break;
        }
        e1 = (e1 + arr[e1] as usize + 1 ) % len;
        e2 = (e2 + arr[e2] as usize + 1 ) % len;
       // println!("");
       // println!("picked indexes: {} {} ", e1, e2 );
    }
    
    //println!("");

    for i in 0..10 {
        print!("{}", res_arr[i]);
    }
    println!("");
}