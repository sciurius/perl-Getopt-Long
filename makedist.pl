#!/usr/local/bin/perl -w
my $RCS_Id = '$Id$ ';

# Author          : Johan Vromans
# Created On      : Tue Sep 15 15:59:04 1992
# Last Modified By: Johan Vromans
# Last Modified On: Fri Oct 22 15:41:10 1999
# Update Count    : 44
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

my $make = 1;			# run perl/make
my $verbose = 0;		# verbose processing

# Development options (not shown with -help).
my $debug = 0;			# debugging
my $trace = 0;			# trace (show process)
my $test = 0;			# test (no actual processing)

app_options();

# Options post-processing.
$trace |= ($debug || $test);

################ Presets ################

my $TMPDIR = $ENV{TMPDIR} || '/usr/tmp';

################ The Process ################

unlink ("GetoptLong.pm");
open (OUT, ">GetoptLong.pm") or die ("Cannot create GetoptLong.pm [$!]\n");
foreach ( qw (GetoptLong.pl GetoptLongAl.pl GetoptLong.pod) ) {
    combine ($_);
}
close (OUT);

if ( $make ) {
    system "perl", "Makefile.PL";
    exec "make", "dist";
}

################ Subroutines ################

sub combine ($) {
    my ($file) = @_;
    my $line;

    open (F, $file) or die ("Cannot open $file [$!]\n");
    while ( defined ($line = <F>) ) {
	if ( $line =~ /^(\s*\$VERSION\s*=\s*)(.+);\s*$/ ) {
	    my ($pre) = $1;
	    my $v = eval ('my $VERSION;'.$line.';$VERSION');
	    my ($maj, $min) = ($v =~ /^(\d+)\.(\d+)$/);
	    $min++;
	    print STDERR ($line, 
			  "New version: [$maj.$min] ");
	    chomp ($v = <STDIN>);
	    $v = "$maj.$min" if $v eq '';
	    $line = $pre . "\"$v\";\n";
	}
	print OUT ($line);
    }
    close (F);
}

sub app_ident;
sub app_usage($);

sub app_options() {
    my $help = 0;		# handled locally
    my $ident = 0;		# handled locally

    # Process options, if any.
    # Make sure defaults are set before returning!
    return unless @ARGV > 0;
    
    if ( !GetOptions(
		     'make!'	=> \$make,
		     'ident'	=> \$ident,
		     'verbose'	=> \$verbose,
		     'trace'	=> \$trace,
		     'help|?'	=> \$help,
		     'debug'	=> \$debug,
		    ) or $help )
    {
	app_usage(2);
    }
    app_ident if $ident;
}

sub app_ident {
    print STDERR ("This is $my_package [$my_name $my_version]\n");
}

sub app_usage($) {
    my ($exit) = @_;
    app_ident;
    print STDERR <<EndOfUsage;
Usage: $0 [options] [file ...]
    -[no]make		run make
    -help		this message
    -ident		show identification
    -verbose		verbose information
EndOfUsage
    exit $exit if $exit != 0;
}
