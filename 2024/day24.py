
def run(data):
    data1 = parse_data(data)
    data2 = parse_data(data)
    return (part1(data1), part2(data2))

def makerulefun(key, a, b, op):
    return lambda k, r, v: rulefun(k, a, b, op, r, v)

def rulefun(key, a, b, op, rules, values):
    opmap = {"AND": "&", "OR": "|", "XOR": "^"}
    if key in values:
        return values[key]
    values[key] = eval(f"rules[a](a, rules, values) {opmap[op]} rules[b](b, rules, values)")
    return values[key]

def parse_data(data):
    s_values, s_rules = data.split("\n\n")
    values = {}
    rules = {}
    for s_value in s_values.splitlines():
        key, value = s_value.split(": ")
        values[key] = int(value)
    for s_rule in s_rules.splitlines():
        expr, key = s_rule.split(" -> ")
        a, op, b = expr.split(" ")
        rules[key] = (a, op, b)
    return values, rules

def part1(data):
    values, rules = data
    z = 0
    rulefuncs = {}
    for key in values.keys():
        rulefuncs[key] = lambda k, r, v: v[k]
    for key, (a, op, b) in rules.items():
        rulefuncs[key] = makerulefun(key, a, b, op)
    for key in rules.keys():
        if key[0] == "z":
            bit = rulefuncs[key](key, rulefuncs, values)
            z |= bit << int(key[1:])
    return z

def expand_print(rules, key):
    if key not in rules:
        return key
    else:
        (a, op, b) = rules[key]
        return f"{key} => ({expand_print(rules,a)} {op} {expand_print(rules, b)})"

def validate_and_swap(key, rules, swapped, xors, carries, ands):
    if key ==  "z45":
        return
    xvar = f"x{key[1:]}"
    yvar = f"y{key[1:]}"
    kk = int(key[1:])
    for k, (ar, opr, br) in rules.items():
        if k != key and opr == "XOR" and ((ar == xvar and br == yvar) or (br == xvar or ar == yvar)):
            xors[kk] = k
        if opr == "AND" and ((ar == xvar and br == yvar) or (br == xvar or ar == yvar)):
            ands[kk] = k
    if key == "z00":
        return
    and_prev = ands[kk-1] if kk - 1 in ands else None
    xor_prev = xors[kk-1] if kk - 1 in xors else None
    carry_prev = carries[kk-1] if kk - 1 in carries else None
    xor_and_prev_carry = None
    if carry_prev is not None and xor_prev is not None:
        for k, (ar, opr, br) in rules.items():
            if opr == "AND" and ((ar == carry_prev and br == xor_prev) or (ar == xor_prev and br == carry_prev)):
                xor_and_prev_carry = k
                break
    elif xor_prev is not None:
        xor_and_prev_carry = xor_prev
    if xor_and_prev_carry is not None:
        for k, (ar, opr, br) in rules.items():
            if opr == "OR" and ((ar == and_prev and br == xor_and_prev_carry) or (ar == xor_and_prev_carry and br == and_prev)):
                carries[kk] = k
                break
    else:
        carries[kk] = and_prev

    a, op, b = rules[key]
    if op == "XOR" and ((a == xors[kk] and b == carries[kk]) or (a == carries[kk] and b == xors[kk] )):
        # all good
        return
    elif op == "XOR":
        if a == xors[kk] and b != carries[kk]:
            s_rule = rules[b]
            rules[b] = rules[carries[kk]]
            rules[carries[kk]] = s_rule
            swapped.add(b)
            swapped.add(carries[kk])
        elif a == carries[kk] and b != xors[kk]:
            s_rule = rules[b]
            rules[b] = rules[xors[kk]]
            rules[xors[kk]] = s_rule
            swapped.add(b)
            swapped.add(xors[kk])
        print(swapped)
    else:
        # need to find the correct xor rule and add it and this to swap
        s_to = None
        for k, (ar, opr, br) in rules.items():
            if opr == "XOR" and ((ar == xors[kk] and br == carries[kk]) or (ar == carries[kk] and br == xors[kk] )):
                swapped.add(k)
                s_to = k
                break
        if s_to is None:
            return
        swapped.add(key)
        s_rule = rules[key]
        rules[key] = rules[s_to]
        rules[s_to] = s_rule
        for k in xors.keys():
            if xors[k] == key:
                xors[k] = s_to
            elif xors[k] == s_to:
                xors[k] = key
        for k in carries.keys():
            if carries[k] == key:
                carries[k] = s_to
            elif carries[k] == s_to:
                carries[k] = key
        for k in ands.keys():
            if ands[k] == key:
                ands[k] = s_to
            elif ands[k] == s_to:
                ands[k] = key

def part2(data):
    values, rules = data
    zeds = sorted([key for key in rules.keys() if key[0] == "z" ])
    swapped = set()
    xors = {}
    ands = {}
    carries = {}
    for zed in zeds:
        validate_and_swap(zed, rules, swapped, xors, carries, ands)
        if len(swapped) == 8:
            break
    return ",".join(sorted(swapped))



def test():
    test_data = """x00: 1
x01: 1
x02: 1
y00: 0
y01: 1
y02: 0

x00 AND y00 -> z00
x01 XOR y01 -> z01
x02 OR y02 -> z02"""

    test_data_1 = """x00: 1
x01: 0
x02: 1
x03: 1
x04: 0
y00: 1
y01: 1
y02: 1
y03: 1
y04: 1

ntg XOR fgs -> mjb
y02 OR x01 -> tnw
kwq OR kpj -> z05
x00 OR x03 -> fst
tgd XOR rvg -> z01
vdt OR tnw -> bfw
bfw AND frj -> z10
ffh OR nrd -> bqk
y00 AND y03 -> djm
y03 OR y00 -> psh
bqk OR frj -> z08
tnw OR fst -> frj
gnj AND tgd -> z11
bfw XOR mjb -> z00
x03 OR x00 -> vdt
gnj AND wpb -> z02
x04 AND y00 -> kjc
djm OR pbm -> qhw
nrd AND vdt -> hwm
kjc AND fst -> rvg
y04 OR y02 -> fgs
y01 AND x02 -> pbm
ntg OR kjc -> kwq
psh XOR fgs -> tgd
qhw XOR tgd -> z09
pbm OR djm -> kpj
x03 XOR y03 -> ffh
x00 XOR y04 -> ntg
bfw OR bqk -> z06
nrd XOR fgs -> wpb
frj XOR qhw -> z04
bqk OR frj -> z07
y03 OR x01 -> nrd
hwm AND bqk -> z03
tgd XOR rvg -> z12
tnw OR pbm -> gnj"""
    assert part1(parse_data(test_data)) == 4, "Should be 4"
    assert part1(parse_data(test_data_1)) == 2024, "Should be 2024"
    assert part2(parse_data(test_data)) == 0, "Should be 31"
