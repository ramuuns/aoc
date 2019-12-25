package main

import (
	"fmt"
	//	"gopkg.in/karalabe/cookiejar.v1/collections/deque"
	//	"bufio"
	"io/ioutil"
	//	"os"
	"strconv"
	"strings"
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
	ip                  int
	mode_base           int
	data                []int
	input               []int
	last_read_was_empty bool
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
	return Program{p.ip, p.mode_base, data, p.input, p.last_read_was_empty}
}

func (p *Program) append_input(input []int) {
	p.input = append(p.input, input...)
}

func (p *Program) run_one_command() (int, bool) {

	ip := &p.ip
	mode_base := &p.mode_base
	//	reader := bufio.NewReader(os.Stdin)
	//    empty_cnt := 5

	for p.data[*ip] != 99 {
		//fmt.Println(p)
		var opcode = p.data[*ip] % 100
		var p1_mode = p.data[*ip] % 1000 / 100
		var p2_mode = p.data[*ip] % 10000 / 1000
		var p3_mode = p.data[*ip] % 100000 / 10000
		//        fmt.Println("ip:",*ip," opcode: ", opcode, "modes:", [3]int{p1_mode,p2_mode,p3_mode})
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
			//          fmt.Println("set ", dst, "to ", val1, "+" , val2, " = ", val1+val2)
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
			//            fmt.Println("set ", dst, "to ", val1, "*" , val2, " = ", val1*val2)
			p.data[dst] = val1 * val2
			*ip += 4
		case 3:
			//int_val := input
			//fmt.Print(">")
			//text, _, _ := reader.ReadRune()
			int_val := -1
			if len(p.input) > 0 {
				int_val, p.input = p.input[0], p.input[1:]
				p.last_read_was_empty = false
			} else {
				p.last_read_was_empty = true
			}
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
			//            fmt.Println("set", dst, "to", int_val)
			p.data[dst] = int_val
			*ip += 2
		case 4:
			var val1 = get_param(*ip+1, p1_mode, p.data, *mode_base)
			//            fmt.Println("outputting", val1)
			*ip += 2
			return val1, true
		case 5:
			var val1 = get_param(*ip+1, p1_mode, p.data, *mode_base)
			//            fmt.Println(val1, " != 0 ?", val1 != 0)
			if val1 != 0 {
				*ip = get_param(*ip+2, p2_mode, p.data, *mode_base)
				//                fmt.Println("jumping to, ",*ip )
			} else {
				*ip += 3
			}
		case 6:
			var val1 = get_param(*ip+1, p1_mode, p.data, *mode_base)
			//            fmt.Println(val1, " == 0 ?", val1 == 0)
			if val1 == 0 {
				*ip = get_param(*ip+2, p2_mode, p.data, *mode_base)
				//                fmt.Println("jumping to, ",*ip )
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
			//            fmt.Println("setting", dst, "to 1 if", val1, "<", val2, " (", val1 < val2,")")
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
			//            fmt.Println("setting", dst, "to 1 if", val1, "=", val2, " (", val1 == val2,")")
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
			//            fmt.Println("adjusting relative base by", val1, "it is now", *mode_base)
			*ip += 2
		}
		return -1, true
	}

	return 0, false
}

func main() {
	input, err := ioutil.ReadFile("input-23")
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

	network := make([]Program, 50)
	dst_for_message_by_src := make(map[int]int)
	xval_by_src := make(map[int]int)
	has_xval_by_src := make(map[int]bool)
	has_addr_by_src := make(map[int]bool)

	for i := 0; i < 50; i++ {
		program_copy := make([]int, len(string_data))
		copy(program_copy, orig_int_data)
		network[i] = Program{0, 0, program_copy, make([]int, 1), false}
		network[i].input[0] = i
		dst_for_message_by_src[i] = -1
	}
	fmt.Println("set up computers")

	//    should_break := false

	idx_255 := 0
	has_255 := false
	has_xval := false
	xval_255 := 0
	yval_255 := 0

	last_y_val_sent := 0

	k := 0
	for {
		all_idle := true
		for i := 0; i < 50; i++ {
			//           fmt.Println(i)
			//          fmt.Println("gonna run computer", i, "with input", network[i].input)
			idx, cont := network[i].run_one_command()
			if !network[i].last_read_was_empty {
				all_idle = false
			}
			if idx == -1 {
				//          fmt.Println("computer ", i, "has nothing to do and isn't saying things")
				continue
			}
			if cont == false {
				fmt.Println("exiting...")
				break
			}
			fmt.Println("computer", i, "responded with", idx)
			if has_255 && idx_255 == i && has_xval {
				yval_255 = idx
				has_255 = false
				has_xval = false
				continue
			} else if has_255 && idx_255 == i {
				has_xval = true
				xval_255 = idx
				continue
			}
			if idx < 50 && !has_addr_by_src[i] {
				dst_for_message_by_src[i] = idx
				has_addr_by_src[i] = true
				has_xval_by_src[i] = false
				fmt.Println("set message target", idx, "for computer", i)
			} else {
				if idx == 255 && !has_addr_by_src[i] {
					has_255 = true
					idx_255 = i
				} else {
					if has_xval_by_src[i] {
						network[dst_for_message_by_src[i]].input = append(network[dst_for_message_by_src[i]].input, xval_by_src[i], idx)
						has_xval_by_src[i] = false
						has_addr_by_src[i] = false
						fmt.Println("computer", i, "is sending ", xval_by_src[i], idx, "to computer", dst_for_message_by_src[i], "on tick", k)
					} else {
						has_xval_by_src[i] = true
						xval_by_src[i] = idx
					}
				}
			}
		}

		if all_idle && yval_255 != 0 {
			if yval_255 == last_y_val_sent {
				fmt.Println("twice in a row sending ", yval_255, "on tick", k)
				break
			}
			last_y_val_sent = yval_255
			network[0].input = append(network[0].input, xval_255, yval_255)
			xval_255 = 0
			yval_255 = 0
		}
		k++
	}

}
