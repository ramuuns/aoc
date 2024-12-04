from collections import defaultdict

def run(data):
    data = parse_data(data)
    return (part1(data), part2(data))

def parse_data(data):
    return [list(row) for row in data.strip().split("\n")]

def part1(data):
    grid = defaultdict(str)
    xpos = []
    for y, row in enumerate(data):
        for x, c in enumerate(row):
            grid[(x,y)] = c
            if c == 'X':
                xpos.append((x,y))
    return sum([find_xmas(x,y,grid) for x,y in xpos ])

def find_xmas(x,y,grid):
    dirs = [(0,1),(1,1),(1,0),(1,-1),(0,-1),(-1,-1),(-1, 0),(-1,1)]
    return sum([ find_mas(x+dx, y+dy, grid, dx, dy) for dx,dy in dirs])

def find_mas(x,y,grid,dx,dy):
    if grid[(x,y)] == 'M' and grid[(x+dx,y+dy)] == 'A' and grid[(x+dx+dx, y+dy+dy)] == 'S':
        return 1
    return 0

def part2(data):
    grid = defaultdict(str)
    apos = []
    for y, row in enumerate(data):
        for x, c in enumerate(row):
            grid[(x,y)] = c
            if c == 'A':
                apos.append((x,y))
    return sum([is_mas(x,y,grid) for x,y in apos])

def is_mas(x,y,grid):
    if ((grid[(x+1,y+1)] == 'M' and grid[(x-1,y-1)] == 'S') or (grid[(x+1,y+1)] == 'S' and grid[(x-1,y-1)] == 'M')) and ((grid[(x+1,y-1)] == 'M' and grid[(x-1,y+1)] == 'S') or (grid[(x+1,y-1)] == 'S' and grid[(x-1,y+1)] == 'M')):
        return 1
    return 0


def test():
    test_data = """
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
"""
    assert part1(parse_data(test_data)) == 18, "Should be 18"
    assert part2(parse_data(test_data)) == 9, "Should be 9"
