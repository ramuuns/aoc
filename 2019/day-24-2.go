package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

func next_state(states map[int]uint32) map[int]uint32 {
	next_states := make(map[int]uint32)

	min := 0
	max := 0
	for k, _ := range states {
		if k < min {
			min = k
		}
		if k > max {
			max = k
		}
	}
	for l := min - 1; l <= max+1; l++ {

		outer := states[l-1]
		inner := states[l+1]
		state := states[l]

		var next_state uint32 = 0

		for i := uint32(0); i < 25; i++ {
			if i == 12 {
				continue
			}
			k := uint32(1 << i)

			adjacent := 0
			if ((k >> 5) & state) != 0 {
				adjacent++
			}
			if ((k << 5) & state) != 0 {
				adjacent++
			}
			if i%5 != 0 && (k>>1)&state != 0 {
				adjacent++
			}
			if i%5 != 4 && (k<<1)&state != 0 {
				adjacent++
			}
			if i < 5 && outer&(1<<7) != 0 {
				adjacent++
			}
			if i >= 20 && outer&(1<<17) != 0 {
				adjacent++
			}
			if i%5 == 0 && outer&(1<<11) != 0 {
				adjacent++
			}
			if i%5 == 4 && outer&(1<<13) != 0 {
				adjacent++
			}

			if i == 7 {
				for m := 0; m < 5; m++ {
					if inner&(1<<m) != 0 {
						adjacent++
					}
				}
			}
			if i == 17 {
				for m := 20; m < 25; m++ {
					if inner&(1<<m) != 0 {
						adjacent++
					}
				}
			}
			if i == 11 {
				for m := 0; m < 25; m += 5 {
					if inner&(1<<m) != 0 {
						adjacent++
					}
				}
			}
			if i == 13 {
				for m := 4; m < 25; m += 5 {
					if inner&(1<<m) != 0 {
						adjacent++
					}
				}
			}

			if k&state == 0 {
				//                fmt.Println("level", l, "point", i, " is empty, adjacent", adjacent)
				if adjacent == 1 || adjacent == 2 {
					next_state |= k
				}
			} else {
				//has bug
				//                fmt.Println("level", l, "point", i, " not empty, adjacent", adjacent)
				if adjacent == 1 {
					next_state |= k
				}
			}
		}

		if next_state != 0 {
			next_states[l] = next_state
		}

	}

	return next_states
}

func count_bugs(states map[int]uint32) int {
	total := 0
	for _, state := range states {
		for i := uint32(0); i < 25; i++ {
			if i == 12 {
				continue
			}
			if state&(1<<i) != 0 {
				total++
			}
		}
	}
	return total
}

func print_state(states map[int]uint32) {
	fmt.Println("---")
	min := 0
	max := 0
	for k, _ := range states {
		if k < min {
			min = k
		}
		if k > max {
			max = k
		}
	}
	for l := min; l <= max; l++ {
		state := states[l]
		fmt.Println("level", l)
		for i := uint32(0); i < 25; i++ {
			if i == 12 {
				fmt.Print("?")
				continue
			}
			k := uint32(1 << i)
			if state&k == 0 {
				fmt.Print(".")
			} else {
				fmt.Print("#")
			}
			if i%5 == 4 {
				fmt.Println()
			}
		}
	}
	fmt.Println("---")
}

func main() {
	input, err := ioutil.ReadFile("input-24")
	if err != nil {
		fmt.Println(err)
		return
	}
	input_as_str := string(input)
	string_data := strings.Split(strings.TrimSpace(input_as_str), "\n")

	var state uint32 = 0
	//    var newstate uint32 = 0
	for y, line := range string_data {
		dots := []rune(line)
		for x, dot := range dots {
			if dot == '#' {
				shift := 5*y + x
				state |= (1 << shift)
			}
		}
	}

	recursive_states := make(map[int]uint32)
	recursive_states[0] = state
	for i := 0; i < 200; i++ {
		recursive_states = next_state(recursive_states)
		//print_state(recursive_states)
	}
	print_state(recursive_states)
	fmt.Println(count_bugs(recursive_states))
}
