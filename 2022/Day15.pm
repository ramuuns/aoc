package Day15;

use 5.30.0;
use strict;
use warnings;
use feature "signatures";
no warnings "experimental::signatures";

use File::Slurp;

sub run($mode) {
    my @data = read_input($mode);
    return [
      part_1(\@data, $mode eq 'test' ? 10 : 2000000),
      part_2(\@data, $mode eq 'test' ? 20 : 4000000)
    ];
}

sub read_input($mode) {
    return prepare_data(<<TEST_DATA) if $mode eq "test";
Sensor at x=2, y=18: closest beacon is at x=-2, y=15
Sensor at x=9, y=16: closest beacon is at x=10, y=16
Sensor at x=13, y=2: closest beacon is at x=15, y=3
Sensor at x=12, y=14: closest beacon is at x=10, y=16
Sensor at x=10, y=20: closest beacon is at x=10, y=16
Sensor at x=14, y=17: closest beacon is at x=10, y=16
Sensor at x=8, y=7: closest beacon is at x=2, y=10
Sensor at x=2, y=0: closest beacon is at x=2, y=10
Sensor at x=0, y=11: closest beacon is at x=2, y=10
Sensor at x=20, y=14: closest beacon is at x=25, y=17
Sensor at x=17, y=20: closest beacon is at x=21, y=22
Sensor at x=16, y=7: closest beacon is at x=15, y=3
Sensor at x=14, y=3: closest beacon is at x=15, y=3
Sensor at x=20, y=1: closest beacon is at x=15, y=3
TEST_DATA
    my $data = read_file("input-15");
    return prepare_data($data);
}

sub prepare_data($data) {
    return map { $_ =~ /Sensor at x=(-?[0-9]+), y=(-?[0-9]+): closest beacon is at x=(-?[0-9]+), y=(-?[0-9]+)/; [[$1, $2],[$3, $4]]  } split /\n/, $data;
}

sub md($src, $tgt) {
    return abs($src->[0] - $tgt->[0]) + abs($src->[1] - $tgt->[1]);
}

sub part_1($data, $row) {
    my ($minx, $maxx) = find_min_max_x($data, 0, 0, 0)->@*;
    return count_covered_single_row($data, 0, $minx, $maxx, $row, [])->[0];
}

sub find_min_max_x($data, $i, $min, $max) {
    return [$min, $max] if $i == scalar @$data;
    my $t_min = $data->[$i][0][0] < $data->[$i][1][0] ? $data->[$i][0][0] : $data->[$i][1][0];
    my $t_max = $data->[$i][0][0] > $data->[$i][1][0] ? $data->[$i][0][0] : $data->[$i][1][0];
    @_ = ($data, $i+1, $min < $t_min ? $min : $t_min,  $max > $t_max ? $max : $t_max);
    goto &find_min_max_x;
}

use Data::Dumper;

sub count_covered_single_row($data, $i, $min, $max, $row, $ranges) {
    return count_items_in_rages([sort { $a->[0] <=> $b->[0] } @$ranges], $min, $max, 0, $min) if $i == scalar @$data;
    my ($s_x, $s_y) = $data->[$i][0]->@*;
    my $dist = md($data->[$i]->@*);
    if ( $row >= ($s_y - $dist) && $row <= ($s_y + $dist) ) {
        push @$ranges, [$s_x - $dist + abs($row - $s_y), $s_x + $dist - abs($row - $s_y)];
    }
    @_ = ($data, $i+1, $min, $max, $row, $ranges);
    goto &count_covered_single_row;
}

sub count_items_in_rages($ranges, $prev, $max, $count, $gap) {
    return [$count, $gap] if $prev > $max;
    return [$count, $gap] unless @$ranges;
    my ($xs, $xe) = (shift @$ranges)->@*;
    return [$count, $gap] if $xs > $max;
    if ( $prev < $xe ) {
        my $m = $xs > $prev ? $xs : $prev;
        my $e = $xe < $max ? $xe : $max;
        $count += $e - $m;
    }
    @_ = ($ranges, $xe > $prev ? $xe: $prev, $max, $count, $prev < $xs ? $xs - 1 : $gap);
    goto &count_items_in_rages;
}

sub part_2($data, $max_xy) {
    my ($x, $y) = find_xy([@$data], [ map { [$_->[0], $_->[1], md(@$_)] } @$data], 0, $max_xy)->@*;
    return 4000000*$x + $y;
}

