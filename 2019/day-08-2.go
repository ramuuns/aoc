package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

type Layer struct {
	pixels [6][25]int
}

func main() {
	input, err := ioutil.ReadFile("input-08")
	if err != nil {
		fmt.Println(err)
		return
	}
	input_as_str := string(input)
	string_data := strings.Split(input_as_str, "")
	w := 25
	h := 6
	layers := make([]Layer, len(string_data)/(w*h))
	for i, pixel_s := range string_data {
		if strings.TrimSpace(pixel_s) == "" {
			continue
		}
		layer_idx := i / (w * h)
		pixel_x := i % (w * h) % w
		pixel_y := i % (w * h) / w
		pixel, _ := strconv.Atoi(pixel_s)
		layers[layer_idx].pixels[pixel_y][pixel_x] = pixel
	}

	for y := 0; y < h; y++ {
		for x := 0; x < w; x++ {
			for l := 0; l < len(layers); l++ {
				if layers[l].pixels[y][x] == 2 {
					continue
				} else if layers[l].pixels[y][x] == 1 {
					fmt.Print("#")
					break
				} else {
					fmt.Print(" ")
					break
				}
			}
		}
		fmt.Println("")
	}

}
