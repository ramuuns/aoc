package Day25;

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
1=-0-2
12111
2=0=
21
2=01
111
20012
112
1=-1=
1-12
12
1=
122
TEST_DATA
    my $data = read_file("input-25");
    return prepare_data($data);
}

sub prepare_data($data) {
    return split /\n/, $data;
}

sub part_1(@data) {
    return sum_snafu(\@data, 0);
}

sub make_snafu($num, $snafu) {
    return join "", reverse @$snafu unless $num;
    my $digit = $num % 5;
    if ( $digit == 3 ) {
        $digit = '=';
    } elsif ($digit == 4 ) {
        $digit = '-';
    }
    push @$snafu, $digit;
    @_ = (int(($num + 2) / 5), $snafu);
    goto &make_snafu;
}

sub sum_snafu($data, $sum) {
    return make_snafu($sum, []) unless scalar @$data;
    my @digit_rev = reverse split //, shift @$data;
    @_ = ($data, $sum + convert_from_snafu(\@digit_rev, 0, 1));
    goto &sum_snafu;
}

sub convert_from_snafu($digits, $sum, $pow) {
    return $sum unless scalar @$digits;
    my $digit = shift @$digits;
    if ( $digit eq '-' ) {
        $digit = -1;
    } elsif ( $digit eq '=' ) {
        $digit = -2;
    }
    @_ = ($digits, $sum + $pow * $digit, $pow * 5);
    goto &convert_from_snafu;
}

sub part_2(@data) {
    return 0;
}

1;
