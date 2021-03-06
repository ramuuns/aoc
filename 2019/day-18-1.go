package main

import (
	"fmt"
	pq "github.com/jupp0r/go-priority-queue"
	"io/ioutil"
	"sort"
	"strings"
	"unicode"
)

var dirs = [4][2]int{
	[2]int{0, -1},
	[2]int{1, 0},
	[2]int{0, 1},
	[2]int{-1, 0},
}

type QState struct {
	dist int
	tgt  rune
	p    Point
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
	return -float64(abs(src.x-tgt.x) + abs(src.y-tgt.y))
}

type RunePair struct {
	a rune
	b rune
}

func find_best_distances(grid [][]rune, positions map[rune]Point) map[RunePair]int {
	ret := make(map[RunePair]int)
	for src, p1 := range positions {
		fmt.Printf("finding all distances for %s\n", string(src))
		for dst, p2 := range positions {
			if src == dst {
				continue
			}
			if ret[RunePair{src, dst}] > 0 {
				continue
			}
			fmt.Printf("  vs %s \n", string(dst))
			dist := find_path_length(p1, grid, p2)
			ret[RunePair{src, dst}] = dist
			ret[RunePair{dst, src}] = dist
		}
	}
	return ret
}

var mds = make(map[string]int)

func get_min_dist_sum(start rune, visited map[rune]bool, best_distances map[RunePair]int, current_set MapSet, sets_by_gate map[rune][2]MapSet) int {
	key := make([]int, 0)
	for tgt, seen := range visited {
		if !seen {
			key = append(key, int(tgt))
		}
	}
	if len(key) == 0 {
		return 0
	}
	if len(key) == 1 {
		//fmt.Println("returning single distance");
		return best_distances[RunePair{rune(key[0]), start}]
	}
	sort.Ints(key)
	runekey := make([]rune, len(key)+1)
	runekey[0] = start
	for i, ch := range key {
		runekey[i+1] = rune(ch)
	}
	mds_key := string(runekey)
	if mds[mds_key] > 0 {
		return mds[mds_key]
	}
	//fmt.Println("will calculate mds for ", mds_key)
	minsum := 1000000000
	found_any := false
	for tgt, seen := range visited {
		if seen {
			continue
		}
		if _, ok := current_set.keys[tgt]; !ok {
			continue
		}
		if minsum < best_distances[RunePair{start, tgt}] {
			continue
		}
		found_any = true
		visited[tgt] = true
		sum := best_distances[RunePair{start, tgt}]
		cset := recurseJoinSets(current_set, sets_by_gate[unicode.ToUpper(tgt)], sets_by_gate, visited)
		sum += get_min_dist_sum(tgt, visited, best_distances, cset, sets_by_gate)
		visited[tgt] = false
		if sum < minsum {
			minsum = sum
		}
	}
	if !found_any {
		fmt.Println("no route found :O")
		fmt.Println(current_set)
		fmt.Println(visited)
		runekey[111111] = 'd'
	}
	mds[mds_key] = minsum
	return minsum
}

func find_path_length(pos Point, grid [][]rune, tgt Point) int {
	visited := make(map[Point]bool)
	visiting := pq.New()
	pathlen := 0
	visiting.Insert(QState{0, 'a', pos}, 0)
	for visiting.Len() > 0 {
		popreq, _ := visiting.Pop()
		state := popreq.(QState)
		for _, dir := range dirs {
			x := state.p.x + dir[0]
			y := state.p.y + dir[1]
			p := Point{x, y}
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
			visiting.Insert(QState{state.dist + 1, 'a', p}, heuristic(p, tgt)-float64(state.dist+1))
		}
	}
	return pathlen
}

var bp_cache = make(map[string]int)

func get_prefix(curr_path []rune) string {
	return string(curr_path)
}

func get_suffix(collected map[rune]bool) string {
	runes := make([]int, 0)
	for r, seen := range collected {
		if seen {
			continue
		}
		runes = append(runes, int(r))
	}
	sort.Ints(runes)
	r_arr := make([]rune, len(runes))
	for i, r := range runes {
		r_arr[i] = rune(r)
	}
	return string(r_arr)
}

