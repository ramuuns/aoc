from collections import defaultdict
from itertools import combinations

def run(data):
    data = parse_data(data)
    return (part1(data), part2(data))

def parse_data(data):
    return [list(line) for line in data.splitlines()]

def part1(data):
    max_y = len(data)
    max_x = len(data[0])
    freq_groups = get_freq_groups(data)
    antinodes = get_antinodes(freq_groups, max_x, max_y)
    return len(antinodes)

def get_freq_groups(grid):
    groups = defaultdict(list)
    for y, row in enumerate(grid):
        for x, c in enumerate(row):
            if c != '.':
                groups[c].append((x,y))
    return groups

def get_antinodes(groups, max_x, max_y):
    antinodes = set()
    for group in groups.values():
        for a, b in combinations(group, 2):
            x1, y1 = a
            x2, y2 = b
            dx = x2 - x1
            dy = y2 - y1
            x0 = x1 - dx
            y0 = y1 - dy
            x3 = x2 + dx
            y3 = y2 + dy
            if within_bounds(max_x, max_y, x0, y0):
                antinodes.add((x0,y0))
            if within_bounds(max_x, max_y, x3, y3):
                antinodes.add((x3,y3))
                
    return antinodes

def within_bounds(max_x, max_y, x, y):
    return 0 <= x < max_x and 0 <= y < max_y

def get_all_antinodes(groups, max_x, max_y):
    antinodes = set()
    for group in groups.values():
        for a, b in combinations(group, 2):
            x1, y1 = a
            x2, y2 = b
            dx = x2 - x1
            dy = y2 - y1
            x = x1
            y = y1
            while within_bounds(max_x, max_y, x, y):
                antinodes.add((x,y))
                x -= dx
                y -= dy
            x = x2
            y = y2
            while within_bounds(max_x, max_y, x, y):
                antinodes.add((x,y))
                x += dx
                y += dy


    return antinodes


def part2(data):
    max_y = len(data)
    max_x = len(data[0])
    freq_groups = get_freq_groups(data)
    antinodes = get_all_antinodes(freq_groups, max_x, max_y)
    return len(antinodes)


def test():
    test_data = """............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............"""
    assert part1(parse_data(test_data)) == 14, "Should be 14"
    assert part2(parse_data(test_data)) == 34, "Should be 34"
