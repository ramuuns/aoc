
def run(data):
    data1 = parse_data(data)
    data2 = parse_data(data)
    return (part1(data1), part2(data2))

def parse_data(data):
    return [ tuple(map(int, line.split(","))) for line in data.split("\n") ]

def sortfunc(p):
    a,b,d = p
    return d

def distance(a,b):
    x1,y1,z1 = a
    x2,y2,z2 = b
    return (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) + (z2-z1)*(z2-z1)

def part1(data, max_conn=1000):
    pairs = []
    for i, a in enumerate(data):
        for b in data[i+1:]:
            pairs.append((a,b, distance(a,b)))
    pairs.sort(reverse=False, key=sortfunc)
    circuits = {}
    for a,b,d in pairs[:max_conn]:
        circuit = set([a,b])
        if a in circuits and b in circuits:
            circuita = circuits[a]
            circuitb = circuits[b]
            if circuita == circuitb:
                continue
            circuit = circuita.union(circuitb)
        elif a in circuits:
            circuit = circuits[a]
            circuit.add(b)
        elif b in circuits:
            circuit = circuits[b]
            circuit.add(a)
        for item in circuit:
            circuits[item] = circuit
    unique_circuits = set([])
    for circuit in circuits.values():
        unique_circuits.add(frozenset(circuit))
    uc_list = list(unique_circuits)
    uc_list.sort(reverse=True, key=len)
    return len(uc_list[0]) * len(uc_list[1]) * len(uc_list[2])

def part2(data):
    max_size = len(data)
    pairs = []
    for i, a in enumerate(data):
        for b in data[i+1:]:
            pairs.append((a,b, distance(a,b)))
    pairs.sort(reverse=False, key=sortfunc)
    circuits = {}
    magic_num = 0
    for a,b,d in pairs:
        circuit = set([a,b])
        if a in circuits and b in circuits:
            circuita = circuits[a]
            circuitb = circuits[b]
            if circuita == circuitb:
                continue
            circuit = circuita.union(circuitb)
        elif a in circuits:
            circuit = circuits[a]
            circuit.add(b)
        elif b in circuits:
            circuit = circuits[b]
            circuit.add(a)
        if len(circuit) == max_size:
            x1,y1,z1 = a
            x2,y2,z2 = b
            magic_num = x1*x2
            break
        for item in circuit:
            circuits[item] = circuit

    return magic_num


def test():
    test_data = """162,817,812
57,618,57
906,360,560
592,479,940
352,342,300
466,668,158
542,29,236
431,825,988
739,650,466
52,470,668
216,146,977
819,987,18
117,168,530
805,96,715
346,949,466
970,615,88
941,993,340
862,61,35
984,92,344
425,690,689"""
    assert part1(parse_data(test_data), 10) == 40, "Should be 11"
    assert part2(parse_data(test_data)) == 25272, "Should be 31"
