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

	for k := 0; k < 100; k++ {
		for i := len(signal) - 2; i >= 0; i-- {
			signal[i] = (signal[i+1] + signal[i]) % 10
		}
	}

	for c := 0; c < 8; c++ {
		fmt.Print(signal[c])
	}
	fmt.Println()
}
