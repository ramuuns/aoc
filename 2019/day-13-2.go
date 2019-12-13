package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
	"os"
	"bufio"
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

type Point struct {
	x int
	y int
}

func draw_game(io map[Point]int) {
	miny := 0
    minx := 0
    maxy := 0
    maxx := 0

    for p, _ := range io {
        if p.x < minx {
            minx = p.x
        }
        if p.y < miny {
            miny = p.y
        }
        if p.x > maxx {
            maxx = p.x
        }
        if p.y > maxy {
            maxy = p.y
        }
    }

    offsetx := -minx
    offsety := -miny
    sizex := maxx - minx
    sizey := maxy - miny

    for y := 0; y < sizey; y++ {
        for x := 0; x < sizex + 1; x++ {
            to_draw := io[Point{x - offsetx, y - offsety}]
			switch to_draw {
			case 0:
				fmt.Print(" ")
			case 1:
				fmt.Print("|")
			case 2:
				fmt.Print("#")
			case 3:
				fmt.Print("=")
			case 4:
				fmt.Print("*")
			}
        }
        fmt.Println()
    }

}

func run_program(data map[int]int, io map[Point]int) map[Point]int {
	ip := 0
	mode_base := 0

	x := 0
	y := 0

	ballX := 0
	paddleX := 0
	reader := bufio.NewReader(os.Stdin)

	output_mode := 0

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
			draw_game(io)
			fmt.Print(">")
            text, _ := reader.ReadString('\n')
            int_val, err := strconv.Atoi(strings.TrimSpace(text))
            if err != nil {
                fmt.Println(err)
                return io
            }
			var dst = get_dest_param(ip+1, p1_mode, data, mode_base)
			data[dst] = int_val
			ip += 2
		case 4:
			var val1 = get_param(ip+1, p1_mode, data, mode_base)
			switch output_mode {
			case 0:
				x = val1
			case 1:
				y = val1
			case 2:
				if x == -1  && y == 0 {
					fmt.Println("Score: ",val1)
				} else {
					io[Point{x,y}] = val1
				}
			}
			output_mode = (output_mode+1) % 3
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

	return io
}

func main() {
	input, err := ioutil.ReadFile("input-13")
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

	orig_int_data[0] = 2
	io := make(map[Point]int)

	io = run_program(orig_int_data, io)
	
	block_count := 0
	for _, val := range io {
		if val == 2  {
			block_count++
		}
	}
	fmt.Println(block_count)

}
