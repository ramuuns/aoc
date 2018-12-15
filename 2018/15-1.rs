use std::fs::File;
use std::io::prelude::*;
use std::collections::BTreeMap;
use std::collections::BTreeSet;
use std::collections::HashMap;
use std::collections::VecDeque;

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

fn do_move(x:usize,y:usize,grid:&Vec<Vec<char>>,tgt : char) -> (usize,usize) {
    let mut visited : HashMap<(usize,usize),u16> = HashMap::new();
    let mut to_visit : VecDeque<(usize,usize, u16)> = VecDeque::new();

    let mut targets : BTreeSet<(u16,usize,usize)> = BTreeSet::new();

    to_visit.push_back((y,x,0));
    visited.insert((y,x),0);

    let mut pd = 0;
    let mut targets_found_this_distance = false;

    while let Some((cy,cx,dist)) = to_visit.pop_front() {

        if targets_found_this_distance && pd != dist {
            break;
        }
        
        if grid[cy-1][cx] == tgt || grid[cy+1][cx] == tgt || grid[cy][cx-1] == tgt || grid[cy][cx+1] == tgt {
            targets.insert((dist,cy,cx));
            targets_found_this_distance = true;
            pd = dist;
        }
        
        if grid[cy-1][cx] == '.' && !visited.contains_key(&(cy-1,cx))  {
            to_visit.push_back((cy-1,cx,dist+1));
            visited.insert((cy-1,cx),dist+1);
        }
        if grid[cy][cx-1] == '.' && !visited.contains_key(&(cy,cx-1))  {
            to_visit.push_back((cy,cx-1,dist+1));
            visited.insert((cy,cx-1),dist+1);
        }
        if grid[cy][cx+1] == '.' && !visited.contains_key(&(cy,cx+1))  {
            to_visit.push_back((cy,cx+1,dist+1));
            visited.insert((cy,cx+1),dist+1);
        }
        if grid[cy+1][cx] == '.' && !visited.contains_key(&(cy+1,cx))  {
            to_visit.push_back((cy+1,cx,dist+1));
            visited.insert((cy+1,cx),dist+1);
        }
    }

    match targets.iter().next() {
        Some((td,ty,tx)) => {
            let mut cd = *td;
            let cy = *ty;
            let cx = *tx;
            let mut prevpaths : BTreeSet<(usize,usize)> = BTreeSet::new();
            prevpaths.insert((cy,cx));
            while cd > 1 {
                let mut paths : BTreeSet<(usize,usize)> = BTreeSet::new();
                for (cy,cx) in prevpaths.clone() {
                    if visited.contains_key(&(cy-1,cx)) && *visited.get(&(cy-1,cx)).unwrap() < cd {
                        paths.insert((cy-1,cx));
                    }
                    if visited.contains_key(&(cy+1,cx)) && *visited.get(&(cy+1,cx)).unwrap() < cd {
                        paths.insert((cy+1,cx));
                    }
                    if visited.contains_key(&(cy,cx-1)) && *visited.get(&(cy,cx-1)).unwrap() < cd {
                        paths.insert((cy,cx-1));
                    }
                    if visited.contains_key(&(cy,cx+1)) && *visited.get(&(cy,cx+1)).unwrap() < cd {
                        paths.insert((cy,cx+1));
                    }
                }
                prevpaths = paths;
                cd -= 1;
            }
            match prevpaths.iter().next() {
                Some((cy,cx)) => {
                    return (*cx,*cy);
                },
                None => {
                    return (cx,cy);
                }
            };
                
        },
        None => {
            return (x,y);
        }
    }
}


