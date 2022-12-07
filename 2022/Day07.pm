package Day07;

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
    return prepare_data(<<'TEST_DATA') if $mode eq "test";
$ cd /
$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
$ cd a
$ ls
dir e
29116 f
2557 g
62596 h.lst
$ cd e
$ ls
584 i
$ cd ..
$ cd ..
$ cd d
$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k
TEST_DATA
    my $data = read_file("input-07");
    return prepare_data($data);
}

sub prepare_data($data) {
    return split /\n/, $data;
}

sub part_1($_meh, @data) {
    my $flat_dirs = flatten( [ make_dir_tree( [@data], mk_dir('/'), []) ], [] );
    return sum_total([map { $_->{size} } grep { $_->{size} < 100_000 } @$flat_dirs ], 0);
}

sub mk_dir($name) {
    { name => $name, size => 0, dirs => {} }
}

sub sum_total($arr, $total) {
    return $total unless scalar @$arr;
    @_ = ($arr, $total + shift @$arr);
    goto &sum_total;
}

sub flatten($queue, $list) {
    return $list unless scalar @$queue;
    my $tree = shift @$queue;
    push @$list, $tree;
    push @$queue, values $tree->{dirs}->%*;
    goto &flatten;
}

sub make_dir_tree($commands, $tree, $stack) {
    return $tree if scalar @$commands == 0 && scalar @$stack == 0;
    my $command = scalar @$commands ? shift @$commands : '$ cd ..';
    if ( $command eq '$ cd ..' ) {
        $stack->[-1]->{size} += $tree->{size};
        $tree = pop @$stack;
    }
    $tree->{dirs}{$1} = mk_dir($1) if $command =~ /^dir (\w+)$/;
    $tree->{size} += $1 if $command =~ /^(\d+) /;
    if ( $command =~ /^. cd (\w+)$/ ) {
      push @$stack, $tree;
      $tree = $tree->{dirs}{$1};
    }
    @_ = ($commands, $tree, $stack);
    goto &make_dir_tree;
}

sub part_2($_meh, @data) {
    my $tree = make_dir_tree( [@data], mk_dir('/'), []);
    my $flat_dirs = flatten( [$tree], [] );
    my $free_space = 70000000 - $tree->{size};
    my $need_space = 30000000 - $free_space;
    return min([map { $_->{size} } grep { $_->{size} > $need_space } @$flat_dirs], undef);
}

sub min($list, $min) { 
    return $min unless scalar @$list;
    my $item = shift @$list;
    @_ = ($list, ! defined $min || $item < $min ? $item : $min);
    goto &min;
}

1;
