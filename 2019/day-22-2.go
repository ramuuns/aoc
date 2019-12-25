package main

import (
	"fmt"
	"io/ioutil"
	"math/big"
	"strconv"
	"strings"
)

var deck_size = 119315717514047

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

func get_prev_index_of_cut(index, n int) int {
	if n > 0 {
		return (1*index + n) % deck_size
	} else {
		return (index + n + deck_size) % deck_size
	}
}

func get_prev_index_of_deal_into_new_stack(index int) int {
	return deck_size - 1 - index
}

func get_prev_index_of_deal_with_increment(index, inc int) int {
	if index == 0 {
		return 0
	}
	for i := 0; i < inc; i++ {
		index = (index * inc) % deck_size
	}
	return index
}

func get_seq_func(increment, offset *big.Int) func(*big.Int) (*big.Int, *big.Int) {
	ds := big.NewInt(int64(deck_size))
	return func(it *big.Int) (*big.Int, *big.Int) {
		// calculate (increment, offset) for the number of iterations of the process
		// increment = increment_mul^iterations
		inc := big.NewInt(0)
		inc.Exp(increment, it, ds)
		// offset = 0 + offset_diff * (1 + increment_mul + increment_mul^2 + ... + increment_mul^iterations)
		// use geometric series.
		off := big.NewInt(0)
		im := big.NewInt(0)
		im.Add(big.NewInt(-1), inc)
		off.Mul(offset, im)
		im.Add(big.NewInt(-1), increment)
		im.Mod(im, ds)

		ds_minus_two := big.NewInt(0)
		ds_minus_two.Add(big.NewInt(-2), ds)
		exp := big.NewInt(0)
		exp.Exp(im, ds_minus_two, ds)
		off.Mul(off, exp)
		off.Mod(off, ds)
		return inc, off
	}
}

func get(offset, increment, i *big.Int) *big.Int {
	//# gets the ith number in a given sequence
	ds := big.NewInt(int64(deck_size))
	ret := big.NewInt(0)
	ret.Add(offset, i.Mul(i, increment))
	ret.Mod(ret, ds)
	return ret
}

