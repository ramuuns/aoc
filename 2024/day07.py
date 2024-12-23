import time

def run(data):
    start = time.monotonic()
    data = parse_data(data)
    r = (part1(data), part2(data))
    print(f"took: {time.monotonic() - start}s")
    return r

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
            return sum_or_mul(items[0], items[1:], val)
           

def sum_or_mul(res, items, val):
    if res > val:
        return False
    if items == []:
         return res == val
    a = items[0]
    return sum_or_mul(res * a, items[1:], val) + sum_or_mul(res + a, items[1:], val)



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
            return sum_or_mul_funky(items[-1], items, len(items) - 2,  val) 

def joinnum(a,b):
    d = len(str(b))
    return a * 10**d + b

def sum_or_mul_funky(res, items, idx, val):
    if val < 0:
        return False
    if idx == -1:
         return res == val
    def can_concat():
        d = len(str(res))
        return val % 10**d == res
    def can_multiply():
        return val % res == 0
    a = items[idx]
    return ( (can_concat() and sum_or_mul_funky(a, items, idx-1, val // 10**len(str(res)) )) or 
            (can_multiply() and sum_or_mul_funky(a, items, idx-1, val // res)) or 
            sum_or_mul_funky(a, items, idx-1, val - res) )

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
    assert matches2(190, [10,19]), "come on"
    assert matches2(7290, [6,8,6,15]), "come on"
    assert part1(parse_data(test_data)) == 3749, "Should be 3749"
    assert part2(parse_data(test_data)) == 11387, "Should be 11387"
