package main

import (
	"fmt"
	"io/ioutil"
	"strings"
	"strconv"
)

type Layer struct {
	digits [10]int
}

func main() {
	input, err := ioutil.ReadFile("input-08")
    if err != nil {
        fmt.Println(err)
        return
    }
    input_as_str := string(input)
    string_data := strings.Split(input_as_str,"")
	w := 25
	h := 6
	layers := make([]Layer,len(string_data)/(w*h))
	min_zeroes := 999999999
	layer_min_zeroes := 0
	for i, pixel_s := range(string_data) {
		if strings.TrimSpace(pixel_s) == "" {
			continue
		}
		layer_idx := i/(w*h)
		pixel, _ := strconv.Atoi(pixel_s)
		layers[layer_idx].digits[pixel]++
	}

	for i:=0; i < len(layers); i++ {
		if layers[i].digits[0] < min_zeroes {
			min_zeroes = layers[i].digits[0]
			layer_min_zeroes = i
		}
	}

	fmt.Println(layer_min_zeroes, layers[layer_min_zeroes].digits[1] * layers[layer_min_zeroes].digits[2])
}
