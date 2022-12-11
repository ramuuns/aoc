package Day11;

use 5.30.0;
use strict;
use warnings;
use feature "signatures";
no warnings "experimental::signatures";

use Math::BigInt;
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
Monkey 0:
  Starting items: 79, 98
  Operation: new = old * 19
  Test: divisible by 23
    If true: throw to monkey 2
    If false: throw to monkey 3

Monkey 1:
  Starting items: 54, 65, 75, 74
  Operation: new = old + 6
  Test: divisible by 19
    If true: throw to monkey 2
    If false: throw to monkey 0

Monkey 2:
  Starting items: 79, 60, 97
  Operation: new = old * old
  Test: divisible by 13
    If true: throw to monkey 1
    If false: throw to monkey 3

Monkey 3:
  Starting items: 74
  Operation: new = old + 3
  Test: divisible by 17
    If true: throw to monkey 0
    If false: throw to monkey 1
TEST_DATA
    my $data = read_file("input-11");
    return prepare_data($data);
}

sub prepare_data($data) {
    return make_monkeys([split /\n/, $data], [])->@*
}

sub make_monkeys($data, $monkeys) {
    return $monkeys unless scalar @$data;
    my $row = shift @$data;
    my $monkey;
    if ( $row =~ /^Monkey (\d+)/ ) {
        $monkey = { id => $1, items => [], op => undef, test => undef, if_true => undef, if_false => undef };
    } else {
        $monkey = pop @$monkeys;
    }
    $monkey->{items} = [map { Math::BigInt->new($_) } split /, /, $1] if $row =~ /^  Starting items: (.+)/;
    if ( $row =~ /Operation: new = (.+)/ ) {
        my $op = $1;
        $op =~ s/old \+ (\d+)/\$old->badd(Math::BigInt->new('$1'))/;
        $op =~ s/old \* old/\$old->bpow(Math::BigInt->new('2'))/;
        $op =~ s/old \* (\d+)/\$old->bmul(Math::BigInt->new('$1'))/;
        $monkey->{op} = sub ($old) { return eval $op; };
    }
    $monkey->{test} = $1 if $row =~ /Test: divisible by (\d+)/;
    $monkey->{if_true} = $1 if $row =~ /If true: throw to monkey (\d+)/;
    $monkey->{if_false} = $1 if $row =~ /If false: throw to monkey (\d+)/;
    push @$monkeys, $monkey;
    goto &make_monkeys;
}

use Data::Dumper;

sub part_1(@data) {
    my @ret = sort { $b - $a } monkey_business([@data], 0, 20, [], 0)->@*;
    return $ret[0] * $ret[1];
}

sub monkey_business($monkeys, $round, $max_rounds, $inspect_count, $worry){
    return $inspect_count if $round == $max_rounds;
    monkey_round($monkeys, $inspect_count, 0, $worry);
    @_ = ($monkeys, $round + 1, $max_rounds, $inspect_count, $worry);
    goto &monkey_business;
}

sub monkey_round($monkeys, $inspect_count, $idx, $worry) {
    return unless defined $monkeys->[$idx];
    inspect_items($monkeys, $inspect_count, $idx, $worry);
    @_ = ($monkeys, $inspect_count, $idx + 1, $worry);
    goto &monkey_round;
}

sub inspect_items($monkeys, $inspect_count, $idx, $worry) {
    return unless scalar $monkeys->[$idx]->{items}->@*;
    $inspect_count->[$idx]++;
    my $monkey = $monkeys->[$idx];
    my $item = shift $monkey->{items}->@*;
    $item = $monkey->{op}->($item);
    if ($worry) {
        $item = $item->bmod(Math::BigInt->new(eval join ' * ', map { $_->{test} } $monkeys->@*));
    } else {
        $item = $item->bdiv(Math::BigInt->new('3'));
    }
    my $test = $item->copy()->bmod(Math::BigInt->new($monkey->{test}))->as_int();
    if ( $test == 0 ) {
        push $monkeys->[ $monkey->{if_true} ]->{items}->@*, $item;
    } else {
        push $monkeys->[ $monkey->{if_false} ]->{items}->@*, $item;
    }
    goto &inspect_items;
}

sub part_2(@data) {
    my @ret = sort {$b - $a} monkey_business([@data], 0, 10_000, [], 1)->@*;
    return $ret[0] * $ret[1];
}

1;
