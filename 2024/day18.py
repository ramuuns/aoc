from collections import defaultdict
from heapq import heappush, heappop

def run(data):
    data1 = parse_data(data)
    data2 = parse_data(data)
    return (part1(data1,False), part2(data2, False))

def parse_data(data):
    return [ list(map(int,row.split(','))) for row in data.splitlines()]

def part1(data, is_test):
    size = 7 if is_test else 71
    max_items = 12 if is_test else 1024
    start = (0,0)
    end = (size-1, size-1)
    grid = defaultdict(lambda: '#')
    for x in range(size):
        for y in range(size):
            grid[(x,y)] = '.'
    for (x,y) in data[:max_items]:
        grid[(x,y)] = '#'
    steps = astar_me(start, end, grid, 1)
    return steps

def md(x,y, tgt):
    tx,ty = tgt
    return abs(tx - x) + abs(ty - y)

def astar_me(start, end, grid, sure):
    pq = [(0, start, 0)]
    seen = {}
    seen[start] = 0
    dirs = [(0,1), (1,0), (0,-1), (-1,0)]
    while len(pq):
        _, p, steps = heappop(pq)
        if p == end:
            return steps
        x,y = p
        for d in dirs:
            dx, dy = d
            if grid[(x+dx, y+dy)] == '.' and ( (x+dx, y+dy) not in seen or seen[(x+dx, y+dy)] > steps + 1):
                seen[(x+dx, y+dy)] = steps + 1
                heappush(pq, (steps+1 - md(x+dx, y+dy, end)*sure, (x+dx, y+dy), steps+1))
    return -1

def part2(data, is_test):
    size = 7 if is_test else 71
    start = (0,0)
    end = (size-1, size-1)
    grid = defaultdict(lambda: '#')
    for x in range(size):
        for y in range(size):
            grid[(x,y)] = '.'
    for (x,y) in data:
        grid[(x,y)] = '#'
        steps = astar_me(start, end, grid, 1)
        if steps == -1:
            return f"{x},{y}"
    return 0


def test():
    test_data = """5,4
4,2
4,5
3,0
2,1
6,3
2,4
1,5
0,6
3,3
2,6
5,1
1,2
5,5
2,5
6,5
1,4
0,4
6,4
1,1
6,1
1,0
0,5
1,6
2,0"""
    assert part1(parse_data(test_data), True) == 22, "Should be 22"
    assert part2(parse_data(test_data), True) == '6,1', "Should be 6,1"
