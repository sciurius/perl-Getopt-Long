#!/usr/local/bin/perl -w
my $RCS_Id = '$Id$ ';

# Author          : Johan Vromans
# Created On      : Tue Sep 15 15:59:04 1992
# Last Modified By: Johan Vromans
# Last Modified On: Sat Mar  9 10:18:02 1996
# Update Count    : 10
# Status          : Unknown, Use with caution!

################ Common stuff ################

# $LIBDIR = $ENV{'LIBDIR'} || '/usr/local/lib/sample';
# unshift (@INC, $LIBDIR);
# require 'common.pl';
use strict;
my $my_package = 'Sciurix';
my ($my_name, $my_version) = $RCS_Id =~ /: (.+).pl,v ([\d.]+)/;
$my_version .= '*' if length('$Locker$ ') > 12;

################ Program parameters ################

use Getopt::Long 2.00;
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

    # Process options.
    if ( @ARGV > 0 && $ARGV[0] =~ /^[-+]/ ) {
	&usage 
	    unless &GetOptions ('ident' => \$ident,
				'verbose' => \$verbose,
				'trace' => \$trace,
				'help' => \$help,
				'debug' => \$debug)
		&& !$help;
    }
    print STDERR ("This is $my_package [$my_name $my_version]\n")
	if $ident;
}

sub usage {
    print STDERR <<EndOfUsage;
This is $my_package [$my_name $my_version]
Usage: $0 [options] [file ...]
    -help		this message
    -ident		show identification
    -verbose		verbose information
EndOfUsage
    exit 1;
}
