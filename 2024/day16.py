from heapq import heappush, heappop
from collections import deque

def run(data):
    data1 = parse_data(data)
    data2 = parse_data(data)
    return (part1(data1), part2(data2))

def parse_data(data):
    grid = {}
    start = 0
    end = 0
    for y,row in enumerate(data.splitlines()):
        for x, c in enumerate(row):
            if c == 'S':
                start = (x,y)
                grid[(x,y)] = '.'
            elif c == 'E':
                end = (x,y)
                grid[(x,y)] = '.'
            else:
                grid[(x,y)] = c

    return (start, end, grid)

def part1(data):
    start, end, grid = data
    score, path = min_score(start,end,grid)
    return score

def rotate(d, left):
    if left:
        match d:
            case (1, 0):
                return (0, -1)
            case (0, -1):
                return (-1, 0)
            case (-1, 0):
                return (0, 1)
            case (0, 1):
                return (1, 0)
    else:
        match d:
            case (1, 0):
                return (0, 1)
            case (0, 1):
                return (-1, 0)
            case (-1, 0):
                return (0, -1)
            case (0, -1):
                return (1, 0)

def min_score(start, end, grid):
    seen = {}
    direction = (1, 0)
    seen[(start, direction)] = 0
    pq = [(0, (start, direction))]
    while True:
        score, (p, d) = heappop(pq)
        if p == end:
            return score, seen
        if seen[(p,d)] < score:
            continue
        x, y = p
        dx, dy = d
        if grid[(x+dx, y+dy)] == '.' and (((x+dx, y+dy), d) not in seen or seen[((x+dx, y+dy), d)] > score + 1):
            heappush(pq, (score+1, ((x+dx,y+dy), d )))
            seen[((x+dx, y+dy), d)] = score + 1
        left = rotate(d, True)
        if (p, left) not in seen or seen[(p, left)] > score + 1000:
            heappush(pq, (score+1000, (p, left)))
            seen[(p,left)] = score + 1000
        right = rotate(d, False)
        if (p, right) not in seen or seen[(p, right)] > score + 1000:
            heappush(pq, (score+1000, (p, right)))
            seen[(p,right)] = score + 1000


def backtrack(best_score, start, end, seen):
    path = {start,}
    deq = deque([])
    for (p, d) in seen.keys():
        if p == start and seen[(p,d)] == best_score:
            deq.append((p, d, best_score))
    while deq:
        p, d, s = deq.popleft()
        if p == end:
            continue
        dx, dy = d
        x, y = p
        if ((x-dx, y-dy), d) in seen and seen[((x-dx, y-dy), d)] == s-1:
            path.add((x-dx, y-dy))
            deq.append(((x-dx, y-dy), d, s-1))
        left = rotate(d, True)
        if (p, left) in seen and seen[(p, left)] == s - 1000:
            deq.append((p, left, s - 1000))
        right = rotate(d, False)
        if (p, right) in seen and seen[(p, right)] == s - 1000:
            deq.append((p, right, s - 1000))

    return len(path)


def part2(data):
    start, end, grid = data
    score, seen = min_score(start,end,grid)
    return backtrack(score, end, start, seen)


def test():
    test_data = """###############
#.......#....E#
#.#.###.#.###.#
#.....#.#...#.#
#.###.#####.#.#
#.#.#.......#.#
#.#.#####.###.#
#...........#.#
###.#.#####.#.#
#...#.....#.#.#
#.#.#.###.#.#.#
#.....#...#.#.#
#.###.#.#.#.#.#
#S..#.....#...#
###############"""

    test_data_2 = """#################
#...#...#...#..E#
#.#.#.#.#.#.#.#.#
#.#.#.#...#...#.#
#.#.#.#.###.#.#.#
#...#.#.#.....#.#
#.#.#.#.#.#####.#
#.#...#.#.#.....#
#.#.#####.#.###.#
#.#.#.......#...#
#.#.###.#####.###
#.#.#...#.....#.#
#.#.#.#####.###.#
#.#.#.........#.#
#.#.#.#########.#
#S#.............#
#################"""

    assert part1(parse_data(test_data)) == 7036, "Should be 7036"
    assert part1(parse_data(test_data_2)) == 11048, "Should be 11048"
    assert part2(parse_data(test_data)) == 45, "Should be 45"
    assert part2(parse_data(test_data_2)) == 64, "Should be 64"
