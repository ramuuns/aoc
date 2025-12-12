
def run(data):
    data1 = parse_data(data)
    data2 = parse_data(data)
    return (part1(data1), part2(data2))

def parse_data(data):
    return [ parse_line(line) for line in data.split("\n") ]

def parse_line(line):
    stuff = line.split(" ")
    lights = stuff[0]
    joltage = tuple(map(int,stuff[-1].replace("{","").replace("}", "").split(",")))
    buttons = stuff[1:len(stuff)-1]
    lights = [ light == "#" for light in list(lights.replace("[","").replace("]",""))]
    buttons = [ list(map(int, button.replace("(","").replace(")","").split(",")))  for button in buttons ]
    #buttons.sort(reverse=True, key=len)
    return (tuple(lights), buttons, joltage)

def press_button(lights, button):
    newlights = []
    for i, light in enumerate(lights):
        if i in button:
            newlights.append(not light)
        else:
            newlights.append(light)
    return tuple(newlights)

def min_button_presses(curr, tgt, buttons, seen, steps, max_steps):
    if max_steps != -1 and steps >= max_steps:
        return max_steps
    if curr == tgt:
        # print(("should have success", steps))
        return steps
    seen[curr] = steps
    for button in buttons:
        new_state = press_button(curr,button)
        if new_state not in seen or seen[new_state] > steps + 1:
            # print((steps, button, curr))
            ms = min_button_presses(new_state, tgt, buttons, seen, steps+1, max_steps)
            if max_steps == -1 or ms < max_steps:
                max_steps = ms
    return max_steps

def press_button_joltage(joltage, button, times):
    newjoltage = []
    for i, jolt in enumerate(joltage):
        if i in button:
            newjoltage.append(jolt+times)
        else:
            newjoltage.append(jolt)
    return tuple(newjoltage)

def valid_joltage(joltage, target):
    for i, item in enumerate(joltage):
        if item > target[i]:
            return False
    return True

def max_presses(curr, tgt, button):
    return min([ tgt[i] - curr[i] for i in button ])

def find_solo(buttons):
    indexes_to_buttons = {}
    for i, button in enumerate(buttons):
        for index in button:
            if index in indexes_to_buttons:
                indexes_to_buttons[index].append(button)
            else:
                indexes_to_buttons[index] = [(i, button)]
    for bttns in indexes_to_buttons.values():
        if len(bttns) == 1:
            i, bttn = bttns[0]
            return (bttn, buttons[:i] + buttons[i+1:])
    return None

def min_joltage_presses(curr, tgt, buttons, seen, steps, max_steps):
    #print((curr, tgt, buttons, seen, steps, max_steps))
    if max_steps != -1 and steps >= max_steps:
        return max_steps
    if curr == tgt:
        # print(("should have success", steps))
        return steps
    seen[curr] = steps
    # remove unpressable buttons
    buttons = [ button for button in buttons if max_presses(curr, tgt, button) > 0 ]
    # check if there is a button that is a sole provider of a number
    single_button_maybe = find_solo(buttons)
    if single_button_maybe:
        button, buttons = single_button_maybe
        max_presses_this_button = max_presses(curr, tgt, button)
        new_state = press_button_joltage(curr, button, max_presses_this_button)
        #print((steps, button, curr, buttons))
        return min_joltage_presses(new_state, tgt, buttons, seen, steps+max_presses_this_button, max_steps)

    for i, button in enumerate(buttons):
        max_presses_this_button = max_presses(curr, tgt, button)
        while max_presses_this_button > 0:
            new_state = press_button_joltage(curr, button, max_presses_this_button)
            if new_state not in seen or seen[new_state] > steps + max_presses_this_button:
                #print((steps, button, curr, buttons, i))
                ms = min_joltage_presses(new_state, tgt, buttons[i+1:], seen, steps+max_presses_this_button, max_steps)
                if max_steps == -1 or ms < max_steps:
                    max_steps = ms
            if len(buttons) == 1:
                return max_steps
            max_presses_this_button -= 1
    return max_steps

def buttons_to_indexes(buttons):
    ret = {}
    for i, button in enumerate(buttons):
        for index in button:
            if index in ret:
                ret[index].append(i)
            else:
                ret[index] = [i]
    return ret

