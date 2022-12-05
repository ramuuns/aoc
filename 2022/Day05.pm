package Day05;

use 5.30.0;
use strict;
use warnings;
use feature "signatures";
no warnings "experimental::signatures";

use File::Slurp;

sub run($mode) {
    return [
      part_1(read_input($mode)),
      part_2(read_input($mode))
    ];
}

sub read_input($mode) {
    return prepare_data(<<TEST_DATA) if $mode eq "test";
    [D]    
[N] [C]    
[Z] [M] [P]
 1   2   3 

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2
TEST_DATA
    my $data = read_file("input-05");
    return prepare_data($data);
}

sub prepare_data($data) {
    return prepare_inner([split /\n/, $data], []);
}

sub prepare_inner($data, $stacks) {
    my $item = shift @$data;
    if ($item =~ /^ 1/) {
        shift @$data;
        return ($stacks, $data);
    }
    my @line = split //, $item;
    unshift_multiple(\@line, scalar @line, 0, $stacks);
    goto &prepare_inner;
}

sub unshift_multiple($line, $len, $idx, $stacks) {
    return if $idx * 4 + 1 > $len;
    my $char = $line->[$idx*4+1];
    if ( $char ne " " ) {
      $stacks->[$idx] //= [];
      unshift $stacks->[$idx]->@*, $char;
    }
    @_ = ($line, $len, $idx+1, $stacks);
    goto &unshift_multiple;
}

sub part_1($stacks, $instr) {
    return join "", stack_top( move_crates($instr, $stacks, 0));
}

sub move_crates($instr, $stacks, $retain){
    return $stacks unless scalar @$instr;
    my $line = shift @$instr;
    $line =~ m/^move (\d+) from (\d+) to (\d+)/;
    my ($amount, $src, $dest) = ($1, $2-1, $3-1);
    do_the_move_retain($stacks, $amount, $src, $dest, []) if $retain;
    do_the_move($stacks, $amount, $src, $dest) unless $retain;
    goto &move_crates;
}

sub stack_top($stacks) {
    return map { pop $_->@* } @$stacks;
}

sub do_the_move($stacks, $amount, $src, $dest) {
    return unless $amount;
    my $item = pop $stacks->[$src]->@*;
    push $stacks->[$dest]->@*, $item;
    @_ = ($stacks, $amount-1, $src, $dest);
    goto &do_the_move;
}

sub do_the_move_retain($stacks, $amount, $src, $dest, $temp) {
    return if $amount == 0 && scalar @$temp == 0;
    if ( $amount == 0 ) {
      my $item = pop @$temp;
      push $stacks->[$dest]->@*, $item;
    } else {
      my $item = pop $stacks->[$src]->@*;
      push @$temp, $item;
      @_ = ($stacks, $amount-1, $src, $dest, $temp);
    }
    goto &do_the_move_retain;
}

sub part_2($stacks, $instr) {
    return join "", stack_top( move_crates($instr, $stacks, 1));
}

1;
