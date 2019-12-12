package main

import (
	"fmt"
	"io/ioutil"
	"regexp"
	"strconv"
	"strings"
)

type Point struct {
	x int
	y int
	z int
}

type Moon struct {
	id  int
	pos Point
	vel Point
}

func Abs(n int) int {
	if n < 0 {
		return -n
	}
	return n
}

func (m *Moon) updateVel(moons []Moon) {
	for _, other := range moons {
		if m.id == other.id {
			continue
		}
		dx := other.pos.x - m.pos.x
		dy := other.pos.y - m.pos.y
		dz := other.pos.z - m.pos.z
		if dx != 0 {
			dx = dx / Abs(dx)
		}
		if dy != 0 {
			dy = dy / Abs(dy)
		}
		if dz != 0 {
			dz = dz / Abs(dz)
		}
		m.vel.x += dx
		m.vel.y += dy
		m.vel.z += dz
	}
}

func (m *Moon) updatePos() {
	m.pos.x += m.vel.x
	m.pos.y += m.vel.y
	m.pos.z += m.vel.z
}

func (m Moon) energy() int {
	potential := Abs(m.pos.x) + Abs(m.pos.y) + Abs(m.pos.z)
	kinetic := Abs(m.vel.x) + Abs(m.vel.y) + Abs(m.vel.z)
	return potential * kinetic
}

func Gcd(x, y int) int {
	if y == 0 {
		return x
	}
	return Gcd(y, x%y)
}

func Lcm3(x, y, z int) int {
	return Lcm(x, Lcm(y, z))
}

func Lcm(a, b int) int {
	return a * b / Gcd(a, b)
}

type PosVelKey struct {
	pos [4]int
	vel [4]int
}

func main() {
	input, err := ioutil.ReadFile("input-12")
	if err != nil {
		fmt.Println(err)
		return
	}
	input_as_str := string(input)
	lines := strings.Split(input_as_str, "\n")
	moons := make([]Moon, 4)
	input_cleanup := regexp.MustCompile("[^0-9,-]")
	for i, line := range lines {
		if i > 3 {
			continue
		}
		line = input_cleanup.ReplaceAllString(line, "")
		points_as_str := strings.Split(line, ",")
		moons[i].pos.x, _ = strconv.Atoi(points_as_str[0])
		moons[i].pos.y, _ = strconv.Atoi(points_as_str[1])
		moons[i].pos.z, _ = strconv.Atoi(points_as_str[2])
		moons[i].id = i
	}

	hasLoopX := false
	hasLoopY := false
	hasLoopZ := false
	seenX := make(map[PosVelKey]int)
	seenY := make(map[PosVelKey]int)
	seenZ := make(map[PosVelKey]int)
	loopX := 0
	loopY := 0
	loopZ := 0
	startLoopX := 0
	startLoopY := 0
	startLoopZ := 0

	for i := 0; i < 10000000; i++ {
		if hasLoopX && hasLoopY && hasLoopZ {
			break
		}
		for k, _ := range moons {
			moons[k].updateVel(moons)
		}
		for k, _ := range moons {
			moons[k].updatePos()
		}
		if !hasLoopX {
			k := PosVelKey{[4]int{moons[0].pos.x, moons[1].pos.x, moons[2].pos.x, moons[3].pos.x}, [4]int{moons[0].vel.x, moons[1].vel.x, moons[2].vel.x, moons[3].vel.x}}
			if xs, ok := seenX[k]; ok {
				hasLoopX = true
				startLoopX = xs
				loopX = i - xs
			} else {
				seenX[k] = i
			}
		}
		if !hasLoopY {
			k := PosVelKey{[4]int{moons[0].pos.y, moons[1].pos.y, moons[2].pos.y, moons[3].pos.y}, [4]int{moons[0].vel.y, moons[1].vel.y, moons[2].vel.y, moons[3].vel.y}}
			if xs, ok := seenY[k]; ok {
				hasLoopY = true
				startLoopY = xs
				loopY = i - xs
			} else {
				seenY[k] = i
			}
		}
		if !hasLoopZ {
			k := PosVelKey{[4]int{moons[0].pos.z, moons[1].pos.z, moons[2].pos.z, moons[3].pos.z}, [4]int{moons[0].vel.z, moons[1].vel.z, moons[2].vel.z, moons[3].vel.z}}
			if xs, ok := seenZ[k]; ok {
				hasLoopZ = true
				startLoopZ = xs
				loopZ = i - xs
			} else {
				seenZ[k] = i
			}
		}
	}

	fmt.Println(startLoopX, loopX)
	fmt.Println(startLoopY, loopY)
	fmt.Println(startLoopZ, loopZ)

	fmt.Println(Lcm3(loopX, loopY, loopZ))
}
