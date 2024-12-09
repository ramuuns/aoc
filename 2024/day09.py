
def run(data):
    data = parse_data(data)
    return (part1(data.copy()), part2(data.copy()))

def parse_data(data):
    return list(map(int,list(data)))

def part1(data):
    block_id = 0
    checksum = []
    endptr = len(data) - 1
    if endptr % 2 == 1:
        endptr -= 1
    for idx, size in enumerate(data):
        if idx > endptr:
            break
        if idx % 2 == 0:
            # file
            for _ in range(0, size):
                checksum.append( block_id * (idx // 2) )
                block_id += 1
        else:
            while size >= data[endptr]:
                for _ in range(0, data[endptr]): 
                    checksum.append( block_id * (endptr // 2))
                    block_id += 1
                size -= data[endptr]
                endptr -= 2
            for _ in range(0, size):
                checksum.append( block_id * (endptr //2))
                data[endptr] -= 1
                block_id += 1
    return sum(checksum)

def part2(data):
    block_id = 0
    orig_idx_to_block_id = {}
    for idx, size in enumerate(data):
        orig_idx_to_block_id[idx] = block_id
        block_id += size

    checksum = []
    endptr = len(data) - 1
    if endptr % 2 == 1:
        endptr -= 1
    while endptr > 0:
        size = data[endptr]
        idx = 1
        while idx < endptr and size > data[idx]:
            idx += 2
        if idx > endptr:
            block_id = orig_idx_to_block_id[endptr]
            for _ in range(0, size):
                checksum.append( block_id * (endptr // 2))
                block_id += 1
            endptr -= 2
            continue
        block_id = orig_idx_to_block_id[idx]
        for _ in range(0, size):
            checksum.append( block_id * (endptr // 2))
            block_id += 1
        orig_idx_to_block_id[idx] += size
        data[idx] -= size
        endptr -= 2
    return sum(checksum)


def test():
    test_data = """2333133121414131402"""
    assert part1(parse_data(test_data)) == 1928, "Should be 1928"
    assert part2(parse_data(test_data)) == 2858, "Should be 2858"
