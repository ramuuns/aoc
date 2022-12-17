package Day17;

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
>>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>
TEST_DATA
    my $data = read_file("input-17");
    return prepare_data($data);
}

sub prepare_data($data) {
    $data =~ s/\s//g;
    return split //, $data;
}

sub shapes() {
    [
      { 
        id => 0,
        h => 1,
        shape => [0b0011110],
      },
      {
        id => 1,
        h => 3,
        shape =>
        [0b0001000,
         0b0011100,
         0b0001000],
     },
     {
       id => 2,
       h => 3,
       shape =>
        [0b0011100, 
         0b0000100,
         0b0000100],
     },
     {
       id => 3,
       h => 4,
       shape =>
        [0b0010000,
         0b0010000,
         0b0010000,
         0b0010000]
    },
    {
      id => 4,
      h => 2,
      shape => 
        [0b0011000, 
         0b0011000]
    }
   ]
}

sub part_1(@moves) {
    my $b = do_the_tetris(\@moves, 0, shapes(), 0, 2022, { found_cycle => 0, skips => 0, min_y => 0, width => 7, height => 0, board => [] });
    say $b->{skips} - 1;
    return $b->{height} + ($b->{skips} - 1) * $b->{cycle_height};
}

use Data::Dumper;

sub do_the_tetris($moves, $move_idx, $shapes, $shape_idx, $max_shapes, $board) {
    return $board if $shape_idx == $max_shapes;
    my @shape = $shapes->[$shape_idx%5]->{shape}->@*;
    #print_shape(\@shape);
    $move_idx = move_until_stops($moves, $move_idx, \@shape, $board, 3);
    unless ($board->{found_cycle} ) {
    my $cycle_height = check_for_cycle($board, $shape_idx % 5, $shape_idx);
        if ( $cycle_height ) {
            $board->{cycle_height} = $cycle_height;
            #say $shape_idx;
            say "incrementing cycle";
            $shape_idx = inc_cycle($max_shapes, $board, $shape_idx, $shape_idx);
            #say Dumper($board);
            #say $shape_idx;
        }
    }
    #say Dumper($board);
    @_ = ($moves, $move_idx, $shapes, $shape_idx + 1, $max_shapes, $board);
    goto &do_the_tetris;
}

sub inc_cycle($max_shapes, $board, $shape_idx, $p_shape_idx) {
    $board->{skips} = int(($max_shapes - $shape_idx) / $board->{cycle_size});
    return $shape_idx + ($board->{skips} - 1) * $board->{cycle_size};
}

sub move_until_stops($moves, $move_idx, $shape, $board, $y) {
    push_shape($moves->[$move_idx], $shape, $board, $y);

    #print_board_with_shape($board, $shape, $y);
    if ( is_blocked($y-1, $shape, $board) ) {
        add_to_board($board, $shape, $y);
        return (($move_idx + 1) % scalar @$moves);
    }
    @_ = ($moves, ($move_idx + 1) % scalar @$moves, $shape, $board, $y-1);
    goto &move_until_stops;
}

