use std::collections::HashMap;
use std::collections::BTreeMap;
use std::collections::VecDeque;

struct PriorityQueue<T> {
    queues : BTreeMap<usize,VecDeque<T>>
}

impl<T> PriorityQueue<T> {
    fn new() -> PriorityQueue<T> {
        let queues : BTreeMap<usize,VecDeque<T>> = BTreeMap::new();
        return PriorityQueue { queues };
    }

    fn push_back(&mut self, item : T, priority : usize) {
        let mut q = self.queues.entry(priority).or_insert(VecDeque::new());
        q.push_back(item);
    }

    fn pop_front(&mut self) -> Option<T> {
        if self.queues.is_empty() {
            return None;
        }
        let ret : Option<T>;
        let mut can_remove = false;
        let mut prio_to_remove = 0usize;
        match self.queues.iter_mut().next() {
            None => { return None },
            Some((prio,q)) => {
                ret = q.pop_front();
                if q.is_empty() {
                    can_remove = true;
                    prio_to_remove = *prio;

                }
            }
        }
        if can_remove {
            self.queues.remove(&prio_to_remove);
        }

        return ret;
    }
}


fn main() {
    let depth = 7305;
    //let depth = 510;
    let modulo = 20183;
    let xmult = 16807;
    let ymult = 48271;
    //let tx = 10;
    //let ty = 10;
    let tx = 13;
    let ty = 734;
    //let mut erosion_levels_grid = vec![vec![0usize;14];735];
    let mut erosion_levels_grid : Vec<Vec<usize>> = Vec::new();


    fn extend_grid(y: usize,x : usize, mut erosion_levels_grid : Vec<Vec<usize>>) -> (Vec<Vec<usize>>) {
        //let depth = 510;
        let depth = 7305;
        let modulo = 20183;
        let xmult = 16807;
        let ymult = 48271;
        //let tx = 10;
        //let ty = 10;
        let tx = 13;
        let ty = 734;
        if y >= erosion_levels_grid.len() {
            erosion_levels_grid = extend_grid(y-1,x,erosion_levels_grid);
            erosion_levels_grid.push(Vec::new());
            for xx in 0..=x {
                let g_index = if xx == 0 && y == 0 || xx == tx && y == ty {
                    0
                } else if y == 0 {
                    xx*xmult
                } else if xx == 0 {
                    y*ymult
                } else {
                    erosion_levels_grid[y-1][xx] * erosion_levels_grid[y][xx-1]
                };
                let erosion_level = (g_index + depth)%modulo;
                erosion_levels_grid[y].push(erosion_level);
            }
            return erosion_levels_grid;
        }

        if y < erosion_levels_grid.len() {
            if x < erosion_levels_grid[y].len() {
                return erosion_levels_grid;
            }
            if y > 0 && x >= erosion_levels_grid[y-1].len() {
                erosion_levels_grid = extend_grid(y-1,x,erosion_levels_grid);
            }
            
            for xx in erosion_levels_grid[y].len()..=x {
                let g_index = if xx == 0 && y == 0 || xx == tx && y == ty {
                    0
                } else if y == 0 {
                    xx*xmult
                } else if x == 0 {
                    y*ymult
                } else {
                    erosion_levels_grid[y-1][xx] * erosion_levels_grid[y][xx-1]
                };
                let erosion_level = (g_index + depth)%modulo;
                erosion_levels_grid[y].push(erosion_level);
            }
            return erosion_levels_grid;
        }
        return erosion_levels_grid;
    }
/*

If the erosion level modulo 3 is 0, the region's type is rocky.
If the erosion level modulo 3 is 1, the region's type is wet.
If the erosion level modulo 3 is 2, the region's type is narrow.

In rocky regions, you can use the climbing gear or the torch. You cannot use neither (you'll likely slip and fall).
. 0 <- (t)1||(c)2
In wet regions, you can use the climbing gear or neither tool. You cannot use the torch (if it gets wet, you won't have a light source).
= 1 <- (c)2||(n)0
In narrow regions, you can use the torch or neither tool. You cannot use the climbing gear (it's too bulky to fit).
| 2 <- (n)0||(t)1

00
01
10

~ | 

*/

    fn heuristic(x: usize,y: usize,tgtx: usize,tgty:usize) -> usize {
        return if tgtx > x { tgtx - x } else { x - tgtx } + if tgty > y { tgty - y } else { y - tgty };
    }

    fn find_path(x:usize,y:usize,tgtx:usize,tgty:usize,tool:usize, mut erosion_levels_grid : Vec<Vec<usize>> )  -> usize {
        let mut visited : HashMap<(usize,usize,usize),usize> = HashMap::new();
        let mut pq : PriorityQueue<(usize,usize,usize,usize)> = PriorityQueue::new();
        pq.push_back((x,y,0,tool),0);
        visited.insert((x,y,tool),0);
        let mut maxx = x;
        let mut maxy = y;
        while let Some((xx,yy,dist,t)) = pq.pop_front() {
            if xx > maxx {
                maxx = xx;
            }
            if yy > maxy {
                maxy = yy;
            }
            //println!("{},{}, {}, {}", xx,yy,dist,t);
            
            if xx == tgtx && yy == tgty {
            /*  for yyy in 0..=maxy {
                    for xxx in 0..=maxx {
                        let c = if erosion_levels_grid.len() > yyy && erosion_levels_grid[yyy].len() > xxx {
                            if erosion_levels_grid[yyy][xxx] % 3 == 0 { 
                                '.' 
                            } else if erosion_levels_grid[yyy][xxx] % 3 == 1 {
                                '='
                            } else {
                                '|'
                            }
                        } else {
                            ' '
                        };
                        let d = if visited.contains_key(&(xxx,yyy)) {
                            *visited.get(&(xxx,yyy)).unwrap()
                        } else {
                            99
                        };
                        print!{"{} {:02}", c,d }
                    }
                    println!("");
                }  */
                return dist;
            }
            
            let ctype = erosion_levels_grid[yy][xx] % 3;
            let directions = vec![(-1,0),(0,-1),(0,1),(1,0)];
            for (dy,dx) in directions {
                if xx as isize + dx < 0 || yy as isize +dy < 0 {
                    continue;
                }
                let xxx = (xx as isize + dx as isize) as usize;
                let yyy = (yy as isize + dy as isize) as usize;
                if yyy >= erosion_levels_grid.len() {
                    erosion_levels_grid = extend_grid(yyy,xxx, erosion_levels_grid);
                }
                if xxx >= erosion_levels_grid[yyy].len() {
                    erosion_levels_grid = extend_grid(yyy,xxx, erosion_levels_grid);
                }
                let ntype = erosion_levels_grid[yyy][xxx] % 3;
                let newtool = if ntype == ctype || t != ntype {
                    t
                } else {
                    !(ntype|ctype)&3
                };
                if yyy == tgty && xxx == tgtx {
                    let nd = if ntype == ctype || t != ntype {
                        dist + 1 + if t == 1 { 0 } else { 7 }
                    } else {
                        dist + 8 + if !(ntype|ctype)&3 == 1 { 0 } else { 7 }
                    };
                    if !visited.contains_key(&(xxx,yyy,newtool)) || *visited.get(&(xxx,yyy,newtool)).unwrap() > nd {
                        pq.push_back((xxx,yyy,nd,t),nd + heuristic(xxx,yyy,tgtx,tgty));
                        visited.insert((xxx, yyy, newtool), nd);
                    }
                } else {
                    if ntype == ctype || t != ntype {
                        if !visited.contains_key(&(xxx,yyy,newtool)) || 
                            *visited.get(&(xxx,yyy,newtool)).unwrap() > dist + 1  {
                            pq.push_back((xxx,yyy,dist+1,newtool),dist+1 + heuristic(xxx,yyy,tgtx,tgty));
                            visited.insert((xxx,yyy,newtool),dist+1);
                        }
                    } else {
                        if !visited.contains_key(&(xxx,yyy,newtool)) || 
                            *visited.get(&(xxx,yyy,newtool)).unwrap() > dist + 8  {
                            
                            pq.push_back((xxx,yyy,dist+8, newtool),dist+8 + heuristic(xxx,yyy,tgtx,tgty));
                            visited.insert((xxx,yyy, newtool),dist+8);
                        }
                    }
                }
            }

        }
        return 0;
    }
    
    for y in 0..=ty {
        erosion_levels_grid.push(Vec::new());
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
            erosion_levels_grid[y].push(erosion_level);
        }
    }

    println!("Will now try to find path");


    println!("sum {}", find_path(0,0,tx,ty,1,erosion_levels_grid) );
}