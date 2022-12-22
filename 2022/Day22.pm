package Day22;

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
      part_2(read_input($mode))
    ];
}

sub read_input($mode) {
    return prepare_data(<<TEST_DATA) if $mode eq "test";
        ...#
        .#..
        #...
        ....
...#.......#
........#...
..#....#....
..........#.
        ...#....
        .....#..
        .#......
        ......#.

10R5L5R10L4R5L5
TEST_DATA
    my $data = read_file("input-22");
    return prepare_data($data);
}

sub prepare_data($data) {
    my ($raw_map, $raw_path) = split /\n\n/, $data;
    return (parse_map( [split /\n/, $raw_map], 0, { map => [], row_mm => [], col_mm => [] }), parse_moves($raw_path));
}

sub parse_map($rows, $y, $map) {
    return $map if $y == scalar @$rows;
    my $row = [split //, $rows->[$y] ];
    push $map->{map}->@*, $row;
    $map->{row_mm}[$y] = [0,0];
    update_min_max($map, $row, $y, 0);
    @_ = ($rows, $y + 1, $map);
    goto &parse_map;
}

sub update_min_max($map, $row, $y, $x) {
    return if $x == scalar @$row;
    $map->{col_mm}[$x] //= [$y,$y];
    if ( $row->[$x] eq " " ) {
        if ( $map->{row_mm}[$y][0] == $map->{row_mm}[$y][1] ) {
            $map->{row_mm}[$y][0]++;
            $map->{row_mm}[$y][1]++;
        }
        if ( $map->{col_mm}[$x][0] == $map->{col_mm}[$x][1] ) {
            $map->{col_mm}[$x][0]++;
            $map->{col_mm}[$x][1]++;
        }
    } else {
        $map->{row_mm}[$y][1]++;
        $map->{col_mm}[$x][1]++;
    }
    @_ = ($map, $row, $y, $x+1);
    goto &update_min_max;
}

sub parse_moves($raw_path) {
    $raw_path =~ s/\s+//;
    my @moves = split /L|R/, $raw_path;
    my @turns = split //, $raw_path =~ s/\d//gr;
    return [\@moves, \@turns];
}

sub dir_to_dx($dir) {
    state %d_to_d = (
        E => 1,
        W => -1,
        N => 0,
        S => 0,
    );
    return $d_to_d{$dir};
}

sub dir_to_dy($dir) {
    state %d_to_d = (
        E => 0,
        W => 0,
        N => -1,
        S => 1,
    );
    return $d_to_d{$dir};
}

sub next_dir($dir, $turn) {
    state %dirs = (
      R => {
        N => 'E',
        E => 'S',
        S => 'W',
        W => 'N'
      },
      L => {
        N => 'W',
        W => 'S',
        S => 'E',
        E => 'N'
      }
    );
    return $dirs{$turn}->{$dir};
}

sub dir_to_idx($dir) {
    my %d_to_i = (
        E => 0,
        S => 1,
        W => 2,
        N => 3
    );
    return $d_to_i{$dir};
}

use Data::Dumper;

my $path = [];
sub part_1($map, $moves_and_turns) {
    my $x = $map->{row_mm}[0][0];
    my $y = 0;
    my $dir = 'E';
    my $pos = {
        x => $x,
        y => $y,
        dir => $dir
    };
    do_the_moves($map, $moves_and_turns, $pos, 0);
    return ($pos->{y} + 1) * 1_000 + ($pos->{x} +1) * 4 + dir_to_idx($pos->{dir});
}

sub do_the_moves($map, $moves_and_turns, $pos, $cube) {
    my $move_amount = shift $moves_and_turns->[0]->@*;
    move_until_a_wall($map, $pos, $move_amount, $cube);
    return unless scalar $moves_and_turns->[1]->@*;
    my $turn = shift $moves_and_turns->[1]->@*;
    $pos->{dir} = next_dir($pos->{dir}, $turn);
    goto &do_the_moves;
}

sub move_until_a_wall($map, $pos, $move_amount, $cube) {
    return unless $move_amount;
    my $dx = dir_to_dx($pos->{dir});
    my $dy = dir_to_dy($pos->{dir});
    my $next_dir = $pos->{dir};
    my $next_x = $pos->{x} + $dx;
    my $next_y = $pos->{y} + $dy;
    my $say = 0;
    if ( $cube ) {
        if ( $dx == 1 && $next_x >= $map->{row_mm}[$pos->{y}][1] ) {
            my $face = int($pos->{y} / 50);
            if ( $face % 2 == 0 ) {
                $next_y = 149 - $pos->{y};
                $next_x = $map->{row_mm}[$next_y][1] - 1;
                $next_dir = 'W';
            } else {
                my $offset = $map->{col_mm}[$next_x][1];
                $next_x = $pos->{y} - $offset + $map->{row_mm}[$next_y][1];
                $next_y = $offset - 1;
                $next_dir = 'N';
            }
        } elsif ( $dx == -1 && $next_x < $map->{row_mm}[$pos->{y}][0] ) {
            my $face = int($pos->{y} / 50);
            if ( $face % 2 == 0 ) {
                $next_y = 149 - $pos->{y};
                $next_x = $map->{row_mm}[$next_y][0];
                $next_dir = 'E';
            } elsif ( $face == 1 ) {
                $next_x = $pos->{y} - 50;
                $next_y = $map->{col_mm}[$next_x][0];
                $next_dir = 'S';
            } else {
                $next_x = $pos->{y} - 100;
                $next_y = $map->{col_mm}[$next_x][0];
                $next_dir = 'S';
            }
        } elsif ( $dy == 1 && $next_y >= $map->{col_mm}[$pos->{x}][1] ) {
            my $face = int($pos->{x} / 50);
            if ( $face == 0 ) {
                $next_y = 0;
                $next_x = $next_x + 100;
            } else {
                my $offset = $map->{row_mm}[$next_y][1];
                $next_x = $offset - 1;
                $next_y = $pos->{x} - $offset + $map->{col_mm}[$pos->{x}][1];
                $next_dir = 'W';
            }
        } elsif ( $dy == -1 && $next_y < $map->{col_mm}[$pos->{x}][0] ) {
            my $face = int($pos->{x} / 50);
            if ( $face == 2 ) {
                $next_x = $next_x - 100;
                $next_y = $map->{col_mm}[0][1] - 1;

            } elsif ( $face == 0 ) {
                $next_y = $pos->{x} + 50;
                $next_x = $map->{row_mm}[$next_y][0];
                $next_dir = 'E';
            } else {
                $next_y = $pos->{x} + 100;
                $next_x = $map->{row_mm}[$next_y][0];
                $next_dir = 'E';
            }
        }
    } else {
        if ( $dx ) {
            if ( $dx == 1 && $next_x >= $map->{row_mm}[$pos->{y}][1] ) {
                $next_x = $map->{row_mm}[$pos->{y}][0];
            } elsif ( $dx == -1 && $next_x < $map->{row_mm}[$pos->{y}][0] ) {
                $next_x = $map->{row_mm}[$pos->{y}][1] - 1;
            }
        } else {
            if ( $dy == 1 && $next_y >= $map->{col_mm}[$pos->{x}][1] ) {
                $next_y =  $map->{col_mm}[$pos->{x}][0];
            } elsif ( $dy == -1 && $next_y < $map->{col_mm}[$pos->{x}][0] ) {
                $next_y = $map->{col_mm}[$pos->{x}][1] - 1;
            }
        }
    }
    #say "attemting to go to $next_y, $next_x";
    #say "attempting to go from $pos->{y}, $pos->{x} ($pos->{dir})  to $next_y, $next_x ($next_dir)" if $say;
    #die Dumper($pos) unless $map->{map}[$next_y][$next_x];
    #die Dumper($pos) if $map->{map}[$next_y][$next_x] eq ' ';
    #print_path($map, $path) if $cube && $map->{map}[$next_y][$next_x] eq '#';
    return if $map->{map}[$next_y][$next_x] eq '#';
    $pos->{x} = $next_x;
    $pos->{y} = $next_y;
    $pos->{dir} = $next_dir;

    push @$path, { x => $next_x, y => $next_y, dir => $next_dir };
    @_ = ($map, $pos, $move_amount - 1, $cube);
    goto &move_until_a_wall;
}


sub part_2($map, $moves_and_turns) {
    my $x = $map->{row_mm}[0][0];
    my $y = 0;
    my $dir = 'E';
    my $pos = {
        x => $x,
        y => $y,
        dir => $dir
    };
    $path = [];
    do_the_moves($map, $moves_and_turns, $pos, 1);

    # print_path($map, $path);
    return ($pos->{y} + 1) * 1_000 + ($pos->{x} +1) * 4 + dir_to_idx($pos->{dir});
}

sub print_path($map, $path) {
    my %d_to_p = (
        N => '^',
        E => '>',
        S => 'V',
        W => '<'
    );
    $map->{map}[$_->{y}][$_->{x}] = $d_to_p{$_->{dir}} for @$path;
    say join '', $_->@* for $map->{map}->@*;
}

1;
