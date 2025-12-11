
def run(data):
    data1 = parse_data(data)
    data2 = parse_data(data)
    return (part1(data1), part2(data2))

def parse_data(data):
    graph = {}
    for line in data.split("\n"):
        node, children = line.split(": ")
        children = children.split(" ")
        graph[node] = children
    return graph

def part1(data):
    start = "you"
    end = "out"
    path_sum = sum_paths(start, end, data, {})
    return path_sum

def sum_paths(start, end, graph, paths):
    if start == end:
        return 1
    if start not in graph:
        return 0
    if start in paths:
        return paths[start]
    num_paths = 0
    for node in graph[start]:
        num_paths += sum_paths(node, end, graph, paths)
    paths[start] = num_paths
    return num_paths

def part2(data):
    start = "svr"
    end = "out"
    path_sum = sum_paths("dac", "out", data, {})
    path_sum *= sum_paths("fft", "dac", data, {})
    path_sum *= sum_paths("svr", "fft", data, {})
    print(path_sum)
    return path_sum


def test():
    test_data = """aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out"""
    test_data2 = """svr: aaa bbb
aaa: fft
fft: ccc
bbb: tty
tty: ccc
ccc: ddd eee
ddd: hub
hub: fff
eee: dac
dac: fff
fff: ggg hhh
ggg: out
hhh: out"""
    assert part1(parse_data(test_data)) == 5, "Should be 11"
    assert part2(parse_data(test_data2)) == 2, "Should be 31"
