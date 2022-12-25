#!/usr/bin/perl

use 5.30.0;
use strict;
use warnings;
use feature "signatures";
no warnings "experimental::signatures";
use Time::HiRes qw/time/;

my @arr;
push @arr, int(rand(1000)) for 1..20_000;


my $t_sum = 0;
my $n = 100;
while( $n > 0 ) {
  my $start = time;
  my $sum = 0;
  my $i = 0;
  while ( $i < scalar @arr ) {
    $sum += $arr[$i];
    $i++;
  }
  $t_sum += time - $start;
  $n--;
}

my %timings = (
    'simple_while' => $t_sum
);

$t_sum = 0;
$n = 100;

while( $n > 0 ) {
    my @arr2 = @arr;
    my $start = time;
    my $sum = 0;
    while ( scalar @arr2 ) {
        $sum += shift @arr2;
    }
    $t_sum += time - $start;
    $n--;
}

$timings{shift_while} = $t_sum;
$t_sum = 0;
$n = 100;

while( $n > 0 ) {
    my $start = time;
    my $sum = 0;
    for my $el (@arr) {
        $sum += $el;
    }
    $t_sum += time - $start;
    $n--;
}

$timings{simple_for} = $t_sum;
$t_sum = 0;
$n = 100;

while( $n > 0 ) {
    my $start = time;
    my $sum = 0;
    for (my $i = 0; $i < scalar @arr; $i++ ) {
        $sum += $arr[$i];
    }
    $t_sum += time - $start;
    $n--;
}

$timings{classic_for} = $t_sum;
$t_sum = 0;
$n = 100;

while( $n > 0 ) {
    my $start = time;
    my $sum = 0;
    for my $i (0..$#arr) {
        $sum += $arr[$i];
    }
    $t_sum += time - $start;
    $n--;
}

$timings{for_0_to_n} = $t_sum;
$t_sum = 0;
$n = 100;

sub sum_shift_arref($arr, $sum) {
    return $sum unless scalar @$arr;
    @_ = ($arr, $sum + shift @$arr);
    goto &sum_shift_arref;
}

while( $n > 0 ) {
    my $a_ref = [@arr];
    my $start = time;
    my $sum = sum_shift_arref($a_ref, 0);
    $t_sum += time - $start;
    $n--;
}

$timings{sum_shift_arref} = $t_sum;
$t_sum = 0;
$n = 100;

sub sum_arref_index($arr, $i, $sum) {
    return $sum unless $i < scalar @$arr;
    @_ = ($arr, $i+1, $sum + $arr->[$i]);
    goto &sum_arref_index;
}

while( $n > 0 ) {
    my $start = time;
    my $sum = sum_arref_index(\@arr, 0, 0);
    $t_sum += time - $start;
    $n--;
}

$timings{sum_arref_index} = $t_sum;

say "$_->[0] : $_->[1]" for sort { $b->[1] <=> $a->[1] } map { [$_, $timings{$_} ] } keys %timings;
