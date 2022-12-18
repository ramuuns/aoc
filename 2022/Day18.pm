package Day18;

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
      part_2(read_input($mode))
    ];
}

sub read_input($mode) {
    return prepare_data(<<TEST_DATA) if $mode eq "test";
2,2,2
1,2,2
3,2,2
2,1,2
2,3,2
2,2,1
2,2,3
2,2,4
2,2,6
1,2,5
3,2,5
2,1,5
2,3,5
TEST_DATA
    my $data = read_file("input-18");
    return prepare_data($data);
}

sub prepare_data($data) {
    return map { { pos => $_, adj => 0 } } map { [ split /,/] } split /\n/, $data;
}

use Data::Dumper;

sub part_1(@data) {
    my $cubes = \@data;
    return count_sides(count_adj($cubes, 0, {}), 0, 0);
}

sub n_indexes($pos) {
    my ($x, $y, $z) = @$pos;
    [
        [$x+1, $y, $z],
        [$x-1, $y, $z],
        [$x, $y+1, $z],
        [$x, $y-1, $z],
        [$x, $y, $z+1],
        [$x, $y, $z-1],
    ]
}

sub count_adj($cubes, $i, $map) {
    return $cubes if $i == scalar @$cubes;
    my $cube = $cubes->[$i];
    $map->{join ",", $cube->{pos}->@*} = $cube;
    check_neighbors($cube, $map, n_indexes($cube->{pos}));
    @_ = ($cubes, $i+1, $map);
    goto &count_adj;
}

sub check_neighbors($cube, $map, $other_pos) {
    return unless scalar @$other_pos;
    my $n = join ',', (shift @$other_pos)->@*;
    $map->{$n}{adj}++ if defined $map->{$n};
    $cube->{adj}++ if defined $map->{$n};
    goto &check_neighbors;
}

sub count_sides($cubes, $i, $cnt) {
    return $cnt if $i == scalar @$cubes;
    my $cube = $cubes->[$i];

    @_ = ( $cubes, $i+1, $cnt + 6 - $cube->{adj} );
    goto &count_sides;
}

sub part_2(@data) {
    my $cubes = \@data;
    my $map = {};
    my $outside_map = {};
    count_adj_with_outside($cubes, 0, $map, $outside_map);
    my $outside_groups = make_outside_groups($outside_map, $map, [keys %$outside_map], []);
    my @g = map { sum_adj($_, 0, 0) } @$outside_groups;
    return count_sides($cubes, 0, 0) - sum(\@g, 0);
}

sub sum($items, $sum) {
    return $sum unless scalar @$items;
    @_ = ($items, $sum + shift @$items);
    goto &sum;
}

sub sum_adj($group, $i, $sum) {
    return $sum if $i == scalar @$group;
    @_ = ($group, $i+1, $sum + $group->[$i]->{adj} );
    goto &sum_adj;
}

sub make_outside_groups($outside_map, $map, $outside_keys, $groups) {
    return $groups unless scalar @$outside_keys;
    my $key = shift @$outside_keys;
    unless ( $outside_map->{$key}{seen} ) {
        $outside_map->{$key}{seen} = 1;
        if ( i_am_part_of_a_bubble($map, $key )) {
            my ($is_bubble, $maybe_bubble) = make_group($outside_map, $map, [ $outside_map->{$key} ], []);
            push @$groups, $maybe_bubble if $is_bubble;
            unless ( $is_bubble ) {
                $_->{not_in_a_bubble} = 1 for $maybe_bubble->@*
            }
        } else {
            $outside_map->{$key}{not_in_a_bubble} = 1;
        }
    }
    goto &make_outside_groups;
}

sub make_group($outside_map, $map, $deq, $ret) {
    return 1, $ret unless scalar @$deq;
    my $item = shift @$deq;
    push @$ret, $item;
    my @ok_neighbors = grep { defined $outside_map->{$_} || defined $map->{$_} || i_am_part_of_a_bubble($map, $_) }  map { join ",", $_->@* } n_indexes( $item->{pos} )->@*;
    return 0, $ret unless scalar @ok_neighbors == 6;
    if ( grep { defined $outside_map->{$_} && $outside_map->{$_}{seen} && defined $outside_map->{$_}{not_in_a_bubble} } @ok_neighbors ) {
        return 0, $ret;
    }
    my @n_keys = grep { defined $outside_map->{$_} && !$outside_map->{$_}{seen} } @ok_neighbors;
    $outside_map->{$_}{seen} = 1 for @n_keys;
    push @$deq, $outside_map->{$_} for @n_keys;
    goto &make_group;
}

sub say_but_true($str) {
    say $str;
    return 1;
}

sub i_am_part_of_a_bubble($map, $key) {
    my ($x,$y,$z) = split /,/, $key;
    found_something($map, $x+1, $y, $z, 1, 0, 0) 
    && found_something($map, $x-1, $y, $z, -1, 0, 0) 
    && found_something($map, $x, $y+1, $z, 0, 1, 0) 
    && found_something($map, $x, $y-1, $z, 0, -1, 0) 
    && found_something($map, $x, $y, $z+1, 0, 0, 1) 
    && found_something($map, $x, $y, $z-1, 0, 0, -1) 
}

sub found_something($map, $x, $y, $z, $dx, $dy, $dz) {
    my $key = "$x,$y,$z";
    return 1 if defined $map->{$key};
    return 0 if $x < 0 || $y < 0 || $z < 0;
    return 0 if $x > 21 || $y > 21 || $z > 21;
    @_ = ($map, $x+$dx, $y+$dy, $z+$dz, $dx, $dy, $dz);
    goto &found_something;
}

sub count_adj_with_outside($cubes, $i, $map, $outside_map) {
    return if $i == scalar @$cubes;
    my $cube = $cubes->[$i];
    my $key = join ",", $cube->{pos}->@*;
    $map->{$key} = $cube;
    delete $outside_map->{$key} if defined $outside_map->{$key};
    check_neighbors_with_outside($cube, $map, $outside_map, n_indexes($cube->{pos}));
    @_ = ($cubes, $i+1, $map, $outside_map);
    goto &count_adj_with_outside;
}

sub check_neighbors_with_outside($cube, $map, $outside_map, $other_pos) {
    return unless scalar @$other_pos;
    my $n = join ',', (shift @$other_pos)->@*;
    $map->{$n}{adj}++ if defined $map->{$n};
    $cube->{adj}++ if defined $map->{$n};
    $outside_map->{$n}{adj}++ if defined $outside_map->{$n};
    $outside_map->{$n} = { adj => 1, pos => [split ',', $n], seen => 0 } if !defined $map->{$n} && ! defined $outside_map->{$n};
    goto &check_neighbors_with_outside;
}

1;
