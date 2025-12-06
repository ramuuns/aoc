import re

def run(data):
    data1 = parse_data(data)
    data2 = parse_data(data)
    return (part1(data1), part2(data2))

def parse_data(data):
    return data

def parse_data1(data):
    rows = data.split("\n")
    ops = rows[-1]
    rows = rows[:-1]
    return ([list(map(int, re.split("\\s+", row.strip()))) for row in rows], re.split("\\s+", ops.strip()))

def parse_data2(data):
    rows = data.split("\n")
    ops = rows[-1]
    rows = rows[:-1]
    return (magic_numbers(rows, ops), re.split("\\s+", ops.strip()))

def i_to_number_index(i, lengths):
    (number, digit) = (0, 0)
    while i > 0:
        l = lengths[number]
        if i < l:
            digit = i
            break
        i -= l + 1
        number += 1
    return (number, digit)

def magic_numbers(rows, ops):
    spaces = re.split("\\S", ops)[1:]
    lengths = [ len(space) for space in spaces ]
    lengths[-1] += 1
    numbers = []
    for length in lengths:
        numbers.append([0]*length)
    for row in rows:
        for i, n in enumerate(list(row)):
            if n != ' ':
                k, j = i_to_number_index(i, lengths)
                numbers[k][j] = numbers[k][j]*10 + int(n)
    return numbers

def perform_op(op, i, numbers):
    s = 1 if op == "*" else 0
    for nums in numbers:
        if op == "+":
            s += nums[i]
        else:
            s *= nums[i]
    return s

def perform_op2(op, i, numbers):
    s = 1 if op == "*" else 0
    for num in numbers[i]:
        if op == "+":
            s += num
        else:
            s *= num
    return s


def part1(data):
    data = parse_data1(data)
    numbers, ops = data
    return sum([ perform_op(op, i, numbers) for i, op in enumerate(ops)])

def part2(data):
    data = parse_data2(data)
    numbers, ops = data
    return sum([ perform_op2(op, i, numbers) for i, op in enumerate(ops)])


def test():
    test_data = """123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   +  """
    assert part1(parse_data(test_data)) == 4277556, "Should be 11"
    assert part2(parse_data(test_data)) == 3263827, "Should be 31"
