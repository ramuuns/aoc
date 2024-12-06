
def run(data):
    data = parse_data(data)
    return (part1(data), part2(data))

def parse_data(data):
    return [list(line) for line in data.strip().splitlines()]

def part1(data):
    (direction,pos) = get_start_pos(data)
    vcount = len(walk_while_in_grid(direction, pos, data, {pos}))
    return vcount

def get_start_pos(grid):
    for y, row in enumerate(grid):
        for x, c in enumerate(row):
            if c == '^':
                return ((0, -1), (x,y))
            if c == '>':
                return ((1, 0), (x,y))
            if c == 'v':
                return ((0,1), (x,y))
            if c == '<':
                return ((-1, 0), (x,y))
    raise "wtf couldn't get start position"

def walk_while_in_grid(direction, pos, grid, visited):
    dx, dy = direction
    x, y = pos
    while True:
        if x+dx < 0 or x+dx >= len(grid[0]) or y+dy < 0 or y+dy >= len(grid):
            return visited
        if grid[y+dy][x+dx] == '#':
            dx,dy = turn_left((dx,dy))
            continue
        x+=dx
        y+=dy
        visited.add((x,y))

def turn_left(direction):
    match direction:
        case 0, -1:
            return 1,0
        case 1, 0:
            return 0,1
        case 0, 1:
            return -1, 0
        case -1,0:
            return 0, -1

def part2(data):
    (direction,pos) = get_start_pos(data)
    loop_count = walk_finding_loops(direction, pos, data, {(direction, pos)})
    return loop_count

def walk_finding_loops(direction, pos, grid, visited):
    dx, dy = direction
    x,y = pos
    obstacles = set()
    loop_count = 0
    while True:
        if x+dx < 0 or x+dx >= len(grid[0]) or y+dy < 0 or y+dy >= len(grid):
            return loop_count
        if grid[y+dy][x+dx] == '#':
            dx,dy = turn_left((dx,dy))
            continue
        if ((x+dx, y+dy)) not in obstacles and add_obstacle_and_check_loop((dx,dy), (x,y), visited.copy(), grid):
            loop_count+=1
        obstacles.add((x+dx, y+dy))
        x+=dx
        y+=dy
        visited.add(((dx, dy),(x,y)))

def add_obstacle_and_check_loop(direction, pos, visited, grid):
    x, y = pos
    dx,dy = direction
    grid[y+dy][x+dx] = 'O'
    dx,dy = turn_left(direction)
    while True:
        if x+dx < 0 or x+dx >= len(grid[0]) or y+dy < 0 or y+dy >= len(grid):
            x,y = pos
            dx, dy = direction
            grid[y+dy][x+dx] = '.'
            return False
        if grid[y+dy][x+dx] == '#' or grid[y+dy][x+dx] == 'O':
            dx,dy = turn_left((dx,dy))
            continue
        if ((dx,dy),(x+dx,y+dy)) in visited:
        #    print_grid_and_visited(grid, visited, (x+dx,y+dy))
            x,y = pos
            dx, dy = direction
            grid[y+dy][x+dx] = '.'
            return True
        x+=dx
        y+=dy
        visited.add(((dx, dy),(x,y)))

def print_grid_and_visited(grid, visited, endpos):
    print("")
    endx, endy = endpos
    for y, row in enumerate(grid):
        line = []
        for x, c in enumerate(row):
            if y == endy and x == endx:
                line.append('X')
                continue
            has_y = ((0,1),(x,y)) in visited or ((0,-1), (x,y)) in visited
            has_x = ((1,0),(x,y)) in visited or ((-1,0), (x,y)) in visited
            match (has_x, has_y):
                case True, True:
                    line.append('+')
                case True, _:
                    line.append('-')
                case _, True:
                    line.append('|')
                case _:
                    line.append(c)
        print(''.join(line))

    print("")
            

def test():
    test_data = """
....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...
"""
    assert part1(parse_data(test_data)) == 41, "Should be 41"
    assert part2(parse_data(test_data)) == 6, "Should be 6"
