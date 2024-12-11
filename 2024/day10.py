from collections import deque, defaultdict

def run(data):
    data1 = parse_data(data)
    data2 = parse_data(data)
    return (part1(data1), part2(data2))

def parse_data(data):
    grid = defaultdict(lambda: -2)
    for y, row in enumerate(data.splitlines()):
        for x, c in enumerate(row):
            grid[(x,y)] = int(c)
    return grid

def part1(data):
    start_points = get_startpoints(data, 0)
    trail_scores = [get_trail_score(data, start, 1, 9) for start in start_points]
    return sum(trail_scores)

def get_startpoints(grid, val):
    ret = []
    for k, v in grid.items():
        if v == val:
            ret.append(k)
    return ret

def get_trail_score(grid, start, d, target):
    deq = deque([start])
    seen = {start}
    neighbors = [(1,0), (0,1), (-1,0), (0, -1)]
    score = 0
    while deq:
        p = deq.popleft()
        val = grid[p]
        if val == target:
            score += 1
            continue
        x,y = p
        for dx, dy in neighbors:
            np = (x+dx, y+dy)
            if np not in seen and grid[np] - val == d:
                seen.add(np)
                deq.append(np)
    return score


def part2(data):
    start_points = get_startpoints(data, 0)
    trail_scores = [get_trail_score_2(data, start, 1, 9) for start in start_points]
    return sum(trail_scores)

def get_trail_score_2(grid, start, d, target):
    deq = deque([start])
    neighbors = [(1,0), (0,1), (-1,0), (0, -1)]
    score = 0
    while deq:
        p = deq.popleft()
        val = grid[p]
        if val == target:
            score += 1
            continue
        x,y = p
        for dx, dy in neighbors:
            np = (x+dx, y+dy)
            if grid[np] - val == d:
                deq.append(np)
    return score

def test():
    test_data = """89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732"""
    assert part1(parse_data(test_data)) == 36, "Should be 36"
    assert part2(parse_data(test_data)) == 81, "Should be 81"
