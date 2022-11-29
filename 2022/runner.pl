#!/usr/bin/perl

use 5.30.0;
use strict;
use warnings;
use feature 'signatures';
no warnings "experimental::signatures";
no strict 'refs';

use Cwd qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path($0));

use Time::HiRes qw/time/;

use Getopt::Long;
my $test = 0;
my $day = "all";

GetOptions(
    "test" => \$test,
);

$day = defined ( $ARGV[0] ) ? $ARGV[0] : $day;

sub main($day, $test) {
    my $total = run_day($day eq "all" ? 1 : $day, $test, $day eq "all", 0);
    say "\ntook ${total}s in total" if $day eq "all";
}

sub run_day($day, $test, $continue, $total) {
    my $d = $day < 10 ? "0$day" : $day;
    my $module = "Day$d";
    return $total unless -e "$module.pm";
    require "$module.pm";
    my $run = "$module"."::run";
    my $start = time;
    my $res = $run->($test == 1 ? "test" : "real");
    say "P1: ". $res->[0];
    say "P2: ". $res->[1];
    my $took = time - $start;
    say "Took: $took";
    return unless $continue;
    @_ = ($day+1, $test, $continue, $total + $took);
    goto &run_day;
}

main($day, $test);

