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
	period := 10000
	signal := make([]int, len(signal_as_chars)*period)
	for i, cv := range signal_as_chars {
		v, _ := strconv.Atoi(cv)
		for k := 0; k < period; k++ {
			signal[i+k*len(signal_as_chars)] = v
		}
	}

	var offset int
	for c := 0; c < 7; c++ {
		offset *= 10
		offset += signal[c]
	}
	fmt.Println(offset)
	signal = signal[offset:]
	fmt.Println(len(signal))

	//var pattern = [4]int{0, 1, 0, -1};

	for k := 0; k < 100; k++ {
		//		fmt.Println(k)
		new_signal := make([]int, len(signal))
		for i, _ := range signal {
			//fmt.Println(i)
			var it = 0
			if i == 0 {
				for c := i; c < len(signal); c++ {
					it += signal[c]
				}
				new_signal[i] = abs(it % 10)
			} else {
				new_signal[i] = (new_signal[i-1] + 10 - signal[i-1]) % 10
			}
		}
		//fmt.Println(new_signal);
		signal = new_signal
	}

	for c := 0; c < 8; c++ {
		fmt.Print(signal[c])
	}
	fmt.Println()
}
