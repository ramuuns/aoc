package Day06;

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
zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw
TEST_DATA
    my $data = read_file("input-06");
    return prepare_data($data);
}

sub prepare_data($data) {
    return split //, $data;
}

sub part_1(@data) {
    return first_different(\@data, 0, 0, 4 - 1);
}

sub part_2(@data) {
    return first_different(\@data, 0, 0, 14 - 1);
}

sub first_different($data, $i, $duplicate_distance, $min_size) {
    my $new_dd = find_new_dd($data, $i, $duplicate_distance, 1, $min_size);
    return $i + 1 if  $i > $min_size && $new_dd > $min_size;
    @_ = ($data, $i+1, $new_dd, $min_size);
    goto &first_different;
}

sub find_new_dd($data, $i, $dd, $newdd, $min_size) {
    return $dd + 1 if ($i - $newdd) < 0;
    return $dd + 1 if ($dd + 1) < $newdd;
    return $newdd if $data->[$i] eq $data->[$i - $newdd];
    return $dd + 1 if $newdd == $min_size;
    @_ = ($data, $i, $dd, $newdd + 1, $min_size);
    goto &find_new_dd;
}

1;
