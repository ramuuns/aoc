from collections import defaultdict
from functools import cmp_to_key

def run(data):
    data = parse_data(data)
    return (part1(data), part2(data))

def mk_rule():
    return {"before": set(), "after": set()}

def parse_data(data):
    (rules, updates) = data.strip().split("\n\n")
    return (parse_rules(rules), parse_updates(updates))

def parse_rules(in_rules):
    rules = defaultdict(mk_rule)
    for rule_str in in_rules.splitlines():
        (a,b) = list(map(int,rule_str.split("|")))
        rules[a]["after"].add(b)
        rules[b]["before"].add(a)
    return rules

def parse_updates(updates):
    return [list(map(int, line.split(","))) for line in updates.splitlines()]

def part1(data):
    rules, updates = data
    def rulesort(a,b):
        if b in rules[a]["after"] or a in rules[b]["before"]:
            return -1
        return 1

    total = 0
    for update in updates:
        sorted_update = sorted(update, key=cmp_to_key(rulesort))

        if update == sorted_update:
            total += update[len(update)//2]
    return total

def part2(data):
    rules, updates = data
    def rulesort(a,b):
        if b in rules[a]["after"] or a in rules[b]["before"]:
            return -1
        return 1

    total = 0
    for update in updates:
        sorted_update = sorted(update, key=cmp_to_key(rulesort))

        if update != sorted_update:
            total += sorted_update[len(sorted_update)//2]
    return total


def test():
    test_data = """
47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47
"""
    assert part1(parse_data(test_data)) == 143, "Should be 143"
    assert part2(parse_data(test_data)) == 123, "Should be 123"
