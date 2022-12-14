package Day14;

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
498,4 -> 498,6 -> 496,6
503,4 -> 502,4 -> 502,9 -> 494,9
TEST_DATA
    my $data = read_file("input-14");
    return prepare_data($data);
}

sub prepare_data($data) {
    return make_grid([], [ split /\n/, $data ]);
}

use Data::Dumper;

sub make_grid($grid, $lines) {
    return $grid unless scalar @$lines;
    my @line = map {[ split ',', $_  ]} split / -> /, shift @$lines;
    draw_line($grid, \@line);
    goto &make_grid;
}

sub draw_line($grid, $points) {
    return if scalar @$points == 1;
    my ($src_x, $src_y) = shift( @$points )->@*;
    my ($dst_x, $dst_y) = $points->[0]->@*;
    if ( $src_y == $dst_y ) {
        $grid->[$src_y] //= [];
        my $min_x = $src_x < $dst_x ? $src_x : $dst_x;
        my $max_x = $src_x < $dst_x ? $dst_x : $src_x;
        $grid->[$src_y][$_] = '#' for $min_x..($max_x);
    } else {
        my $min_y = $src_y < $dst_y ? $src_y : $dst_y;
        my $max_y = $src_y < $dst_y ? $dst_y : $src_y;
        $grid->[$_] //= [] for $min_y..($max_y);
        $grid->[$_][$src_x] = '#' for $min_y..($max_y);
    }
    goto &draw_line;
}

sub print_grid($grid, $y) {
    return if $y == scalar @$grid;
    say join '', map { !defined $_ ? '.' : $_ } $grid->[$y]->@*;
    @_ = ($grid, $y+1);
    goto &print_grid;
}

sub part_1($grid) {
    return drop_sand_until_out_of_grid($grid, 500, 0, 0);
}

sub drop_sand_until_out_of_grid($grid, $x, $y, $sand_cnt) {
    return $sand_cnt if $y+1 == scalar @$grid;
    if ( ! defined $grid->[$y+1][$x] ) {
        $y++;
    } elsif ( ! defined $grid->[$y+1][$x-1] ) {
        $y++;
        $x--;
    } elsif ( ! defined $grid->[$y+1][$x+1] ) {
        $y++;
        $x++;
    } else {
        $grid->[$y][$x] = 'o';
        $x = 500;
        $y = 0;
        $sand_cnt++;
    }
    @_ = ($grid, $x, $y, $sand_cnt);
    goto &drop_sand_until_out_of_grid;
}

sub part_2($grid) {
    push @$grid, [];
    return drop_sand_until_out_of_room($grid, 500, 0, 1);
}

sub drop_sand_until_out_of_room($grid, $x, $y, $sand_cnt) {
    return $sand_cnt - 1 if $x == 500 && $y == 0 && defined $grid->[0][500];
    if ( $y + 1 == scalar @$grid ) {
        $grid->[$y][$x] = 'o';
        $x = 500;
        $y = 0;
        $sand_cnt++;
    } elsif ( ! defined $grid->[$y+1][$x] ) {
        $y++;
    } elsif ( ! defined $grid->[$y+1][$x-1] ) {
        $y++;
        $x--;
    } elsif ( ! defined $grid->[$y+1][$x+1] ) {
        $y++;
        $x++;
    } else {
        $grid->[$y][$x] = 'o';
        $x = 500;
        $y = 0;
        $sand_cnt++;
    }
    @_ = ($grid, $x, $y, $sand_cnt);
    goto &drop_sand_until_out_of_room;
}

1;
