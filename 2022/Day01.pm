package Day01;

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
1000
2000
3000

4000

5000
6000

7000
8000
9000

10000
TEST_DATA
    my $data = read_file("input-01");
    return prepare_data($data);
}

sub prepare_data($data) {
    return split /\n/, $data;
}

sub part_1(@data) {
    return find_max_calories(0, 0, @data);
}

sub part_2(@data) {
    return find_top_three_calories([0,0,0], 0, @data);
}

sub find_max_calories {
    my ($max, $this_elf, $item, @rest) = @_;
    return $this_elf > $max ? $this_elf : $max unless defined $item;
    @_ = (
      $item eq "" ? ($max > $this_elf ? $max : $this_elf) : $max,
      $item eq "" ? 0 : $this_elf + $item, 
      @rest);
    goto &find_max_calories;
}

sub find_top_three_calories {
    my ($top3, $this_elf, $item, @rest) = @_;
    return array_sum(top_three($this_elf, @$top3)) unless defined $item;
    @_ = (
      $item eq "" ? [top_three($this_elf, @$top3)] : $top3,
      $item eq "" ? 0 : $this_elf + $item,
      @rest
    );
    goto &find_top_three_calories;
}

sub top_three(@data) {
    my @sorted = sort { $b <=> $a } @data;
    return @sorted[0..2];
}

sub array_sum {
    my ($total, $item, @rest) = @_;
    return $total unless defined $item;
    @_ = ($total + $item, @rest);
    goto &array_sum;
}

1;
