package main

import (
	"bufio"
	"fmt"
	"io/ioutil"
	"os"
	"strconv"
	"strings"
)

func get_param(idx, mode int, data map[int]int, mode_base int) int {
	var ret int
	var ok bool
	if mode == 1 {
		ret, ok = data[idx]
	} else if mode == 0 {
		ret, ok = data[data[idx]]
	} else {
		// mode 2
		ret, ok = data[data[idx]+mode_base]
	}
	if !ok {
		return 0
	}
	return ret
}

func get_dest_param(idx int, mode int, data map[int]int, mode_base int) int {
	ret, ok := data[idx]
	if !ok {
		ret = 0
	}
	if mode == 0 {
		return ret
	} else {
		return ret + mode_base
	}
}

func run_program(data map[int]int) {
	ip := 0
	mode_base := 0
	reader := bufio.NewReader(os.Stdin)

	for data[ip] != 99 {
		var opcode = data[ip] % 100
		var p1_mode = data[ip] % 1000 / 100
		var p2_mode = data[ip] % 10000 / 1000
		var p3_mode = data[ip] % 100000 / 10000
		switch opcode {
		case 1:
			var val1 = get_param(ip+1, p1_mode, data, mode_base)
			var val2 = get_param(ip+2, p2_mode, data, mode_base)
			var dst = get_dest_param(ip+3, p3_mode, data, mode_base)
			data[dst] = val1 + val2
			ip += 4
		case 2:
			var val1 = get_param(ip+1, p1_mode, data, mode_base)
			var val2 = get_param(ip+2, p2_mode, data, mode_base)
			var dst = get_dest_param(ip+3, p3_mode, data, mode_base)
			data[dst] = val1 * val2
			ip += 4
		case 3:
			fmt.Print(">")
			text, _ := reader.ReadString('\n')
			int_val, err := strconv.Atoi(strings.TrimSpace(text))
			if err != nil {
				fmt.Println(err)
				return
			}
			var dst = get_dest_param(ip+1, p1_mode, data, mode_base)
			data[dst] = int_val
			ip += 2
		case 4:
			var val1 = get_param(ip+1, p1_mode, data, mode_base)
			fmt.Println(val1)
			ip += 2
		case 5:
			var val1 = get_param(ip+1, p1_mode, data, mode_base)
			if val1 != 0 {
				ip = get_param(ip+2, p2_mode, data, mode_base)
			} else {
				ip += 3
			}
		case 6:
			var val1 = get_param(ip+1, p1_mode, data, mode_base)
			if val1 == 0 {
				ip = get_param(ip+2, p2_mode, data, mode_base)
			} else {
				ip += 3
			}
		case 7:
			var val1 = get_param(ip+1, p1_mode, data, mode_base)
			var val2 = get_param(ip+2, p2_mode, data, mode_base)
			var dst = get_dest_param(ip+3, p3_mode, data, mode_base)
			if val1 < val2 {
				data[dst] = 1
			} else {
				data[dst] = 0
			}
			ip += 4
		case 8:
			var val1 = get_param(ip+1, p1_mode, data, mode_base)
			var val2 = get_param(ip+2, p2_mode, data, mode_base)
			var dst = get_dest_param(ip+3, p3_mode, data, mode_base)
			if val1 == val2 {
				data[dst] = 1
			} else {
				data[dst] = 0
			}
			ip += 4
		case 9:
			var val1 = get_param(ip+1, p1_mode, data, mode_base)
			mode_base += val1
			ip += 2
		}
	}
}

func main() {
	input, err := ioutil.ReadFile("input-09")
	if err != nil {
		fmt.Println(err)
		return
	}
	input_as_str := string(input)
	string_data := strings.Split(input_as_str, ",")
	var orig_int_data = make(map[int]int)
	for i, s := range string_data {
		s = strings.TrimSpace(s)
		int_val, err := strconv.Atoi(s)
		if err != nil {
			fmt.Println(err)
			return
		}
		orig_int_data[i] = int_val
	}

	run_program(orig_int_data)

}
