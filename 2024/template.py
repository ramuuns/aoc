
def run(data):
    data1 = parse_data(data)
    data2 = parse_data(data)
    return (part1(data1), part2(data2))

def parse_data(data):
    return data

def part1(data):
    return 0

def part2(data):
    return 0


def test():
    test_data = """
_SOME_NONSENSE_
"""
    assert part1(parse_data(test_data)) == 11, "Should be 11"
    assert part2(parse_data(test_data)) == 31, "Should be 31"
