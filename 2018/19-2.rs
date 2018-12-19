fn main () {
    let mut sum_factors = 0;
    let to_factorize = 10551367;
    for i in 1..=10551367 {
        if to_factorize % i == 0 {
            sum_factors+=i;
        }
    }
    println!("{}", sum_factors);
}

