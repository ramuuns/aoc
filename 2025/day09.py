
def run(data):
    data1 = parse_data(data)
    data2 = parse_data(data)
    return (part1(data1), part2(data2))

def parse_data(data):
    return [tuple(map(int, row.split(","))) for row in data.split("\n")]

def part1(data):
    max_area = 0
    for i, a in enumerate(data):
        for b in data[:i+1]:
            x1,y1 = a
            x2,y2 = b
            max_area = max(max_area, (abs(x2-x1)+1)*(abs(y2-y1+1)))
        
    return max_area

def intersects_badly(edge, p1, p2, debug=False):
    ep1, ep2 = edge
    px1, py1 = p1
    px2, py2 = p2
    epx1, epy1 = ep1
    epx2, epy2 = ep2

    is_inside_x = lambda x : x >= min(px1, px2) and x <= max(px1,px2)
    is_inside_y = lambda y : y >= min(py1, py2) and y <= max(py1,py2)

    if (( epx1 < min(px1, px2) or epx1 > max(px1, px2 ) or epy1 < min(py1, py2) or epy1 > max(py1, py2) ) and
       ( epx2 < min(px1, px2) or epx2 > max(px1, px2 ) or epy2 < min(py1, py2) or epy2 > max(py1, py2) )):
        if epx1 == epx2 and abs(epy2-epy1) > abs(py2 - py1):
            if min(px1,px2) < epx1 and max(px1,px2) > epx1:
                if debug:
                    print("cuts!")
                return True
        if epy1 == epy2 and abs(epx2-epx1) > abs(px2 - px1):
            if min(py1,py2) < epy1 and max(py1, py2) > epy1:
                if debug:
                    print("cuts (other variety)!")
                return True
        if debug:
            print("def outside both of em")
        return False

    if is_inside_x(epx1) and is_inside_x(epx2) and is_inside_y(epy1) and is_inside_y(epy2):
        #all points of the edge are inside
        if (epx1 == epx2 and (epx1 == px1 or epx1 == px2)) or (epy1 == epy2 and (epy1 == py1 or epy1 == py2)):
            if debug:
                print("all inside but point on edge")
            return False
        if debug:
            print("all inside")
        return True
    if (is_inside_x(epx1) and is_inside_y(epy1)) or (is_inside_x(epx2) and is_inside_y(epy2)):
        #one of the points of the edge is inside
        if ep1 == p1 or ep1 == p2 or ep2 == p1 or ep2 == p2:
            if epx1 == epx2 and (min(py1, py2) >= min(epy1, epy2) and max(py1, py2) <= max(epy1, epy2)):
                if debug:
                    print("inside, outside, but corner match (vertical")
                return False
            if epy1 == epy2 and (min(px1, px2) >= min(epx1, epx2) and max(px1, px2) <= max(epx1, epx2)):
                if debug:
                    print("inside, outside, but corner match (horizontal)")
                return False
        # one of the points of the edge is on the edge of the square
        if epx1 == epx2 and (epy1 in [py1, py2] or epy2 in [py1, py2]):
            # deal with a potental cut
            if ((max(epy1,epy2) == max(py1, py2) and min(epy1,epy2) < min(py1,py2)) or
                (min(epy1,epy2) == min(py1, py2) and max(epy1,epy2) > max(py1,py2))):
                if debug:
                    print("funky cut!")
                return True
            if debug:
                print("inside, outside, but point on edge vertical")
            return False
        if epy1 == epy2 and (epx1 in [px1, px2] or epx2 in [px1, px2]):
            if ((max(epx1,epx2) == max(px1, px2) and min(epx1,epx2) < min(px1,px2)) or
                (min(epx1,epx2) == min(px1, px2) and max(epx1,epx2) > max(px1,px2))):
                if debug:
                    print("funky cut (other one)!")
                return True

            if debug:
                print("inside, outside, but point on edge horizontal")
            return False
        if debug:
            print("inside, outside bad")
        return True
               
    raise "umm what"
    if debug:
        print("all outside, or are they?")
    return False

    #edge fully outside is good
    #edge fully inside is bad (unless its the outer edge of the square)


def intersects(l1, l2):
    p1, p2 = l1
    epx1,epy1 = p1
    epx2,epy2 = p2
    if epy2 == epy1:
        return False
    lp1, lp2 = l2
    lpx1, lpy1 = lp1
    lpx2, lpy2 = lp2
    if epx1 >= lpx1 and epx1 <= lpx2:
        if min(epy1, epy2) <= lpy1 and max(epy1, epy2) >= lpy1:
            return True
    return False


def is_inside(edges, p1, p2, debug=False):
    x1, y1 = p1
    x2, y2 = p2
    cx, cy = (min(x1,x2) + abs(x2-x1)//2, min(y1,y2) + abs(y2-y1)//2)
    intersection_count = 0
    for edge in edges:
        if False and debug:
            print((edge, ((0, cy), (cx,cy)), intersects(edge, ((0, cy), (cx,cy)))))
        if intersects(edge, ((0, cy), (cx,cy))):
            intersection_count += 1
        if debug:
            print((edge, p1,p2))
        is_bad = intersects_badly(edge, p1, p2, debug)
        if debug: 
            print(is_bad)
        if is_bad:
            return False
    if debug:
        print((cx,cy))
        print(intersection_count)
    return intersection_count % 2 == 1

def part2(data):
    edges = [ (data[i-1], point) for i, point in enumerate(data)]
    max_area = 0
    for i, a in enumerate(data):
        for b in data[i+1:]:
            x1,y1 = a
            x2,y2 = b
            if is_inside(edges, a,b, (9,5) == a and (2,3) == b):
                max_area = max(max_area, (abs(x2-x1)+1)*(abs(y2-y1)+1))
                if (abs(x2-x1)+1)*(abs(y2-y1)+1) == 1691456895:
                    is_inside(edges, a, b, True)
    assert max_area < 1691456895, "still too much"
    assert max_area < 4596179031, "this is too much"
    assert max_area < 4664572758, "this is too much"
    print(max_area)
    return max_area


def test():
    test_data = """7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3"""
    assert part1(parse_data(test_data)) == 50, "Should be 11"
    assert part2(parse_data(test_data)) == 24, "Should be 31"
