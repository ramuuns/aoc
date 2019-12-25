package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

var deck_size = 10 // 10007

func deal_with_increment(src, tgt []int, inc int) {
	for i, card := range src {
		tgt[(i*inc)%deck_size] = card
	}
}

func deal_into_new_stack(src, tgt []int) {
	for i, card := range src {
		tgt[deck_size-(1+i)] = card
	}
}

func cut(src, tgt []int, n int) {
	if n > 0 {
		for i, card := range src {
			if i < n {
				tgt[deck_size-n+i] = card
			} else {
				tgt[i-n] = card
			}
		}
	} else {
		for i, card := range src {
			if i-n < deck_size {
				tgt[i-n] = card
			} else {
				tgt[(i-n)%deck_size] = card
			}
		}
	}
}

func main() {
	input, err := ioutil.ReadFile("input-22")
	if err != nil {
		fmt.Println(err)
		return
	}
	input_as_str := string(input)
	string_data := strings.Split(strings.TrimSpace(input_as_str), "\n")
	deck := make([]int, deck_size)
	deck2 := make([]int, deck_size)
	for i, _ := range deck {
		deck[i] = i
	}
	for j := 0; j < 2; j++ {
		for _, instruction := range string_data {
			instr_parts := strings.Split(instruction, " ")
			//        fmt.Println(instr_parts)
			if instr_parts[0] == "cut" {
				n, _ := strconv.Atoi(instr_parts[1])
				cut(deck, deck2, n)
			}
			if instr_parts[1] == "with" {
				n, _ := strconv.Atoi(instr_parts[3])
				deal_with_increment(deck, deck2, n)
			}
			if instr_parts[1] == "into" {
				deal_into_new_stack(deck, deck2)
			}
			copy(deck, deck2)
		}
		fmt.Println(j, deck)
	}

	/*
	   for i, card := range deck {
	       if card == 2019 {
	           fmt.Println(i)
	       }
	   }
	*/
}