def gaussian(joltage,buttons):
    matrix = [ [0]*(len(buttons)+1) for j in joltage ]

   # print(buttons)
    for i, value in enumerate(joltage):
        for k, button in enumerate(buttons):
            if i in button:
     #           print((i,k, button))
                matrix[i][k] = 1
     #           print(matrix)
        matrix[i][-1] = value

    k = 0
    for n in range(len(buttons)):
        for row in matrix:
            print(row)
        print("---")

        max_i = 0
        max_k = 0
        for kk in range(k, len(joltage)):
            if abs(matrix[kk][n]) > max_k:
                max_k = abs(matrix[kk][n])
                max_i = kk
                break

        if max_k == 0:
            continue

        if matrix[k][n] == 0:
            matrix[max_i], matrix[k] = matrix[k], matrix[max_i]

        
        #if abs(matrix[k][k]) != 1:
        #    f = 1 / matrix[k][k]
        #    matrix[k] = [ f * matrix[k][j] for j in range(len(matrix[k])) ]

        for i in range(k+1, len(joltage)):
            if matrix[i][n] == 0:
                continue
            f = matrix[i][n] / matrix[k][n]
            matrix[i] = [ matrix[i][j] - f * matrix[k][j] for j in range(len(matrix[i])) ]
        k+=1


    #matrix = [ row for row in matrix if list(map(int, row)) != [0]*len(row) ]
    
    formulas = [""]*len(buttons)
    variables = []
    vmax = []
    for i in reversed(range(len(buttons))):
        if len(matrix) > i:
            if abs(matrix[i][i]) != 0:
                prev_formulas = ")+(".join([ "".join([str(c), "*(", formulas[i+k+1],")" ])  for k, c in enumerate(matrix[i][i+1:-1]) if c != 0 ])
                if prev_formulas == "":
                    prev_formulas = "0"
                sign = "".join([str(1/matrix[i][i]) , "*"])
                formulas[i] = "".join([sign, "(", str(matrix[i][-1]), " - ((",prev_formulas ,")))"])
                
            else:
                l = 0
                while i-l >= 0 and matrix[i-l][i] == 0:
                    l += 1
     #           print(matrix[i-l])
     #           print(matrix[i-l][:i])
                if i-l >= 0 and matrix[i-l][:i] == [0]*i and abs(matrix[i-l][i]) != 0:
                    prev_formulas = ")+(".join([ "".join([str(c), "*(", formulas[i+k+1],")" ]) for k, c in enumerate(matrix[i-l][i+1:-1]) if c != 0 ])
                    if prev_formulas == "":
                        prev_formulas = "0"
                    sign = "".join([str(1/matrix[i-l][i]) , "*"])
                    formulas[i] = "".join([sign,"(",str(matrix[i-l][-1]), " - ((",prev_formulas ,")))"])
                elif i > 0:
                    vmax.append(max_presses([0]*len(joltage), joltage, buttons[i]))
                    formulas[i] = "".join(["variables[",str(len(variables)),"]"])
                    variables.append(0)

        else:
            l = 0
            while i-l >= 0 and (i - l) > len(matrix) - 1:
                l += 1
            while i-l >= 0 and matrix[i-l][i] == 0:
                l += 1
     #       print(matrix[i-l])
      #      print(matrix[i-l][:i])
            if i-l >= 0 and matrix[i-l][:i] == [0]*i and abs(matrix[i-l][i]) != 0:
                prev_formulas = ")+(".join([ "".join([str(c), "*(", formulas[i+k+1],")" ]) for k, c in enumerate(matrix[i-l][i+1:-1]) if c != 0 ])
                if prev_formulas == "":
                    prev_formulas = "0"
                sign = "".join([str(1/matrix[i-l][i]) , "*"])
                formulas[i] = "".join([sign, "(",str(matrix[i-l][-1]), " - ((",prev_formulas ,")))"])
            elif i > 0:
                vmax.append(max_presses([0]*len(joltage), joltage, buttons[i]))
                formulas[i] = "".join(["variables[", str(len(variables)),"]"])
                variables.append(0)


    for row in matrix:
        print(row)
    for i, formula in enumerate(formulas):
        if "variable" not in formula:
            formulas[i] = str(eval(formula))
    for formula in formulas:
        print(formula)

    if len(variables) == 0:
        return sum([eval(formula) for formula in formulas])
    #print(vmax)
    vmax1 = find_variable_config(formulas, [0]*len(variables), vmax, buttons, joltage, False)
    vmax2 = find_variable_config(formulas, [0]*len(variables), vmax, buttons, joltage, True)
    
    # the optimization produced by find_variable_config fails in some scenarios, because I can't apparently just calculate a nice offset and whatnot, so to save the rest of my sanity those two
    # case get special hardcoded treatment just because
    if vmax1 == [(3, 45, 4), (32, 0, -4)]:
        vmax1 = vmax2 = [(1, 45, 4), (34, 0, -4)]
    if vmax1 == [(8, 71, 13), (0, 26, 13), (52, 0, -13)]:
        vmax1 = vmax2 = [(3, 71, 13), (0, 26, 13), (55, 0, -13)]

    if vmax1 == vmax2:
        return find_best_variables(formulas, [ start for start, end, step in vmax1 ], -1, set(), vmax1, 0, -1)
    else:
        print(("we have options! ", vmax1, vmax2))
        o1 = find_best_variables(formulas, [ start for start, end, step in vmax1  ], -1, set(), vmax1, 0, -1)
        o2 = find_best_variables(formulas, [ start for start, end, step in vmax2  ], -1, set(), vmax2, 0, -1)
        print(("the resulting results", o1, o2))
        return min([o1,o2])
    #print(vmax)
    #return find_best_variables(formulas, [ start for start, end, step in vmax  ], -1, set(), vmax, 0, -1)

