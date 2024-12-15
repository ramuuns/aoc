
def run(data):
    data1 = parse_data(data)
    data2 = parse_data(data)
    return (part1(data1), part2(data2))

def parse_data(data):
    grid, moves = data.split("\n\n")
    moves = list("".join(moves.splitlines()))
    actual_grid = {}
    
    for y, row in enumerate(grid.splitlines()):
        for x, c in enumerate(row):
            actual_grid[(x,y)] = c if c != '@' else '.'
            if c == '@':
                start = x,y
    return actual_grid, start, moves

def part1(data):
    grid, start, moves = data
    pos = start
    for move in moves:
        grid, pos = move_robot(grid, pos, move)
    total = 0
    for k, v in grid.items():
        if v == 'O':
            x, y = k
            total += y*100 + x
    return total

moves_to_dx_dy = {
    "<": (-1, 0),
    "^": (0, -1),
    ">": (1,0),
    "v": (0,1)
}

def move_robot(grid, pos, move):
    dx, dy = moves_to_dx_dy[move]
    x, y = pos
    if grid[(x+dx, y+dy)] == '.':
        return grid, (x+dx, y+dy)
    if grid[(x+dx, y+dy)] == '#':
        return grid, pos
    n = 2
    while True:
        if grid[(x+dx*n, y+dy*n)] == '.':
            grid[(x+dx*n, y+dy*n)] = 'O'
            grid[(x+dx, y+dy)] = '.'
            return grid, (x+dx, y+dy)
        if grid[(x+dx*n, y+dy*n)] == '#':
            return grid, pos
        n += 1

def move_robot_2(grid, pos, move):
    dx, dy = moves_to_dx_dy[move]
    x, y = pos
    if grid[(x+dx, y+dy)] == '.':
        return grid, (x+dx, y+dy)
    if grid[(x+dx, y+dy)] == '#':
        return grid, pos
    if dy == 0:
        n = 2
        while True:
            if grid[(x+dx*n, y)] == '.':
                for i in range(x+dx*n, x, dx*-1):
                    grid[(i, y)] = grid[(i-dx, y)]
                return grid, (x+dx, y)
            if grid[(x+dx*n, y)] == '#':
                return grid, pos
            n+=1
    else:
        if grid[(x, y+dy)] == '[':
            box_edge = [x,x+1]
        else:
            box_edge = [x-1,x]
        n = 2
        all_boxes = [(y+dy, box_edge)]
        while True:
            all_empty = True
            new_edge = set()
            for xx in box_edge:
                if grid[(xx, y+dy*n)] == '#':
                    return grid, pos
                if grid[(xx, y+dy*n)] == '[' or grid[(xx, y+dy*n)] == ']':
                    new_edge.add(xx)
                    if grid[(xx, y+dy*n)] == '[':
                        new_edge.add(xx+1)
                    else:
                        new_edge.add(xx-1)
                    all_empty = False
            if all_empty:
                for aby in reversed(all_boxes):
                    by, boxes = aby
                    for bx in boxes:
                        assert grid[(bx, by+dy)] == '.'
                        grid[(bx, by+dy)] = grid[(bx, by)]
                        grid[(bx, by)] = '.'
                return grid, (x+dx, y+dy)
            else:
                box_edge = sorted(new_edge)
                all_boxes.append((y+dy*n, box_edge))
            n+=1

def print_grid(grid, robot):
    x_max = 0 
    y_max = 0
    for (x,y) in grid.keys():
        x_max = max(x,x_max)
        y_max = max(y,y_max)
    for y in range(0, y_max+1):
        line = ''
        for x in range(0, x_max+1):
            line += '@' if (x,y) == robot and grid[(x,y)] == '.' else grid[(x,y)]
        print(line)
    print("\n")


def double_the_grid(grid):
    newgrid = {}
    for pos, item in grid.items():
        x, y = pos
        if item == '.':
            newgrid[(2*x, y)] = '.'
            newgrid[(2*x+1, y)] = '.'
        elif item == '#':
            newgrid[(2*x, y)] = '#'
            newgrid[(2*x+1, y)] = '#'
        elif item == 'O':
            newgrid[(2*x, y)] = '['
            newgrid[(2*x+1, y)] = ']'
    return newgrid

def part2(data):
    grid, start, moves = data
    grid = double_the_grid(grid)
    start_x, y = start
    start_x = start_x * 2
    start = start_x, y
    pos = start
    k = 1
    for move in moves:
        grid, pos = move_robot_2(grid, pos, move)
        #print(move)
        #print_grid(grid,pos)
        #k+=1
        #if k == 3:
        #    break
    total = 0
    for k, v in grid.items():
        if v == '[':
            x, y = k
            total += y*100 + x
    return total


def test():
    test_data = """########
#..O.O.#
##@.O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

<^^>>>vv<v>>v<<"""

    test_data1 = """##########
#..O..O.O#
#......O.#
#.OO..O.O#
#..O@..O.#
#O#..O...#
#O..O..O.#
#.OO.O.OO#
#....O...#
##########

<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<<<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^>^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^<><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^"""
    assert part1(parse_data(test_data)) == 2028, "Should be 2028"
    assert part1(parse_data(test_data1)) == 10092, "Should be 10092"
    assert part2(parse_data(test_data1)) == 9021, "Should be 9021"
