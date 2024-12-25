
def run(data):
    data1 = parse_data(data)
    data2 = parse_data(data)
    return (part1(data1), part2(data2))

def parse_data(data):
    items = data.split("\n\n")
    keys = []
    locks = []
    for item in items:
        if item[0] == '.':
            keys.append(parse_lock(list(reversed(item.splitlines()))))
        else:
            locks.append(parse_lock(item.splitlines()))
    return keys, locks

def parse_lock(lines):
    lock = [0 for k in lines[0]]
    for row in lines[1:]:
        for index, item in enumerate(row):
            if item == '#':
                lock[index] += 1
    return lock


def part1(data):
    keys, locks = data
    total_ok = 0
    for key in keys:
        for lock in locks:
            total_ok += 1 if key_fits_maybe(key,lock) else 0
    return total_ok

def key_fits_maybe(key,lock):
    for k,l in zip(key, lock):
        if k+l > 5:
            return False
    return True

def part2(data):
    return 0


def test():
    test_data = """#####
.####
.####
.####
.#.#.
.#...
.....

#####
##.##
.#.##
...##
...#.
...#.
.....

.....
#....
#....
#...#
#.#.#
#.###
#####

.....
.....
#.#..
###..
###.#
###.#
#####

.....
.....
.....
#....
#.#..
#.#.#
#####"""
    assert part1(parse_data(test_data)) == 3, "Should be 3"
    assert part2(parse_data(test_data)) == 0, "Should be 31"
