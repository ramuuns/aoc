
const SERIAL_NUMBER : i32 = 4172;

fn single_cell(x:usize,y:usize) -> i32 {
    return ( ( ( ( (x as i32 + 10) * (y as i32) + SERIAL_NUMBER) * ((x as i32) + 10)) / 100) % 10) - 5;
}

fn main () {
    let mut max = -100;
    let mut max_x = 0;
    let mut max_y = 0;
    let mut grid = vec![vec![0;300];300];
    for y in 0..300 {
        for x in 0..300 {
            grid[y][x] = single_cell(x,y) + 
                if x > 0 { grid[y][x-1] } else { 0 } +
                if y > 0 { grid[y-1][x] } else { 0 } -
                if x > 0 && y > 0 { grid[y-1][x-1] } else { 0 }
        }
    }

    for y in 0..300-3 {
        for x in 0..300-3 {
            let sum = grid[y+2][x+2] -
                if x > 0 { grid[y+2][x-1] } else { 0 } -
                if y > 0 { grid[y-1][x+2] } else { 0 } +
                if y > 0 && x > 0 { grid[y-1][x-1] } else { 0 };
            if sum > max {
                max = sum;
                max_x = x;
                max_y = y;
            }
        }
    }

    println!("coord: {}x{}", max_x, max_y);
}

