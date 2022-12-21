package Day21;

use 5.30.0;
use strict;
use warnings;
use feature "signatures";
no warnings "experimental::signatures";


use Scalar::Util qw(looks_like_number);
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
root: pppw + sjmn
dbpl: 5
cczh: sllz + lgvd
zczc: 2
ptdq: humn - dvpt
dvpt: 3
lfqf: 4
humn: 5
ljgn: 2
sjmn: drzm * dbpl
sllz: 4
pppw: cczh / lfqf
lgvd: ljgn * ptdq
drzm: hmdt - zczc
hmdt: 32
TEST_DATA
    my $data = read_file("input-21");
    return prepare_data($data);
}

sub prepare_data($data) {
    return split /\n/, $data;
}

sub part_1(@data) {
    my %hash = map { split /: /, $_ } @data;
    evaluate_hash(\%hash, [ 'root' ]);
    return $hash{root};
}

sub is_number($value) {
    return looks_like_number($value);
}

sub evaluate_hash($hash, $stack){
    return unless scalar @$stack;
    my $key = pop @$stack;
    unless ( is_number($hash->{$key}) ) {
        my ($key_a, $op, $key_b) = split / /, $hash->{$key};
        if ( is_number($hash->{$key_a}) && is_number($hash->{$key_b}) ) {
            $hash->{$key} = eval "$hash->{$key_a} $op $hash->{$key_b}";
        } else {
            push @$stack, $key;
            push @$stack, $key_a unless is_number($hash->{$key_a});
            push @$stack, $key_b unless is_number($hash->{$key_b});
        }
    }
    goto &evaluate_hash;
}

sub part_2(@data) {
    my %hash = map { split /: /, $_ } @data;
    return binary_search_for_x(\@data, 0, $hash{humn});

}

sub binary_search_for_x($data, $x1, $x2) {
    my $delta_x = abs($x2 - $x1);
    return $x1 if $x1 == $x2;
    my %hash_1 = map { split /: /, $_ } @$data;
    my %hash_2 = map { split /: /, $_ } @$data;
    $hash_1{humn} = $x1;
    $hash_2{humn} = $x2;
    my ($left, $meh, $right) = split / /, $hash_1{root};
    evaluate_hash(\%hash_1, [ $left, $right ]);
    evaluate_hash(\%hash_2, [ $left, $right ]);
    return $x1 if $hash_1{$left} == $hash_1{$right};
    return $x2 if $hash_2{$left} == $hash_2{$right};
    my $y_key = $hash_1{$left} == $hash_2{$left} ? $right: $left;
    my $tgt = $hash_1{$left} == $hash_2{$left} ? $hash_1{$left} : $hash_1{$right};
    my $y1 = $hash_1{$y_key};
    my $y2 = $hash_2{$y_key};
    
    if (  ($y1 < $tgt && $y2 > $tgt) || ($y2 < $tgt && $y1 > $tgt ) ) {
        my $delta_y1 = abs($y1 - $tgt);
        my $delta_y2 = abs($y2 - $tgt);
        if ( $delta_y1 < $delta_y2 ) {
            $x2 = int( $x1 + abs($x2 - $x1)/2 );
        } else {
            $x1 = int( $x1 + abs($x2 - $x1)/2 );
        }
    } else {
        my $delta_y1 = abs($y1 - $tgt);
        my $delta_y2 = abs($y2 - $tgt);
        if ( $delta_y1 < $delta_y2 ) {
            $x2 = $x1;
            $x1 = $x1 - $delta_x * 2;
        } else {
            $x1 = $x2;
            $x2 = $x2 + $delta_x * 2;
        }
    }
    @_ = ($data, $x1, $x2);
    goto &binary_search_for_x;
}

1;
