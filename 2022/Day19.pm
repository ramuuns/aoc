package Day19;

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

my $DEBUG = 0;

sub read_input($mode) {
    return prepare_data(<<TEST_DATA) if $mode eq "test";
Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.
TEST_DATA
    my $data = read_file("input-19");
    return prepare_data($data);
}

sub prepare_data($data) {
    return map { parse_line($_) } split /\n/, $data;
}

sub parse_line($line) {
    $line =~ /Blueprint (\d+): Each ore robot costs (\d+) ore. Each clay robot costs (\d+) ore. Each obsidian robot costs (\d+) ore and (\d+) clay. Each geode robot costs (\d+) ore and (\d+) obsidian./;
    return { id => $1, bots => [ 
        { needs => { ore => $6, obsidian => $7}, makes => 'geode' },
        { needs => { ore => $4, clay => $5 }, makes => 'obsidian' },
        { needs => { ore => $3 }, makes => 'clay' }, 
        { needs => { ore => $2 }, makes => 'ore' }, 
      ]
    };
}

use Data::Dumper;

sub sum($items, $acc) {
    return $acc unless @$items;
    @_ = ($items, $acc + shift @$items);
    goto &sum;
}

sub part_1(@data) {
    return sum(get_quality_levels([@data],[]), 0);
    #return 0;
}

sub get_quality_levels($blueprints, $ret ) {
    return $ret unless scalar @$blueprints;
    my $blueprint = shift @$blueprints;
    my $initial_state = {
        resources => {
            ore => 0,
            clay => 0,
            obsidian => 0,
            geode => 0,
        },
        bots => {
            ore => 1,
            clay => 0,
            obsidian => 0,
            geode => 0
        },
    };
    say $blueprint->{id};
    push @$ret, get_quality_level($blueprint, [ [ 24, $initial_state, [] ] ], {}) * $blueprint->{id};
    goto &get_quality_levels;
}

sub min($one, $two ) {
    $one > $two ? $two : $one;
}


sub made_to_letter($made){
    state %things = (
        ore => 'o',
        obsidian => 'b',
        clay => 'c',
        geode => 'g'
    );
    return $things{$made};
}

sub could_build_both_last_time($blueprint, $state) {
    my $ore_last_time = $state->{resources}{ore} - $state->{bots}{ore};
    return $ore_last_time >= $blueprint->{bots}[2]{needs}{ore} && $ore_last_time >= $blueprint->{bots}[3]{needs}{ore};
}

sub could_build_three_last_time($blueprint, $state) {
    my $ore_last_time = $state->{resources}{ore} - $state->{bots}{ore};
    my $clay_last_time = $state->{resources}{clay} - $state->{bots}{clay};
    return $ore_last_time >= $blueprint->{bots}[2]{needs}{ore} 
        && $ore_last_time >= $blueprint->{bots}[3]{needs}{ore}
        && $ore_last_time >= $blueprint->{bots}[1]{needs}{ore}
        && $clay_last_time >= $blueprint->{bots}[1]{needs}{clay};
}

sub get_moves_to_build($state, $bp, $t) {
    return -1 if grep { $state->{bots}{$_} == 0 } keys $bp->{needs}->%*;
    my @needs = keys $bp->{needs}->%*;
    my @res = map { $state->{resources}{$_} - $bp->{needs}{$_} } @needs;
    if ( scalar @res == scalar grep { $_ >= 0 } @res ) {
      return $t;
    }
    #@res = map { $res[$_] + $state->{bots}->{$needs[$_]} } 0..$#needs;
    return try_to_build_it_tho(\@res, $state->{bots}, \@needs, $t - 1);
}

