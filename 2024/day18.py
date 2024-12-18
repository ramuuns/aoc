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
    steps, _ = astar_me(start, end, grid)
    return steps

def md(x,y, tgt):
    tx,ty = tgt
    return abs(tx - x) + abs(ty - y)

def astar_me(start, end, grid):
    pq = [(0, start, 0, {start,})]
    seen = {}
    seen[start] = 0
    dirs = [(0,1), (1,0), (0,-1), (-1,0)]
    while len(pq):
        _, p, steps, path = heappop(pq)
        if p == end:
            return steps, path
        x,y = p
        for d in dirs:
            dx, dy = d
            if grid[(x+dx, y+dy)] == '.' and ( (x+dx, y+dy) not in seen or seen[(x+dx, y+dy)] > steps + 1):
                seen[(x+dx, y+dy)] = steps + 1
                heappush(pq, (steps+1 - md(x+dx, y+dy, end), (x+dx, y+dy), steps+1, path | {(x+dx, y+dy),}))
    return -1, set()

def part2(data, is_test):
    size = 7 if is_test else 71
    start = (0,0)
    end = (size-1, size-1)
    grid = defaultdict(lambda: '#')
    for x in range(size):
        for y in range(size):
            grid[(x,y)] = '.'
    s = 1
    best_path = {}
    for (x,y) in data:
        grid[(x,y)] = '#'
        if len(best_path) == 0 or (x,y) in best_path:
            steps, best_path = astar_me(start, end, grid)
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
