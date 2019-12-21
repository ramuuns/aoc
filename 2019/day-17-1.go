package main

import (
	"fmt"
	//	"gopkg.in/karalabe/cookiejar.v1/collections/deque"
	"io/ioutil"
	"strconv"
	"strings"
	//	"os"
	//	"bufio"
)

func get_param(idx, mode int, data []int, mode_base int) int {
	var ret int
	if mode == 1 {
		ret = data[idx]
	} else if mode == 0 {
		if data[idx] >= len(data) {
			return 0
		}
		ret = data[data[idx]]
	} else {
		// mode 2
		if data[idx]+mode_base >= len(data) {
			return 0
		}
		ret = data[data[idx]+mode_base]
	}
	return ret
}

func get_dest_param(idx int, mode int, data []int, mode_base int) int {
	ret := data[idx]
	if mode == 0 {
		return ret
	} else {
		return ret + mode_base
	}
}

type Point struct {
	x int
	y int
}

type Program struct {
	ip        int
	mode_base int
	data      []int
}

type PState struct {
	dist    int
	point   Point
	program Program
}

type VState struct {
	dist  int
	point Point
}

func (p *Program) duplicate() Program {
	data := make([]int, len(p.data))
	copy(data, p.data)
	return Program{p.ip, p.mode_base, data}
}

func (p *Program) run_until_output(input int) (int, bool) {

	ip := &p.ip
	mode_base := &p.mode_base

	for p.data[*ip] != 99 {
		//fmt.Println(p)
		var opcode = p.data[*ip] % 100
		var p1_mode = p.data[*ip] % 1000 / 100
		var p2_mode = p.data[*ip] % 10000 / 1000
		var p3_mode = p.data[*ip] % 100000 / 10000
		switch opcode {
		case 1:
			var val1 = get_param(*ip+1, p1_mode, p.data, *mode_base)
			var val2 = get_param(*ip+2, p2_mode, p.data, *mode_base)
			var dst = get_dest_param(*ip+3, p3_mode, p.data, *mode_base)
			if dst >= len(p.data) {
				data_ := make([]int, dst+1)
				copy(data_, p.data)
				p.data = data_
			}
			p.data[dst] = val1 + val2
			*ip += 4
		case 2:
			var val1 = get_param(*ip+1, p1_mode, p.data, *mode_base)
			var val2 = get_param(*ip+2, p2_mode, p.data, *mode_base)
			var dst = get_dest_param(*ip+3, p3_mode, p.data, *mode_base)
			if dst >= len(p.data) {
				data_ := make([]int, dst+1)
				copy(data_, p.data)
				p.data = data_
			}
			p.data[dst] = val1 * val2
			*ip += 4
		case 3:
			int_val := input
			//fmt.Print(">")
			//text, _ := reader.ReadString('\n')
			//int_val, err := strconv.Atoi(strings.TrimSpace(text))
			//if err != nil {
			//    fmt.Println(err)
			//    return io
			//}
			var dst = get_dest_param(*ip+1, p1_mode, p.data, *mode_base)
			if dst >= len(p.data) {
				data_ := make([]int, dst+1)
				copy(data_, p.data)
				p.data = data_
			}
			p.data[dst] = int_val
			*ip += 2
		case 4:
			var val1 = get_param(*ip+1, p1_mode, p.data, *mode_base)
			*ip += 2
			return val1, true
		case 5:
			var val1 = get_param(*ip+1, p1_mode, p.data, *mode_base)
			if val1 != 0 {
				*ip = get_param(*ip+2, p2_mode, p.data, *mode_base)
			} else {
				*ip += 3
			}
		case 6:
			var val1 = get_param(*ip+1, p1_mode, p.data, *mode_base)
			if val1 == 0 {
				*ip = get_param(*ip+2, p2_mode, p.data, *mode_base)
			} else {
				*ip += 3
			}
		case 7:
			var val1 = get_param(*ip+1, p1_mode, p.data, *mode_base)
			var val2 = get_param(*ip+2, p2_mode, p.data, *mode_base)
			var dst = get_dest_param(*ip+3, p3_mode, p.data, *mode_base)
			if dst >= len(p.data) {
				data_ := make([]int, dst+1)
				copy(data_, p.data)
				p.data = data_
			}
			if val1 < val2 {
				p.data[dst] = 1
			} else {
				p.data[dst] = 0
			}
			*ip += 4
		case 8:
			var val1 = get_param(*ip+1, p1_mode, p.data, *mode_base)
			var val2 = get_param(*ip+2, p2_mode, p.data, *mode_base)
			var dst = get_dest_param(*ip+3, p3_mode, p.data, *mode_base)
			if dst >= len(p.data) {
				data_ := make([]int, dst+1)
				copy(data_, p.data)
				p.data = data_
			}
			if val1 == val2 {
				p.data[dst] = 1
			} else {
				p.data[dst] = 0
			}
			*ip += 4
		case 9:
			//	fmt.Println(*ip+1, p1_mode, p.data, *mode_base)
			var val1 = get_param(*ip+1, p1_mode, p.data, *mode_base)
			//	fmt.Println(val1)
			*mode_base += val1
			*ip += 2
		}
	}

	return 0, false
}

func main() {
	input, err := ioutil.ReadFile("input-17")
	if err != nil {
		fmt.Println(err)
		return
	}
	input_as_str := string(input)
	string_data := strings.Split(input_as_str, ",")
	var orig_int_data = make([]int, len(string_data))
	for i, s := range string_data {
		s = strings.TrimSpace(s)
		int_val, err := strconv.Atoi(s)
		if err != nil {
			fmt.Println(err)
			return
		}
		orig_int_data[i] = int_val
	}

	p := Program{0, 0, orig_int_data}
	x := 0
	y := 0
	max_x := 0
	grid := make([][]int, 1)
	maybe_cross := make([]Point, 0)
	path_ch := int('#')
	for {
		ch, cont := p.run_until_output(0)
		if !cont {
			break
		}
		fmt.Printf("%c", ch)
		grid[y] = append(grid[y], ch)
		if ch == path_ch && y > 0 && x > 0 {
			if grid[y][x-1] == path_ch && grid[y-1][x] == path_ch {
				maybe_cross = append(maybe_cross, Point{x, y})
			}
		}
		x++
		if ch == 10 {
			grid = append(grid, make([]int, 0))
			y++
			if x > max_x {
				max_x = x
			}
			x = 0
		}
	}

	y--
	max_y := y

	fmt.Println(max_x, max_y)
	sum := 0
	for _, p := range maybe_cross {
		fmt.Println(p)
		if p.y < max_y && p.x < max_x {
			if p.y == 38 {
				continue
			}
			if grid[p.y+1][p.x] == grid[p.y][p.x+1] && grid[p.y+1][p.x] == grid[p.y][p.x] {
				sum += p.x * p.y
			}
		}
	}

	fmt.Println(sum)

}
