package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

func next_state(state uint32) uint32 {
	var next_state uint32 = 0

	for i := uint32(0); i < 25; i++ {
		k := uint32(1 << i)
		if k&state == 0 {
			//empty
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
			if adjacent == 1 || adjacent == 2 {
				next_state |= k
			}
		} else {
			//has bug
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
			if adjacent == 1 {
				next_state |= k
			}
		}
	}

	return next_state
}

func print_state(state uint32) {
	fmt.Println("---")
	for i := uint32(0); i < 25; i++ {
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

	seen := make(map[uint32]bool)
	seen[state] = true
	for {
		//print_state(state)
		state = next_state(state)
		if seen[state] {
			break
		}
		seen[state] = true
	}
	fmt.Println(state)
}