func main() {
	input, err := ioutil.ReadFile("input-22")
	if err != nil {
		fmt.Println(err)
		return
	}
	input_as_str := string(input)
	string_data := strings.Split(strings.TrimSpace(input_as_str), "\n")
	//    deck := make([]int, deck_size)
	//    deck2 := make([]int, deck_size)
	//    history := make(map[int]int)
	//    step_to_val := make(map[int]int)
	//    for i,_ := range deck {
	//        deck[i] = i
	//    }
	//    steps := 0

	instrs := make([][2]int, len(string_data))
	offset := big.NewInt(0)
	increment := big.NewInt(1)
	ds := big.NewInt(int64(deck_size))

	for i, instruction := range string_data {
		instr_parts := strings.Split(instruction, " ")
		if instr_parts[0] == "cut" {
			n, _ := strconv.Atoi(instr_parts[1])
			instrs[i] = [2]int{0, n}
			ni := big.NewInt(int64(n))
			ni.Mul(ni, increment)
			offset.Add(offset, ni)
			offset.Mod(offset, ds)
			fmt.Println(offset)
		}
		if instr_parts[1] == "with" {
			n, _ := strconv.Atoi(instr_parts[3])
			instrs[i] = [2]int{1, n}

			//increment_mul *= inv(q)
			//increment_mul %= cards
			ni := big.NewInt(int64(n))

			ds_minus_two := big.NewInt(0)
			ds_minus_two.Add(big.NewInt(-2), ds)

			increment.Mul(increment, ni.Exp(ni, ds_minus_two, ds))
			increment.Mod(increment, ds)
		}
		if instr_parts[1] == "into" {
			instrs[i] = [2]int{2, 0}

			increment.Mul(increment, big.NewInt(-1))
			increment.Mod(increment, ds)

			offset.Add(offset, increment)
			offset.Mod(offset, ds)

		}
	}

	A := big.NewInt(1)
	B := big.NewInt(0)

	for i := 0; i < len(instrs); i++ {
		ins := instrs[i]
		if ins[0] == 0 {
			B.Add(B, big.NewInt(int64(ins[1])))
			//index = get_prev_index_of_cut(index, ins[1])
		} else if ins[0] == 1 {
			//p = pow(inc, ld-2,ld)
			ds_minus_two := big.NewInt(0)
			ds_minus_two.Add(big.NewInt(-2), ds)
			P := big.NewInt(0)
			P.Exp(big.NewInt(int64(ins[1])), ds_minus_two, ds)
			A.Mul(A, P)
			B.Mul(A, P)
			//index = get_prev_index_of_deal_with_increment(index, ins[1])
		} else {
			B.Add(B, big.NewInt(1))
			B.Mul(B, big.NewInt(-1))
			A.Mul(A, big.NewInt(-1))
			//index = get_prev_index_of_deal_into_new_stack(index)
		}
		A.Mod(A, ds)
		B.Mod(B, ds)
	}

	fmt.Println(increment, offset)
	fmt.Println(A, B)

	gs_func := get_seq_func(increment, offset)

	times := big.NewInt(101741582076661)
	card := big.NewInt(2020)

	incr, offs := gs_func(times)

	fmt.Println(incr, offs)

	fmt.Println(get(offs, incr, card))

	first := big.NewInt(0)
	first.Exp(A, times, ds)
	first.Mul(first, card)

	second := big.NewInt(0)
	second.Exp(A, times, ds)
	second.Add(second, ds)
	second.Add(second, big.NewInt(-1))
	second.Mul(second, B)

	a_minus_one := big.NewInt(0)
	a_minus_one.Add(A, big.NewInt(-1))

	ds_minus_two := big.NewInt(0)
	ds_minus_two.Add(ds, big.NewInt(-2))

	third := big.NewInt(0)
	third.Exp(a_minus_one, ds_minus_two, ds)

	first.Mul(first, second)
	first.Mul(first, third)
	first.Mod(first, ds)

	fmt.Println(first)

	/*

	   print((
	       pow(a, times, ld) * card +
	       b * (pow(a, times, ld) +ld- 1)
	         * (pow(a-1, ld - 2, ld))
	   ) % ld)

	*/

	/*
	       index := 2020

	       history := make(map[int]int)
	       step_to_val := make(map[int]int)
	       history[2020] = 0
	       step_to_val[0] = 2020
	       step := 0

	       a:=2020
	       b:=0

	       for j:=0; j<10; j++{

	       for i := len(instrs) - 1; i>= 0; i-- {
	   //    for i:= 0; i<len(instrs); i++{
	           ins := instrs[i]
	           if ins[0] == 0 {
	               index = get_prev_index_of_cut(index, ins[1])
	           } else if ins[0] == 1 {
	               index = get_prev_index_of_deal_with_increment(index, ins[1])
	           } else {
	               index = get_prev_index_of_deal_into_new_stack(index)
	           }
	       }

	       step++;
	       if step == 101741582076661 {
	           fmt.Println("no loops", index)
	           break
	       }
	       if psteps, ok := history[index]; ok {
	           fmt.Println(step - psteps, psteps, index, step_to_val[ 101741582076661  % (step - psteps) ])
	           break

	       }
	       history[index] = step
	       step_to_val[step] = index

	       if b == 0 {
	           b = index - step_to_val[step-1]
	       }

	       fmt.Println(step, step_to_val[step-1] , index , uint64(a+b*step) % uint64(deck_size) )// ((step_to_val[step-1] - index ) + deck_size) % deck_size)

	       if step % 100000 == 0 {
	           fmt.Println(step, index)
	       }

	       }
	   /*
	       for {
	           if psteps, ok := history[deck[2020]]; ok {
	               fmt.Println(steps - psteps, psteps, deck[2020], step_to_val[ 101741582076661 % (steps - psteps) ])
	               break
	           }
	           history[deck[2020]] = steps
	           step_to_val[steps] = deck[2020]
	           steps++
	           for _, ins := range instrs {
	               if ins[0] == 0 {
	                   cut(deck,deck2, ins[1])
	               } else if ins[0] == 1 {
	                   deal_with_increment(deck, deck2, ins[1])
	               } else {
	                   deal_into_new_stack(deck, deck2)
	               }
	               copy(deck, deck2)
	           }

	       }*/
	/*
	   for i, card := range deck {
	       if card == 2019 {
	           fmt.Println(i)
	       }
	   }
	*/
}
