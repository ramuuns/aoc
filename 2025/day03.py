
def run(data):
    data1 = parse_data(data)
    data2 = parse_data(data)
    return (part1(data1), part2(data2))

def parse_data(data):
    return [list(row) for row in  data.split("\n")]

def part1(data):
    return sum([max_joltage(battery) for battery in data ])

def part2(data):
    return sum([max_joltage_12(battery) for battery in data])

def max_joltage(row):
    num_row = [int(d) for d in row]
    tens = 0
    singles = 0
    max_idx_tens = len(num_row) - 1
    for idx, n in enumerate(num_row):
        if n > tens and idx != max_idx_tens:
            tens = n
            singles = 0
        elif n > singles:
            singles = n
        if tens == 9 and singles == 9:
            break
    return tens*10 + singles

def max_joltage_12(row):
    num_row = [int(d) for d in row]
    max_digits = [0,0,0,0,0,0,0,0,0,0,0,0]
    max_indexes = [11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
    max_l = len(row)
    s = 0
    for idx, n in enumerate(num_row):
        if n == 9 and idx < max_l - max_indexes[0]:
            s = s*10 + 9
            max_digits = [0] * (len(max_digits) - 1)
            max_indexes = max_indexes[1:]
            if len(max_indexes) == 0:
                break
            continue

        for k, d in enumerate(max_digits):
            if n > d and idx < max_l - max_indexes[k]:
                max_digits[k] = n
                max_digits[k+1:] = [0] * (len(max_digits) - k - 1)
                break
    for d in max_digits:
        s = s*10 + d
    return s

def test():
    test_data = """987654321111111
811111111111119
234234234234278
818181911112111"""
    assert part1(parse_data(test_data)) == 357, "Should be 357"
    assert part2(parse_data(test_data)) == 3121910778619, "Should be 3121910778619"
