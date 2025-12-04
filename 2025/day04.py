
def run(data):
    data1 = parse_data(data)
    data2 = parse_data(data)
    return (part1(data1), part2(data2))

def parse_data(data):
    return set([(x,y) for y, row in enumerate(data.split("\n")) for x, c in enumerate(list(row)) if c == "@"]) 

def neighbors(pos):
    x, y = pos
    return [(x-1, y-1), (x, y-1), (x+1, y-1),
            (x-1, y), (x+1, y),
            (x-1, y+1), (x, y+1), (x+1, y+1)]

def count_neighbors(pos, data):
    return sum([1 for n in neighbors(pos) if n in data])

def part1(data):
    return sum([1 for pos in data if count_neighbors(pos, data) < 4])

def part2(data):
    total_removed = 0
    while True:
        can_be_removed_pos = [pos for pos in data if count_neighbors(pos, data) < 4]
        if len(can_be_removed_pos) == 0:
            break
        total_removed += len(can_be_removed_pos)
        for pos in can_be_removed_pos:
            data.remove(pos)
    return total_removed


def test():
    test_data = """..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@."""
    assert part1(parse_data(test_data)) == 13, "Should be 11"
    assert part2(parse_data(test_data)) == 43, "Should be 31"
