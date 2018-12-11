
const SERIAL_NUMBER : i32 = 4172;

fn single_cell(x:usize,y:usize) -> i32 {
    return ( ( ( ( (x as i32 + 10) * (y as i32) + SERIAL_NUMBER) * ((x as i32) + 10)) / 100) % 10) - 5;
}

fn main () {
    let mut max = -100;
    let mut max_x = 0;
    let mut max_y = 0;
    let mut max_size = 0;
    let mut grid = vec![vec![0;300];300];
    for y in 0..300 {
        for x in 0..300 {
            grid[y][x] = single_cell(x,y) + 
                if x > 0 { grid[y][x-1] } else { 0 } +
                if y > 0 { grid[y-1][x] } else { 0 } -
                if x > 0 && y > 0 { grid[y-1][x-1] } else { 0 }
        }
    }

    for size in 1..300 {
        for y in 0..300-size {
            for x in 0..300-size {
                let sum = grid[y+size-1][x+size-1] -
                    if x > 0 { grid[y+size-1][x-1] } else { 0 } -
                    if y > 0 { grid[y-1][x+size-1] } else { 0 } +
                    if y > 0 && x > 0 { grid[y-1][x-1] } else { 0 };
                if sum > max {
                    max = sum;
                    max_x = x;
                    max_y = y;
                    max_size = size;
                }
            }
        }
    }

    println!("coord: {},{},{}", max_x, max_y, max_size);
}

