import re
from collections import defaultdict

def run(data):
    data = parse_data(data)
    return (part1(data), part2(data))

def parse_data(data):
    left = []
    right = []
    for lr in data.split("\n"):
        match re.split("\\s+", lr):
            case ('', ''):
                continue
            case (l, r):
                left.append(int(l))
                right.append(int(r))
            case _:
                continue
    return (left, right)

def part1(data):
    left = data[0]
    right = data[1]
    left.sort()
    right.sort()
    dist = 0
    for lr in zip(left, right):
        match lr:
            case (left, right):
                dist = dist + abs(left - right)
            case _:
                print("matched nothingu")
    return dist

def part2(data):
    left = data[0]
    right = data[1]
    r_dict = defaultdict(int)
    for d in right:
        r_dict[d] = r_dict[d] + 1
    similarity = 0
    for l in left:
        similarity = similarity + l * r_dict[l]
    return similarity


def test():
    test_data = """
3   4
4   3
2   5
1   3
3   9
3   3
                            """
    assert part1(parse_data(test_data)) == 11, "Should be 11"
    assert part2(parse_data(test_data)) == 31, "Should be 31"
