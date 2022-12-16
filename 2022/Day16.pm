package Day16;

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
Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
Valve BB has flow rate=13; tunnels lead to valves CC, AA
Valve CC has flow rate=2; tunnels lead to valves DD, BB
Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
Valve EE has flow rate=3; tunnels lead to valves FF, DD
Valve FF has flow rate=0; tunnels lead to valves EE, GG
Valve GG has flow rate=0; tunnels lead to valves FF, HH
Valve HH has flow rate=22; tunnel leads to valve GG
Valve II has flow rate=0; tunnels lead to valves AA, JJ
Valve JJ has flow rate=21; tunnel leads to valve II
TEST_DATA
    my $data = read_file("input-16");
    return prepare_data($data);
}

sub prepare_data($data) {
    my $graph = {};
    $graph->{$_->{name}} = $_ for map { 
        $_ =~ /Valve ([A-Z]{2}) has flow rate=(\d+); tunnels? leads? to valves? (.+)/;
        my $nam = $1;
        my $r = $2;
        my $nei = $3;
        { name => $nam, flow_rate => $r, neighbors => [ split /, /, $nei ] }
    } split /\n/, $data;
    return ($graph);
}

sub part_1($graph) {
    my @targets = map { $_->{name} } sort { $b->{flow_rate} <=> $a->{flow_rate} } grep { $_->{flow_rate} > 0 } values %$graph;
    my @sorted = sort { $b->[0] <=> $a->[0] } all_pressure_release($graph, \@targets, [['AA', 30, 0, {}] ], [] )->@*;
    return (shift @sorted )->[0];
}

sub all_pressure_release($graph, $targets, $deq, $results) {
    state $distances;
    return $results unless scalar @$deq;
    my ($curr, $t_left, $pressure, $seen) = shift(@$deq)->@*;
    my @candidates = grep {
        $_->[2] > 0
    } map {
        my $d_key = join '', sort ($curr, $_);
        my $dist = $distances->{$d_key} //= dist($graph, $_, { $curr => 1 }, [[$curr, 0]]);
        my $p = ($t_left - $dist - 1) * $graph->{$_}->{flow_rate};
        [$_, $dist, $p]
    } grep { !$seen->{$_} } @$targets;
    push @$deq, [$_->[0], $t_left - $_->[1] - 1, $pressure + $_->[2], { %$seen, $_->[0] => 1 } ] for @candidates;
    push @$results, [$pressure, $seen];
    goto &all_pressure_release;
}

sub max_pressure_release($graph, $targets, $deq, $best) {
    state $distances;
    return $best unless scalar @$deq;
    my ($curr, $t_left, $pressure, $seen, $path) = shift(@$deq)->@*;
    my @candidates = grep {
        $_->[2] > 0
    } map {
        my $d_key = join '', sort ($curr, $_);
        my $dist = $distances->{$d_key} //= dist($graph, $_, { $curr => 1 }, [[$curr, 0]]);
        my $p = ($t_left - $dist - 1) * $graph->{$_}->{flow_rate};
        [$_, $dist, $p]
    } grep { !$seen->{$_} } @$targets;
    push @$deq, [$_->[0], $t_left - $_->[1] - 1, $pressure + $_->[2], { %$seen, $_->[0] => 1 }, [ @$path, $curr ] ] for @candidates;
    @_ = ($graph, $targets, $deq, $best->[0] < $pressure ? [ $pressure, [ @$path, $curr ] ] : $best);
    goto &max_pressure_release;
}

sub dist($graph, $tgt, $seen, $deq) {
    die unless scalar @$deq;
    my ($curr, $dist) = shift(@$deq)->@*;
    return $dist if $tgt eq $curr;
    my @n = grep { !$seen->{$_} } $graph->{$curr}{neighbors}->@*;
    $seen->{$_} = 1 for @n;
    push @$deq, [$_, $dist + 1] for @n;
    goto &dist;
}

sub make_distinct($paths, $ret) {
    return $ret unless scalar @$paths;
    my $path = shift @$paths;
    my $path_key = join('', (sort (keys $path->[1]->%*)));
    $ret->{$path_key} //= $path;
    $ret->{$path_key} = $path if $path->[0] > $ret->{$path_key}[0];
    goto &make_distinct;
}

sub part_2($graph) {
    my @targets = map { $_->{name} } sort { $b->{flow_rate} <=> $a->{flow_rate} } grep { $_->{flow_rate} > 0 } values %$graph;
    my $start = time;
    my @all_paths = all_pressure_release($graph, \@targets, [['AA', 26, 0, {}] ], [] )->@*;
    my $got_graph = time;
    my @distinct_paths = sort { $b->[0] <=> $a->[0] } values make_distinct(\@all_paths, {})->%*;
    return max_sum(\@distinct_paths, 0, 1, scalar @distinct_paths, 0);
}


sub max_sum($paths, $i, $j, $length, $max) {
    return $max if $i == $length - 1;
    if ( $j == $length ) {
        @_ = ($paths, $i+1, $i+2, $length, $max);
        goto &max_sum;
    } elsif ( $paths->[$i][0] + $paths->[$j][0] < $max ) {
        @_ = ($paths, $i+1, $i+2, $length, $max);
        goto &max_sum;
    } else {
        if ( $paths->[$i][0] + $paths->[$j][0] > $max && no_intersection($paths->[$i][1], [keys $paths->[$j][1]->%*]) ) {
            $max = $paths->[$i][0] + $paths->[$j][0];
        }
        @_ = ($paths, $i, $j+1, $length, $max);
        goto &max_sum;
    }
}

sub no_intersection($patha, $pathb) {
    return 1 unless scalar @$pathb;
    my $it = shift @$pathb;
    return 0 if $patha->{$it};
    goto &no_intersection;
}

1;
