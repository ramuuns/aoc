
def run(data):
    data = parse_data(data)
    return (part1(data), part2(data))

def parse_data(data):
    return data

def part1(data):
    floor = 0
    for instr in data:
        if instr == "(":
            floor = floor+1
        elif instr == ")":
            floor = floor-1
        else:
            pass
    return floor

def part2(data):
    pos = 1
    floor = 0
    for instr in data:
        if instr == "(":
            floor = floor+1
        elif instr == ")":
            floor = floor-1
        else:
            pass
        if floor == -1:
            break
        pos = pos+1
    return pos

def test():
    assert part1(parse_data("(())")) == 0, "Should be 0"
    assert part1(parse_data("()()")) == 0, "Should be 0"
    assert part1(parse_data("(((")) == 3, "Should be 3"
    assert part1(parse_data("(()(()(")) == 3, "Should be 3"
    assert part1(parse_data("))(((((")) == 3, "Should be 3"
    assert part1(parse_data("())")) == -1, "Should be -1"
    assert part1(parse_data("))(")) == -1, "Should be -1"
    assert part1(parse_data(")))")) == -3, "Should be -3"
    assert part1(parse_data(")())())")) == -3, "Should be -3"
    assert part2(parse_data(")")) == 1, "Should be 1"
    assert part2(parse_data("()())")) == 5, "Should be 5"
