package DayTHE_DAY;

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
{test-data}
TEST_DATA
    my $data = read_file("input-THE_DAY");
    return prepare_data($data);
}

sub prepare_data($data) {
    return split /\n/, $data;
}

sub part_1(@data) {
    return 0;
}

sub part_2(@data) {
    return 0;
}

1;
