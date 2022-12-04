package Day04;

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
2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8
TEST_DATA
    my $data = read_file("input-04");
    return prepare_data($data);
}

sub prepare_data($data) {
    return map { [ map { [split /-/, $_] } split /,/, $_] } split /\n/, $data;
}

sub part_1(@data) {
    return count_fully_contained([@data], 0);
}

sub part_2(@data) {
    return count_overlaps([@data], 0);
}
sub count_fully_contained($data, $count) {
    return $count unless scalar @$data;
    my $item = shift @$data;
    my ($first, $second) = @$item;
    @_ = (
      $data,
      $count + (contains_range($first, $second) || contains_range($second, $first))
    );
    goto &count_fully_contained;
}

sub contains_range($first, $second) {
    my ($st_first, $end_first) = @$first;
    my ($st_second, $end_second) = @$second;
    return $st_second >= $st_first && $end_second <= $end_first ? 1 : 0;
}

sub count_overlaps($data, $count) {
    return $count unless scalar @$data;
    my $item = shift @$data;
    my ($first, $second) = @$item;
    @_ = (
      $data,
      $count + (contains_overlap($first, $second) || contains_overlap($second, $first))
    );
    goto &count_overlaps;
}

sub contains_overlap($first, $second) {
    my ($st_first, $end_first) = @$first;
    my ($st_second, $end_second) = @$second;
    return $st_first <= $st_second && $st_second <= $end_first;
}

1;
