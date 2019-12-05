package main

import(
	"fmt"
	"io/ioutil"
	"bufio"
	"os"
	"strings"
	"strconv"
)

func get_param(idx, mode int, data[]int) int {
	if mode == 1 {
		return data[idx]
	} else {
		return data[data[idx]]
	}
}

func main() {
	input, err := ioutil.ReadFile("input-05")
	if err != nil {
		fmt.Println(err)
		return
	}
	input_as_str := string(input)
	string_data := strings.Split(input_as_str,",")
	var orig_int_data = make([]int, len(string_data))
	for i, s := range(string_data) {
		s = strings.TrimSpace(s)
		int_val, err := strconv.Atoi(s)
		if err != nil {
			fmt.Println(err)
			return
		}
		orig_int_data[i] = int_val
	}

	reader := bufio.NewReader(os.Stdin)

	ip := 0

	for orig_int_data[ip] != 99 {
		var opcode  = orig_int_data[ip] % 100
		var p1_mode = orig_int_data[ip] % 1000 / 100
		var p2_mode = orig_int_data[ip] % 10000 / 1000
		//var p3_mode = orig_int_data[ip] % 100000 / 10000
		switch opcode {
		case 1:
			var val1 = get_param(ip+1, p1_mode, orig_int_data)
			var val2 = get_param(ip+2, p2_mode, orig_int_data)
			var dst = orig_int_data[ip+3]
			orig_int_data[dst] = val1+val2
			ip+=4
		case 2:
			var val1 = get_param(ip+1, p1_mode, orig_int_data)
            var val2 = get_param(ip+2, p2_mode, orig_int_data)
            var dst = orig_int_data[ip+3]
            orig_int_data[dst] = val1*val2
            ip+=4
		case 3:
			fmt.Print(">")
			text, _ := reader.ReadString('\n')
			int_val, err := strconv.Atoi(strings.TrimSpace(text))
			if err != nil {
				fmt.Println(err)
				return
			}
			var dst = orig_int_data[ip+1]
			orig_int_data[dst] = int_val
			ip+=2
		case 4:
			var val1 = get_param(ip+1, p1_mode, orig_int_data)
			fmt.Println(val1)
			ip+=2
		case 5:
			var val1 = get_param(ip+1, p1_mode, orig_int_data)
			if ( val1 != 0 ) {
				ip = get_param(ip+2,p2_mode,orig_int_data)
			} else {
				ip+=3
			}
		case 6:
			var val1 = get_param(ip+1, p1_mode, orig_int_data)
            if ( val1 == 0 ) {
                ip = get_param(ip+2,p2_mode,orig_int_data)
            } else {
                ip+=3
            }
		case 7:
			var val1 = get_param(ip+1, p1_mode, orig_int_data)
            var val2 = get_param(ip+2, p2_mode, orig_int_data)
            var dst = orig_int_data[ip+3]
			if val1 < val2 {
				orig_int_data[dst] = 1
			} else {
				orig_int_data[dst] = 0
			}
			ip += 4
		case 8:
			var val1 = get_param(ip+1, p1_mode, orig_int_data)
            var val2 = get_param(ip+2, p2_mode, orig_int_data)
            var dst = orig_int_data[ip+3]
            if val1 == val2 {
                orig_int_data[dst] = 1
            } else {
                orig_int_data[dst] = 0
            }
            ip += 4
		}
	}

}
