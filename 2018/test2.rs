fn main() {
    //pos=<58901937,1840529,45022137>, r=72434972
    let r = 72434972i64;
    let x = 58901937i64;
    let y = 1840529i64;
    let z = 45022137i64;

    let mut s = 0;

    for xx in x-r..=x+r { //8 9 10 11 12
        for yy in y-r+(x-xx).abs()..=y+r-(x-xx).abs() { 
            for _zz in z-r+(x-xx).abs()+(y-yy).abs()..=z+r-(x-xx).abs()-(y-yy).abs() {
                s+=1;
                //println!("{},{},{}",xx,yy,zz);
            }
        }
    }

    println!("{}", s);
}