sub try_to_build_it_tho($res, $bots, $needs, $t) {
    return $t if $t < 0;
    $res = [map { $res->[$_] + $bots->{$needs->[$_]} } 0..$#$needs];
    if ( scalar @$res == scalar grep { $_ >= 0 } @$res ) { 
      return $t;
    }
    @_ = ($res, $bots, $needs, $t - 1);
    goto &try_to_build_it_tho;
}

sub can_build_more_ore_bots($bots, $blueprint) {
    my $ok = 0;
    $ok ||= $bots < $_->{needs}{ore} for $blueprint->{bots}->@*;
    return $ok;
}

sub can_build_more_clay_bots($bots, $blueprint) {
    return $bots < $blueprint->{bots}[1]{needs}{clay};
}

sub can_build_more_obsidian_bots($bots, $blueprint) {
    return $bots < $blueprint->{bots}[0]{needs}{obsidian};
}

sub max_possible($state, $time_left) {
    my $curr = $state->{resources}{geode};
    my $curr_bots = $state->{bots}{geode};
    return $curr + $curr_bots * $time_left + $time_left*($time_left-1)/2;
}

sub get_quality_level($blueprint, $deq, $max) {
    return $max->{0}{geode} unless @$deq;
    my ($time_left, $state, $path) = (shift @$deq)->@*;

    $max->{0} //= {
        geode => 0,
    };
    if ( ($time_left > 0) && ( max_possible($state, $time_left) > $max->{0}{geode} ) ) {
        my @new_states = 
        map {
            my ($t_left, $ns) = $_->@*;
            #say $t_left if $time_left == 21;
            #say $time_left - $t_left if $time_left == 21;
            #say Dumper($ns) if $time_left == 21;
            [ $t_left - 1,
            {
                bots => $ns->{bots},
                resources => {
                    map { $_ => ($ns->{resources}{$_} // 0) + ($state->{bots}{$_} * ($time_left - $t_left + 1)) } keys $state->{bots}->%*
                },
                made => made_to_letter($ns->{made})
            }
            ]
        } grep {
            $_->[0] > 0
        } map {
            my $bp = $_;
            my %bots = $state->{bots}->%*;
            my %resources = $state->{resources}->%*;
            my $t_when_built = get_moves_to_build($state, $bp, $time_left);
            $bots{$bp->{makes}}++;
            $resources{$_} -= $bp->{needs}{$_} for keys $bp->{needs}->%*;
            [ $t_when_built,
            {
                bots => { %bots },
                resources => { %resources },
                made => $bp->{makes},
            } ]
        } grep {
            $_->{makes} eq 'geode'
            || $_->{makes} eq 'ore' && can_build_more_ore_bots( $state->{bots}{ore}, $blueprint )
            || $_->{makes} eq 'clay' && can_build_more_clay_bots( $state->{bots}{clay}, $blueprint )
            || $_->{makes} eq 'obsidian' && can_build_more_obsidian_bots( $state->{bots}{obsidian}, $blueprint) 
        } $blueprint->{bots}->@*;


        push @new_states, [0, {
            bots => {
                $state->{bots}->%*
            },
            resources => {
                map { $_ => ($state->{resources}{$_} // 0) + $state->{bots}{$_} * $time_left } keys $state->{bots}->%*
            },
            made => '-'
        }];


        push @$deq, [$_->[0], $_->[1], [@$path, '-'x( $time_left - $_->[0] -1), $_->[1]{made}] ] for @new_states;

    }
    if ( $time_left == 0 && $state->{resources}{geode} > $max->{$time_left}{geode} ) {
        say "new best: $state->{resources}{geode} $time_left";
        say join "", $path->@*;
        $max->{$time_left}{geode} = $state->{resources}{geode};
    }
    @_ = ($blueprint, $deq, $max);
    goto &get_quality_level;
}

sub part_2(@data) {
    return get_max_geodes_prod(\@data, 0, 3, 1);
    return 0;
}

sub get_max_geodes_prod($blueprints, $i, $max,  $ret ) {
    return $ret if $i == $max || $i == scalar @$blueprints;
    my $blueprint = $blueprints->[$i];
    my $initial_state = {
        resources => {
            ore => 0,
            clay => 0,
            obsidian => 0,
            geode => 0,
        },
        bots => {
            ore => 1,
            clay => 0,
            obsidian => 0,
            geode => 0
        },
    };
    say $blueprint->{id};
    @_ = ($blueprints, $i+1, $max, $ret * get_quality_level($blueprint, [ [32, $initial_state, [] ] ], {}));
    goto &get_max_geodes_prod;
}

1;