sub push_shape($move, $shape, $board, $y) {
#say $move;
    if ( $move eq '<' ) {
        my $not_ok = 0;
        $not_ok += $_ & 0b1000000 for @$shape;
        return if $not_ok;
        my $new_shape = [map { $_ << 1 } @$shape];
        $board->{board}[$board->{height} + $y + $_] //= 0 for 0..((scalar @$shape) - 1);
        $not_ok += ($board->{board}[$board->{height} + $y + $_] // 0) & $new_shape->[$_] for 0..((scalar @$shape) - 1);
        return if $not_ok;
        $shape->[$_] = $new_shape->[$_] for 0..((scalar @$shape) - 1);
    } else {
        my $not_ok = 0;
        $not_ok += $_ & 0b1 for @$shape;
        return if $not_ok;
        my $new_shape = [map { $_ >> 1 } @$shape];
        $board->{board}[$board->{height} + $y + $_] //= 0 for 0..((scalar @$shape) - 1);
        $not_ok += ($board->{board}[$board->{height} + $y + $_] // 0) & $new_shape->[$_] for 0..((scalar @$shape) - 1);
        return if $not_ok;
        $shape->[$_] = $new_shape->[$_] for 0..((scalar @$shape) - 1);
    }
}

sub is_blocked($y, $shape, $board) {
#say "checking if $y, $x is blocked";
    return 0 if $y > 0;
    if ( $board->{height} == 0 ) {
        return $y == -1;
    }
    return 1 if $board->{height} + $y == -1;
    my $is_blocked = 0;
    $board->{board}[$board->{height} + $y + $_] //= 0 for 0..((scalar @$shape) - 1);
    $is_blocked += ($board->{board}[$board->{height} + $y + $_] // 0) & $shape->[$_] for 0..((scalar @$shape) - 1);
    return $is_blocked;
}

sub print_shape($shape) {
    say "--- shape ---";
    for my $line ( reverse @$shape ) {
        my $str = "|";
        my $mask = 0b1000000;
        while ( $mask ) {
            $str .= $mask & $line ? "#" : " ";
            $mask = $mask >> 1;
        }
        $str .= "|";
        say $str;
    }
    say "--end shape--";
}

sub check_for_cycle($board, $shape_id, $shape_idx) {
    my $b = $board->{board};
    $board->{at_end_of_each} //= [];
    $board->{last_seen_at} //= {};
    my $index = $board->{height} - 1;
    my $value = $b->[$index];
    my $hash_key = "$shape_id|$value";
    push $board->{at_end_of_each}->@*, [$value, $shape_idx, $shape_id, $board->{height}];
    if ( ! $board->{maybe_a_loop} ) {
        if ($board->{last_seen_at}{$hash_key}) {
            $board->{cycle_start} = $board->{last_seen_at}{$hash_key};
            $board->{cycle_size} = $shape_idx - $board->{cycle_start};
            $board->{maybe_a_loop} = 1;
        }
    } else {
        my ($prev_value, $prev_idx, $p_shape_id, $prev_height) = $board->{at_end_of_each}[$shape_idx - $board->{cycle_size}]->@*;
        if ( $prev_value != $value || $shape_id != $p_shape_id ) {
            $board->{maybe_a_loop} = 0;
        } else {
            if ( $shape_idx - 2*$board->{cycle_size} == $board->{cycle_start} ) {
              #say Dumper($board->{at_end_of_each}[$shape_idx - $board->{cycle_size}]);
        #say "cycle size: $board->{cycle_size}, height:".($board->{height} - $prev_height);
                $board->{found_cycle} = 1; 
                return $board->{height} - $prev_height;
            }
        }
    }
    $board->{last_seen_at}{$hash_key} = $shape_idx;
    return 0;
}

sub print_board_with_shape($board, $shape, $y) {
    say "--board-with-shape--";
    if ( $board->{height} == 0 ) {
        print_shape($shape);
    } else {
        for my $i (reverse 0..(scalar @$shape)) {
            my $str = "|";
            my $mask = 0b1000000;
            my $s = $i > 0 ? $shape->[$i - 1] : 0;
            my $bs = $board->{board}[ $board->{height} - 1 + $y + $i ] // 0;
            while ($mask) {
                $str.= $mask & $s ? '@' : ($mask & $bs ? '#' : '.');
                $mask = $mask >> 1;
            }
            $str .= '|';
            say $str;
        } 
    }
    say "--end-board-with-shape--";
    say "";
}

sub print_board($board) {
    for my $line (reverse $board->{board}->@*) {
        my $str = "|";
        my $mask = 0b1000000;
        while ( $mask ) {
            $line //= 0;
            $str .= $mask & $line ? "#" : ".";
            $mask = $mask >> 1;
        }
        $str .= "|";
        say $str;
    }
    say "+-------+";
    say "";
}

sub add_to_board($board, $shape, $y) {
    $board->{min_y} //= 0;
    $board->{min_y} = $y if $y < $board->{min_y};
    my $h = $board->{height};
    if ( $h == 0 ) {
        $board->{board}[$_] = $shape->[$_] for 0..((scalar @$shape) - 1);
        $board->{height} = scalar @$shape;
    } else {
        $board->{board}[$h + $y + $_] //= 0 for 0..((scalar @$shape) - 1);
        $board->{board}[$h + $y + $_] |= $shape->[$_] for 0..((scalar @$shape) - 1);
        $board->{height} += $y + scalar @$shape unless ($y + scalar @$shape) < 0;
    }
    #print_board($board);
}

sub part_2(@moves) {
    my $b = do_the_tetris(\@moves, 0, shapes(), 0, 1_000_000_000_000, { found_cycle => 0, skips => 0, min_y => 0, width => 7, height => 0, board => [] });
    return $b->{height} + ($b->{skips} - 1)  * $b->{cycle_height};
}

1;
