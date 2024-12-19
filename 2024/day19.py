import re

def run(data):
    data1 = parse_data(data)
    data2 = parse_data(data)
    return (part1(data1), part2(data2))

def parse_data(data):
    towels, patterns = data.split("\n\n")
    return set(towels.split(", ")), patterns.splitlines()

def part1(data):
    towels, patterns = data
    return sum([is_possible_re(pattern, towels) for pattern in patterns])

def is_possible_re(pattern, towels):
    return re.match(r"^(" + "|".join(towels) + ")+$" , pattern) != None

cache = {}
def arrangements(pattern, towels):
    if pattern == "":
        return 1
    if pattern in cache:
        return cache[pattern]
    pref_sum = 0
    for towel in towels:
        l = len(towel)
        if pattern[:l] == towel:
            pref_sum += arrangements(pattern[l:], towels)
    cache[pattern] = pref_sum
    return pref_sum


def part2(data):
    towels, patterns = data
    return sum([arrangements(pattern, sorted(list(towels))) for pattern in patterns])


def test():
    test_data = """r, wr, b, g, bwu, rb, gb, br

brwrr
bggr
gbbr
rrbgbr
ubwu
bwurrg
brgr
bbrgwb"""
    assert part1(parse_data(test_data)) == 6, "Should be 6"
    assert part2(parse_data(test_data)) == 16, "Should be 16"
