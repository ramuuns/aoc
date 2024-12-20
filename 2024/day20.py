from collections import defaultdict, deque
from heapq import heappush, heappop

def run(data):
    data1 = parse_data(data)
    data2 = parse_data(data)
    return (part1(data1), part2(data2))

def parse_data(data):
    start = end = (0,0)
    grid = {}
    for y,row in enumerate(data.splitlines()):
        for x, c in enumerate(row):
            if c == 'S':
                grid[(x,y)] = '.'
                start = (x,y)
            elif c == 'E':
                grid[(x,y)] = '.'
                end = (x,y)
            else:
                grid[(x,y)] = c
    return start, end, grid

def part1(data):
    start, end, grid = data
    path = best_path(start, end, grid)
    cheats_by_time = find_cheats_by_time(grid, path)
    total = 0
    for t, c in cheats_by_time.items():
        total += c if t >= 100 else 0
    return total

def best_path(start, end, grid):
    path = {}
    path[start] = 0
    dirs = [(0,1), (1,0), (0,-1), (-1,0)]
    steps = 0
    p = start
    while p != end:
        x, y = p
        for (dx, dy) in dirs:
            if grid[(x+dx, y+dy)] == '.' and (x+dx, y+dy) not in path:
                steps += 1
                p = (x+dx, y+dy)
                path[p] = steps
                break
    return path

def find_cheats_by_time(grid, path):
    dirs = [(0,1), (1,0), (0,-1), (-1,0)]
    cheats_by_time = defaultdict(int)
    for p, t in path.items():
        x, y = p
        for (dx, dy) in dirs:
            if grid[(x+dx, y+dy)] == '#' and (x+2*dx, y+2*dy) in grid and grid[(x+2*dx, y+2*dy)] == '.' and path[(x+2*dx, y+2*dy)] > t + 2:
                cheats_by_time[path[(x+2*dx, y+2*dy)] - t - 2] += 1
    return cheats_by_time

def find_cheats_by_time_20(grid,path):
    cheats_by_time = defaultdict(int)
    for p, t in path.items():
        floodfill_cheats(p, 0, t, grid, path, cheats_by_time)
    return cheats_by_time

def floodfill_cheats(s, dt, t, grid, path, cheats_by_time):
    dirs = [(0,1), (1,0), (0,-1), (-1,0)]
    seen = {s,}
    deq = [(dt, s)]
    while deq:
        dt, p = heappop(deq)
        if dt == 20:
            continue
        x, y = p
        for dx, dy in dirs:
            newp = x+dx, y+dy
            if newp in grid and  newp not in seen:
                seen.add(newp)
                heappush(deq, (dt+1, newp))
                if grid[newp] == '.' and path[newp] > t+dt+1:
                    cheats_by_time[path[newp] - t - dt - 1] += 1


def part2(data):
    start, end, grid = data
    path = best_path(start, end, grid)
    cheats_by_time = find_cheats_by_time_20(grid, path)
    total = 0
    for t, c in cheats_by_time.items():
        total += c if t >= 100 else 0
    return total


def test():
    test_data = """###############
#...#...#.....#
#.#.#.#.#.###.#
#S#...#.#.#...#
#######.#.#.###
#######.#.#...#
#######.#.###.#
###..E#...#...#
###.#######.###
#...###...#...#
#.#####.#.###.#
#.#...#.#.#...#
#.#.#.#.#.#.###
#...#...#...###
###############"""
    start, end, grid = parse_data(test_data)
    path = best_path(start, end, grid)
    cheats_by_time = find_cheats_by_time(grid, path)
    test_cheats_by_time = {}
    test_cheats_by_time[2] = 14
    test_cheats_by_time[4] = 14
    test_cheats_by_time[6] = 2
    test_cheats_by_time[8] = 4
    test_cheats_by_time[10] = 2
    test_cheats_by_time[12] = 3
    test_cheats_by_time[20] = 1
    test_cheats_by_time[36] = 1
    test_cheats_by_time[38] = 1
    test_cheats_by_time[40] = 1
    test_cheats_by_time[64] = 1

    assert cheats_by_time == test_cheats_by_time, "cheats by time should match"
    cheats_by_time20 = find_cheats_by_time_20(grid, path)
    print(cheats_by_time20)
    assert cheats_by_time20[76] == 3, "there's three by 76"
    assert cheats_by_time20[74] == 4, "there's three by 76"
    assert cheats_by_time20[72] == 22, "there's three by 76"
    assert cheats_by_time20[70] == 12, "there's three by 76"
    assert cheats_by_time20[50] == 32, "there's three by 76"

    #assert part2(parse_data(test_data)) == 31, "Should be 31"
