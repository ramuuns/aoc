package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

type Point struct {
	x int
	y int
}

func main() {
	input, err := ioutil.ReadFile("input-10")
	if err != nil {
		fmt.Println(err)
		return
	}
	input_as_str := string(input)
	lines := strings.Split(input_as_str, "\n")
	asteroids := make([]Point, 0)
	asteroid_map := make(map[Point]int)
	for y, line := range lines {
		l_points := strings.Split(line, "")
		for x, c := range l_points {
			if c == "#" {
				p := Point{x, y}
				asteroids = append(asteroids, p)
				asteroid_map[p] = 1
			}
		}
	}

	visible := make(map[Point]int)

	for i, p1 := range asteroids {
		for j := i + 1; j < len(asteroids); j++ {
			p2 := asteroids[j]
			if is_visible(p1, p2, asteroid_map) {
				visible[p1]++
				visible[p2]++
			}
		}
	}

	max_vis := 0
	for _, p := range asteroids {
		v, ok := visible[p]
		if ok && v > max_vis {
			max_vis = v
		}
	}

	fmt.Println(max_vis)
}

func Abs(n int) int {
	if n < 0 {
		return -n
	}
	return n
}

func Gcd(x, y int) int {
	if y == 0 {
		return x
	}
	return Gcd(y, x%y)
}

func is_visible(p1, p2 Point, astro_map map[Point]int) bool {
	minx := p1.x
	maxx := p1.x
	miny := p1.y
	maxy := p1.y
	if p2.x < minx {
		minx = p2.x
	}
	if p2.x > maxx {
		maxx = p2.x
	}
	if p2.y < miny {
		miny = p2.y
	}
	if p2.y > maxy {
		maxy = p2.y
	}
	ydelta := p2.y - p1.y
	xdelta := p2.x - p1.x
	abs_ydelta := Abs(ydelta)
	abs_xdelta := Abs(xdelta)
	if xdelta != 0 {
		if ydelta == 0 {
			for x := minx + 1; x < maxx; x++ {
				if _, ok := astro_map[Point{x, miny}]; ok {
					return false
				}
			}
		} else {
			if abs_xdelta == 1 || abs_ydelta == 1 {
				return true
			}
			if abs_xdelta < abs_ydelta {
				gcd := Gcd(abs_ydelta, abs_xdelta)
				if gcd != 1 {
					yd := ydelta / gcd
					xd := xdelta / gcd
					n := 0
					for x := p1.x + xd; x != p2.x; x += xd {
						n++
						y := p1.y + n*yd
						if _, ok := astro_map[Point{x, y}]; ok {
							return false
						}
					}
				}
			} else {
				gcd := Gcd(abs_xdelta, abs_ydelta)
				if gcd != 1 {
					yd := ydelta / gcd
					xd := xdelta / gcd
					n := 0
					for y := p1.y + yd; y != p2.y; y += yd {
						n++
						x := p1.x + n*xd
						if _, ok := astro_map[Point{x, y}]; ok {
							return false
						}
					}
				}
			}
		}
	} else {
		for y := miny + 1; y < maxy; y++ {
			if _, ok := astro_map[Point{minx, y}]; ok {
				return false
			}
		}
	}
	return true
}
