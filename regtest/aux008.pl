#!/usr/bin/perl -w

# Another REF type problem, thanks to Tels.

use Getopt::Long;

my $v = \*STDIN;
@ARGV=qw(-v 2);

# This will give an "invalid linkage" error in 2.35_01 and before.
GetOptions ("v:1" => \$v);
