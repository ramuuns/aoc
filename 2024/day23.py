from collections import defaultdict

def run(data):
    data1 = parse_data(data)
    data2 = parse_data(data)
    return (part1(data1), part2(data2))

def parse_data(data):
    graph = {}
    for conn in data.splitlines():
        a,b = conn.split('-')
        if a not in graph:
            graph[a] = set()
        if b not in graph:
            graph[b] = set()
        graph[a].add(b)
        graph[b].add(a)
    return graph

def part1(data):
    res = set()
    for a, conns in data.items():
        for c in conns:
            for b in data[c]:
                if b in conns and 't' in f"{a[0]}{b[0]}{c[0]}":
                    res.add(tuple(sorted([a,b,c])))
                    
    return len(res)


def bors_kerbosch_v2(R, P, X, G, C):

    if len(P) == 0 and len(X) == 0:
        if len(R) > 2:
            C.append(sorted(R))            
        return

    (d, pivot) = max([(len(G[v]), v) for v in P.union(X)])
                     
    for v in P.difference(G[pivot]):
        bors_kerbosch_v2(R.union(set([v])), P.intersection(G[v]), X.intersection(G[v]), G, C)
        P.remove(v)
        X.add(v)

def part2(data):
    output = []
    bors_kerbosch_v2(set(), set(data.keys()), set(), data, output)
    the_biggest = []
    for o in output:
        if len(o) > len(the_biggest):
            the_biggest = o

    return ",".join(the_biggest)


def test():
    test_data = """kh-tc
qp-kh
de-cg
ka-co
yn-aq
qp-ub
cg-tb
vc-aq
tb-ka
wh-tc
yn-cg
kh-ub
ta-co
de-co
tc-td
tb-wq
wh-td
ta-ka
td-qp
aq-cg
wq-ub
ub-vc
de-ta
wq-aq
wq-vc
wh-yn
ka-de
kh-ta
co-tc
wh-qp
tb-vc
td-yn"""
    assert part1(parse_data(test_data)) == 7, "Should be 7"
    assert part2(parse_data(test_data)) == 'co,de,ka,ta', "Should be co,de,ka,ta"
