#!/usr/local/bin/perl -w
my $RCS_Id = '$Id$ ';

# Author          : Johan Vromans
# Created On      : Tue Sep 15 15:59:04 1992
# Last Modified By: Johan Vromans
# Last Modified On: Mon Sep 16 20:28:03 1996
# Update Count    : 28
# Status          : Unknown, Use with caution!

################ Documentation ################

=head1 NAME

sample - skeleton for GetOpt::Long and Pod::Usage

=head1 SYNOPSIS

sample [options] [file ...]

 Options:
   -help		this message
   -ident		show identification
   -verbose		verbose information

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-ident>

Prints program identification.

=item B<-verbose>

More verbose information.

=item I<file>

Input file(s).

=back

=head1 DESCRIPTION

B<This program> will read the given input file(s) and do someting
useful with the contents thereof.

=cut

################ Common stuff ################

# $LIBDIR = $ENV{'LIBDIR'} || '/usr/local/lib/sample';
# unshift (@INC, $LIBDIR);
# require 'common.pl';
use strict;
my $my_package = 'Sciurix';
my ($my_name, $my_version) = $RCS_Id =~ /: (.+).pl,v ([\d.]+)/;
$my_version .= '*' if length('$Locker$ ') > 12;

################ Program parameters ################

my $verbose = 0;
my ($debug, $trace, $test) = (0, 0, 0);
&options;

################ Presets ################

my $TMPDIR = $ENV{'TMPDIR'} || '/usr/tmp';

################ The Process ################

exit 0;

################ Subroutines ################

sub options {
    my $help = 0;		# handled locally
    my $ident = 0;		# handled locally
    my $man = 0;		# handled locally

    # Process options. Load Getopt::Long only if needed.
    if ( @ARGV > 0 && $ARGV[0] =~ /^[-+]/ ) {
	# The next require / import is equivalent to "use Getopt::Long".
	require "Getopt/Long.pm";
	import Getopt::Long;
	&GetOptions ('ident' => \$ident,
		     'verbose' => \$verbose,
		     'trace' => \$trace,
		     'help' => \$help,
		     'man' => \$man,
		     'debug' => \$debug) or pod2usage (2);
    }
    if ( $ident or $help or $man ) {
	print STDERR ("This is $my_package [$my_name $my_version]\n");
    }
    if ( $man or $help ) {
	# Load Pod::Usage only if needed.
	require "Pod/Usage.pm";
	import Pod::Usage;
	pod2usage (1) if $help;
	pod2usage (VERBOSE => 2) if $man;
    }
}
