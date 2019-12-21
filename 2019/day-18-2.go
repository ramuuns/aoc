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
	idx  int
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

func get_min_dist_sum(start rune, visited map[rune]bool, best_distances map[RunePair]int, keypos_this_partition map[rune]Point) int {
	key := make([]int, 0)
	for tgt, seen := range visited {
		if _, ok := keypos_this_partition[tgt]; !ok {
			continue
		}
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
		if _, ok := keypos_this_partition[tgt]; !ok {
			continue
		}
		if minsum < best_distances[RunePair{start, tgt}] {
			continue
		}
		found_any = true
		visited[tgt] = true
		sum := best_distances[RunePair{start, tgt}]
		sum += get_min_dist_sum(tgt, visited, best_distances, keypos_this_partition)
		visited[tgt] = false
		if sum < minsum {
			minsum = sum
		}
	}
	if !found_any {
		fmt.Println("no route found :O")
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
	visiting.Insert(QState{0, 'a', 0, pos}, 0)
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
			visiting.Insert(QState{state.dist + 1, 'a', 0, p}, heuristic(p, tgt)-float64(state.dist+1))
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

func calc_cache_key(tgt rune, visited map[rune]bool, robots []Robot, index int) string {
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
	cache_key_runes := make([]rune, 4)
	for i := 0; i < 4; i++ {
		if i == index {
			cache_key_runes[i] = tgt
		} else {
			cache_key_runes[i] = robots[i].last_key
		}
	}
	for _, r := range needed_runes {
		cache_key_runes = append(cache_key_runes, rune(r))
	}
	return string(cache_key_runes)
}

func best_path(
	robots []Robot,
	grid [][]rune,
	keypos_by_partition []map[rune]Point,
	path_length int,
	collected map[rune]bool,
	still_needed int,
	curr_path []rune,
	min_path int,
	best_distances []map[RunePair]int,
	sets_by_gate map[rune][2]MapSet) int {

	//    fmt.Println(robots)

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
	cache_key_runes := make([]rune, 4)
	for i := 0; i < 4; i++ {
		cache_key_runes[i] = robots[i].last_key
	}
	for _, r := range needed_runes {
		cache_key_runes = append(cache_key_runes, rune(r))
	}
	cache_key := string(cache_key_runes)

	visited_by_tgt := make(map[rune]map[Point]bool)
	found := make(map[rune]bool)
	visiting := pq.New()
	mds_by_tgt := make(map[rune]int)
	for i := 0; i < 4; i++ {
		mds_by_tgt[robots[i].last_key] = get_min_dist_sum(robots[i].last_key, collected, best_distances[i], keypos_by_partition[i])
	}
	for i := 0; i < 4; i++ {

		for tgt, seen := range collected {
			if seen {
				continue
			}
			if _, ok := robots[i].current_set.keys[tgt]; !ok {
				continue
			}
			collected[tgt] = true
			mds_by_tgt[tgt] = get_min_dist_sum(tgt, collected, best_distances[i], keypos_by_partition[i])
			collected[tgt] = false
			mds_sum := mds_by_tgt[tgt]
			for j := 0; j < 4; j++ {
				if j != i {
					mds_sum += mds_by_tgt[robots[j].last_key]
				}
			}
			visiting.Insert(QState{path_length, tgt, i, keypos_by_partition[i][robots[i].last_key]}, heuristic(keypos_by_partition[i][robots[i].last_key], keypos_by_partition[i][tgt])-float64(mds_sum))
			visited_by_tgt[tgt] = make(map[Point]bool)
			found[tgt] = false
		}
	}
	//fmt.Println("got mds_by_tgt", still_needed)
	keys_found := 0
	iter := 0
	for visiting.Len() > 0 {
		popreq, _ := visiting.Pop()
		state := popreq.(QState)
		//      fmt.Println(state)
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
			new_robots := make([]Robot, 4)
			for i := 0; i < 4; i++ {
				new_robots[i].last_key = robots[i].last_key
				new_robots[i].current_set = recurseJoinSets(robots[i].current_set, sets_by_gate[unicode.ToUpper(state.tgt)], sets_by_gate, collected)
			}
			new_robots[state.idx].last_key = state.tgt
			path := best_path(new_robots, grid, keypos_by_partition, state.dist, collected, still_needed-1, npath, min_path, best_distances, sets_by_gate)
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

			if min_path > 0 && min_path < dist-int(heuristic(keypos_by_partition[state.idx][state.tgt], state.p))+bp_cache[calc_cache_key(state.tgt, collected, robots, state.idx)] {
				continue
			}
			mds_sum := mds_by_tgt[state.tgt]
			for i := 0; i < 4; i++ {
				if i != state.idx {
					mds_sum += mds_by_tgt[robots[i].last_key]
				}
			}
			prio := heuristic(keypos_by_partition[state.idx][state.tgt], state.p) - float64(mds_sum) - float64(dist)
			visited_by_tgt[state.tgt][p] = true
			visiting.Insert(QState{dist, state.tgt, state.idx, p}, prio)

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

type Robot struct {
	last_key    rune
	current_set MapSet
}

func main() {
	input, err := ioutil.ReadFile("input-18-2")
	if err != nil {
		fmt.Println(err)
		return
	}
	input_as_str := string(input)
	string_data := strings.Split(strings.TrimSpace(input_as_str), "\n")
	needed_keys := 0
	collected := make(map[rune]bool)
	grid := make([][]rune, len(string_data))
	keypos := make(map[rune]Point)

	start_pos := make([]Point, 4)
	sp_idx := 0
	for y, line := range string_data {
		runes := []rune(line)
		grid[y] = runes
		for x, ch := range runes {
			if ch == '@' {
				start_pos[sp_idx].x = x
				start_pos[sp_idx].y = y
				keypos[ch+rune(sp_idx)] = Point{x, y}
				sp_idx++
				continue
			}
			if unicode.IsLetter(ch) && unicode.IsLower(ch) {
				collected[ch] = false
				keypos[ch] = Point{x, y}
				needed_keys++
			}
		}
	}

	sets_by_start_pos := make([][]MapSet, 4)
	sets_by_key := make(map[rune]MapSet)
	sets_by_gate := make(map[rune][2]MapSet)

	keys_in_partition := make([][]rune, 4)
	keypos_by_partition := make([]map[rune]Point, 4)

	for sp_idx = 0; sp_idx < 4; sp_idx++ {
		keys_in_partition[sp_idx] = make([]rune, 0)
		keypos_by_partition[sp_idx] = make(map[rune]Point)
		keypos_by_partition[sp_idx][rune('@')+rune(sp_idx)] = keypos[rune('@')+rune(sp_idx)]

		visited := make(map[Point]bool)
		visiting := pq.New()
		visiting.Insert(SetQueueItem{start_pos[sp_idx], 0}, 0)
		all_sets := make([]MapSet, 0)
		initial_set := MapSet{make(map[Point]bool), make(map[rune]Point), make(map[rune]Point)}
		sets_by_key[rune('@')+rune(sp_idx)] = initial_set
		all_sets = append(all_sets, sets_by_key[rune('@')+rune(sp_idx)])
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
					all_sets = append(all_sets, newset)
					visiting.Insert(SetQueueItem{p, idx}, 0)
					continue
				}
				if unicode.IsLetter(grid[p.y][p.x]) && unicode.IsLower(grid[p.y][p.x]) {
					sets_by_key[grid[p.y][p.x]] = set
					set.keys[grid[p.y][p.x]] = p
					keys_in_partition[sp_idx] = append(keys_in_partition[sp_idx], grid[p.y][p.x])
					keypos_by_partition[sp_idx][grid[p.y][p.x]] = keypos[grid[p.y][p.x]]
				}
				visiting.Insert(SetQueueItem{p, pnt.set_idx}, 0)
			}
		}
		sets_by_start_pos[sp_idx] = all_sets

	}

	//    fmt.Println(requires)
	/*   collected['j'] = true
	test_set := recurseJoinSets(sets_by_key['@'], sets_by_gate['J'], sets_by_gate, collected)
	fmt.Println(test_set)
	fmt.Println(sets_by_key['@'])
	fmt.Println(sets_by_gate['J'])
	return
	*/

	for i, sets := range sets_by_start_pos {
		fmt.Println(i)
		for _, s := range sets {
			fmt.Println(s)
		}
	}
	for k, set := range sets_by_key {
		fmt.Println(string(k), set)
	}
	for k, sets := range sets_by_gate {
		fmt.Println(string(k))
		for _, s := range sets {
			fmt.Println(s)
		}
	}

	best_distances := make([]map[RunePair]int, 4)
	robots := make([]Robot, 4)

	for i := 0; i < 4; i++ {
		best_distances[i] = find_best_distances(grid, keypos_by_partition[i])
		robots[i] = Robot{rune('@') + rune(i), sets_by_key[rune('@')+rune(i)]}
	}

	path := make([]rune, 0)
	answer := best_path(robots, grid, keypos_by_partition, 0, collected, needed_keys, path, 10000000000, best_distances, sets_by_gate)
	fmt.Println(answer)

	return

	//keypos['@'] = start;
	//best_distances := find_best_distances(grid, keypos);
	//delete(keypos, '@')
	//path := make([]rune,0)
	//answer := best_path('@',start,grid,keypos,0,collected,needed_keys,path, 1000000000000000, best_distances, sets_by_key['@'], sets_by_gate )
	//fmt.Println(bp_cache)
	//fmt.Println(answer)
}
