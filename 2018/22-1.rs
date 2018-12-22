fn main() {
    let depth = 7305;
    let modulo = 20183;
    let xmult = 16807;
    let ymult = 48271;
    let mut sum = 0;
    let tx = 13;
    let ty = 734;
    let mut erosion_levels_grid = vec![vec![0usize;14];735];
    
    for y in 0..=ty {
        for x in 0..=tx {
            let g_index = if x == 0 && y == 0 || x == tx && y == ty {
                0
            } else if y == 0 {
                x*xmult
            } else if x == 0 {
                y*ymult
            } else {
                erosion_levels_grid[y-1][x] * erosion_levels_grid[y][x-1]
            };
            let erosion_level = (g_index + depth)%modulo;
            erosion_levels_grid[y][x] = erosion_level;
            sum += erosion_level%3;
        }
    }

    println!("sum {}", sum);
}