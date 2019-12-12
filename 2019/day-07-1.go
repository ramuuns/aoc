package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

func get_param(idx, mode int, data []int) int {
	if mode == 1 {
		return data[idx]
	} else {
		return data[data[idx]]
	}
}

func run_program(data []int, stdin []string) string {
	ip := 0
	stdin_ptr := 0
	stdout := ""
	for data[ip] != 99 {
		var opcode = data[ip] % 100
		var p1_mode = data[ip] % 1000 / 100
		var p2_mode = data[ip] % 10000 / 1000
		switch opcode {
		case 1:
			var val1 = get_param(ip+1, p1_mode, data)
			var val2 = get_param(ip+2, p2_mode, data)
			var dst = data[ip+3]
			data[dst] = val1 + val2
			ip += 4
		case 2:
			var val1 = get_param(ip+1, p1_mode, data)
			var val2 = get_param(ip+2, p2_mode, data)
			var dst = data[ip+3]
			data[dst] = val1 * val2
			ip += 4
		case 3:
			text := stdin[stdin_ptr]
			stdin_ptr++
			int_val, err := strconv.Atoi(strings.TrimSpace(text))
			if err != nil {
				fmt.Println(err)
				return "-1"
			}
			var dst = data[ip+1]
			data[dst] = int_val
			ip += 2
		case 4:
			var val1 = get_param(ip+1, p1_mode, data)
			stdout += strconv.Itoa(val1)
			ip += 2
		case 5:
			var val1 = get_param(ip+1, p1_mode, data)
			if val1 != 0 {
				ip = get_param(ip+2, p2_mode, data)
			} else {
				ip += 3
			}
		case 6:
			var val1 = get_param(ip+1, p1_mode, data)
			if val1 == 0 {
				ip = get_param(ip+2, p2_mode, data)
			} else {
				ip += 3
			}
		case 7:
			var val1 = get_param(ip+1, p1_mode, data)
			var val2 = get_param(ip+2, p2_mode, data)
			var dst = data[ip+3]
			if val1 < val2 {
				data[dst] = 1
			} else {
				data[dst] = 0
			}
			ip += 4
		case 8:
			var val1 = get_param(ip+1, p1_mode, data)
			var val2 = get_param(ip+2, p2_mode, data)
			var dst = data[ip+3]
			if val1 == val2 {
				data[dst] = 1
			} else {
				data[dst] = 0
			}
			ip += 4
		}
	}
	return stdout
}

func call_run(data []int, input_0 int, input_1 int) int {
	input_params := make([]string, 2)
	input_params[0] = strconv.Itoa(input_0)
	input_params[1] = strconv.Itoa(input_1)
	ret, _ := strconv.Atoi(run_program(data, input_params))
	return ret
}

func main() {
	input, err := ioutil.ReadFile("input-07")
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

	max := 0

	for i := 0; i < 5; i++ {
		for j := 0; j < 5; j++ {
			if j == i {
				continue
			}
			for k := 0; k < 5; k++ {
				if k == i || k == j {
					continue
				}
				for l := 0; l < 5; l++ {
					if l == i || l == j || l == k {
						continue
					}
					for m := 0; m < 5; m++ {
						if m == i || m == j || m == k || m == l {
							continue
						}
						input := 0
						input = call_run(orig_int_data, i, input)
						input = call_run(orig_int_data, j, input)
						input = call_run(orig_int_data, k, input)
						input = call_run(orig_int_data, l, input)
						input = call_run(orig_int_data, m, input)
						if input > max {
							//fmt.Println(i,j,k,l,m)
							max = input
						}
					}
				}
			}
		}
	}

	fmt.Println(max)
}
