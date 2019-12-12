package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

func main() {
	input, err := ioutil.ReadFile("input-02")
	if err != nil {
		fmt.Println(err)
		return
	}
	input_as_str := string(input)
	string_data := strings.Split(input_as_str, ",")
	var int_data = make([]int, len(string_data))
	for i, s := range string_data {
		s = strings.TrimSpace(s)
		int_val, err := strconv.Atoi(s)
		if err != nil {
			fmt.Println(err)
			return
		}
		int_data[i] = int_val
	}

	int_data[1] = 12
	int_data[2] = 2

	for i := 0; int_data[i] != 99; i += 4 {
		var opcode = int_data[i]
		var val1 = int_data[int_data[i+1]]
		var val2 = int_data[int_data[i+2]]
		var dst = int_data[i+3]
		switch opcode {
		case 1:
			int_data[dst] = val1 + val2
		case 2:
			int_data[dst] = val1 * val2
		}
	}
	fmt.Println(int_data[0])
}