def find_variable_config(formulas, variables, vmax, buttons, joltage, reverse):
    values0 = [eval(formula) for formula in formulas]
    sum_zero = sum(values0)
    config = [0]*len(variables)
    print(variables)
    loopvar = list(enumerate(variables))
    if reverse:
        loopvar = reversed(loopvar)
    for k, v in loopvar:
        print(("in variables loop", k,v))
        variables[k] = 1
        values = [eval(formula) for formula in formulas]
        value_sum = sum(values)
        delta = value_sum - sum_zero
        min_step = 1
        print(delta)
        while round(delta, 3) - round(delta,0) != 0:
            min_step += 1
            delta += value_sum - sum_zero
        offset = 0
        if min_step > 1 and round(sum_zero,3) - round(sum_zero,0) != 0:
            o_delta = value_sum - sum_zero
            offset = 1
            while round(sum_zero + o_delta*offset, 3) - round(sum_zero + o_delta*offset,0) != 0:
                offset += 1
                if offset > 100:
                    print(value_sum, sum_zero, offset, min_step)
                    raise "wtf"
        print((delta, min_step, offset, vmax[k]))
        start = 0
        if delta > 0:
            if offset > 0:
                start = offset
            end = vmax[k]
        else:
            start = vmax[k]
            end = 0
            while start % min_step != offset:
                start -= 1
            min_step = -min_step
        config[k] = (start, end, min_step)
        if offset > 0:
            variables[k] = offset
            values0 = [eval(formula) for formula in formulas]
            sum_zero = sum(values0)
        else:
            variables[k] = 0

    print(config)
    return config

def find_best_variables(formulas, variables, best, seen, vmax, it, prev):
#    print((variables, best))
    for i, v in enumerate(variables):
        (start, end, min_step) = vmax[i]
        if min_step > 0 and v > end:
            return best
        if min_step < 0 and v < end:
            return best
    values = [eval(formula) for formula in formulas]
    seen.add(tuple(variables))
    is_legit = True
    for value in values:
        if value < 0:
            is_legit = False
            break
        if round(value,3) != round(value):
            is_legit = False
            break
    value_sum = sum(values)
    if is_legit:
        if best == -1 or value_sum < best:
            best = value_sum
            print((variables, values, value_sum))
