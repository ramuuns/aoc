package main

import (
	"fmt"
	"strings"
	"io/ioutil"
	"unicode"
    "sort"
    pq "github.com/jupp0r/go-priority-queue"
)

var dirs = [4][2]int {
	[2]int{0,-1},
	[2]int{1,0},
	[2]int{0,1},
	[2]int{-1,0},
}

type QState struct {
	dist int
    tgt rune
	p Point
}

type Point struct {
	x int
	y int
}

func abs(n int) int {
    if n < 0 {
        return -n
    }
    return n
}

func heuristic(src, tgt Point) float64 {
    return -float64(abs(src.x - tgt.x) + abs(src.y - tgt.y))
}

type RunePair struct {
    a rune
    b rune
}

func find_best_distances(grid[][]rune, positions map[rune]Point) map[RunePair]int {
    ret := make(map[RunePair]int)
    for src, p1 := range positions {
        fmt.Printf("finding all distances for %s\n", string(src))
        for dst, p2 := range positions {
            if src == dst {
                continue
            }
            if ret[RunePair{src,dst}] > 0 {
                continue
            }
            fmt.Printf("  vs %s \n", string(dst))
            dist := find_path_length(p1, grid, p2)
            ret[RunePair{src,dst}] = dist
            ret[RunePair{dst,src}] = dist
        }
    }
    return ret
}

var mds = make(map[string]int)

func get_min_dist_sum(start rune, visited map[rune]bool, best_distances map[RunePair]int) int {
    key := make([]int,0)
    for tgt, seen := range visited {
        if ! seen {
            key = append(key, int(tgt))
        }
    }
    if len(key) == 0 {
        return 0
    }
    if len(key) == 1 {
        return best_distances[RunePair{rune(key[0]),start}]
    }
    sort.Ints(key)
    runekey := make([]rune, len(key))
    for i, ch := range key {
        runekey[i] = rune(ch)
    }
    mds_key := string(runekey)
    if mds[mds_key] > 0 {
        return mds[mds_key]
    }
    minsum := -1
    for tgt, seen := range visited {
        if seen {
            continue
        }
        if minsum > 0 && minsum < best_distances[RunePair{start,tgt}] {
            continue
        }
        visited[tgt] = true
        sum := best_distances[RunePair{start,tgt}]
        sum += get_min_dist_sum(tgt, visited, best_distances)
        visited[tgt] = false
        if minsum < 0 || sum < minsum {
            minsum = sum
        }
    }
    mds[mds_key] = minsum
    return minsum
}

func find_path_length(pos Point, grid[][]rune, tgt Point) int {
    visited := make(map[Point]bool)
    visiting := pq.New()
    pathlen := 0
    visiting.Insert(QState{0, 'a', pos},0)
    for visiting.Len() > 0 {
        popreq, _ := visiting.Pop()
        state := popreq.(QState)
        for _, dir := range dirs {
            x:= state.p.x + dir[0]
            y:= state.p.y + dir[1]
            p:= Point{x,y}
            if p == tgt {
                return state.dist + 1
            }
            if grid[y][x] == '#' {
                continue
            }
            if visited[p] {
                continue
            }
            visited[p] = true
            visiting.Insert( QState{ state.dist+1, 'a', p}  , heuristic(p, tgt) - float64( state.dist + 1 ) )
        }
    }
    return pathlen
}

