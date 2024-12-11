import functools

def run(data):
    data1 = parse_data(data)
    data2 = parse_data(data)
    return (part1(data1), part2(data2))

def parse_data(data):
    return list(map(int,data.split(' ')))

def part1(data):
    return len(blink1(data, 25))

def blink1(stones, times):
    while times > 0:
        times -= 1
        newstones = [];
        for stone in stones:
            str_stone = str(stone)
            if stone == 0:
                newstones.append(1)
            elif len(str_stone) % 2 == 0:
                mid = len(str_stone) // 2
                newstones.append(int(str_stone[0:mid]))
                newstones.append(int(str_stone[mid:]))
            else:
                newstones.append(stone * 2024)
        stones = newstones
    return stones

def part2(data):
    return sum([blink2(stone, 75) for stone in data])

@functools.cache
def blink2(stone, times):
    str_stone = str(stone)
    if times == 1:
        if len(str_stone) % 2 == 0:
            return 2
        return 1

    if stone == 0:
        return blink2(1, times - 1)
    if len(str_stone) % 2 == 0:
        mid = len(str_stone) // 2
        return blink2(int(str_stone[0:mid]), times -1) + blink2(int(str_stone[mid:]), times - 1)
    return blink2(stone*2024, times - 1)

def test():
    test_data = """125 17"""
    assert part1(parse_data(test_data)) == 55312, "Should be 55312"

    assert sum([blink2(stone, 25) for stone in parse_data(test_data)]) == 55312, "Should be 55312"
