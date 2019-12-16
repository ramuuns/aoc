package main

import (
	"fmt"
	//    "gopkg.in/karalabe/cookiejar.v1/collections/deque"
	"io/ioutil"
	"strconv"
	"strings"
)

func abs(n int) int {
	if n < 0 {
		return -n
	}
	return n
}

func main() {
	input, err := ioutil.ReadFile("input-16")
	if err != nil {
		fmt.Println(err)
		return
	}
	input_as_str := string(input)
	signal_as_chars := strings.Split(strings.TrimSpace(input_as_str), "")
	signal := make([]int, len(signal_as_chars))
	for i, cv := range signal_as_chars {
		signal[i], _ = strconv.Atoi(cv)
	}

	var pattern = [4]int{0, 1, 0, -1}

	for k := 0; k < 100; k++ {
		new_signal := make([]int, len(signal))
		for i, _ := range signal {
			var it = 0
			for c := i; c < len(signal); c++ {
				//	fmt.Print(" + ", pattern[( (c+1)/(i+1) )%4] ," * ", signal[c])
				it += pattern[((c+1)/(i+1)+4)%4] * signal[c]
			}
			//fmt.Println(" = ", abs(it%10));
			new_signal[i] = abs(it % 10)
		}
		//fmt.Println(new_signal)
		signal = new_signal
	}

	for c := 0; c < 8; c++ {
		fmt.Print(signal[c])
	}
	fmt.Println()
}
