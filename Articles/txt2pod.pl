#!/usr/local/bin/perl -w
my $RCS_Id = '$Id: skel.pl,v 1.6 1997-12-25 16:22:28+01 jv Exp $ ';

# Author          : Johan Vromans
# Created On      : Tue Sep 15 15:59:04 1992
# Last Modified By: Johan Vromans
# Last Modified On: Sun Apr 19 19:26:09 1998
# Update Count    : 58
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
$my_version .= '*' if length('$Locker:  $ ') > 12;

################ Command line parameters ################

use Text::Tabs;
use Getopt::Long 2.11;
my $verbose = 0;
my ($debug, $trace, $test) = (0, 0, 0);
app_options();

################ Presets ################

my $TMPDIR = $ENV{TMPDIR} || '/usr/tmp';

################ The Process ################

$/ = '';
my $line = <>;			# skip enriched preamble
my $inenum = 0;
while ( defined ( $line = <> ) ) {
    last if $line =~ /^;;/;
    $line = expand ($line);
    if ( $line =~ /^   +(<fixed>)?/ ) {
	if ( $inenum ) {
	    $inenum = 0;
	    print STDOUT ("=back\n\n");
	}
	$line = "  ". $';
	$line =~ s/[ \t\n]*$//;
	$line =~ s/<\/fixed>$//;
    }
    elsif ( $line =~ /^ \* / ) {
	$line = $';
	$line =~ s/[ \t\n]+/ /g;
	if ( !$inenum ) {
	    $inenum = 1;
	    print STDOUT ("=over 3\n\n");
	}
	    print STDOUT ("=item *\n\n");
    }
    else {
	if ( $inenum ) {
	    $inenum = 0;
	    print STDOUT ("=back\n\n");
	}
	$line =~ s/[ \t\n]+/ /g;
    }
    $line =~ s/<italic>(.*?)<\/italic>/I<$1>/gs;
    $line =~ s/<bold>(.*?)<\/bold>/B<$1>/gs;
    $line =~ s/<fixed>(.*?)<\/fixed>/C<$1>/gs;
    $line =~ s/<</</g;
    $line =~ s/C<<>>/C<E<lt>E<gt>>/g;

    if ( $line =~ /^B<(.*?)>/ ) {
	print STDOUT ("=head1 $1$'\n\n");
    }
    elsif ( $line =~ /^I<(.*?)>/ ) {
	print STDOUT ("=head2 $1$'\n\n");
    }
    else {
	print STDOUT ($line, "\n\n");
    }
}


exit 0;

################ Subroutines ################

sub app_ident;
sub app_usage($);

sub app_options {
    my $help = 0;		# handled locally
    my $ident = 0;		# handled locally

    # Process options, if any.
    # Make sure defaults are set before returning!
    return unless @ARGV > 0;
    
    if ( !GetOptions(
		     'ident'	=> \$ident,
		     'verbose'	=> \$verbose,
		     'trace'	=> \$trace,
		     'help'	=> \$help,
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
    -help		this message
    -ident		show identification
    -verbose		verbose information
EndOfUsage
    exit $exit if $exit != 0;
}
