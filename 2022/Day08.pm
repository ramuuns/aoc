package Day08;

use 5.30.0;
use strict;
use warnings;
use feature "signatures";
no warnings "experimental::signatures";

use File::Slurp;

sub run($mode) {
    return [
      part_1(read_input($mode)),
      part_2(read_input($mode))
    ];
}

sub read_input($mode) {
    return prepare_data(<<TEST_DATA) if $mode eq "test";
30373
25512
65332
33549
35390
TEST_DATA
    my $data = read_file("input-08");
    return prepare_data($data);
}

sub prepare_data($data) {
    return map {[ map +{ 
        height => $_, 
        e => undef, w => undef, n => undef, s => undef 
      }, split //, $_ ]} split /\n/, $data;
}

use Data::Dumper;

sub part_1(@data) {
    return count_visible([@data], 0, 0, 0);
}

sub count_visible($grid, $cnt, $y, $x) {
    return $cnt if $y == scalar @$grid;
    if ( $x == scalar $grid->[$y]->@* ) {
        @_ = ($grid, $cnt, $y+1, 0);
        goto &count_visible;
    }
    @_ = ($grid, $cnt + is_visible($grid, $x, $y), $y, $x+1);
    goto &count_visible;
}

sub t_say($thing) {
#say $thing;
    return 1;
}

sub is_visible($grid, $x, $y) {
    my ($n, $e, $s, $w) = (
        visible($grid,$x,$y,'n', $grid->[$y][$x]),
        visible($grid,$x,$y,'e', $grid->[$y][$x]),
        visible($grid,$x,$y,'s', $grid->[$y][$x]),
        visible($grid,$x,$y,'w', $grid->[$y][$x])
    );
    return $n || $e || $s || $w;
}

my $op = {
   n => { x => 0, y => -1 },
   e => { x => 1, y => 0 },
   s => { x => 0, y => 1 },
   w => { x => -1, y => 0 } 
};

sub start_x($grid, $dir, $x) {
    return $x unless $op->{$dir}{x};
    return 0 if $op->{$dir}{x} == -1;
    return scalar $grid->[0]->@* -1;
}

sub start_y($grid, $dir, $y) {
    return $y unless $op->{$dir}{y};
    return 0 if $op->{$dir}{y} == -1;
    return scalar @$grid - 1;
}

sub visible($grid, $x, $y, $dir, $origin) {
    my $current = $grid->[$y][$x];
    if ( $current == $origin ) {
        if ( is_edge($grid, $x, $y) ) {
            $current->{$dir} = $current->{height};
            return 1;
        }
        my $n = $grid->[$y+$op->{$dir}{y}][$x+$op->{$dir}{x}];
        unless ( defined $n->{$dir} ) {
            @_ = ($grid, start_x($grid, $dir, $x), start_y($grid, $dir, $y), $dir, $origin);
            goto &visible;
        }
        if ( $n->{$dir} < $current->{height} ) {
            $current->{$dir} = $current->{height};
            return 1;
        } else {
            $current->{$dir} = $n->{$dir};
            return 0;
        }
    } else {
        if ( is_edge($grid, $x, $y) ) {
            $current->{$dir} = $current->{height};
        } else {
            my $n = $grid->[$y+$op->{$dir}{y}][$x+$op->{$dir}{x}];
            $current->{$dir} = $n->{$dir} < $current->{height} ? $current->{height} : $n->{$dir};
        }
        @_ = ($grid, $x-$op->{$dir}{x}, $y-$op->{$dir}{y}, $dir, $origin);
        goto &visible;
    }
}

sub part_2(@data) {
    return max_scenic_score([@data], 0, 0, 0);
}

sub max_scenic_score($grid, $score, $x, $y) {
    return $score if $y == scalar @$grid;
    if ( $x == scalar $grid->[$y]->@* ) {
        @_ = ($grid, $score, 0, $y+1);
        goto &max_scenic_score;
    }
    my $this_score = calc_score($grid, $x, $y);
    @_ = ($grid, $score > $this_score? $score: $this_score, $x+1, $y);
    goto &max_scenic_score;
}

sub calc_score($grid, $x, $y) {
    return 
        view($grid, $x, $y, 0, 'n', $grid->[$y][$x]) 
        * view($grid, $x, $y, 0, 'w', $grid->[$y][$x]) 
        * view($grid, $x, $y, 0, 's', $grid->[$y][$x]) 
        * view($grid, $x, $y, 0, 'e', $grid->[$y][$x]); 
}

sub is_edge($grid, $x, $y) {
    return $x == 0 || $y == 0 || $y == scalar @$grid - 1 || $x == scalar $grid->[$y]->@* - 1;
}

sub view($grid, $x, $y, $d, $dir, $origin) {
    if ( is_edge($grid, $x, $y) ) {
        $origin->{$dir} = $d;
        return $d;
    }
    my $n = $grid->[$y+$op->{$dir}{y}][$x+$op->{$dir}{x}];
    if ( $n->{height} >= $origin->{height} ) {
        $origin->{$dir} = $d + 1;
        return $d + 1;
    }
    unless ( defined $n->{$dir} ) {
        @_ = ($grid, $x+$op->{$dir}{x}, $y+$op->{$dir}{y}, $d+1, $dir, $origin);
        goto &view;
    }
    if ( $n->{$dir} == 0 ) {
        $origin->{$dir} = $d + 1;
        return $d + 1;
    }
    @_ = ($grid, $x + $op->{$dir}{x} * $n->{$dir}, $y + $op->{$dir}{y} * $n->{$dir}, $d + $n->{$dir}, $dir, $origin);
    goto &view;
}


1;