func calc_cache_key(tgt rune, visited map[rune]bool) string {
	needed_runes := make([]int, 0)
	for r, ok := range visited {
		if r == tgt {
			continue
		}
		if !ok {
			needed_runes = append(needed_runes, int(r))
		}
	}
	sort.Ints(needed_runes)
	cache_key_runes := make([]rune, 1)
	cache_key_runes[0] = tgt
	for _, r := range needed_runes {
		cache_key_runes = append(cache_key_runes, rune(r))
	}
	return string(cache_key_runes)
}

func best_path(
	start_rune rune,
	pos Point,
	grid [][]rune,
	keypos map[rune]Point,
	path_length int,
	collected map[rune]bool,
	still_needed int,
	curr_path []rune,
	min_path int,
	best_distances map[RunePair]int,
	current_set MapSet,
	sets_by_gate map[rune][2]MapSet,
	requires map[rune][]rune) int {

	if still_needed == 0 {
		fmt.Print(path_length)
		for _, ch := range curr_path {
			fmt.Print(" ", string(ch))
		}
		fmt.Println()
		return path_length
	}

	needed_runes := make([]int, 0)
	for r, ok := range collected {
		if !ok {
			needed_runes = append(needed_runes, int(r))
		}
	}
	sort.Ints(needed_runes)
	cache_key_runes := make([]rune, 1)
	cache_key_runes[0] = start_rune
	for _, r := range needed_runes {
		cache_key_runes = append(cache_key_runes, rune(r))
	}
	cache_key := string(cache_key_runes)
	/*    if res, ok := bp_cache[cache_key]; ok {
	          return path_length + res
	      }
	*/
	//visited := make(map[Point]int)
	visited_by_tgt := make(map[rune]map[Point]bool)
	found := make(map[rune]bool)
	mds_by_tgt := make(map[rune]int)
	visiting := pq.New()
	for tgt, seen := range collected {
		if seen {
			continue
		}
		if _, ok := current_set.keys[tgt]; !ok {
			continue
		}
		collected[tgt] = true
		cset := recurseJoinSets(current_set, sets_by_gate[unicode.ToUpper(tgt)], sets_by_gate, collected)
		//        fmt.Println("trying to get mds for ", string(tgt))
		mds_by_tgt[tgt] = get_min_dist_sum(tgt, collected, best_distances, cset, sets_by_gate)
		collected[tgt] = false
		visiting.Insert(QState{path_length, tgt, pos}, heuristic(pos, keypos[tgt])-float64(mds_by_tgt[tgt]))
		visited_by_tgt[tgt] = make(map[Point]bool)
		found[tgt] = false
	}
	//fmt.Println("got mds_by_tgt", still_needed)
	keys_found := 0
	iter := 0
	for visiting.Len() > 0 {
		popreq, _ := visiting.Pop()
		state := popreq.(QState)
		//fmt.Println(state)
		iter++
		if iter%400 == 0 {
			//            fmt.Println(still_needed, keys_found, iter, state, found[state.tgt],  min_path, state.dist - int(heuristic(keypos[state.tgt], state.p)) + mds_by_tgt[state.tgt] ,  curr_path)
		}
		if found[state.tgt] {
			continue
		}

		//        if start_rune != '@' && state.dist - path_length > best_distances[RunePair{start_rune,state.tgt}] {
		//fmt.Println("giving up...")
		//            continue
		//        }

		if grid[state.p.y][state.p.x] == state.tgt {
			found[state.tgt] = true
			keys_found++
			npath := append(curr_path, state.tgt)
			collected[state.tgt] = true
			cset := recurseJoinSets(current_set, sets_by_gate[unicode.ToUpper(state.tgt)], sets_by_gate, collected)
			path := best_path(state.tgt, state.p, grid, keypos, state.dist, collected, still_needed-1, npath, min_path, best_distances, cset, sets_by_gate, requires)
			if path < min_path {
				min_path = path
				fmt.Println("new minpath ", min_path, get_prefix(curr_path), string(state.tgt), get_suffix(collected))
			}
			collected[state.tgt] = false
			if keys_found == still_needed {
				bp_cache[cache_key] = min_path - path_length
				return min_path
			}
			continue
		}

		//		if min_path > 0 && min_path < state.dist - int(heuristic(state.tgt, state.p)) + get_min_dist_sum(state.tgt, collected, best_distances) {
		//			return min_path
		//		}

		for _, dir := range dirs {
			x := state.p.x + dir[0]
			y := state.p.y + dir[1]
			p := Point{x, y}
			if grid[y][x] == '#' {
				continue
			}
			if visited_by_tgt[state.tgt][Point{x, y}] {
				continue
			}
			if unicode.IsLetter(grid[y][x]) && unicode.IsUpper(grid[y][x]) && !collected[unicode.ToLower(grid[y][x])] {
				continue
			}
			if unicode.IsLetter(grid[y][x]) && unicode.IsLower(grid[y][x]) && !collected[grid[y][x]] && grid[y][x] != state.tgt {
				continue
			}
			dist := state.dist + 1
			//if start_rune != '@' && dist - path_length > best_distances[RunePair{start_rune,state.tgt}] {
			//fmt.Println("giving up...")
			//   continue
			//}

			if min_path > 0 && min_path < dist-int(heuristic(keypos[state.tgt], state.p))+bp_cache[calc_cache_key(state.tgt, collected)] {
				continue
			}
			prio := heuristic(keypos[state.tgt], state.p) - float64(mds_by_tgt[state.tgt]) - float64(dist)
			visited_by_tgt[state.tgt][p] = true
			visiting.Insert(QState{dist, state.tgt, p}, prio)

		}
	}
	bp_cache[cache_key] = min_path - path_length
	return min_path
}

