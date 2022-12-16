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

use Data::Dumper;

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
    return max_pressure_release($graph, \@targets, [['AA', 30, 0, {}, []]], [0, []])->[0];
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

sub bitmask($n, $k) {
    my $t = 1 << $k;
    return $n & $t
}

sub part_2($graph) {
    my @targets = map { $_->{name} } sort { $b->{flow_rate} <=> $a->{flow_rate} } grep { $_->{flow_rate} > 0 } values %$graph;
    my ($p1, $path1) = max_pressure_release($graph, \@targets, [['AA', 26, 0, {}, []]], [0, []])->@*;
    shift @$path1; #drop the AA
    my $best = $p1;
    my $p1_len = scalar @$path1;
    return elephant_pressure($graph, (2 ** $p1_len) - 1, \@targets, $best, $path1, $p1_len);
}

sub elephant_pressure($graph, $i, $targets, $best, $path, $size) {
    return $best if $i < 0;
    my %excl_set = map { $path->[$_] => 1 } grep { bitmask($i, $_) } (0..$size-1);
    my ($my_pressure, $my_path) = max_pressure_release($graph, $targets, [['AA', 26, 0, \%excl_set, []]], [0, []])->@*;
    my ($elephant_pressure, $elephant_path) = max_pressure_release($graph, $targets, [['AA', 26, 0, { map { $_ => 1 } @$my_path },[]]], [0, []] )->@*;
    @_ = ($graph, $i - 1, $targets, $best > $my_pressure + $elephant_pressure ? $best :  $my_pressure + $elephant_pressure, $path, $size);
    goto &elephant_pressure;
}

1;
