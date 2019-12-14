package main

import (
	"fmt"
	"gopkg.in/karalabe/cookiejar.v1/collections/deque"
	"io/ioutil"
	"strconv"
	"strings"
)

type Chem struct {
	min_prod int
	reqs     map[string]int
}

type Req struct {
	name   string
	amount int
}

func main() {
	input, err := ioutil.ReadFile("input-14")
	if err != nil {
		fmt.Println(err)
		return
	}
	input_as_str := string(input)
	lines := strings.Split(strings.TrimSpace(input_as_str), "\n")
	produced_map := make(map[string]int)
	used_map := make(map[string]int)
	chem_map := make(map[string]Chem)
	for _, line := range lines {
		parts := strings.Split(line, " => ")
		chem_parts := strings.Split(parts[1], " ")
		min_amount, _ := strconv.Atoi(chem_parts[0])
		name := chem_parts[1]
		reqs := make(map[string]int)
		for _, req_item := range strings.Split(parts[0], ", ") {
			req_item_parts := strings.Split(req_item, " ")
			req_amount, _ := strconv.Atoi(req_item_parts[0])
			reqs[req_item_parts[1]] = req_amount
		}
		chem_map[name] = Chem{min_amount, reqs}
	}

	prod_queue := deque.New()
	for name, amount := range chem_map["FUEL"].reqs {
		prod_queue.PushLeft(Req{name, amount})
	}

	for !prod_queue.Empty() {
		popreq := prod_queue.PopRight()
		req := popreq.(Req)
		if req.name == "ORE" {
			produced_map[req.name] += req.amount
			used_map[req.name] += req.amount
			continue
		}
		produced, _ := produced_map[req.name]
		used, _ := used_map[req.name]
		//fmt.Println(req.name, req.amount, produced, used)
		if (produced - used) >= req.amount {
			used_map[req.name] += req.amount
		} else {
			chem := chem_map[req.name]
			want_to_produce := req.amount - (produced - used)
			will_produce := 0
			produce_multiplier := 1
			if want_to_produce < chem.min_prod {
				will_produce = chem.min_prod
			} else {
				if want_to_produce%chem.min_prod == 0 {
					produce_multiplier = want_to_produce / chem.min_prod
				} else {
					produce_multiplier = (want_to_produce / chem.min_prod) + 1
				}
			}
			//fmt.Println(want_to_produce,  chem.min_prod * produce_multiplier, chem.min_prod)
			will_produce = chem.min_prod * produce_multiplier
			produced_map[req.name] += will_produce
			used_map[req.name] += req.amount
			for name, amount := range chem.reqs {
				prod_queue.PushLeft(Req{name, amount * produce_multiplier})
			}
		}
	}

	fmt.Println(produced_map["ORE"])
}
