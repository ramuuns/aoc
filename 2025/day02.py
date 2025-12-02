
def run(data):
    data1 = parse_data(data)
    data2 = parse_data(data)
    return (part1(data1), part2(data2))

def parse_data(data):
    return [ r.split('-') for r in data.split(',') ]

def part1(data):
    return sum([ sum(double_num(r[0], r[1])) for r in data ])

def part2(data):
    return sum([ sum(repeat_num(r[0], r[1])) for r in data])

def double_num(start,end):
    s_int = int(start)
    e_int = int(end)
    s_len = len(start)
    e_len = len(end)
    ret = []
    if (s_len % 2 == 0):
        top = int(start[:s_len//2])
        exp = s_len//2
        while top * (10 ** exp) + top <= e_int:
            if top * (10 ** exp) + top >= s_int:
                ret.append(top * (10 ** exp) + top)
            top += 1
            if top >= 10**exp:
                break
    elif e_len % 2 == 0:
        exp = e_len//2
        top = 10 ** (exp - 1)
        while top * (10 ** exp) + top <= e_int:
            if top * (10 ** exp) + top >= s_int:
                ret.append(top * (10 ** exp) + top)
            top += 1
    return [x for x in ret if x >= s_int and x <= e_int]

def make_num(num, exp, size):
    size -= exp
    ret = num
    while size > 0:
        ret = ret * (10 ** exp) + num
        size -= exp
    return ret

def select_top(num, e, s_len, e_len, the_length):
    if s_len % e == 0 and the_length == s_len:
        return int(num[:e])
    else:
        return 10 ** (e-1)

def select_lengths(e, s_len, e_len):
    if s_len % e == 0 and e_len % e == 0:
        return [x for x in set([ s_len, e_len ])]
    elif s_len % e == 0:
        return [ s_len ]
    else:
        return [ e_len ]

def repeat_num(start, end):
    s_int = int(start)
    e_int = int(end)
    s_len = len(start)
    e_len = len(end)
    ret = []
    exponents = [e+1 for e in range(0, e_len//2) if s_len % (e+1) == 0 or e_len % (e+1) == 0]
    #print((start, end, exponents))
    for e in exponents:
        for the_length in select_lengths(e, s_len, e_len):
            top = select_top(start, e, s_len, e_len, the_length)
            #print((top, e, the_length))
            while True:
                n = make_num(top, e, the_length)
                #print(n)
                if n > e_int:
                    break
                if n >= s_int and n > 10:
                    ret.append(n)
                top += 1
                if top >= 10**e:
                    break
    #print(sorted (set(ret)))
    return set(ret)


def test():
    test_data = """11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"""
    assert part1(parse_data(test_data)) == 1227775554, "Should be 1227775554"
    assert part2(parse_data("11-22")) == 33, "should be 33"
    assert part2(parse_data("95-115")) == 210, "should be 210"
    assert part2(parse_data("998-1012")) == 2009, "should be 2009"
    assert part2(parse_data("1188511880-1188511890")) == 1188511885, "should be 1188511885"
    assert part2(parse_data(test_data)) == 4174379265, "Should be 4174379265"
