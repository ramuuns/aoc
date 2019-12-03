package main
  
import(
    "fmt"
    "io/ioutil"
    "strings"
    "strconv"
	"sort"
)


type HLine struct {
	y int
	start int
	end int
	steps int
}

type VLine struct {
	x int
	start int
	end int
	steps int
}

func Abs(x int) int {
	if x < 0 {
		return -x
	}
	return x
}

func main() {
    input, err := ioutil.ReadFile("input-03")
    if err != nil {
        fmt.Println(err)
        return
    }
    input_as_str := string(input)
	lines := strings.Split(input_as_str, "\n")
	wire1 := strings.Split(lines[0],",")
	wire2 := strings.Split(lines[1],",")
	var x int
	var y int
	var steps int
	var hlines []HLine
	var vlines []VLine
	for _, segment := range(wire1) {
		runes := []rune(segment)
		dir := string(runes[0:1])
		len_as_str := string(runes[1:])
		len_as_int, err := strconv.Atoi(len_as_str)
		if err != nil {
			fmt.Println(err)
			return
		}
		switch dir {
		case "U":
			line := VLine{x: x, start: y, end: y+len_as_int, steps: steps}
			vlines = append(vlines, line)
			y+=len_as_int
		case "D":
			line := VLine{x: x, start: y-len_as_int, end: y, steps: steps}
            vlines = append(vlines, line)
            y-=len_as_int
		case "R":
			line := HLine{y: y, start: x, end: x+len_as_int, steps: steps}
            hlines = append(hlines, line)
            x+=len_as_int
		case "L":
			line := HLine{y: y, start: x-len_as_int, end: x, steps: steps}
            hlines = append(hlines, line)
            x-=len_as_int
		}
		steps+=len_as_int
	}
	x = 0
	y = 0
	steps = 0
	closest := -1
	sort.Slice(hlines, func(i,j int) bool {
		return hlines[i].y < hlines[j].y
	})
	sort.Slice(vlines, func(i,j int) bool {
        return vlines[i].x < vlines[j].x
    })
	for _, segment := range(wire2) {
        runes := []rune(segment)
		dir := string(runes[0:1])
		len_as_str := string(runes[1:])
        len_as_int, err := strconv.Atoi(len_as_str)
		if err != nil {
            fmt.Println(err)
            return
        }
		switch dir {
        case "U":
			for _, hline := range(hlines) {
				if hline.y > y + len_as_int {
					break
				} else if hline.y >= y && hline.y <= y+len_as_int {
					if hline.start <= x && hline.end >= x && x != 0 && hline.y != 0 {
						dist := steps + (hline.y - y) + hline.steps + (x - hline.start)
						if closest == -1 || dist < closest {
							closest = dist
						}
					}
				}
			}
			y += len_as_int
		case "D":
			for _, hline := range(hlines) {
                if hline.y > y {
                    break
                } else if hline.y <= y && hline.y >= y-len_as_int {
                    if hline.start <= x && hline.end >= x && x != 0 && hline.y != 0  {
						dist := steps + (y - hline.y) + hline.steps + (x - hline.start)
                        if closest == -1 || dist < closest {
                            closest = dist
                        }
                    }
                }
            }
			y -= len_as_int
		case "R":
			for _, vline := range(vlines) {
                if vline.x > x + len_as_int {
                    break
                } else if vline.x >= x && vline.x <= x+len_as_int {
                    if vline.start <= y && vline.end >= y && y != 0 && vline.x != 0 {
						dist := steps + (vline.x - x) + vline.steps + (y - vline.start)
                        if closest == -1 || dist < closest {
                            closest = dist
                        }
                    }
                }
            }
            x += len_as_int
		case "L":
			for _, vline := range(vlines) {
                if vline.x > x {
                    break
                } else if vline.x <= x && vline.x >= x-len_as_int {
                    if vline.start <= y && vline.end >= y && y != 0 && vline.x != 0 {
                        dist := steps + (x - vline.x) + vline.steps + (y - vline.start)
                        if closest == -1 || dist < closest {
                            closest = dist
                        }
                    }
                }
            }
            x -= len_as_int
		}
		steps += len_as_int
	}
	fmt.Println(closest)
}
