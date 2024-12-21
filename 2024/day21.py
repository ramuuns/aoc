import functools

def run(data):
    data1 = parse_data(data)
    data2 = parse_data(data)
    return (part1(data1), part2(data2))

def parse_data(data):
    return data.splitlines()

def part1(data):
    total = 0
    for code in data:
        d1 = replace_numpad_code(code)
        total += count_rec(d1, 2) * int(code[:-1])
    return total

def part2(data):
    total = 0
    for code in data:
        d1 = replace_numpad_code(code)
        total += count_rec(d1, 25) * int(code[:-1])
    return total

@functools.cache
def count_rec(dpad_moves, depth):
    if depth == 1:
        src = 'A'
        total = 0
        for dst in dpad_moves:
            total += len(dpad(src, dst) if src != dst else 'A')
            src = dst
        return total
    total = 0
    src = 'A'
    for dst in dpad_moves:
        total += count_rec(dpad(src,dst) if src != dst else 'A', depth-1)
        src = dst
    return total

def replace_numpad_code(code):
    src = 'A'
    seq = []
    for dst in code:
        seq.append(numpad(src, dst) if src != dst else 'A')
        src = dst
    return "".join(seq)

def replace_dpad_code(code):
    src = 'A'
    seq = []
    for dst in code:
        seq.append(dpad(src, dst) if src != dst else 'A')
        src = dst
    return "".join(seq)

def dpad(src, dst):
    move_map = {
        'A': {
            '^': '<A',
            '<': 'v<<A',
            'v': '<vA',
            '>': 'vA'
        },
        '^': {
            'A': '>A',
            '<': 'v<A',
            'v': 'vA',
            '>': 'v>A'
        },
        '<': {
            'A': '>>^A',
            '^': '>^A',
            'v': '>A',
            '>': '>>A'
        },
        'v': {
            'A': '^>A',
            '^': '^A',
            '<': '<A',
            '>': '>A',
        },
        '>': {
            'A': '^A',
            '^': '<^A',
            '<': '<<A',
            'v': '<A'
        }
    }
    return move_map[src][dst]

def numpad(src, dst):
    move_map = {
        'A': {
            '0': '<A',
            '1': '^<<A',
            '2': '^<A',
            '3': '^A',
            '4': '^^<<A',
            '5': '<^^A',
            '6': '^^A',
            '7': '^^^<<A',
            '8': '<^^^A',
            '9': '^^^A',
        },
        '0': {
            'A': '>A',
            '1': '^<A',
            '2': '^A',
            '3': '>^A',
            '4': '^^<A',
            '5': '^^A',
            '6': '>^^A',
            '7': '^^^<A',
            '8': '^^^A',
            '9': '>^^^A',
        },
        '1': {
            'A': '>>vA',
            '0': '>vA',
            '2': '>A',
            '3': '>>A',
            '4': '^A',
            '5': '>^A',
            '6': '^>>A',
            '7': '^^A',
            '8': '^^>A',
            '9': '^^>>A',
        },
        '2': {
            'A': '>vA',
            '0': 'vA',
            '1': '<A',
            '3': '>A',
            '4': '^<A',
            '5': '^A',
            '6': '>^A',
            '7': '^^<A',
            '8': '^^A',
            '9': '>^^A',
        },
        '3': {
            'A': 'vA',
            '0': '<vA',
            '1': '<<A',
            '2': '<A',
            '4': '<<^A',
            '5': '<^A',
            '6': '^A',
            '7': '<<^^A',
            '8': '<^^A',
            '9': '^^A',
        },
        '4': {
            'A': '>>vvA',
            '0': '>vvA',
            '1': 'vA',
            '2': '>vA',
            '3': '>>vA',
            '5': '>A',
            '6': '>>A',
            '7': '^A',
            '8': '>^A',
            '9': '>>^A',
        },
        '5': {
            'A': 'vv>A',
            '0': 'vvA',
            '1': '<vA',
            '2': 'vA',
            '3': '>vA',
            '4': '<A',
            '6': '>A',
            '7': '<^A',
            '8': '^A',
            '9': '^>A',
        },
        '6': {
            'A': 'vvA',
            '0': '<vvA',
            '1': '<<vA',
            '2': '<vA',
            '3': 'vA',
            '4': '<<A',
            '5': '<A',
            '7': '<<^A',
            '8': '<^A',
            '9': '^A',
        },
        '7': {
            'A': '>>vvvA',
            '0': '>vvvA',
            '1': 'vvA',
            '2': 'vv>A',
            '3': 'vv>>A',
            '4': 'vA',
            '5': '>vA',
            '6': '>>vA',
            '8': '>A',
            '9': '>>A',
        },
        '8': {
            'A': 'vvv>A',
            '0': 'vvvA',
            '1': '<vvA',
            '2': 'vvA',
            '3': 'vv>A',
            '4': '<vA',
            '5': 'vA',
            '6': 'v>A',
            '7': '<A',
            '9': '>A',
        },
        '9': {
            'A': 'vvvA',
            '0': '<vvvA',
            '1': '<<vvA',
            '2': '<vvA',
            '3': 'vvA',
            '4': '<<vA',
            '5': '<vA',
            '6': 'vA',
            '7': '<<A',
            '8': '<A',
        }
    }
    return move_map[src][dst]

def test():
    test_data = """029A
980A
179A
456A
379A"""
    assert part1(parse_data(test_data)) == 126384, "Should be 126384"
