#!/usr/local/bin/perl -w
my $RCS_Id = '$Id$ ';

# Author          : Johan Vromans
# Created On      : Sun Sep 15 18:39:01 1996
# Last Modified By: Johan Vromans
# Last Modified On: Fri Mar 27 12:33:58 1998
# Update Count    : 15
# Status          : Unknown, Use with caution!

################ Common stuff ################

use strict;

# Package or program libraries, if appropriate.
# $LIBDIR = $ENV{'LIBDIR'} || '/usr/local/lib/sample';
# use lib qw($LIBDIR);
# require 'common.pl';

# Package name.
my $my_package = 'Sciurix';
# Program name and version.
my ($my_name, $my_version) = $RCS_Id =~ /: (.+).pl,v ([\d.]+)/;
# Tack '*' if it is not checked in into RCS.
$my_version .= '*' if length('$Locker$ ') > 12;

################ Command line parameters ################

use Getopt::Long 2.13;
sub app_options();

my $verbose = 0;		# verbose processing

# Development options (not shown with -help).
my $debug = 0;			# debugging
my $trace = 0;			# trace (show process)
my $test = 0;			# test (no actual processing)

app_options();

# Options post-processing.
$trace |= ($debug || $test);

################ Presets ################

my $TMPDIR = $ENV{'TMPDIR'} || '/usr/tmp';

################ The Process ################

exit 0;

################ Subroutines ################

sub app_options() {
    my $help = 0;		# handled locally
    my $ident = 0;		# handled locally
    my $man = 0;		# handled locally

    # Process options.
    if ( @ARGV > 0 ) {
	GetOptions('ident'	=> \$ident,
		   'verbose'	=> \$verbose,
		   'trace'	=> \$trace,
		   'help|?'	=> \$help,
		   'man'	=> \$man,
		   'debug'	=> \$debug)
	  or pod2usage(2);
    }
    if ( $ident or $help or $man ) {
	print STDERR ("This is $my_package [$my_name $my_version]\n");
    }
    if ( $man or $help ) {
	# Load Pod::Usage only if needed.
	require "Pod/Usage.pm";
	import Pod::Usage;
	pod2usage(1) if $help;
	pod2usage(VERBOSE => 2) if $man;
    }
}

__END__

################ Documentation ################

=head1 NAME

sample - skeleton for GetOpt::Long and Pod::Usage

=head1 SYNOPSIS

sample [options] [file ...]

 Options:
   -ident		show identification
   -help		brief help message
   -man                 full documentation
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
