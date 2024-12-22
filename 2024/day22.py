from collections import defaultdict

def run(data):
    data1 = parse_data(data)
    data2 = parse_data(data)
    return (part1(data1), part2(data2))

def parse_data(data):
    return list(map(int,data.splitlines()))

def part1(data):
    return sum([randomize(number, 2000) for number in data])

def part2(data):
    all_sequences = defaultdict(int)
    max_num = 0
    for monkey, number in enumerate(data):
        max_num = gen_sequences(number, 2000, all_sequences, max_num)
    return max_num

MAX_MASK = 16777216 - 1

def randomize(number, times):
    while times > 0:
        times -= 1
        number = (number ^ (number <<  6)) & MAX_MASK
        number = (number ^ (number >>  5)) & MAX_MASK
        number = (number ^ (number << 11)) & MAX_MASK
    return number

def gen_sequences(number, times, all_sequences, max_num):
    s1, s2, s3, s4 = (0, 0, 0, 0)
    seen = set()
    i = 0
    while times > 0:
        i+=1
        times -= 1
        before = number % 10
        number = (number ^ (number <<  6)) & MAX_MASK
        number = (number ^ (number >>  5)) & MAX_MASK
        number = (number ^ (number << 11)) & MAX_MASK
        s4 = s3
        s3 = s2
        s2 = s1
        s1 = (number  % 10) - before
        if i > 3:
            if (s4, s3, s2, s1) not in seen:
                all_sequences[(s4, s3, s2, s1)] += number % 10
                if all_sequences[(s4, s3, s2, s1)] > max_num:
                    max_num = all_sequences[(s4, s3, s2, s1)]
                seen.add((s4,s3,s2,s1))
    return max_num

def test():
    test_data = """1
10
100
2024"""

    test_data_2 = """1
2
3
2024"""

    #print(gen_sequences(123, 10, set()))
    #assert 0 == 1, "stop"
    assert randomize(123,1) == 15887950, "one time"
    assert randomize(123,2) == 16495136, "two time"
    assert randomize(123,3) == 527345, "three time"
    assert part1(parse_data(test_data)) == 37327623, "Should be 37327623"
    assert part2(parse_data(test_data_2)) == 23, "Should be 23"
