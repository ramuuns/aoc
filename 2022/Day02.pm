package Day02;

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
A Y
B X
C Z
TEST_DATA
    my $data = read_file("input-02");
    return prepare_data($data);
}

sub prepare_data($data) {
    $data =~ s/A/0/g; 
    $data =~ s/B/1/g; 
    $data =~ s/C/2/g; 
    $data =~ s/X/0/g; 
    $data =~ s/Y/1/g; 
    $data =~ s/Z/2/g; 
    return split /\n/, $data;
}

sub part_1(@data) {
    return score_round_p1(0, @data);
}

sub part_2(@data) {
    return score_round_p2(0, @data);
}

sub score_round_p1 {
    my ($score, $round, @rest) = @_;
    return $score unless defined $round;
    my ($opponent, $me) = split / /, $round;
    my $outcome = (($me - $opponent) + 3) % 3;
    @_ = (
      $score 
      + ($outcome+1)%3*3
      + ($me+1), 
      @rest
    );
    goto &score_round_p1;
}

sub score_round_p2 {
    my ($score, $round, @rest) = @_;
    return $score unless defined $round;
    my ($opponent, $outcome) = split / /, $round;
    $outcome = ($outcome + 2) % 3;
    @_ = (
      $score 
      + ($outcome+1)%3*3
      + (($opponent + $outcome)%3 + 1),
      @rest
    );
    goto &score_round_p2;
}

1;
