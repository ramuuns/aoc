package main

import (
	"fmt"
	"gopkg.in/karalabe/cookiejar.v1/collections/deque"
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
	input, err := ioutil.ReadFile("input-15")
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
	prog_queue := deque.New()
	visited := make(map[Point]bool)
	visited[Point{0, 0}] = true
	prog_queue.PushLeft(PState{0, Point{0, 0}, p})

	var dirmap = map[int][2]int{
		1: [2]int{0, 1},
		2: [2]int{0, -1},
		3: [2]int{1, 0},
		4: [2]int{-1, 0},
	}

	for !prog_queue.Empty() {
		popreq := prog_queue.PopRight()
		state := popreq.(PState)
		done := false
		for dir := 1; dir < 5; dir++ {
			x := state.point.x + dirmap[dir][0]
			y := state.point.y + dirmap[dir][1]
			if visited[Point{x, y}] {
				continue
			}
			visited[Point{x, y}] = true
			prog := state.program.duplicate()
			out, cont := prog.run_until_output(dir)
			if cont == false {
				continue
			}
			if out == 2 {
				fmt.Println("Done: ", state.dist+1)
				done = true
				break
			} else if out == 1 {
				prog_queue.PushLeft(PState{state.dist + 1, Point{x, y}, prog})
			}
		}
		if done {
			break
		}
	}

}
