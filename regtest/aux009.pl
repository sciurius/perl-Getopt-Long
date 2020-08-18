#!/usr/bin/perl -w

# callback object method 'given'

# Based on a suggestion from Angus McLeod.

use Getopt::Long;

my $colour;

my %opt = ( 'red|green|blue' => sub { $colour = uc $_[0]->given; } );


@ARGV = qw( --red );
$ok = GetOptions( %opt ) && $colour eq "RED";
@ARGV = qw( -b );
$ok &&= GetOptions( %opt ) && $colour eq "BLUE";

exit ($ok ? 0 : 1);

