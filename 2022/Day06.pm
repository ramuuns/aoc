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

sub first_different($data, $i, $closest_duplicate_offset, $min_size) {
    $closest_duplicate_offset = find_closest_duplicate_offset($data, $i, $closest_duplicate_offset + 1, 1, $min_size);
    return $i + 1 if  $i > $min_size && $closest_duplicate_offset > $min_size;
    @_ = ($data, $i+1, $closest_duplicate_offset, $min_size);
    goto &first_different;
}

sub find_closest_duplicate_offset($data, $i, $old_offset, $new_offset, $min_size) {
    return $old_offset if ($i - $new_offset) < 0;
    return $old_offset if $old_offset < $new_offset;
    return $new_offset if $data->[$i] eq $data->[$i - $new_offset];
    return $old_offset if $new_offset == $min_size;
    @_ = ($data, $i, $old_offset, $new_offset + 1, $min_size);
    goto &find_closest_duplicate_offset;
}

1;
