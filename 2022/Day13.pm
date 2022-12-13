package Day13;

use 5.30.0;
use strict;
use warnings;
use feature "signatures";
no warnings "experimental::signatures";

use File::Slurp;

sub run($mode) {
    my @data = read_input($mode, 1);
    return [
      part_1(@data),
      part_2(read_input($mode, 2))
    ];
}

sub read_input($mode, $p) {
    return prepare_data(<<TEST_DATA, $p) if $mode eq "test";
[1,1,3,1,1]
[1,1,5,1,1]

[[1],[2,3,4]]
[[1],4]

[9]
[[8,7,6]]

[[4,4],4,4]
[[4,4],4,4,4]

[7,7,7,7]
[7,7,7]

[]
[3]

[[[]]]
[[]]

[1,[2,[3,[4,[5,6,7]]]],8,9]
[1,[2,[3,[4,[5,6,0]]]],8,9]
TEST_DATA
    my $data = read_file("input-13");
    return prepare_data($data, $p);
}

sub prepare_data($data, $p) {
    return map { map { parse_into_list([split(//, $_)], [], [], 0) } split /\n/, $_ } split /\n\n/, $data if $p == 2;
    return map { [ map { parse_into_list([split(//, $_)], [], [], 0) } split /\n/, $_ ] } split /\n\n/, $data;
}

sub parse_into_list($tokens, $ret, $index_stack, $index) {
    return $ret unless scalar @$tokens;
    my $token = shift @$tokens;
    if ( $token eq '[' ) {
        my $arr = item($ret, $index_stack, 0);
        $arr->[$index] = [];
        push @$index_stack, $index;
        $index = 0;
    } elsif ( $token eq ']' ) {
        $index = pop @$index_stack;
    } elsif ( $token eq ',' ) {
        $index++;
    } else {
        my $arr = item($ret, $index_stack, 0);
        $arr->[$index] //= 0;
        $arr->[$index] = $arr->[$index]*10 + $token;
    }
    @_ = ($tokens, $ret, $index_stack, $index);
    goto &parse_into_list;
}

sub part_1(@data) {
    return check_order(\@data, 0, 0);
}

sub check_order($data, $index, $ok_index_sum) {
    return $ok_index_sum if $index == scalar @$data;
    my $is_ok = compare($data->[$index][0], $data->[$index][1], [0]) == -1;
    @_ = ($data, $index + 1, $ok_index_sum += ($index + 1)*$is_ok);
    goto &check_order;
}

sub item($arr, $index_stack, $i) {
    return $arr if $i == scalar @$index_stack;
    @_ = ($arr->[$index_stack->[$i]], $index_stack, $i + 1);
    goto &item;
}

sub convert($arr, $index_stack, $i) {
    if ( $i == scalar @$index_stack - 1 ) {
        $arr->[$index_stack->[$i]] = [ $arr->[$index_stack->[$i]] ];
        return;
    }
    @_ = ($arr->[$index_stack->[$i]], $index_stack, $i + 1);
    goto &convert;
}

sub compare($left, $right, $index) {
    die "equal!!!" unless scalar @$index;
    my $l = item($left, $index, 0);
    my $r = item($right, $index, 0);
    if ( ! defined $l && ! defined $r) {
        pop @$index;
    } elsif ( !defined $l ) {
        return -1;
    } elsif ( !defined $r ) {
        return 1;
    } elsif ( ref $l && ref $r ) {
        push @$index, -1;
    } elsif ( ref $l ) {
        convert($right, $index, 0);
        push @$index, -1;
    } elsif ( ref $r ) {
        convert($left, $index, 0);
        push @$index, -1;
    } else {
        return -1 if $l < $r;
        return 1 if $r < $l;
    }
    $index->[-1]++;
    goto &compare;
}

sub part_2(@data) {
    my $div1 = [[2]];
    my $div2 = [[6]];
    push @data, $div1;
    push @data, $div2;
    @data = sort { compare($a,$b,[0]) } @data;
    my ($d1, $d2) = find_indexes(\@data, $div1, $div2, 0, [])->@*;
    return ($d1 + 1) * ($d2 + 1);
}

sub find_indexes($arr, $el1, $el2, $index, $indexes) {
    return $indexes if scalar @$indexes == 2;
    push @$indexes, $index if $arr->[$index] == $el1 || $arr->[$index] == $el2;
    @_ = ( $arr, $el1, $el2, $index + 1, $indexes );
    goto &find_indexes;
}

1;