func best_path(
    start_rune rune,
    pos Point,
    grid [][]rune,
    keypos map[rune]Point,
    path_length int,
    collected map[rune]bool,
    still_needed int,
    curr_path[]rune,
    min_path int,
    best_distances map[RunePair]int) int {

	if still_needed == 0 {
		fmt.Print(path_length)
        for _, ch := range curr_path {
            fmt.Print(" ", string(ch))
        }
        fmt.Println()
		return path_length
	}

	//visited := make(map[Point]int)
    visited_by_tgt := make(map[rune]map[Point]bool)
    found := make(map[rune]bool)
    mds_by_tgt := make(map[rune]int)
	visiting := pq.New()
    for tgt, seen := range collected {
        if seen {
            continue
        }
        mds_by_tgt[tgt] = get_min_dist_sum(tgt, collected, best_distances)
        visiting.Insert(QState{path_length, tgt, pos}, heuristic( pos, keypos[tgt] ) - float64(mds_by_tgt[tgt]) )
        visited_by_tgt[tgt] = make(map[Point]bool)
        found[tgt] = false
    }
	keys_found := 0
    iter := 0
	for visiting.Len() > 0 {
		popreq, _ := visiting.Pop()
        state := popreq.(QState)
        //fmt.Println(state)
        iter++;
        if iter % 400 == 0 {
            fmt.Println(still_needed, keys_found, iter, state, found[state.tgt],  min_path, state.dist - int(heuristic(keypos[state.tgt], state.p)) + mds_by_tgt[state.tgt] ,  curr_path)
        }
        if found[state.tgt] {
            continue
        }

        if start_rune != '@' && state.dist - path_length > best_distances[RunePair{start_rune,state.tgt}] {
            //fmt.Println("giving up...")
            continue
        }

        if grid[state.p.y][state.p.x] == state.tgt {
            found[state.tgt] = true
            keys_found++
            npath := append(curr_path, state.tgt)
            collected[state.tgt] = true
            path := best_path(state.tgt, state.p, grid, keypos, state.dist, collected, still_needed - 1, npath, min_path, best_distances)
            collected[state.tgt] = false
            if min_path == -1 || path < min_path {
                min_path = path
            }
            if keys_found == still_needed {
                return min_path
            }
            continue
        }

//		if min_path > 0 && min_path < state.dist - int(heuristic(state.tgt, state.p)) + get_min_dist_sum(state.tgt, collected, best_distances) {
//			return min_path
//		}

		for _, dir := range dirs {
			x:= state.p.x + dir[0]
			y:= state.p.y + dir[1]
            p:= Point{x,y}
			if grid[y][x] == '#' {
				continue
			}
			if visited_by_tgt[state.tgt][Point{x,y}] {
				continue
			}
			if unicode.IsLetter(grid[y][x]) && unicode.IsUpper(grid[y][x]) && !collected[unicode.ToLower(grid[y][x])] {
                continue
            }
            if unicode.IsLetter(grid[y][x]) && unicode.IsLower(grid[y][x]) && !collected[grid[y][x]] && grid[y][x] != state.tgt {
                continue
            }
            dist := state.dist+1
            if start_rune != '@' && dist - path_length > best_distances[RunePair{start_rune,state.tgt}] {
                //fmt.Println("giving up...")
               continue
            }

            if min_path > 0 && min_path < dist - int(heuristic(keypos[state.tgt], state.p)) + mds_by_tgt[state.tgt] {
                continue
            }
            prio := heuristic(keypos[state.tgt], state.p) - float64(mds_by_tgt[state.tgt]) - float64(dist);
            visited_by_tgt[state.tgt][p] = true
            visiting.Insert(QState{dist, state.tgt, p}, prio)

		}
	}
	return min_path
}

type MapSet struct {
    points: map[Point]rune
    doors: map[rune]Point
    keys: map[rune]Point
}

func joinSets(a,b MapSet) MapSet {
    new_set := MapSet{make(map[Point]rune),make(map[rune]Point), make(map[rune]Point)}
    for k,v := range a.points {
        new_set.points[k] = v
    }
    for k,v := range b.points {
        new_set.points[k] = v
    }
    for k,v := range a.doors {
        new_set.doors[k] = v
    }
    for k,v := range b.doors {
        new_set.doors[k] = v
    }
    for k,v := range a.keys {
        new_set.keys[k] = v
    }
    for k,v := range b.keys {
        new_set.keys[k] = v
    }
    return new_set
}

func main() {
	input, err := ioutil.ReadFile("input-18")
    if err != nil {
        fmt.Println(err)
        return
    }
    input_as_str := string(input)
    string_data := strings.Split(strings.TrimSpace(input_as_str), "\n")
	needed_keys := 0
	collected := make(map[rune]bool)
	grid := make([][]rune, len(string_data))
	start := Point{0,0};
    keypos := make(map[rune]Point)
	for y, line := range string_data {
		runes := []rune(line);
		grid[y] = runes;
		for x, ch := range runes {
			if ch == '@' {
				start.x = x
				start.y = y
				continue
			}
			if unicode.IsLetter(ch) && unicode.IsLower(ch) {
				collected[ch] = false
                keypos[ch] = Point{x,y}
				needed_keys++
			}
		}
	}
    visited := map[Point]bool;
    set_index := 0
    visiting := pq.New()
    visiting.Insert(start,0)
    for visiting.Len() > 0 {
        
    }

    best_distances := find_best_distances(grid, keypos);
	path := make([]rune,0)
	answer := best_path('@',start,grid,keypos,0,collected,needed_keys,path, -1, best_distances)
	fmt.Println(answer)
}

