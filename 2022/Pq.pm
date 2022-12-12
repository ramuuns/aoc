package Pq;

use 5.30.0;
use strict;
use warnings;
use feature "signatures";
no warnings "experimental::signatures";

use Exporter 'import';
our @EXPORT_OK =qw/
    pq_push
    pq_pop
/;

sub min($arr, $min) {
    return $min unless scalar @$arr;
    my $item = shift @$arr;
    $min = $item unless defined $min;
    $min = $item if $item < $min;
    @_ = ($arr, $min);
    goto &min;
}

sub pq_push($pq, $prio, $value) {
    $pq->{heap} //= [];
    heap_add($pq->{heap}, [$prio, $value]);
    return $pq;
}

sub heap_add($heap, $item) {
    push @$heap, $item;
    heap_add_inner($heap, $item, scalar @$heap - 1);
}
use Data::Dumper();

sub heap_add_inner($heap, $item, $index) {
    return if $index == 0;
    my $parent = int(($index-1)/2);
    return if $heap->[$parent]->[0] < $item->[0];
    $heap->[$index] = $heap->[$parent];
    $heap->[$parent] = $item;
    @_ = ($heap, $item, $parent);
    goto &heap_add_inner;
}

sub heap_shift($heap) {
    my $min = $heap->[0];
    my $value = pop @$heap;
    return $value unless scalar @$heap;
    $heap->[0] = $value;
    heapify($heap, 0, scalar @$heap);
    return $min;
}

sub heapify($heap, $index, $heap_size) {
    my $left = $index * 2 + 1;
    my $right = $index * 2 + 2;
    my $min_index = $index;
    $min_index = $left if $left < $heap_size && $heap->[$left]->[0] < $heap->[$index]->[0];
    $min_index = $right if $right < $heap_size && $heap->[$right]->[0] < $heap->[$index]->[0];
    return if $min_index == $index;
    my $tmp = $heap->[$index];
    $heap->[$index] = $heap->[$min_index];
    $heap->[$min_index] = $tmp;
    @_ = ($heap, $min_index, $heap_size);
    goto &heapify;
}

sub pq_pop($pq) {
    return undef unless scalar $pq->{heap}->@*;
    my ($_whatevs, $item) = heap_shift($pq->{heap})->@*;
    return $item;
}

1;
