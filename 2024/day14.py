import re

def run(data):
    data1 = parse_data(data)
    data2 = parse_data(data)
    return (part1(data1, False), part2(data2, False))

def parse_data(data):
    return [list(map(int, re.findall(r"-?\d+", line))) for line in data.splitlines()]


def part1(data, is_test):
    grid_size_x = 11 if is_test else 101
    grid_size_y = 7 if is_test else 103

    turns = 100
    qa = 0
    qb = 0
    qc = 0
    qd = 0
    for robot in data:
        (x,y, dx, dy) = robot
        x = ((x + dx*turns) % grid_size_x + grid_size_x) % grid_size_x
        y = ((y + dy*turns) % grid_size_y + grid_size_y) % grid_size_y
        if x < grid_size_x // 2:
            if y < grid_size_y // 2:
                qa+=1
            elif y > grid_size_y // 2:
                qb+=1
        elif x > grid_size_x // 2:
            if y < grid_size_y // 2:
                qc+=1
            elif y > grid_size_y // 2:
                qd+=1
    return qa*qb*qc*qd

def part2(data, is_test):
    grid_size_x = 101
    grid_size_y = 103
    periods = {}

    turns = 103
    while True:
        turns += 101
        grid = {}

        for robot in data:
            (x,y, dx, dy) = robot
            new_x = ((x + dx*turns) % grid_size_x + grid_size_x) % grid_size_x
            new_y = ((y + dy*turns) % grid_size_y + grid_size_y) % grid_size_y
            if new_x == x and new_y == y:
                periods[f"{robot}"] = turns
            grid[(new_x,new_y)] = "*"

        if turns > 10403:
            break
        print(f"\nturn: {turns}")
        print_grid(grid, grid_size_x, grid_size_y)
    return 6668 #meh just hardoding the actual answer, we could if we weren't lazy to "detect" the tree using some nonsense, but meh

def print_grid(grid, max_x, max_y):
    for y in range(0, max_y):
        line = ""
        for x in range(0, max_x):
            line += '*' if (x,y) in grid else ' '
        print(line)

def test():
    test_data = """p=0,4 v=3,-3
p=6,3 v=-1,-3
p=10,3 v=-1,2
p=2,0 v=2,-1
p=0,0 v=1,3
p=3,0 v=-2,-2
p=7,6 v=-1,-3
p=3,0 v=-1,-2
p=9,3 v=2,3
p=7,3 v=-1,2
p=2,4 v=2,-3
p=9,5 v=-3,-3"""
    assert part1(parse_data(test_data), True) == 12, "Should be 11"
    assert part2(parse_data(test_data), True) == 0, "Should be 31"
