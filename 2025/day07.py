from collections import deque

def run(data):
    data1 = parse_data(data)
    data2 = parse_data(data)
    return (part1(data1), part2(data2))

def parse_data(data):
    start = (0,0)
    maxy = 0
    splitters = set([])
    for y, row in enumerate(data.split("\n")):
        maxy = y
        for x, c in enumerate(list(row)):
            if c == "S":
                start = (x,y)
            elif c == "^":
                splitters.add((x,y))
        
    return (start, maxy, splitters)

def part1(data):
    start, maxy, splitters = data
    split_count = 0
    beams = deque([start])
    seen_beams = set([start])
    seen_splitters = set([])
    while beams:
        (x,y) = beams.popleft()
        while y <= maxy:
            y += 1
            seen_beams.add((x,y))
            if (x,y) in splitters:
                if (x,y) not in seen_splitters:
                    seen_splitters.add((x,y))
                    split_count += 1
                    if (x-1, y) not in seen_beams:
                        beams.append((x-1, y))
                        seen_beams.add((x-1, y))
                    if (x+1, y) not in seen_beams:
                        seen_beams.add((x+1, y))
                        beams.append((x+1, y))
                break
    return split_count

worlds_from_splitter = {}

def calc_worlds_from_splitter(splitter, maxy, splitters):
    if splitter in worlds_from_splitter:
        return worlds_from_splitter[splitter]
    (x,y) = splitter
    worlds = 0
    while y < maxy:
        y+=1
        if (x-1, y) in splitters:
            worlds += calc_worlds_from_splitter((x-1, y), maxy, splitters)
            break
    if y == maxy:
        worlds += 1
    (x,y) = splitter
    while y < maxy:
        y+=1
        if (x+1, y) in splitters:
            worlds += calc_worlds_from_splitter((x+1, y), maxy, splitters)
            break
    if y == maxy:
        worlds += 1
    worlds_from_splitter[splitter] = worlds
    return worlds

def part2(data):
    start, maxy, splitters = data

    
    (x,y) = start
    r = calc_worlds_from_splitter((x, y+2), maxy, splitters)
    return r


def test():
    test_data = """.......S.......
...............
.......^.......
...............
......^.^......
...............
.....^.^.^.....
...............
....^.^...^....
...............
...^.^...^.^...
...............
..^...^.....^..
...............
.^.^.^.^.^...^.
..............."""
    assert part1(parse_data(test_data)) == 21, "Should be 11"
    assert part2(parse_data(test_data)) == 40, "Should be 31"
