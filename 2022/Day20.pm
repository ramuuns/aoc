package Day20;

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
1
2
-3
3
-2
0
4
TEST_DATA
    my $data = read_file("input-20");
    return prepare_data($data);
}

sub prepare_data($data) {
    return split /\n/, $data;
}

use Data::Dumper;

sub part_1(@data) {
    my $zeroe = { value => 0 };
    my $initial = make_initial_data(\@data, [] , 0, $zeroe);
    #say Dumper($initial);
    my $mixed = mix($initial, 0, 0, 1);
    my $sum = 0;
    #say $zeroe->{index};
    my @ret = map { $_->{value} } ( $mixed->[ ($zeroe->{index} + 1000) % scalar @$mixed ],  $mixed->[ ($zeroe->{index} + 2000) % scalar @$mixed ],  $mixed->[ ($zeroe->{index} + 3000) % scalar @$mixed ] );
    #say Dumper(\@ret); 
    $sum += $_ for @ret;
    return $sum;
}

sub make_initial_data($arr, $ret, $i, $zeroe) {
    if ( $i == scalar @$arr ) {
        $ret->[$_]{prev} = $ret->[$_ - 1] for 0..($i-1);
        $ret->[$_]{next} = $ret->[($_ + 1) % $i] for 0..($i-1);
        return $ret;
    }
    push @$ret, {
        index => $i,
        value => $arr->[$i],
    } if $arr->[$i];
    if ( $arr->[$i] == 0 ) {
        push @$ret, $zeroe;
        $zeroe->{index} = $i;
    }
    @_ = ($arr, $ret, $i+1, $zeroe);
    goto &make_initial_data;
}

sub make_the_ret($arr, $i, $ret, $offset) {
    return $ret if $i == scalar @$arr;
    $ret->[($arr->[$i]->{index} - $offset ) % scalar @$arr ] = $arr->[$i];
    @_ = ($arr, $i+1, $ret, $offset);

    goto &make_the_ret;
}

sub mix($arr, $i, $offset, $rounds) {
    return make_the_ret($arr, 0, [], $offset) if $rounds == 0;
    if ( $i == scalar @$arr ) {
        @_ = ($arr, 0, $offset, $rounds - 1);
        goto &mix;
    }
    say $i if $i %500 == 0;
    my $item = $arr->[$i];
    if ( $item->{value} > 0 ) {
        $offset = shift_right($item, $item->{value} % (scalar @$arr - 1), scalar @$arr, $offset);
    } else {
        $offset = shift_left($item, -$item->{value} % (scalar @$arr - 1), scalar @$arr, $offset);
    }
    #   print_arr(make_the_ret($arr, 0, [], $offset));
    @_ = ($arr, $i+1, $offset, $rounds);
    goto &mix;
}

sub print_arr($arr) {
    say Dumper([ map { $_->{value} } @$arr ]);
}

sub shift_right($item, $amount, $mod, $offset) {
#say "moving right: by $amount";
#say "[ $item->{prev}{value}, $item->{value}, $item->{next}{value} ]";
    return $offset if $amount == 0;
    my $next = $item->{next};
    my $prev = $item->{prev};
    $prev->{next} = $next;
    $next->{prev} = $prev;
    $next->{index} = ($next->{index} - 1) % $mod;
    $item->{index} = ($item->{index} + 1) % $mod;
    #$offset -= 1 if $item->{index} == 0;

    $item->{next} = $next->{next};
    $next->{next}{prev} = $item;
    $next->{next} = $item;
    $item->{prev} = $next;
    
    @_ = ($item, $amount - 1, $mod, $offset);
    goto &shift_right;
}

sub shift_left($item, $amount, $mod, $offset) {
#say "moving left: by $amount";
#say "[ $item->{prev}{value}, $item->{value}, $item->{next}{value} ]";
    return $offset if $amount == 0;
    my $next = $item->{next};
    my $prev = $item->{prev};
    $prev->{next} = $next;
    $next->{prev} = $prev;

    $prev->{index} = ($prev->{index} + 1) % $mod;
    #$offset += 1 if $item->{index} == 0;
    $item->{index} = ($item->{index} - 1) % $mod;

    $item->{prev} = $prev->{prev};
    $prev->{prev}{next} = $item;
    $prev->{prev} = $item;
    $item->{next} = $prev;
    @_ = ($item, $amount - 1, $mod, $offset);
    goto &shift_left;
}

sub part_2(@data) {
    my $zeroe = { value => 0 };
    my $initial = make_initial_data([ map { $_ * 811589153 } @data ], [] , 0, $zeroe);
    #say Dumper($initial);
    my $mixed = mix($initial, 0, 0, 10);
    my $sum = 0;
    #say $zeroe->{index};
    my @ret = map { $_->{value} } ( $mixed->[ ($zeroe->{index} + 1000) % scalar @$mixed ],  $mixed->[ ($zeroe->{index} + 2000) % scalar @$mixed ],  $mixed->[ ($zeroe->{index} + 3000) % scalar @$mixed ] );
    #say Dumper(\@ret); 
    $sum += $_ for @ret;
    return $sum;
    return 0;
}

1;
