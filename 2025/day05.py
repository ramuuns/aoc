
def run(data):
    data1 = parse_data(data)
    data2 = parse_data(data)
    return (part1(data1), part2(data2))

def mk_range(range_str):
    ab = [int(n) for n in range_str.split("-")]
    return (ab[0], ab[1])

def parse_data(data):
    (ranges_str, items_str) = data.split("\n\n")
    return ([ mk_range(range_str) for range_str in ranges_str.split("\n") ] ,[int(n) for n in items_str.split("\n")])

def sortfunc(r):
    (a,b) = r
    return a

def merge_and_sort_ranges(ranges):
    ranges.sort(reverse=False, key=sortfunc)
    merged_ranges = []
    for (a,b) in ranges:
        if len(merged_ranges) > 0:
            (c,d) = merged_ranges[-1]
            if a > d:
                merged_ranges.append((a,b))
            else:
                merged_ranges[-1] = (c, max(b,d))
        else:
            merged_ranges = [(a,b)]
    return merged_ranges

def in_range(n, ranges):
    for (a,b) in ranges:
        if n < a:
            return False
        if n <= b:
            return True
    return False

def part1(data):
    (ranges, items) = data
    merged_and_sorted_ranges = merge_and_sort_ranges(ranges)
    return sum([in_range(item, merged_and_sorted_ranges) for item in items])

def part2(data):
    (ranges, items) = data
    merged_and_sorted_ranges = merge_and_sort_ranges(ranges)
    return sum([b-a+1 for a,b in merged_and_sorted_ranges])


def test():
    test_data = """3-5
10-14
16-20
12-18

1
5
8
11
17
32"""
    assert part1(parse_data(test_data)) == 3, "Should be 11"
    assert part2(parse_data(test_data)) == 14, "Should be 31"
