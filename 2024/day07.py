
def run(data):
    data = parse_data(data)
    return (part1(data), part2(data))

def parse_data(data):
    def parse_line(line):
        num, items = line.split(": ")
        return int(num), list(map(int, items.split(" ")))
    return [parse_line(line) for line in data.splitlines()]


def part1(data):
    total = 0
    for val, items in data:
        if matches(val, items):
            total += val
    return total

def matches(val, items):
    if val < 0:
        return False
    match items:
        case []:
            return val == 0
        case [a]:
            return val == a
        case [a,b]:
            if val == a+b or val == a*b:
                return True
        case _:
            return val in sum_or_mul(items[0], items[1:], [])
           

def sum_or_mul(res, items, ret):
    if items == []:
         return ret + [res]
    a = items[0]
    return sum_or_mul(res + a, items[1:], ret) + sum_or_mul(res * a, items[1:], ret)



def part2(data):
    total = 0
    for val, items in data:
        if matches2(val, items):
            total += val
    return total


def matches2(val, items):
    if val < 0:
        return False
    match items:
        case []:
            return val == 0
        case [a]:
            return val == a
        case [a,b]:
            if val == a+b or val == a*b or f"{val}" == f"{a}{b}":
                return True
        case _:
            return val in sum_or_mul_funky(items[0], items[1:], [])

def sum_or_mul_funky(res, items, ret):
    if items == []:
         return ret + [res]
    a = items[0]
    return sum_or_mul_funky(res + a, items[1:], ret) + sum_or_mul_funky(res * a, items[1:], ret) + sum_or_mul_funky(int(f"{res}{a}"), items[1:], ret) 

def test():
    test_data = """190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20"""
    assert matches(190, [10,19]), "come on"
    assert part1(parse_data(test_data)) == 3749, "Should be 3749"
    assert part2(parse_data(test_data)) == 11387, "Should be 11387"
