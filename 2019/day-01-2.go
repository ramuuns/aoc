package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

func main() {
	input, err := ioutil.ReadFile("input-01")
	if err != nil {
		fmt.Println(err)
		return
	}
	input_as_str := string(input)
	data := strings.Split(input_as_str, "\n")
	var sum = 0
	for _, val := range data {
		mweight, err := strconv.Atoi(val)
		if err != nil {
			//meh
		} else {
			var mweight_fuel = mweight/3 - 2
			var tmp = mweight_fuel
			var tmp_sum = 0
			for tmp > 0 {
				tmp_sum += tmp
				tmp = tmp/3 - 2
			}
			sum += tmp_sum
		}
	}
	fmt.Println(sum)
}
