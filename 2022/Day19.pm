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
Blueprint 28: Each ore robot costs 4 ore. Each clay robot costs 4 ore. Each obsidian robot costs 2 ore and 11 clay. Each geode robot costs 4 ore and 8 obsidian.
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
#return sum(get_quality_levels([@data],[]), 0);
    return 0;
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
    push @$ret, get_quality_level($blueprint, [ [24, $initial_state, [] ] ], {}) * $blueprint->{id};
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

sub get_quality_level($blueprint, $deq, $max) {
    return $max->{0}{geode} unless @$deq;
    my ($time_left, $state, $path) = (pop @$deq)->@*;

    $max->{$time_left} //= {
        geode => 0,
    };
    if ( ( $time_left > 0 ) && ( $state->{resources}{geode} >= $max->{$time_left}{geode} ) ) {
        my @new_states = 
        map {
            my $ns = $_;
            {
                bots => $ns->{bots},
                resources => {
                    map { $_ => ($ns->{resources}{$_} // 0) + $state->{bots}{$_} } keys $state->{bots}->%*
                },
                made => made_to_letter($ns->{made})
            }
        } grep {
            ! grep { $_ < 0 } values $_->{resources}->%*
        } map {
            my $bp = $_;
            my %bots = $state->{bots}->%*;
            my %resources = $state->{resources}->%*;
            $bots{$bp->{makes}}++;
            $resources{$_} -= $bp->{needs}{$_} for keys $bp->{needs}->%*;
            {
                bots => { %bots },
                resources => { %resources },
                made => $bp->{makes},
            }
        } $blueprint->{bots}->@*;

        my $waiting_too_long_to_start = scalar(grep {$_->{made} eq 'o' || $_->{made} eq 'c' } @new_states) == 2 && $state->{bots}{clay} == 0 && $state->{bots}{ore} == 1;
        my $waiting_too_long = scalar(grep {$_->{made} eq 'o' || $_->{made} eq 'c' } @new_states) == 2 && $state->{bots}{clay} == 0;  

        if ( scalar(grep {$_->{made} eq 'o' || $_->{made} eq 'b' || $_->{made} eq 'c' } @new_states)  == 3 && $path->[-1] eq '-' && could_build_three_last_time($blueprint, $state) ) {
            @new_states = grep { $_->{made} ne 'o' || $_->{made} ne 'b' || $_->{made} ne 'c'  } @new_states;
        }


        if ( scalar(grep {$_->{made} eq 'o' || $_->{made} eq 'c' } @new_states) == 2 && $path->[-1] eq "-" && could_build_both_last_time($blueprint, $state) ) {
            @new_states = grep { $_->{made} ne 'o' && $_->{made} ne 'c' } @new_states;
        }

        push @new_states, {
            bots => {
                $state->{bots}->%*
            },
            resources => {
                map { $_ => ($state->{resources}{$_} // 0) + $state->{bots}{$_} } keys $state->{bots}->%*
            },
            made => '-'
        } unless $waiting_too_long_to_start || $waiting_too_long;

        my @to_build = grep { $_->{made} eq 'g' } @new_states;
        @to_build = @new_states unless scalar @to_build;

        push @$deq, [$time_left - 1, $_, [@$path, $_->{made}] ] for reverse @to_build; # sort { calc_score($blueprint, $time_left - 1, $b) <=> calc_score($blueprint, $time_left - 1, $a) } @new_states;
    }
    if ($state->{resources}{geode} > $max->{$time_left}{geode} ) {
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