type MapSet struct {
	points map[Point]bool
	doors  map[rune]Point
	keys   map[rune]Point
}

func recurseJoinSets(a MapSet, bsets [2]MapSet, sets_by_gate map[rune][2]MapSet, keys map[rune]bool) MapSet {
	new_set := a
	can_join0 := false
	for a_door, _ := range a.doors {
		for b_door, _ := range bsets[0].doors {
			if a_door == b_door && keys[unicode.ToLower(a_door)] {
				can_join0 = true
				break
			}
		}
		if can_join0 {
			break
		}
	}
	if can_join0 {
		new_set = joinSets(a, bsets[0])
	}
	can_join1 := false
	for a_door, _ := range a.doors {
		for b_door, _ := range bsets[1].doors {
			if a_door == b_door && keys[unicode.ToLower(a_door)] {
				can_join1 = true
				break
			}
		}
		if can_join1 {
			break
		}
	}
	if can_join1 {
		new_set = joinSets(new_set, bsets[1])
	}
	if len(a.doors) == len(new_set.doors) && len(a.keys) == len(new_set.keys) {
		return new_set
	}
	for key, _ := range keys {
		new_set = recurseJoinSets(new_set, sets_by_gate[unicode.ToUpper(key)], sets_by_gate, keys)
	}
	return new_set
}

func joinSets(a, b MapSet) MapSet {
	new_set := MapSet{make(map[Point]bool), make(map[rune]Point), make(map[rune]Point)}
	for k, v := range a.points {
		new_set.points[k] = v
	}
	for k, v := range b.points {
		new_set.points[k] = v
	}
	for k, v := range a.doors {
		new_set.doors[k] = v
	}
	for k, v := range b.doors {
		new_set.doors[k] = v
	}
	for k, v := range a.keys {
		new_set.keys[k] = v
	}
	for k, v := range b.keys {
		new_set.keys[k] = v
	}
	return new_set
}

