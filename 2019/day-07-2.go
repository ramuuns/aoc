package main

import(
    "fmt"
    "io/ioutil"
    "strings"
    "strconv"
)

func get_param(idx, mode int, data[]int) int {
    if mode == 1 {
        return data[idx]
    } else {
        return data[data[idx]]
    }
}


func run_program(in_data *[]int, stdin[]string, ip int) (string, int, int) {
	stdin_ptr := 0
	stdout := ""
	data := *in_data
	for data[ip] != 99 {
		var opcode  = data[ip] % 100
        var p1_mode = data[ip] % 1000 / 100
        var p2_mode = data[ip] % 10000 / 1000
		switch opcode {
        case 1:
            var val1 = get_param(ip+1, p1_mode, data)
            var val2 = get_param(ip+2, p2_mode, data)
            var dst = data[ip+3]
            data[dst] = val1+val2
            ip+=4
        case 2:
            var val1 = get_param(ip+1, p1_mode, data)
            var val2 = get_param(ip+2, p2_mode, data)
            var dst = data[ip+3]
            data[dst] = val1*val2
            ip+=4
        case 3:
            text := stdin[stdin_ptr]
			stdin_ptr++
            int_val, err := strconv.Atoi(strings.TrimSpace(text))
            if err != nil {
                fmt.Println(err)
                return "-1", 0, 99
            }
            var dst = data[ip+1]
            data[dst] = int_val
            ip+=2
        case 4:
            var val1 = get_param(ip+1, p1_mode, data)
			stdout += strconv.Itoa(val1)
            ip+=2
			return stdout, ip, 0
        case 5:
            var val1 = get_param(ip+1, p1_mode, data)
            if ( val1 != 0 ) {
                ip = get_param(ip+2,p2_mode,data)
            } else {
                ip+=3
            }
        case 6:
            var val1 = get_param(ip+1, p1_mode, data)
            if ( val1 == 0 ) {
                ip = get_param(ip+2,p2_mode,data)
            } else {
                ip+=3
            }
		case 7:
            var val1 = get_param(ip+1, p1_mode, data)
            var val2 = get_param(ip+2, p2_mode, data)
            var dst = data[ip+3]
            if val1 < val2 {
                data[dst] = 1
            } else {
                data[dst] = 0
            }
            ip += 4
        case 8:
            var val1 = get_param(ip+1, p1_mode, data)
            var val2 = get_param(ip+2, p2_mode, data)
            var dst = data[ip+3]
            if val1 == val2 {
                data[dst] = 1
            } else {
                data[dst] = 0
            }
            ip += 4
		}
	}
	return stdout, ip, 99
}

func call_run(data *[]int, input_0 int, input_1 int) (int, int, int) {
	input_params := make([]string, 2)
	input_params[0] = strconv.Itoa(input_0)
	input_params[1] = strconv.Itoa(input_1)
	p_ret, ip, status := run_program(data,input_params, 0)
	ret, _ := strconv.Atoi( p_ret )
	return ret, ip, status
}

func call_continue_run(data *[]int, input int, ip int) (int, int, int) {
	input_params := make([]string, 1)
	input_params[0] = strconv.Itoa(input)
	var p_ret string
	var status int
	p_ret, ip, status = run_program(data, input_params, ip)
	ret, _ := strconv.Atoi( p_ret )
	return ret, ip, status
}

func main() {
    input, err := ioutil.ReadFile("input-07")
    if err != nil {
        fmt.Println(err)
        return
    }
    input_as_str := string(input)
    string_data := strings.Split(input_as_str,",")
    var orig_int_data = make([]int, len(string_data))
    for i, s := range(string_data) {
        s = strings.TrimSpace(s)
        int_val, err := strconv.Atoi(s)
        if err != nil {
            fmt.Println(err)
            return
        }
        orig_int_data[i] = int_val
    }

	max := 0

	for i:= 5; i < 10; i++ {
		for j:= 5; j < 10; j++ {
			if j == i {
				continue;
			}
			for k:= 5; k < 10; k++ {
				if k == i || k == j {
					continue;
				}
				for l := 5; l < 10; l++ {
					if l == i || l == j || l == k {
						continue;
					}
					for m := 5; m < 10; m++ {
						if m == i || m == j || m == k || m == l {
							continue
						}
						input := 0
						data1 := make([]int, len(orig_int_data))
						copy(data1, orig_int_data)
						data2 := make([]int, len(orig_int_data))
						copy(data2, orig_int_data)
						data3 := make([]int, len(orig_int_data))
						copy(data3, orig_int_data)
						data4 := make([]int, len(orig_int_data))
						copy(data4, orig_int_data)
						data5 := make([]int, len(orig_int_data))
						copy(data5, orig_int_data)
						ip1 := 0
						ip2 := 0
						ip3 := 0
						ip4 := 0
						ip5 := 0
						status := 0

						input, ip1, status = call_run(&data1, i, input)
						
						input, ip2, status = call_run(&data2, j, input)
						input, ip3, status = call_run(&data3, k, input)
						input, ip4, status = call_run(&data4, l, input)
						input, ip5, status = call_run(&data5, m, input)
						for {
							p_input := input
							input, ip1, status = call_continue_run(&data1, input, ip1)
							if status == 99 {
								input = p_input
								break
							}
                        	input, ip2, status = call_continue_run(&data2, input, ip2)
                        	input, ip3, status = call_continue_run(&data3, input, ip3)
                        	input, ip4, status = call_continue_run(&data4, input, ip4)
                        	input, ip5, status = call_continue_run(&data5, input, ip5)
							if (status == 99) {
								break
							}
						}
						if input > max {
					//		fmt.Println(i,j,k,l,m)
							max = input
						}
					}
				}
			}
		}
	}

	fmt.Println(max)
}

