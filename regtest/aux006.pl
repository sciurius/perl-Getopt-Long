#!/usr/bin/perl -w

# REF type problem when used with bignum.

use bignum;
use Getopt::Long;

my $v=0;
@ARGV=qw(-v 2);

# This will give an "invalid linkage" error in 2.35_01 and before.
GetOptions ("v:1" => \$v);
