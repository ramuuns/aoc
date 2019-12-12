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
		intval, err := strconv.Atoi(val)
		if err != nil {
			//meh
		} else {
			sum += intval/3 - 2
		}
	}
	fmt.Println(sum)
}
