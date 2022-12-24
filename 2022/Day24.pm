package Day24;

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
#.######
#>>.<^<#
#.<..<<#
#>v.><>#
#<^v^^>#
######.#
TEST_DATA
    my $data = read_file("input-24");
    return prepare_data($data);
}

sub prepare_data($data) {
    return make_blizzards([split /\n/, $data], -1, { row_blizzards => [], col_blizzards =>[] });
}

sub make_blizzards($rows, $y, $blizzards) {
    return $blizzards unless scalar @$rows;
    my $row = [split //, shift @$rows];
    $blizzards->{w} = scalar @$row - 2;
    $blizzards->{h} = $y;
    if ( $row->[2] ne "#" ) {
        add_to_row_col_blizzards($row, $y, 0, $blizzards);
    }
    @_ = ($rows, $y + 1, $blizzards);
    goto &make_blizzards;
}

sub add_to_row_col_blizzards($row, $y, $x, $blizzards) {
    return unless scalar @$row;
    my $char = shift @$row;
    if ( $char eq '<' || $char eq '>' ) {
        $blizzards->{row_blizzards}[$y] //= [];
        $blizzards->{row_blizzards}[$y][$x - 1] = $char eq '<' ? -1 : 1;
    } elsif ( $char eq '^' || $char eq 'v' ) {
        $blizzards->{col_blizzards}[$x - 1] //= [];
        $blizzards->{col_blizzards}[$x - 1][$y] = $char eq '^' ? -1 : 1;
    }
    @_ = ($row, $y, $x + 1, $blizzards);
    goto &add_to_row_col_blizzards;
}

use Data::Dumper;

sub part_1($blizzards) {
    return find_shortest_path($blizzards, [[0, -1, 0]], {}, $blizzards->{h}, $blizzards->{w} - 1);
}

sub get_next_steps($y,$x,$b) {
    grep { ($_->[0] > -1 || $_->[0] == -1 && $_->[1] == 0 ) && ($_->[0] < $b->{h} || $_->[0] == $b->{h} && $_->[1] == $b->{w} - 1 ) }
    grep { $_->[1] >= 0 && $_->[1] < $b->{w} }
    ([$y-1, $x],[$y, $x - 1],[$y, $x],[$y, $x +1],[$y+1, $x])
}

sub find_shortest_path($blizzards, $deq, $seen, $tgt_y, $tgt_x) {
    return -1 unless scalar @$deq;
    my ($steps, $y, $x) = (shift @$deq)->@*;

    return $steps if $y == $tgt_y && $x == $tgt_x;
    my @next_steps = get_next_steps($y, $x, $blizzards);
    $seen->{$steps + 1 % ( $blizzards->{w} * $blizzards->{h} )} //= {};
    @next_steps = 
    grep {
        ! $seen->{$steps + 1 % ( $blizzards->{w} * $blizzards->{h} )}{"$_->[0]|$_->[1]"}
    }
    grep {
        ! ( 
            defined  $blizzards->{col_blizzards}[$_->[1]][ ($_->[0] + $steps + 1) % $blizzards->{h} ] &&
            $blizzards->{col_blizzards}[$_->[1]][ ($_->[0] + $steps + 1) % $blizzards->{h} ] == -1 || 
            defined $blizzards->{col_blizzards}[$_->[1]][ ($_->[0] - $steps -1) % $blizzards->{h} ] &&
            $blizzards->{col_blizzards}[$_->[1]][ ($_->[0] - $steps -1) % $blizzards->{h} ] == 1 )
    }
    grep {
        $_->[0] == -1 ||
        $_->[0] == $blizzards->{h} ||
        ! ( 
        defined $blizzards->{row_blizzards}[$_->[0]][ ($_->[1] + $steps + 1) % $blizzards->{w} ] &&
        $blizzards->{row_blizzards}[$_->[0]][ ($_->[1] + $steps + 1) % $blizzards->{w} ] == -1 || 
        defined $blizzards->{row_blizzards}[$_->[0]][ ($_->[1] - $steps -1) % $blizzards->{w} ] &&
        $blizzards->{row_blizzards}[$_->[0]][ ($_->[1] - $steps -1) % $blizzards->{w} ] == 1 )
    } @next_steps;
    
    $seen->{$steps + 1 % ( $blizzards->{w} * $blizzards->{h} )}{"$_->[0]|$_->[1]"} = 1 for @next_steps;
    push @$deq, [ $steps + 1, $_->[0], $_->[1] ] for @next_steps;
    goto &find_shortest_path;
}

sub part_2($blizzards) {
    my $steps1 = find_shortest_path($blizzards, [[0, -1, 0]], {}, $blizzards->{h}, $blizzards->{w} - 1);
    my $steps2 = find_shortest_path($blizzards, [[$steps1, $blizzards->{h}, $blizzards->{w} - 1]], {}, -1, 0);
    return find_shortest_path($blizzards, [[$steps2, -1, 0]], {}, $blizzards->{h}, $blizzards->{w} - 1);
}

1;
