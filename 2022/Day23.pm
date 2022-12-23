package Day23;

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
....#..
..###.#
#...#.#
.#...##
#.###..
##.#.##
.#..#..
TEST_DATA
    my $data = read_file("input-23");
    return prepare_data($data);
}

sub prepare_data($data) {
    return make_map([split /\n/, $data], 0, { map => {}, min_x => 0, max_x => 0, min_y => 0, max_y => 0, num_elves => 0 });
}

sub make_map($rows, $y, $map) {
    return $map if $y == scalar @$rows;
    $map->{max_y} = $y;
    add_row([split //, $rows->[$y]], $map, $y, 0);
    @_ = ($rows, $y + 1, $map);
    goto &make_map;
}

sub add_row($row, $map, $y, $x) {
    return if $x == scalar @$row;
    if ( $row->[$x] eq '#' ) {
        $map->{num_elves}++;
        $map->{map}{"$y|$x"} = 1;
        $map->{max_x} = $x if $x > $map->{max_x};
    }
    @_ = ($row, $map, $y, $x+1);
    goto &add_row;
}

use Data::Dumper;

sub part_1($map) {
    move_the_elves($map, 10, 0);
    #say Dumper($map);
    return abs($map->{max_x} + 1 - $map->{min_x}) * abs($map->{max_y} + 1 - $map->{min_y}) - $map->{num_elves};
}

sub move_the_elves($map, $rounds_left, $idx) {
    #say $rounds_left;
    return $idx if $rounds_left == 0;
    my $thoughts = think_about_it($map, [keys $map->{map}->%*], { map => {}, elf_to_dest => {} }, $idx % 4);
    #say Dumper($thoughts);

    $map->{map} = {};
    $map->{min_y} =  10000000;
    $map->{max_y} = -10000000;
    $map->{min_x} =  10000000;
    $map->{max_x} = -10000000;
    my $did_move = execute_thoughts($map, $thoughts, [keys $thoughts->{elf_to_dest}->%*], 0);
    #print_map($map);
    #say Dumper($map);
    return $idx unless $did_move;
    @_ = ($map, $rounds_left - 1, $idx + 1);
    goto &move_the_elves;
}

sub print_map($map) {
    say "";
    say "--- map ---";
    for my $y ($map->{min_y}..$map->{max_y}) {
        my $line = "";
        for my $x ($map->{min_x}..$map->{max_x} ){ 
            $line .= defined $map->{map}{"$y|$x"} ? "#" : ".";
        }
        say $line;
    }

    say "-- end map --";
}

sub execute_thoughts($map, $thoughts, $elves, $did_any_move) {
    return $did_any_move unless scalar @$elves;
    my $elf = shift @$elves;
    my $dest = $thoughts->{elf_to_dest}{$elf};
    my ($new_y, $new_x);
    if ( $thoughts->{map}{$dest} == 1 ) {
        ($new_y, $new_x) = split /\|/, $dest;
        $did_any_move ||= $elf ne $dest;
    } else {
        ($new_y, $new_x) = split /\|/, $elf;
    }
    $map->{map}{"$new_y|$new_x"} = 1;
    $map->{min_y} = $new_y if $map->{min_y} > $new_y;
    $map->{max_y} = $new_y if $map->{max_y} < $new_y;
    $map->{min_x} = $new_x if $map->{min_x} > $new_x;
    $map->{max_x} = $new_x if $map->{max_x} < $new_x;
    @_ = ($map, $thoughts, $elves, $did_any_move);
    goto &execute_thoughts;
}

sub get_neighbors($map, $y, $x, $shift_amount) {
    my $n_count = 0;
    my $nc_grouped = [[0,0,0], [0,0,0], [0,0,0], [0,0,0]];
    my $next_y = $y - 1;
    $nc_grouped->[0][0] += defined $map->{map}{"$next_y|$_"} for $x-1..$x+1;
    $nc_grouped->[0][1] = $next_y;
    $nc_grouped->[0][2] = $x;
    my $next_x = $x + 1;
    $nc_grouped->[3][0] += defined $map->{map}{"$_|$next_x"} for $y-1..$y+1;
    $nc_grouped->[3][1] = $y;
    $nc_grouped->[3][2] = $next_x;

    $next_y = $y + 1;
    $nc_grouped->[1][0] += defined $map->{map}{"$next_y|$_"} for $x-1..$x+1;
    $nc_grouped->[1][1] = $next_y;
    $nc_grouped->[1][2] = $x;

    $next_x = $x - 1;
    $nc_grouped->[2][0] += defined $map->{map}{"$_|$next_x"} for $y-1..$y+1;
    $nc_grouped->[2][1] = $y;
    $nc_grouped->[2][2] = $next_x;

    push @$nc_grouped, shift @$nc_grouped for 0..$shift_amount-1;

    $n_count += $_->[0] for @$nc_grouped;
    return ($n_count, $nc_grouped);
}

sub do_think($candidates, $thoughts, $y, $x) {
    unless ( scalar @$candidates ) {
        $thoughts->{map}{"$y|$x"} = 1;
        $thoughts->{elf_to_dest}{"$y|$x"} = "$y|$x";
        return;
    }
    my $cand = shift @$candidates;
    unless ( shift @$cand ) {
        my ($cy, $cx) = @$cand;
        $thoughts->{map}{"$cy|$cx"}++;
        $thoughts->{elf_to_dest}{"$y|$x"} = "$cy|$cx";
        return;
    }
    goto &do_think;
}

sub think_about_it($map, $elf_positions, $thoughts, $shift_amount) {
    return $thoughts unless scalar @$elf_positions;
    my $pos = shift @$elf_positions;
    my ($y, $x) = split /\|/, $pos;

    my ($n_count, $n_grouped) = get_neighbors($map, $y, $x, $shift_amount);
    if ($n_count) {
        do_think($n_grouped, $thoughts, $y, $x);
    } else {
        $thoughts->{map}{"$y|$x"} = 1;
        $thoughts->{elf_to_dest}{"$y|$x"} = "$y|$x";
    }
    goto &think_about_it;
}

sub part_2($map) {
    my $num_rounds = move_the_elves($map, -1, 0);
    return $num_rounds + 1;
}

1;
