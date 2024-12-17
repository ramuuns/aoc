
def run(data):
    data1 = parse_data(data)
    data2 = parse_data(data)
    return (part1(data1), part2(data2))

def parse_data(data):
    regs, prog = data.split("\n\n")
    program = list(map(int, prog.split(": ")[1].split(",")))
    registers = [ int(reg.split(": ")[1]) for reg in regs.splitlines() ]
    return registers, program

def part1(data):
    registers, program = data
    output = run_program(0, registers, program)
    return ",".join(map(str,output))

def run_program(ip, reg, program):
    output = []
    ip_max = len(program)
    while ip >= 0 and ip < ip_max:
        match program[ip]:
            case 0:
                # adv
                reg[0] = reg[0] >> combo(ip+1, program, reg)
            case 1:
                # bxl
                reg[1] = reg[1] ^ program[ip+1]
            case 2:
                # bst
                reg[1] = combo(ip+1, program, reg) & 0b111
            case 3:
                # jnz
                if reg[0] != 0:
                    ip = program[ip+1]
                    continue
            case 4:
                # bxc
                reg[1] = reg[1] ^ reg[2]
            case 5:
                # out
                output.append(combo(ip+1, program, reg) & 0b111)
            case 6:
                reg[1] = reg[0] >> combo(ip+1, program, reg)
            case 7:
                reg[2] = reg[0] >> combo(ip+1, program, reg)
            case _:
                raise "Invalid program - contains value > 7"
        ip += 2
    return output

def combo(ptr, program, registers):
    if program[ptr] < 4:
        return program[ptr]
    if program[ptr] >= 7:
        raise "invalid program - combo operand >= 7"
    return registers[program[ptr] & 0b11]


def find_bits2(tgt, tgt_len, k):
    options = []
    for i in range(0,8):
        output = run_program(0, [(k << 3) + i,0,0], tgt)
        if len(output) == tgt_len and tgt[-tgt_len:] == output:
            if tgt_len == len(tgt):
                return [(k << 3) + i]
            for option in find_bits2(tgt, tgt_len + 1, (k << 3) + i):
                options.append(option)
    return options

def part2(data):
    _, program = data
    return min(find_bits2(program, 1, 0))

def test():
    test_data = """Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0"""

    test_data_2 = """Register A: 2024
Register B: 0
Register C: 0

Program: 0,3,5,4,3,0"""

    assert parse_data(test_data) == ([729,0,0],[0,1,5,4,3,0])
    assert part1(parse_data(test_data)) == "4,6,3,5,6,3,5,2,1,0", "Should be 4,6,3,5,6,3,5,2,1,0"
    assert part2(parse_data(test_data_2)) == 117440, "Should be 117440"
