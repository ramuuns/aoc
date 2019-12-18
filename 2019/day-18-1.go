package main

import (
	"fmt"
	"strings"
	"gopkg.in/karalabe/cookiejar.v1/collections/deque"
	"io/ioutil"
	"unicode"
)

var dirs = [4][2]int {
	[2]int{0,-1},
	[2]int{1,0},
	[2]int{0,1},
	[2]int{-1,0},
}

type QState struct {
	dist int
	p Point
}

type Point struct {
	x int
	y int
}

func best_path(pos Point, grid [][]rune, path_length int, collected map[rune]bool, still_needed int, curr_path[]rune, min_path int) int {
	if still_needed == 0 {
		fmt.Println(path_length, curr_path)
		return path_length
	}
	visited:= make(map[Point]bool)
	visiting := deque.New()
	visiting.PushLeft(QState{path_length,pos})
	keys_found := 0
	for !visiting.Empty() {
		popreq := visiting.PopRight()
        state := popreq.(QState)
		if min_path > 0 && min_path <= state.dist {
			return min_path
		}

		for _, dir := range dirs {
			x:= state.p.x + dir[0]
			y:= state.p.y + dir[1]
			if grid[y][x] == '#' {
				continue
			}
			if visited[Point{x,y}] {
				continue
			}
			if unicode.IsLetter(grid[y][x] ) {
				if unicode.IsUpper(grid[y][x]) && !collected[unicode.ToLower(grid[y][x])] {
					continue
				}
				if unicode.IsLower(grid[y][x]) && !collected[unicode.ToLower(grid[y][x])] {
					keys_found++
					collected[grid[y][x]] = true
					npath := append(curr_path,grid[y][x])
					path := best_path(Point{x,y}, grid, state.dist + 1, collected, still_needed - 1, npath, min_path)
					collected[grid[y][x]] = false
					if min_path == -1 || path < min_path {
						min_path = path
					}
					if (keys_found == still_needed ) {
						return min_path;
					}
				}
			}
			visited[Point{x,y}] = true
			visiting.PushLeft(QState{state.dist + 1,Point{x,y}})
		}
	}
	return min_path
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
				needed_keys++
			}
		}
	}
	path := make([]rune,0)
	answer := best_path(start,grid,0,collected,needed_keys,path, -1, needed_keys)
	fmt.Println(answer)
}

