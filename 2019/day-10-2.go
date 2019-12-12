package main

import (
	"fmt"
	"io/ioutil"
	"sort"
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
	visible_map := make(map[Point][]Point)

	for i, p1 := range asteroids {
		for j := i + 1; j < len(asteroids); j++ {
			p2 := asteroids[j]
			if is_visible(p1, p2, asteroid_map) {
				visible[p1]++
				visible[p2]++
				visible_map[p1] = append(visible_map[p1], p2)
				visible_map[p2] = append(visible_map[p2], p1)
			}
		}
	}

	max_vis := 0
	var max_vispoint Point
	for _, p := range asteroids {
		v, ok := visible[p]
		if ok && v > max_vis {
			max_vis = v
			max_vispoint = p
		}
	}

	var last_point Point
	var vaporized = 0
	for {
		sort.SliceStable(visible_map[max_vispoint], func(i, j int) bool {
			p1 := visible_map[max_vispoint][i]
			p2 := visible_map[max_vispoint][j]
			var xd1 int
			if p1.x-max_vispoint.x != 0 {
				xd1 = (p1.x - max_vispoint.x) / Abs(p1.x-max_vispoint.x)
			}
			var xd2 int
			if (p2.x - max_vispoint.x) != 0 {
				xd2 = (p2.x - max_vispoint.x) / Abs(p2.x-max_vispoint.x)
			}
			if xd1 != xd2 {
				if xd1 == 0 || xd2 == 0 {
					if xd1 == -1 {
						return false
					}
					if xd2 == -1 {
						return true
					}
					if xd1 == 0 && p1.y < max_vispoint.y {
						return true
					} else if xd1 == 0 && xd2 == 1 {
						return false
					}
					if xd2 == 0 && p2.y < max_vispoint.y {
						return false
					} else if xd2 == 0 && xd2 == 1 {
						return true
					}
				} else {
					return xd1 > xd2
				}
			} else {
				if xd1 == 0 {
					return p1.y < p2.y
				}
				tg1 := float32(p1.y-max_vispoint.y) / float32(p1.x-max_vispoint.x)
				tg2 := float32(p2.y-max_vispoint.y) / float32(p2.x-max_vispoint.x)
				return tg1 < tg2
			}
			return true
		})
		if len(visible_map[max_vispoint])+vaporized >= 200 {
			last_point = visible_map[max_vispoint][199-vaporized]
			break
		}
		for _, p := range visible_map[max_vispoint] {
			delete(asteroid_map, p)
			vaporized++
		}

		visible_map[max_vispoint] = nil
		for p, _ := range asteroid_map {
			if p == max_vispoint {
				continue
			}
			if is_visible(max_vispoint, p, asteroid_map) {
				visible_map[max_vispoint] = append(visible_map[max_vispoint], p)
			}
		}
	}
	fmt.Println(last_point.x*100 + last_point.y)

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
