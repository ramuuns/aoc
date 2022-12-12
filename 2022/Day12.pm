package Day12;

use 5.30.0;
use strict;
use warnings;
use feature "signatures";
no warnings "experimental::signatures";

use Pq qw/pq_push pq_pop/;

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
Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi
TEST_DATA
    my $data = read_file("input-12");
    return prepare_data($data);
}

sub prepare_data($data) {
    my @rows = map { [split //, $_] } split /\n/, $data;
    my $start = [0,0];
    my $end = [0,0];
    return find_start_end(\@rows, $start, $end, 0, 0);
}

sub find_start_end($grid, $start, $end, $y, $found) {
    return ($grid, $start, $end) if $found == 2;
    $found = check_row($grid, $start, $end, $y, 0, $found);
    @_ = ($grid, $start, $end, $y + 1, $found);
    goto &find_start_end;
}

sub check_row($grid, $start, $end, $y, $x, $found) {
    return $found if $found == 2 || $x == scalar $grid->[$y]->@*;
    if ( $grid->[$y][$x] eq 'S' ) {
        $grid->[$y][$x] = 'a';
        $found = $found + 1;
        $start->[0] = $y;
        $start->[1] = $x;
    }
    if ( $grid->[$y][$x] eq 'E' ) {
        $grid->[$y][$x] = 'z';
        $found = $found + 1;
        $end->[0] = $y;
        $end->[1] = $x;
    }
    @_ = ($grid, $start, $end, $y, $x + 1, $found);
    goto &check_row;
}

sub part_1($grid, $start, $end) {
    return find_min_steps($grid, [@$start], $end, 0, { (join 'x', @$start ) => 1 }, {});
}

sub find_min_steps($grid, $pos, $end, $steps, $seen, $pq) {
    return $steps if $pos->[0] == $end->[0] && $pos->[1] == $end->[1];
    my @neighbors = grep {
        $_->[0] >= 0 && $_->[1] >= 0 #lower bounds check
      && defined $grid->[$_->[0]] && defined $grid->[$_->[0]][$_->[1]] # upper bounds check
      && (!defined $seen->{join 'x', @$_} || $seen->{join 'x', @$_} > $steps + 1) # not visited or visited via a longer path
    } neighbors($pos)->@*;
    my $curr = $grid->[$pos->[0]][$pos->[1]];
    @neighbors = grep { not_much_higher($grid, $curr, $_) } @neighbors;
    $seen->{join 'x', @$_} = $steps + 1 for @neighbors;
    pq_push($pq, $steps + 1 + md($_, $end), [$steps + 1, $_]) for @neighbors;
    my $next = pq_pop($pq);
    @_ = ($grid, $next->[1], $end, $next->[0], $seen, $pq );
    goto &find_min_steps;
}

sub neighbors($pos) {
    my ($y, $x) = @$pos;
    return [[$y, $x+1], [$y, $x - 1], [$y+1, $x], [$y -1, $x]];
}

sub not_much_higher($grid, $here, $pos) {
    my ($y,$x) = @$pos;
    return ( ord($grid->[$y][$x]) - 1 ) <= ord($here);
}

sub not_not_much_higher($grid, $here, $pos) {
    my ($y,$x) = @$pos;
    return ( ord($here) - 1 ) <=  ord($grid->[$y][$x]);
}

sub md($start, $end) {
    return abs($start->[0] - $end->[0]) + abs($start->[1] - $end->[1]);
}

sub part_2($grid, $start, $end) {
    return rev_min_steps($grid, $end, 0, { (join 'x', @$end) => 1 }, []);
}

sub rev_min_steps($grid, $pos, $steps, $seen, $pq) {
    return $steps if $grid->[$pos->[0]][$pos->[1]] eq 'a';
    my @neighbors = grep { $_->[0] >= 0 && $_->[1] >= 0 && defined $grid->[$_->[0]] && defined $grid->[$_->[0]][$_->[1]] && ! defined $seen->{join 'x', @$_} } neighbors($pos)->@*;
    my $curr = $grid->[$pos->[0]][$pos->[1]];
    @neighbors = grep { not_not_much_higher($grid, $curr, $_) } @neighbors;
    $seen->{join 'x', @$_} = 1 for @neighbors;
    push @$pq, [$steps + 1, $_] for @neighbors;
    my $next = shift @$pq;
    @_ = ($grid, $next->[1], $next->[0], $seen, $pq );
    goto &rev_min_steps;
}

1;