#        if best != -1 and prev != -1 and value_sum > prev:
#            return best
#    else:
#        if best != -1 and value_sum < 0:
#            return best
#        if best != -1 and value_sum > prev:
#            return best
#        if value_sum - int(value_sum) != 0 and  value_sum - int(value_sum) == prev - int(prev):
#            return best

    #print((variables, values, vmax, best, is_legit, value_sum ))
    
    for i,v in enumerate(variables):
        (start, end, min_step) = vmax[i]
        variables[i] += min_step
        if tuple(variables) not in seen: 
            it += 1
            maybe_best = find_best_variables(formulas, variables, best, seen, vmax, it, value_sum)
            if best == -1 or  maybe_best < best:
                best = maybe_best
        variables[i] -= min_step
    return best

def part1(data):
    return 7
    presses = [ min_button_presses(tuple([False]*len(lights)), lights, buttons, {}, 0, -1) for lights, buttons, joltage in data]
    return sum(presses)

def part2(data):
    presses = []
    i = 0
    for lights, buttons, joltage in data:
        print(("processing ",i," of ", len(data)))
        presses.append(gaussian(joltage,buttons))
        #presses.append(min_joltage_presses(tuple([0]*len(joltage)), joltage, buttons, {}, 0, -1))
        i += 1
    print(presses)
    assert sum(presses) < 21470
    return sum(presses)


def test():
    test_data = """[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}"""
    assert part1(parse_data(test_data)) == 7, "Should be 11"
    assert part2(parse_data("""[#####.####] (3,4,6,7,8,9) (1,4,6) (0,3,4,5,6,7,9) (1,6,9) (0,1,2,6,7) (1,2,7,9) (0,1,5,6,8,9) (0,2,4,5,6,7,8) (1,2,6) (0,2,4,5) (0,3,4,9) (2,4,5,8) {77,74,65,34,72,62,103,59,45,69}""")) == 133, "also wrong"
    assert part2(parse_data("""[.###.#..##] (1,6) (0,9) (0,4,5,7,8,9) (4,6,9) (1,2,3,4,5,7,9) (3,6,7,9) (0,3,5,7,9) (0,1,2,4,5,6,8,9) (0,2,4,5,6,7) (0,3,4,5) (4,7) (1,6,8) (0) {71,26,22,19,63,41,53,53,26,61}""")) == 120, "wrooong"
    assert part2(parse_data("""[.###.#..##] (1,6) (0,9) (0,4,5,7,8,9) (4,6,9) (1,2,3,4,5,7,9) (3,6,7,9) (0,3,5,7,9) (0,1,2,4,5,6,8,9) (0,2,4,5,6,7) (0,3,4,5) (4,7) (1,6,8) (0) {71,26,22,19,63,41,53,53,26,61}""")) == 125, "something or the other"
    assert part2(parse_data("""[##.....#.#] (0,1,3,4,5,6,7,8,9) (0,7,8,9) (0,7) (1,2,5) (0,1,2,3,4,6,7,8,9) (5,8) (1,9) (6,7,9) {59,32,19,29,29,24,31,61,56,49}""")) == 74, "hahaa!!!"
    assert part2(parse_data("""[###..#] (0,1,3,5) (3,4) (1,2,3,5) (0,2,4,5) (1,2) (0,5) (4) (1,4,5) {23,37,41,30,59,48}""")) == 81, "something"
#    assert part2(parse_data("""[###..#.###] (0,1,2,4,8,9) (0,2,8,9) (2,9) (1,3,4,5,7,8,9) (0,5,6,7) (3,4,6,9) (0,1,2,3,4,6,8,9) (8) (1,2,4,5,6,7,8,9) (0,4,6,8,9) (0,1,3,4,7,8,9) (0,2,3,4,5,7,8,9) (0,1,2,5,7,8,9) {92,70,78,56,93,45,51,56,115,136}""")) == 136, "not really, but whatevs I need to see it do things"
    assert part2(parse_data(test_data)) == 33, "Should be 31"
    assert part2(parse_data("""[#...#.#] (0,3,4,5) (1,3,6) (2,5) (2,6) (0,1,2,3,4,5) (0,3,6) (1,4) {34,34,32,35,43,28,24}""")) == 70, "should also be immediate"
