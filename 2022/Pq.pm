package Pq;

use 5.30.0;
use strict;
use warnings;
use feature "signatures";
no warnings "experimental::signatures";

use Exporter 'import';
our @EXPORT_OK =qw/
    pq_push
    pq_pop
/;

sub pq_push($pq, $prio, $value) {
    $pq->{min} //= $prio;
    $pq->{min} = $prio if $prio < $pq->{min};
    $pq->{values}{$prio} //= [];
    push $pq->{values}{$prio}->@*, $value;
    return $pq;
}

sub pq_pop($pq) {
    return undef unless defined $pq->{min};
    my $item = shift $pq->{values}{$pq->{min}}->@*;
    unless (scalar $pq->{values}{$pq->{min}}->@*) {
        delete $pq->{values}{$pq->{min}};
        $pq->{min} = min([ keys $pq->{values}->%*], undef);
    }
    return $item;
}

1;
