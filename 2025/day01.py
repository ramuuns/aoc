import re

def run(data):
    data1 = parse_data(data)
    data2 = parse_data(data)
    return (part1(data1), part2(data2))

def parse_number(line):
    matches = re.findall("^(L|R)(\\d+)$", line)
    return matches[0]

def parse_data(data):
    return [parse_number(line) for line in data.split("\n")]

def part1(data):
    zeros = 0
    curr = 50
    for (lr, num) in data:
        if lr == "L":
            curr -= int(num)
        else:
            curr +=  int(num)
        if curr % 100 == 0:
            zeros += 1
    return zeros

def part2(data):
    zeros = 0
    curr = 50
    prev = 50
    for (lr, num) in data:
        prev = curr
        if lr == "L":
            curr = (100 + curr - int(num)) % 100
            zeros += int(num) // 100
            if curr > prev and prev != 0:
                zeros += 1
        else:
            curr = (curr + int(num)) % 100
            zeros += int(num) // 100
            if curr < prev and curr != 0:
                zeros += 1
        if curr % 100 == 0 and int(num) % 100 != 0:
            zeros += 1
    return zeros


def test():
    test_data = """L68
L30
R48
L5
R60
L55
L1
L99
R14
L82"""
    assert part1(parse_data(test_data)) == 3, "Should be 3"
    assert part2(parse_data(test_data)) == 6, "Should be 6"
    assert part2(parse_data("R150")) == 2, "should be 2"
