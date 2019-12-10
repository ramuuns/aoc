package main

import(
	"flag"
	"fmt"
	"io/ioutil"
    "strings"
    "strconv"
)

func format_arg(mode int, arg int) string {
	mode_str := "a"
	if (mode == 1) {
		mode_str = "v"
	} else if mode == 2 {
		mode_str = "r"
	}
	return fmt.Sprintf("%s%d",mode_str, arg)
}

func main() {
	flag.Parse()
	args := flag.Args()

	if len(args) != 1 {
		fmt.Println("no args present")
		return
	}

	filename := args[0]
	input, err := ioutil.ReadFile(filename)
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

	data := orig_int_data

	for ip:=0; ip < len(data);  {
		var opcode  = data[ip] % 100
        var p1_mode = data[ip] % 1000 / 100
        var p2_mode = data[ip] % 10000 / 1000
		var p3_mode = data[ip] % 100000 / 10000

		fmt.Printf( "%4d:", ip )

		switch opcode {
			case 1:
				fmt.Printf("( %8s + %8s -> %8s)\n", format_arg(p1_mode, data[ip+1]), format_arg(p2_mode, data[ip+2]), format_arg(p3_mode, data[ip+3]))
				ip += 4
			case 2:
				fmt.Printf("( %8s * %8s -> %8s)\n", format_arg(p1_mode, data[ip+1]), format_arg(p2_mode, data[ip+2]), format_arg(p3_mode, data[ip+3]))
				ip += 4
			case 3:
				fmt.Printf(" read -> a%d\n", data[ip+1])
				ip += 2
			case 4:
				fmt.Printf(" write <- %8s\n", format_arg(p1_mode, data[ip+1]) )
				ip += 2
			case 5:
				fmt.Printf(" if %8s != 0 -> goto %8s\n", format_arg(p1_mode, data[ip+1]), format_arg(p2_mode, data[ip+2]) )
				ip += 3
			case 6:
				fmt.Printf(" if %8s == 0 -> goto %8s\n", format_arg(p1_mode, data[ip+1]), format_arg(p2_mode, data[ip+2]) )
                ip += 3
			case 7:
				fmt.Printf(" if %8s < %8s -> %8s := 1 (else 0)\n", format_arg(p1_mode, data[ip+1]), format_arg(p2_mode, data[ip+2]), format_arg(p3_mode, data[ip+3]))
				ip += 4
			case 8:
                fmt.Printf(" if %8s == %8s -> %8s := 1 (else 0)\n", format_arg(p1_mode, data[ip+1]), format_arg(p2_mode, data[ip+2]), format_arg(p3_mode, data[ip+3]))
                ip += 4
			case 9:
				fmt.Printf("adjust relative base by %8s\n", format_arg(p1_mode, data[ip+1]))
				ip += 2
			case 99:
				fmt.Print("exit\n");
				ip += 1
			default :
				fmt.Printf(" %d \n", data[ip])
				ip++
		}
	}
}
