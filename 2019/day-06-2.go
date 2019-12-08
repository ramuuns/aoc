package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

func main() {
	input, err := ioutil.ReadFile("input-06")
    if err != nil {
        fmt.Println(err)
        return
    }
	orbits := strings.Split(string(input), "\n")
	reverse_map := make(map[string]string)
	for _, orbit := range(orbits) {
		if orbit == "" {
			continue
		}
		objects := strings.Split(orbit, ")")
		reverse_map[objects[1]] = objects[0]
	}

	my_jumps := make(map[string]int)
	k := "YOU";
	dist := 0
	for {
		my_jumps[k] = dist
		newk, ok := reverse_map[k]
		k = newk
		dist++
		if !ok {
			break
		}
	}

	dist = 0
	k = "SAN"
	for {
		k, _ = reverse_map[k]
		dist++
		my_dist, ok := my_jumps[k]
		if ok {
			dist+= my_dist
			break
		}
	}
	fmt.Println(dist-2)
}
