
def run(data):
    data = parse_data(data)
    return (part1(data), part2(data))

def parse_data(data):
    return [list(map(int, row.split())) for row in data.strip().split("\n")]

def part1(data):
    return sum(1 if safe(row) else 0 for row in data)

def part2(data):
    return sum(1 if damp_safe(row) else 0 for row in data)

def safe(arr):
    is_increasing = arr[-1] > arr[0]
    p = arr[0]
    for el in arr[1:]:
        if (is_increasing and el <= p) or (not is_increasing and el >= p) or abs(el - p) > 3:
            return False
        p = el
    return True

def damp_safe(arr):
    if safe(arr):
        return True
    if safe(arr[1:]):
        return True
    return damp_safe_inner(arr) or damp_safe_inner(arr[::-1])

def damp_safe_inner(arr):
    is_increasing = arr[-1] > arr[0]
    dampened = False
    p = arr[0]
    for el in arr[1:]:
        if (is_increasing and el <= p) or (not is_increasing and el >= p) or abs(el - p) > 3:
            if dampened:
                return False
            dampened = True
            continue
        p = el
    return True

def test():
    test_data = """
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
"""
    assert part1(parse_data(test_data)) == 2, "Should be 2"
    assert part2(parse_data(test_data)) == 4, "Should be 4"
    assert damp_safe([1,5,6,7,8]), "should be safe"
    assert damp_safe([93, 90, 92, 90, 89, 87, 84, 81]), "should be safe"
    assert damp_safe([14, 13, 11, 12, 8]), "should also be safe"
