
def run(data):
    data = parse_data(data)
    return (part1(data), part2(data))

def parse_data(data):
    return [list(map(int, row.split())) for row in data.strip().split("\n")]

def part1(data):
    safe_count = 0
    for row in data:
        if safe(row):
            safe_count = safe_count + 1
    return safe_count

def part2(data):
    safe_count = 0
    for row in data:
        if damp_safe(row):
            safe_count = safe_count + 1
    return safe_count

def safe(arr):
    is_increasing = arr[-1] > arr[0]
    unsafe = False
    p = arr[0]
    for el in arr[1:]:
        if (is_increasing and el <= p) or (not is_increasing and el >= p) or abs(el - p) > 3:
            unsafe = True
            break
        p = el
    return not unsafe

def damp_safe(arr):
    if safe(arr):
        return True
    for idx, _el in enumerate(arr):
        if safe(arr[0:idx] + arr[idx+1:]):
            return True
    return False

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
