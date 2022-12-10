package Day10;

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
addx 15
addx -11
addx 6
addx -3
addx 5
addx -1
addx -8
addx 13
addx 4
noop
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx -35
addx 1
addx 24
addx -19
addx 1
addx 16
addx -11
noop
noop
addx 21
addx -15
noop
noop
addx -3
addx 9
addx 1
addx -3
addx 8
addx 1
addx 5
noop
noop
noop
noop
noop
addx -36
noop
addx 1
addx 7
noop
noop
noop
addx 2
addx 6
noop
noop
noop
noop
noop
addx 1
noop
noop
addx 7
addx 1
noop
addx -13
addx 13
addx 7
noop
addx 1
addx -33
noop
noop
noop
addx 2
noop
noop
noop
addx 8
noop
addx -1
addx 2
addx 1
noop
addx 17
addx -9
addx 1
addx 1
addx -3
addx 11
noop
noop
addx 1
noop
addx 1
noop
noop
addx -13
addx -19
addx 1
addx 3
addx 26
addx -30
addx 12
addx -1
addx 3
addx 1
noop
noop
noop
addx -9
addx 18
addx 1
addx 2
noop
noop
addx 9
noop
noop
noop
addx -1
addx 2
addx -37
addx 1
addx 3
noop
addx 15
addx -21
addx 22
addx -6
addx 1
noop
addx 2
addx 1
noop
addx -10
noop
noop
addx 20
addx 1
addx 2
addx 2
addx -6
addx -11
noop
noop
noop
TEST_DATA
    my $data = read_file("input-10");
    return prepare_data($data);
}

sub prepare_data($data) {
    return split /\n/, $data;
}

sub part_1(@data) {
    return funky_cycle_values( [@data], 1, 1, 0 , 20, 0 );
}

sub funky_cycle_values($instrs, $regx, $cycle, $sum, $next_cycle, $to_add ) {
    return $sum unless @$instrs;
    if ( $cycle >= $next_cycle ){
        $sum += $next_cycle * ($regx + ( $cycle == $next_cycle ? $to_add : 0 ));
        $next_cycle += 40;
    }
    my $instr = shift @$instrs;
    $regx += $to_add; 
    if ( $instr =~ /addx (-?\d+)/ ) {
        $to_add = $1;
    } else {
        $to_add = 0;
    }
    @_ = ( $instrs, $regx, $cycle + ($instr eq 'noop' ? 1 : 2), $sum, $next_cycle, $to_add);
    goto &funky_cycle_values;
}

sub part_2(@data) {
    return join "", crt_render([@data], 1, 1, 0, 1, 0,[])->@*;
}

sub crt_render($data, $cycle, $regx, $to_add, $at_cycle, $crt_pos, $ret) {
    return $ret unless scalar @$data;
    $regx += $to_add if $cycle == $at_cycle;
    push @$ret, "\n" if $cycle % 40 == 1;
    if ( $crt_pos >= $regx -1 && $crt_pos <= $regx + 1) {
      push @$ret, '#';
    } else {
      push @$ret, '.';
    }
    
    if ($cycle == $at_cycle) {
        my $instr = shift @$data;
        if ( $instr =~ /addx (-?\d+)/ ) {
            $to_add = $1;
            $at_cycle=$cycle + 2; 
        } else {
            $to_add = 0;
            $at_cycle= $cycle + 1;
        }
    }
    @_ = ($data, $cycle + 1, $regx, $to_add, $at_cycle, ($crt_pos + 1) %40, $ret);
    goto &crt_render;
}
1;
