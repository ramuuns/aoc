package main

import (
	"fmt"
	pq "github.com/jupp0r/go-priority-queue"
	"io/ioutil"
	// "sort"
	"strings"
	"unicode"
)

type Point struct {
	x int
	y int
}

type QItem struct {
	pnt  Point
	path int
}

var dirs = [4][2]int{
	[2]int{0, -1},
	[2]int{1, 0},
	[2]int{0, 1},
	[2]int{-1, 0},
}

type VKey struct {
	gate  string
	depth int
}

func main() {
	input, err := ioutil.ReadFile("input-20")
	if err != nil {
		fmt.Println(err)
		return
	}
	input_as_str := string(input)
	string_data := strings.Split(input_as_str, "\n")
	grid := make([][]rune, len(string_data))
	doorpos := make(map[Point]string)
	graph := make(map[string]map[string]int)

	for y, line := range string_data {
		if len(line) == 0 {
			continue
		}
		runes := []rune(line)
		grid[y] = runes
		for x, ch := range runes {
			if unicode.IsLetter(ch) && unicode.IsUpper(ch) {
				if x > 0 && unicode.IsLetter(grid[y][x-1]) && unicode.IsUpper(grid[y][x-1]) {
					door := string([]rune{grid[y][x-1], ch})
					if door != "AA" && door != "ZZ" {
						if x == 1 || x == len(runes)-1 {
							door = door + "1"
						}
					}
					if x > 1 {
						if grid[y][x-2] == '.' {
							doorpos[Point{x - 2, y}] = door
						}
					}
					if x < len(runes)-1 {
						if grid[y][x+1] == '.' {
							doorpos[Point{x + 1, y}] = door
						}
					}
					graph[door] = make(map[string]int)
				}
				if ch == 'A' {
					fmt.Println(x, y)
				}
				if y > 0 && unicode.IsLetter(grid[y-1][x]) && unicode.IsUpper(grid[y-1][x]) {
					door := string([]rune{grid[y-1][x], ch})
					if door != "AA" && door != "ZZ" {
						if y == 1 || y == len(string_data)-2 {
							door = door + "1"
						}
					}
					if y > 1 {
						if grid[y-2][x] == '.' {
							doorpos[Point{x, y - 2}] = door
						} else {
							doorpos[Point{x, y + 1}] = door
						}
					} else {
						doorpos[Point{x, y + 1}] = door
					}
					graph[door] = make(map[string]int)
				}
			}
		}
	}

	fmt.Println(doorpos)

	for start, door := range doorpos {
		//       fmt.Println(door)
		visited := make(map[Point]bool)
		visited[start] = true
		deq := pq.New()
		deq.Insert(QItem{start, 0}, 0)
		for deq.Len() > 0 {
			di, _ := deq.Pop()
			state := di.(QItem)
			for _, dir := range dirs {
				x := state.pnt.x + dir[0]
				y := state.pnt.y + dir[1]
				p := Point{x, y}
				if grid[y][x] != '.' {
					continue
				}
				if visited[p] {
					continue
				}
				visited[p] = true
				if other_door, ok := doorpos[p]; ok {
					//                    fmt.Println(door, other_door, state.path+1)
					graph[door][other_door] = state.path + 1
					//graph[other_door][door] = state.path
					continue
				}
				deq.Insert(QItem{p, state.path + 1}, 0)
			}
		}
	}

	fmt.Println(graph)

	visited := make(map[VKey]bool)
	path_taken := make([]string, 0)

	answer := best_path(graph, "AA", 0, 10000, visited, 0, path_taken)

	fmt.Println(answer)
}

func best_path(graph map[string]map[string]int, start string, path, min_path int, visited map[VKey]bool, depth int, path_taken []string) int {
	if depth > 30 {
		return min_path
	}
	path_taken = append(path_taken, start)
	fmt.Println(depth, start, path, min_path, path_taken, visited)
	visited[VKey{start, depth}] = true
	for node, plen := range graph[start] {
		fmt.Println(depth, "gonna try", node)
		if visited[VKey{node, depth}] {
			fmt.Println(depth, "visited")
			if depth == 0 {
				fmt.Println(visited)
			}
			continue
		}
		if (node == "ZZ" || node == "AA") && depth != 0 {
			continue
		}
		if depth == 0 && len(node) == 3 {
			continue
		}
		if node == "ZZ" {
			if path+plen < min_path {
				min_path = path + plen
				fmt.Println(depth, "new minpath", min_path)
			} else {
				fmt.Println(depth, "path was longer anyway")
			}
			continue
		}
		if path+plen+1 > min_path {
			continue
		}
		o_node := node
		visited[VKey{node, depth}] = true
		pt := append(path_taken, node)
		nd := depth
		if len(node) == 2 {
			nd += 1
			o_node = node + "1"
		} else {
			nd -= 1
			o_node = node[0:2]
		}
		fmt.Println(depth, "will attempt", node)
		p := best_path(graph, o_node, path+plen+1, min_path, visited, nd, pt)
		visited[VKey{node, depth}] = false
		if p < min_path {
			min_path = p
		}
	}
	visited[VKey{start, depth}] = false
	return min_path
}
