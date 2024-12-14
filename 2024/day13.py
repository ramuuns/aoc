import re
import math
from functools import reduce

def run(data):
    data1 = parse_data(data)
    data2 = parse_data(data)
    return (part1(data1), part2(data2))

def parse_data(data):
    return list(map(make_machine, data.split("\n\n")))

def make_machine(data):
    abtn_line, bbtn_line, prize_line = data.splitlines()
    ax, ay = list(map(int, re.findall(r"\d+", abtn_line)))
    bx, by = list(map(int, re.findall(r"\d+", bbtn_line)))
    px, py = list(map(int, re.findall(r"\d+", prize_line)))
    return ((ax,ay),(bx,by),(px,py))

def part1(data):
    mintokens = 0
    for machine in data:
        mt = actual_solution(machine, 100)
        bf = bruteforce(machine)
        assert mt == bf, f"Oh hai {machine}, \n {mt} != {bf}"
        mintokens += mt 

    return mintokens

def gcd_ext(a,b):
    if a == 0:
        return b, 0, 1
    gcd, x1, y1 = gcd_ext(b%a, a)
    x = y1 - (b//a)*x1
    y = x1
    return gcd,x,y

def shift_solution(x, y, a, b, sign):
    return x + b * sign, y - a * sign

def mttw__(machine,limit):
    (ax,ay),(bx,by),(px,py)  = machine
    if limit == 0:
        px += 10000000000000
        py += 10000000000000
    #    limit = min(px//ax, py//ay, px//bx, py//by)
        print(f"limit: {limit}")
    
    gcd, u, v = gcd_ext(ax+ay, bx+by)
    if (px+py) % gcd != 0:
        return 0

    a = u * (px+py) // gcd
    b = v * (px+py) // gcd

    qa = (ax+ay) // gcd
    qb = (bx+by) // gcd

    a,b = shift_solution(a, b, qa, qb, -a // qb)
    if a < 0:
        a,b = shift_solution(a, b, qa, qb, 1)

    if limit:
        while b > limit:
            a,b = shift_solution(a, b, qa, qb, 1)
            if a > limit or a < 0 or b < 0:
                return 0

    print("find min that works for both")
    while a*ax + b*bx != px and b*ay+ b*by != py:
        a,b = shift_solution(a, b, qa, qb, 1)
        if a < 0 or b < 0 or (limit and (a > limit or b > limit)):
            return 0
        print(f"{a}, {b} {qa} {qb}")

    print("and now we seaarch")

    min_v = 3*a + b
    pa, pb = a,b
    while True:
        pa, pb = a,b
        a,b = shift_solution(a, b, qa, qb, 1)
        while a*ax + b*bx != px and b*ay+ b*by != py:
            a,b = shift_solution(a, b, qa, qb, 1)
            if a < 0 or b < 0:
                break
            if limit and (a > limit or b > limit):
                break
        if 3*a + b > min_v:
            break
        if a < 0 or b < 0:
            break
        if limit and (a > limit or b > limit):
            break
        min_v = 3*a + b
        print(f"{a}, {b}, {min_v}")

    print(f"{pa, pb}")
    return min_v

def gimme_eq(a,b,c,limit):
    gcd, x, y = gcd_ext(abs(a),abs(b))
    
    if c % gcd:
        return 0

    x *= c // gcd
    y *= c // gcd

    if a < 0:
        x *= -1
    if b < 0:
        y *= -1

    qa = a // gcd
    qb = b // gcd

    sign_b = 1 if b > 0 else -1

    x,y = shift_solution(x,y,qa,qb, -x // qb)
    if x < 0:
        x,y = shift_solution(x,y,qa,qb, sign_b)

    if limit:
        while y > limit:
            x,y = shift_solution(x,y,qa,qb, sign_b)
            if x < 0 or y < 0 or x > limit:
                return 0
    print(f"{( x,y,qa,qb,gcd)}")
    return x,y,qa,qb,gcd

def crt(m ,a):
    s = 0
    prod = reduce(lambda acc, b: acc*b, m)
    for m_i, a_i in zip(m, a):
        p = prod // m_i
        s += a_i * mult_inv(p, m_i) * p
    return s % prod

def mult_inv(a,b):
    b0 = b
    x0, x1 = 0, 1
    if b == 1: return 1
    while a > 1:
        q = a // b
        a,b = b, a%b
        x0, x1 = x1 - q * x0, x0
    if x1 < 0: x1+= b0
    return x1

def actual_solution(machine, limit):
    (ax,ay),(bx,by),(px,py)  = machine
    if limit == 0:
        px += 10000000000000
        py += 10000000000000

    det = ax * by - ay * bx
    if abs(det) == 0:
        raise ValueError(f" det=0")

    u, v = (by * px - bx * py) // det, (-ay * px + ax * py) // det
    if ax * u + bx * v == px and ay * u + by * v == py:
        return 3 * u + v
    return 0

def mttw(machine, limit):
    (ax,ay),(bx,by),(px,py)  = machine
    if limit == 0:
        px += 10000000000000
        py += 10000000000000
        print(f"limit: {limit}")

   
    print(f"starting machine: {machine}")
    x_eq = gimme_eq(ax, bx, px, limit)
    y_eq = gimme_eq(ay, by, py, limit)

    match (x_eq, y_eq):
        case (0, _):
            print("xeq is zero")
            return 0
        case (_, 0):
            print("yeq is zero")
            return 0
        case _:
            a1, b1, qa1, qb1, gcd1 = x_eq
            a2, b2, qa2, qb2, gcd2 = y_eq

            a_mod = crt([qb1, qb2],[a1, a2])
            b_mod = crt([qa1, qa2],[b1, b2])

            print(f"moduli: {a_mod} {b_mod}")
            a = a1+a_mod*qb1
            b = b1+b_mod*qb2
            print(f"{a} {b}")

            return a*3 + b

def min_tokens_to_win(machine):
    (ax,ay),(bx,by),(px,py)  = machine
    cand_a_list = []
    for i in range(0,100):
        if (px - i*ax) % bx == 0 and (py - i*ay) % by == 0:
            if i == 0 and (px - i*ax) // bx > 100:
                continue
            cand_a_list.append(i)

#    print(f"cand_a: {cand_a_list}")
    if len(cand_a_list) == 0:
        return 0

    min_t = 400
    found = False
    for cand_a in cand_a_list:
        k = 1
        while cand_a * k < 100:
            a = cand_a * k
            b = (px - ax * a) // bx
            if b < 100 and  ax * a + bx * b == px and ay * a + by * b == py:
                found = True
                min_t = min(min_t, a*3 + b)
#                print(f"min_t: {min_t}, a: {a}, b: {b}")
            k+=1
    if found:
        return min_t
    return 0

def bruteforce(machine):
    (ax,ay),(bx,by),(px,py)  = machine

    min_t = 400
    found = False
    for a in range(0,100):
        for b in range(0,100):
            if a*ax + b*bx == px and a*ay + b*by == py:
                found = True
                min_t = min(min_t, a*3 + b)
                print(f"bf: min_t: {min_t}, a: {a}, b: {b}")
    if found:
        return min_t
    return 0

def _part2(d):
    return 0

def part2(data):
    mintokens = 0
    for machine in data:
        mt = actual_solution(machine, 0)
        mintokens += mt

    return mintokens


def test():
    test_data = """Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279"""
    assert bruteforce(((28, 63), (33, 14), (3782, 6461))) == 319, "should win here"
    assert actual_solution(((28, 63), (33, 14), (3782, 6461)),100) == 319, "should win here"
    assert min_tokens_to_win(((28, 63), (33, 14), (3782, 6461))) == 319, "should win here"
    assert min_tokens_to_win(((35, 12), (17, 52), (9516, 13408))) == 0, "not four hundred"
    assert min_tokens_to_win(((29, 13), (52, 76), (7167, 1431))) == 0, "not 321"
    assert part1(parse_data(test_data)) == 480, "Should be 480"
    #assert part2(parse_data(test_data)) == 0, "Should be 31"
