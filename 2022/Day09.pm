package Day09;

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
R 5
U 8
L 8
D 3
R 17
D 10
L 25
U 20
TEST_DATA
    my $data = read_file("input-09");
    return prepare_data($data);
}

sub prepare_data($data) {
    return split /\n/, $data;
}

sub part_1(@data) {
    return scalar keys get_the_tail_positions([@data], { hx=> 0, hy =>0, tx => 0,ty =>0 }, {'0,0' => 1})->%*;
}

sub get_the_tail_positions($instructions, $rope, $tail_positions) {
    return $tail_positions unless scalar @$instructions;
    my $instr = shift @$instructions;
    my ($dir, $amount) = split / /, $instr;
    move($rope, $tail_positions, $dir, $amount);
    goto &get_the_tail_positions;
}

sub move($rope, $tail_positions, $dir, $amount) {
    return if $amount == 0;
    move_head($rope, $dir);
    tail_head($rope, $tail_positions);
    @_ = ($rope, $tail_positions, $dir, $amount-1);
    goto &move;
}

my %moves = (
    R => { hx => 1, hy => 0},
    L => { hx => -1, hy => 0},
    U => { hx => 0, hy => 1},
    D => { hx => 0, hy => -1}
);

sub move_head($rope, $dir) {
    my $move = $moves{$dir};
    $rope->{$_} += $move->{$_} for keys %$move;
}

sub tail_head($rope, $tail_positions) {
    return if close_enough($rope);
    my $dir_y = $rope->{hy} - $rope->{ty};
    $rope->{ty} += $dir_y/abs($dir_y) if $dir_y;
    my $dir_x = $rope->{hx} - $rope->{tx};
    $rope->{tx} += $dir_x/abs($dir_x) if $dir_x;
    $tail_positions->{"$rope->{tx},$rope->{ty}"}++;
}

sub close_enough($rope) {
    return abs($rope->{hx}-$rope->{tx}) < 2 && abs($rope->{hy}-$rope->{ty}) < 2;
}

sub make_el() {
    { hx=> 0, hy =>0, tx => 0,ty =>0 }
}

sub make_tail() {
    {'0,0' => 1}
}

sub mk_arr($arr, $maker_sub, $i) {
    return $arr if $i == 0;
    push @$arr, $maker_sub->();
    @_ = ($arr, $maker_sub, $i - 1);
    goto &mk_arr;
}

sub part_2(@data) {
    return scalar keys get_the_tail_positions_arr(
      [@data],
      mk_arr([], sub { { hx=> 0, hy =>0, tx => 0,ty =>0 } }, 9), 
      mk_arr([], sub { {'0,0' => 1} }, 9) 
    )->[8]->%*;
}

sub get_the_tail_positions_arr($instructions, $rope, $tail_positions) {
    return $tail_positions unless scalar @$instructions;
    my $instr = shift @$instructions;
    my ($dir, $amount) = split / /, $instr;
    move_arr($rope, $tail_positions, $dir, $amount);
    goto &get_the_tail_positions_arr;
}

sub move_arr($rope, $tail_positions, $dir, $amount) {
    return if $amount == 0;
    move_arr_inner($rope, $tail_positions, $dir, 0);
    @_ = ($rope, $tail_positions, $dir, $amount-1);
    goto &move_arr;
}

sub move_arr_inner($rope, $tail_positions, $dir, $i) {
    return unless defined $rope->[$i];
    if ( $i > 0 ) {
        return if $rope->[$i]->{hx} == $rope->[$i-1]->{tx} && $rope->[$i]->{hy} == $rope->[$i-1]->{hy};
        $rope->[$i]->{hx} = $rope->[$i-1]->{tx};
        $rope->[$i]->{hy} = $rope->[$i-1]->{ty};
    } else {
        move_head($rope->[0], $dir);
    }
    tail_head($rope->[$i], $tail_positions->[$i]);
    @_ = ($rope, $tail_positions, $dir, $i+1);
    goto &move_arr_inner;
}

1;
