package main

import(
	"fmt"
)

func arr_to_n (arr[]int ) int {
	n := 0
	for i:= 0; i < len(arr); i++ {
		n *= 10
		n += arr[i]
	}
	return n
}

/*
func has_doubles(arr[]int) bool {
	for i := 1; i<len(arr); i++ {
		if arr[i-1] == arr[i] {
			return true
		}
	}
	return false
}
*/

func has_doubles(arr[]int) bool {
	for i := 1; i<len(arr); i++ {
		if i < len(arr) - 1 && i > 1 {
			if arr[i-1] == arr[i] && arr[i-2] != arr[i] && arr[i+1] != arr[i] {
				return true
			}
		} else if i == 1 {
			if arr[i-1] == arr[i] && arr[i+1] != arr[i] {
				return true
			}
		} else if i == len(arr) - 1 {
			if arr[i-1] == arr[i] && arr[i-2] != arr[i] {
				return true
			}
		}
	}
	return false
}

func main() {
	var start = 153517
	//var end = 630395
	var num [6]int
	var num_passwords = 0
	var divisor = 100000
	var modulo = 1000000
	var used_max = false
	for i := 0; i<6; i++ {
		num[i] = ( start % modulo ) / divisor
		if ( i > 0 && num[i-1] > num[i] || used_max ) {
			used_max = true
			num[i] = num[i-1]
		} 
		divisor = divisor / 10
		modulo = modulo / 10
	}

	var seen = make(map[int]bool)

	for i := num[0]; i < 6; i++ {
		num[0] = i
		for j := i; j < 10; j++ {
			num[1] = j
			for k := j; k < 10; k++ {
				num[2] = k
				for l := k; l < 10; l++ {
					num[3] = l
					for m:= l; m < 10; m++ {
						num[4] = m
						for n := m ; n < 10; n++ {
							num[5] = n
							if ( has_doubles(num[:]) ) {
								cnum := arr_to_n(num[:])
								if cnum > start {
									if _, ok:= seen[cnum]; !ok {
										seen[cnum] = true
										fmt.Println(arr_to_n(num[:]))
										num_passwords++
									}
								}
							}
						}
					}
				}
			}
		}
	}

	fmt.Println(arr_to_n(num[:]))
	fmt.Println(num_passwords)
}
