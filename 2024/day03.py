import re

def run(data):
    data = parse_data(data)
    return (part1(data), part2(data))

def parse_data(data):
    return data.strip()

def mul(a,b):
    return a * b

def part1(data):
    muls = re.findall(r'mul\(\d+,\d+\)' ,data)
    total = 0
    for m in muls:
        total = total + eval(m)
    return total

def part2(data):
    muls_dos_and_donts = re.findall(r'(mul\(\d+,\d+\))|(do\(\))|(don\'t\(\))', data)
    total = 0
    enabled = True
    for expr in muls_dos_and_donts:
        match expr:
            case [_,'do()',_]:
                enabled = True
            case [_,_,"don't()"]:
                enabled = False
            case [m,'','']:
                if enabled:
                    total = total + eval(m)
    return total


def test():
    test_data = """
xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
"""
    test_data_2 = """
xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
"""
    assert part1(parse_data(test_data)) == 161, "Should be 161"
    assert part2(parse_data(test_data_2)) == 48, "Should be 48"
