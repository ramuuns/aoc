package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

func count_children(orbits map[string][]string, key string, d int) int {
	var cnt = 0
	for _, child := range(orbits[key]) {
		cnt+=d
		if _, ok := orbits[child]; ok {
			cnt += count_children(orbits, child, d+1)
		}
	}
	return cnt
}

func main() {
	input, err := ioutil.ReadFile("input-06")
    if err != nil {
        fmt.Println(err)
        return
    }
	orbits := strings.Split(string(input), "\n")
	orbits_map := make(map[string][]string)
	for _, orbit := range(orbits) {
		if orbit == "" {
			continue
		}
		objects := strings.Split(orbit, ")")
		arr, _ := orbits_map[objects[0]]
		arr = append(arr, objects[1])
		orbits_map[objects[0]] = arr
	}

	orbit_count := count_children(orbits_map, "COM", 1)
	fmt.Println(orbit_count)
}