type SetQueueItem struct {
	p       Point
	set_idx int
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
	start := Point{0, 0}
	keypos := make(map[rune]Point)
	for y, line := range string_data {
		runes := []rune(line)
		grid[y] = runes
		for x, ch := range runes {
			if ch == '@' {
				start.x = x
				start.y = y
				continue
			}
			if unicode.IsLetter(ch) && unicode.IsLower(ch) {
				collected[ch] = false
				keypos[ch] = Point{x, y}
				needed_keys++
			}
		}
	}
	visited := make(map[Point]bool)
	visiting := pq.New()
	visiting.Insert(SetQueueItem{start, 0}, 0)
	all_sets := make([]MapSet, 0)
	sets_by_key := make(map[rune]MapSet)
	set_by_key_idx := make(map[rune]int)
	sets_by_gate := make(map[rune][2]MapSet)
	set_by_gate_idx := make(map[rune][2]int)
	initial_set := MapSet{make(map[Point]bool), make(map[rune]Point), make(map[rune]Point)}
	sets_by_key['@'] = initial_set
	all_sets = append(all_sets, sets_by_key['@'])
	for visiting.Len() > 0 {
		popreq, _ := visiting.Pop()
		pnt := popreq.(SetQueueItem)
		for _, dir := range dirs {
			x := pnt.p.x + dir[0]
			y := pnt.p.y + dir[1]
			p := Point{x, y}
			if grid[y][x] == '#' {
				continue
			}
			if visited[p] {
				continue
			}
			visited[p] = true
			set := all_sets[pnt.set_idx]
			//      set.points[p] = true
			if unicode.IsLetter(grid[p.y][p.x]) && unicode.IsUpper(grid[p.y][p.x]) {
				idx := len(all_sets)
				newset := MapSet{make(map[Point]bool), make(map[rune]Point), make(map[rune]Point)}
				//            newset.points[p] = true
				newset.doors[grid[p.y][p.x]] = p
				set.doors[grid[p.y][p.x]] = p
				sets_by_gate[grid[p.y][p.x]] = [2]MapSet{set, newset}
				set_by_gate_idx[grid[p.y][p.x]] = [2]int{pnt.set_idx, idx}
				all_sets = append(all_sets, newset)
				visiting.Insert(SetQueueItem{p, idx}, 0)
				continue
			}
			if unicode.IsLetter(grid[p.y][p.x]) && unicode.IsLower(grid[p.y][p.x]) {
				sets_by_key[grid[p.y][p.x]] = set
				set_by_key_idx[grid[p.y][p.x]] = pnt.set_idx
				set.keys[grid[p.y][p.x]] = p
			}
			visiting.Insert(SetQueueItem{p, pnt.set_idx}, 0)
		}
	}

	requires := make(map[rune][]rune)
	for key, _ := range keypos {
		if _, ok := sets_by_key['@'].keys[key]; ok {
			requires[key] = make([]rune, 0)
		} else {
			visited := make(map[int]bool)
			path := make(map[int]int)
			path[set_by_key_idx[key]] = -1
			sq := pq.New()
			sq.Insert(set_by_key_idx[key], 0)
			visited[set_by_key_idx[key]] = true

			for sq.Len() > 0 {
				popreq, _ := sq.Pop()
				set_idx := popreq.(int)
				set := all_sets[set_idx]
				if 0 == set_idx {
					break
				}
				for d, _ := range set.doors {
					for _, s := range set_by_gate_idx[d] {
						if s == set_idx {
							continue
						}
						if visited[s] {
							continue
						}
						visited[s] = true
						path[s] = set_idx
						sq.Insert(s, 0)
					}
				}
			}
			requires[key] = make([]rune, 0)
			pset_idx := 0
			for {
				set_idx, _ := path[pset_idx]
				if set_idx == -1 {
					break
				}
				set := all_sets[set_idx]
				pset := all_sets[pset_idx]

				for a_door, _ := range set.doors {
					for b_door, _ := range pset.doors {
						if a_door == b_door {
							requires[key] = append(requires[key], unicode.ToLower(a_door))
						}
					}
				}
				pset_idx = set_idx
			}
		}
	}

	//    fmt.Println(requires)
	/*   collected['j'] = true
	test_set := recurseJoinSets(sets_by_key['@'], sets_by_gate['J'], sets_by_gate, collected)
	fmt.Println(test_set)
	fmt.Println(sets_by_key['@'])
	fmt.Println(sets_by_gate['J'])
	return
	*/
	/*
	   for _, s := range all_sets {
	       fmt.Println(s)
	   }
	   for k, set := range sets_by_key {
	       fmt.Println(string(k),set)
	   }
	   for k, sets := range sets_by_gate {
	       fmt.Println(string(k))
	       for _,s := range sets {
	           fmt.Println(s)
	      }
	   }
	   return
	*/
	keypos['@'] = start
	best_distances := find_best_distances(grid, keypos)
	delete(keypos, '@')
	path := make([]rune, 0)
	answer := best_path('@', start, grid, keypos, 0, collected, needed_keys, path, 1000000000000000, best_distances, sets_by_key['@'], sets_by_gate, requires)
	//fmt.Println(bp_cache)
	fmt.Println(answer)
}
