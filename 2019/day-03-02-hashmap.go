package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

type Point struct {
	x int
	y int
}

var Dirmap = map[string][2]int{
	"U": [2]int{1, 0},
	"D": [2]int{-1, 0},
	"L": [2]int{0, -1},
	"R": [2]int{0, 1},
}

func main() {
	input, err := ioutil.ReadFile("input-03")
	if err != nil {
		fmt.Println(err)
		return
	}
	input_as_str := string(input)
	lines := strings.Split(input_as_str, "\n")
	wire1 := strings.Split(lines[0], ",")
	wire2 := strings.Split(lines[1], ",")

	points1 := make(map[Point]int)

	var x int
	var y int
	var steps int

	for _, segment := range wire1 {
		runes := []rune(segment)
		dir := string(runes[0:1])
		len_as_str := string(runes[1:])
		len_as_int, err := strconv.Atoi(len_as_str)
		if err != nil {
			fmt.Println(err)
			return
		}
		dir_X := Dirmap[dir][1]
		dir_Y := Dirmap[dir][0]
		for i := 0; i < len_as_int; i++ {
			steps++
			x += dir_X
			y += dir_Y
			p := Point{x, y}
			_, ok := points1[p]
			if !ok {
				points1[p] = steps
			}
		}
	}

	x = 0
	y = 0
	steps = 0

	minsteps := 1000000000

	for _, segment := range wire2 {
		runes := []rune(segment)
		dir := string(runes[0:1])
		len_as_str := string(runes[1:])
		len_as_int, err := strconv.Atoi(len_as_str)
		if err != nil {
			fmt.Println(err)
			return
		}
		dir_X := Dirmap[dir][1]
		dir_Y := Dirmap[dir][0]
		for i := 0; i < len_as_int; i++ {
			steps++
			x += dir_X
			y += dir_Y
			p := Point{x, y}
			w1steps, ok := points1[p]
			if ok && steps+w1steps < minsteps {
				minsteps = steps + w1steps
			}
		}
	}

	fmt.Println(minsteps)

}