sub find_xy($data, $all_data, $min_xy, $max_xy) {
    die "not found" unless scalar @$data;
    my $sensor = shift @$data;
    my $sensor_range = md(@$sensor);
    my ($s_x, $s_y) = $sensor->[0]->@*;
    my ($x, $y) = check_surroundings($all_data, $min_xy, $max_xy, $s_x, $s_y - $sensor_range - 1, $s_x + $sensor_range + 1, $s_y, 1, 1);
    return [$x, $y] if $x;
    ($x, $y) = check_surroundings($all_data, $min_xy, $max_xy, $s_x - $sensor_range - 1, $s_y, $s_x, $s_y - $sensor_range - 1, 1, -1);
    return [$x, $y] if $x;
    ($x, $y) = check_surroundings($all_data, $min_xy, $max_xy, $s_x - $sensor_range - 1, $s_y, $s_x, $s_y + $sensor_range + 1, 1, 1);
    return [$x, $y] if $x;
    ($x, $y) = check_surroundings($all_data, $min_xy, $max_xy, $s_x, $s_y + $sensor_range + 1, $s_x + $sensor_range + 1, $s_y, 1, -1);
    return [$x, $y] if $x;
    @_ = ($data, $all_data, $min_xy, $max_xy);
    goto &find_xy;
}

sub check_surroundings($sensors, $minxy, $maxxy, $x, $y, $t_x, $t_y, $dx, $dy) {
    return (undef, undef) if $x > $maxxy;
    return (undef, undef) if $x - $dx >= $t_x;
    return (undef, undef) if ($x < $minxy && $t_x < $minxy) || ($x > $maxxy && $t_x > $maxxy) || ($y < $minxy && $t_y < $minxy) || ($y > $maxxy && $t_y > $maxxy);
    if ( $x < $minxy ) {
        my $delta = abs($x - $minxy);
        $x = $minxy;
        $y = $y + $dy*$delta;
    }
    return (undef, undef) if ($x < $minxy && $t_x < $minxy) || ($x > $maxxy && $t_x > $maxxy) || ($y < $minxy && $t_y < $minxy) || ($y > $maxxy && $t_y > $maxxy);
    if ( $y < $minxy ) {
        my $delta = abs($y - $minxy);
        $y = $minxy;
        $x = $x + $dx*$delta;
    }
    return (undef, undef) if ($x < $minxy && $t_x < $minxy) || ($x > $maxxy && $t_x > $maxxy) || ($y < $minxy && $t_y < $minxy) || ($y > $maxxy && $t_y > $maxxy);
    if ( $x > $maxxy ) {
        my $delta = abs($x - $maxxy);
        $x = $maxxy;
        $y = $y + $dy*$delta;
    }
    return (undef, undef) if ($x < $minxy && $t_x < $minxy) || ($x > $maxxy && $t_x > $maxxy) || ($y < $minxy && $t_y < $minxy) || ($y > $maxxy && $t_y > $maxxy);
    if ( $y > $maxxy ) {
        my $delta = abs($y - $maxxy);
        $y = $maxxy;
        $x = $x + $dx*$delta;
    }
    return (undef, undef) if ($x < $minxy && $t_x < $minxy) || ($x > $maxxy && $t_x > $maxxy) || ($y < $minxy && $t_y < $minxy) || ($y > $maxxy && $t_y > $maxxy);
    my $in_range = is_in_range($sensors, $x, $y, 0);
    return ($x, $y) unless $in_range;
    my $i = $in_range - 1;
    if ( $dy == 1 ) {
        my $c = $y - $x;
        $x = int((($sensors->[$i][0][0] + $sensors->[$i][0][1] + $sensors->[$i][2]) - $c)/2);
        $y = $x + $c;
    } else {
        my $c = $y + $x;
        $x = int(($c - ($sensors->[$i][0][1] - $sensors->[$i][2] - $sensors->[$i][0][0]))/2);
        $y = -1 * $x + $c;
    }
    @_ = ($sensors, $minxy, $maxxy, $x+$dx, $y+$dy, $t_x, $t_y, $dx, $dy);
    goto &check_surroundings;
}

sub is_in_range($sensors, $x, $y, $i) {
    return 0 if $i == scalar @$sensors;
    return $i + 1 if in_range($sensors->[$i], $x, $y);
    @_ = ($sensors, $x, $y, $i+1);
    goto &is_in_range;
}

sub in_range($sensor, $x, $y) {
    my $sensor_range = $sensor->[2];
    my $point_range = md($sensor->[0], [$x, $y]);
    return $sensor_range >= $point_range;
}

1;
