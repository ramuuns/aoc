from collections import deque, defaultdict

def run(data):
    data1 = parse_data(data)
    data2 = parse_data(data)
    return (part1(data1), part2(data2))

def parse_data(data):
    grid = defaultdict(lambda: '.')
    for y, row in enumerate(data.splitlines()):
        for x, c in enumerate(row):
            grid[(x,y)] = c
    return grid

def part1(grid):
    seen = set()
    res = 0
    keys = list(grid.keys())
    for pos in keys:
        if pos not in seen:
            area, perimeter = floodfill(grid, pos, seen)
            res += area * perimeter
    return res

def floodfill(grid, pos, seen):
    area = 0
    perimeter = 0
    neighbors = [(1,0), (-1,0), (0, 1), (0, -1)]
    seen.add(pos)
    d = deque([pos])
    while d:
        p = d.popleft()
        area += 1
        x,y = p
        for dx, dy in neighbors:
            if grid[(x+dx, y+dy)] != grid[p]:
                perimeter += 1
            else:
                if (x+dx, y+dy) not in seen:
                    seen.add((x+dx, y+dy))
                    d.append((x+dx, y+dy))
    return area, perimeter

def part2(grid):
    seen = set()
    res = 0
    keys = list(grid.keys())
    for pos in keys:
        if pos not in seen:
            area, sides = floodfill2(grid, pos, seen)
            res += area * sides
    return res

def floodfill2(grid, pos, seen):
    area = 0
    perimeter = set()
    neighbors = [(1,0), (-1,0), (0, 1), (0, -1)]
    seen.add(pos)
    d = deque([pos])
    while d:
        p = d.popleft()
        area += 1
        x,y = p
        for dx, dy in neighbors:
            if grid[(x+dx, y+dy)] != grid[p]:
                perimeter.add(p)
            else:
                if (x+dx, y+dy) not in seen:
                    seen.add((x+dx, y+dy))
                    d.append((x+dx, y+dy))
    sides = 0
    pseen = set()
    for p in perimeter:
        x, y = p
        for n in neighbors:
            dx, dy = n
            if grid[p] != grid[(x+dx, y+dy)] and (p, n) not in pseen:
                pseen.add((p, n))
                sides += 1
                if dx == 0:
                    d = 1
                    while (x+d, y) in perimeter and grid[p] != grid[(x+d, y+dy)]:
                        pseen.add(((x+d, y), n))
                        d += 1
                    d = -1
                    while (x+d, y) in perimeter and grid[p] != grid[(x+d, y+dy)]:
                        pseen.add(((x+d, y), n))
                        d -= 1
                else:
                    d = 1
                    while (x, y+d) in perimeter and grid[p] != grid[(x+dx, y+d)]:
                        pseen.add(((x, y+d), n))
                        d += 1
                    d = -1
                    while (x, y+d) in perimeter and grid[p] != grid[(x+dx, y+d)]:
                        pseen.add(((x, y+d), n))
                        d -= 1

    return area, sides

def test():
    test_data = """AAAA
BBCD
BBCC
EEEC"""
    assert part1(parse_data(test_data)) == 140, "Should be 140"
    assert part2(parse_data(test_data)) == 80, "Should be 80"

    test_data2 = """OOOOO
OXOXO
OOOOO
OXOXO
OOOOO"""
    assert part1(parse_data(test_data2)) == 772, "Should be 772"
    assert part2(parse_data(test_data2)) == 436, "Should be 436"

    test_data3 = """RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE"""
    assert part1(parse_data(test_data3)) == 1930, "Should be 1930"
    assert part2(parse_data(test_data3)) == 1206, "Should be 1206"
    
    test_data4 = """EEEEE
EXXXX
EEEEE
EXXXX
EEEEE"""
    assert part2(parse_data(test_data4)) == 236, "Should be 236 (the E)"

    test_data5 = """AAAAAA
AAABBA
AAABBA
ABBAAA
ABBAAA
AAAAAA"""
    assert part2(parse_data(test_data5)) == 368, "Should be 368"
    