fn main () {
    let input = get_input("input-15", |s| s );

    let mut grid : Vec<Vec<char>> = Vec::new();
    let mut elves : BTreeMap<(usize,usize),i16> = BTreeMap::new();
    let mut goblins : BTreeMap<(usize,usize),i16> = BTreeMap::new();
    let mut allunits : BTreeSet<(usize,usize)> = BTreeSet::new();

    let mut y = 0usize;
    for line in input {
        let mut one_line : Vec<char> = Vec::new();
        let mut x = 0usize;
        for ch in line.chars() {
            one_line.push(ch);
            if ch == 'E' {
                elves.insert((y,x),200);
                allunits.insert((y,x));
            } else if ch == 'G' {
                goblins.insert((y,x),200);
                allunits.insert((y,x));
            }
            x += 1;
        }
        grid.push(one_line);
        y += 1;
    }

    let mut rounds : u64 = 0;
    loop {
        
        let mut cannot_move_all_enemies_dead = false;

        let mut moved_this_turn :BTreeSet<(usize,usize)> = BTreeSet::new();

        for (y,x) in allunits.clone() {

            // check who am I
            let ima = grid[y][x]; //E or G
            if ima != 'E' && ima != 'G' {
                continue;
            }

            if moved_this_turn.contains(&(y,x)) {
                continue;
            }

            // see if I need to move
            let needs_to_move = if ima == 'E' {
                !(grid[y+1][x] == 'G' || grid[y-1][x] == 'G' || grid[y][x+1] == 'G' || grid[y][x-1] == 'G')
            } else {
                !(grid[y+1][x] == 'E' || grid[y-1][x] == 'E' || grid[y][x+1] == 'E' || grid[y][x-1] == 'E')
            };

            let mut xx = x;
            let mut yy = y;
            if needs_to_move {
                if ima == 'E' && goblins.len() == 0 {
                    cannot_move_all_enemies_dead = true;
                    break;
                }
                if ima == 'G' && elves.len() == 0 {
                    cannot_move_all_enemies_dead = true;
                    break;
                }
                //we do moving
                let (cx,cy) = do_move(x,y,&grid,if ima == 'E' { 'G' } else { 'E' } );
                xx = cx;
                yy = cy;
                if xx != x || yy != y {
                    grid[y][x] = '.';
                    grid[yy][xx] = ima;
                    allunits.remove(&(y,x));
                    allunits.insert((yy,xx));
                    if ima == 'E' {
                        let hp = elves.remove(&(y,x)).unwrap();
                        elves.insert((yy,xx),hp);
                    } else {
                        let hp = goblins.remove(&(y,x)).unwrap();
                        goblins.insert((yy,xx),hp);
                    }
                }
            }

            moved_this_turn.insert((yy,xx));

            let can_fight = if ima == 'E' {
                grid[yy+1][xx] == 'G' || grid[yy-1][xx] == 'G' || grid[yy][xx+1] == 'G' || grid[yy][xx-1] == 'G'
            } else {
                grid[yy+1][xx] == 'E' || grid[yy-1][xx] == 'E' || grid[yy][xx+1] == 'E' || grid[yy][xx-1] == 'E'
            };

            

            if can_fight {
                if ima == 'E' {
                    let mut tgthp = 300;
                    let mut tgtx = 0;
                    let mut tgty = 0;
                    if grid[yy-1][xx] == 'G' {
                        tgty = yy-1;
                        tgtx = xx;
                        tgthp = *goblins.get(&(yy-1,xx)).unwrap();
                    }
                    if grid[yy][xx-1] == 'G' && tgthp > *goblins.get(&(yy,xx-1)).unwrap() {
                        tgty = yy;
                        tgtx = xx-1;
                        tgthp = *goblins.get(&(yy,xx-1)).unwrap();
                    }
                    if grid[yy][xx+1] == 'G' && tgthp > *goblins.get(&(yy,xx+1)).unwrap() {
                        tgty = yy;
                        tgtx = xx+1;
                        tgthp = *goblins.get(&(yy,xx+1)).unwrap();
                    }
                    if grid[yy+1][xx] == 'G' && tgthp > *goblins.get(&(yy+1,xx)).unwrap() {
                        tgty = yy+1;
                        tgtx = xx;
                        tgthp = *goblins.get(&(yy+1,xx)).unwrap();
                    }
                    tgthp -= 3;

                    if tgthp <= 0 {
                        grid[tgty][tgtx] = '.';
                        goblins.remove(&(tgty,tgtx));
                        allunits.remove(&(tgty,tgtx));
                        moved_this_turn.remove(&(tgty,tgtx));
                    } else {
                        goblins.insert((tgty,tgtx),tgthp);
                    }
                } else {
                    let mut tgthp = 300;
                    let mut tgtx = 0;
                    let mut tgty = 0;
                    if grid[yy-1][xx] == 'E' {
                        tgty = yy-1;
                        tgtx = xx;
                        tgthp = *elves.get(&(yy-1,xx)).unwrap();
                    }
                    if grid[yy][xx-1] == 'E' && tgthp > *elves.get(&(yy,xx-1)).unwrap() {
                        tgty = yy;
                        tgtx = xx-1;
                        tgthp = *elves.get(&(yy,xx-1)).unwrap();
                    }
                    if grid[yy][xx+1] == 'E' && tgthp > *elves.get(&(yy,xx+1)).unwrap() {
                        tgty = yy;
                        tgtx = xx+1;
                        tgthp = *elves.get(&(yy,xx+1)).unwrap();
                    }
                    if grid[yy+1][xx] == 'E' && tgthp > *elves.get(&(yy+1,xx)).unwrap() {
                        tgty = yy+1;
                        tgtx = xx;
                        tgthp = *elves.get(&(yy+1,xx)).unwrap();
                    }
                    tgthp -= 3;

                    if tgthp <= 0 {
                        grid[tgty][tgtx] = '.';
                        elves.remove(&(tgty,tgtx));
                        allunits.remove(&(tgty,tgtx));
                        moved_this_turn.remove(&(tgty,tgtx));
                    } else {
                        elves.insert((tgty,tgtx),tgthp);
                    }
                }
            }
        }

        if cannot_move_all_enemies_dead {
            break;
        }


        rounds += 1;
    }

    let mut hp_s : u64 = 0; 
    if elves.len() > 0 {
        for hp in elves.values() {
            
            hp_s += *hp as u64;
        }
    } else {
        for hp in goblins.values() {
            hp_s += *hp as u64;
        }
    }
    println!("rounds: {} x {} = {}", rounds, hp_s, rounds * hp_s);

}

