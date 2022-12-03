package Day03;

use 5.30.0;
use strict;
use warnings;
use feature "signatures";
no warnings "experimental::signatures";

use File::Slurp;

sub run($mode) {
    my @data = read_input($mode);
    return [
      part_1(@data),
      part_2(@data)
    ];
}

sub read_input($mode) {
    return prepare_data(<<TEST_DATA) if $mode eq "test";
vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw
TEST_DATA
    my $data = read_file("input-03");
    return prepare_data($data);
}

sub prepare_data($data) {
    return split /\n/, $data;
}

sub part_1(@data) {
    return priority_sum(find_duplicates([@data], [] ), 0);
}

sub part_2(@data) {
    return priority_sum(find_badges([@data], [], 0, {}), 0);
}

sub priority_sum($priorities, $sum) {
    return $sum unless scalar @$priorities;
    my $this_prio = shift @$priorities;
    @_ = (
        $priorities,
        $sum + char_to_prio($this_prio)
    );
    goto &priority_sum;
}

sub char_to_prio($char) {
    return 1 + ord($char) - ord('a') if ord($char) >= ord('a');
    return 27 + ord($char) - ord('A');
}

sub find_duplicates($data, $duplicates) {
    return $duplicates unless scalar @$data;
    my @sack = split //, shift @$data;
    push @$duplicates, find_duplicate(\@sack, (scalar @sack) / 2 , 0, {});
    goto &find_duplicates;
}

sub find_duplicate($sack, $pocket_size, $index, $duplicate_map) {
    my $item = shift @$sack;
    return $item if $index >= $pocket_size and $duplicate_map->{$item};
    $duplicate_map->{$item} = 1 if $index < $pocket_size;
    @_ = ($sack, $pocket_size, $index+1, $duplicate_map);
    goto &find_duplicate;
}

sub find_badges($data, $badges, $index, $item_map) {
    return $badges unless scalar @$data;
    my @sack = split //, shift @$data;
    if ( $index ) {
        $item_map = intersect($item_map, \@sack, {});
        push @$badges, [keys %$item_map]->[0] if $index == 2;
    } else {
        $item_map = to_map(\@sack, {});
    }
    @_ = ($data, $badges, ($index + 1)%3, $item_map);
    goto &find_badges;
}

sub to_map($data, $map) {
    return $map unless scalar @$data;
    my $item = shift @$data;
    $map->{$item} = 1;
    goto &to_map;
}

sub intersect($set1, $set2, $result) {
    return $result unless scalar @$set2;
    my $item = shift @$set2;
    $result->{$item} = 1 if $set1->{$item};
    goto &intersect;
}

1;
