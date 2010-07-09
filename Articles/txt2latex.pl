#!/usr/local/bin/perl -w
my $RCS_Id = '$Id: skel.pl,v 1.6 1997-12-25 16:22:28+01 jv Exp $ ';

# Author          : Johan Vromans
# Created On      : Tue Sep 15 15:59:04 1992
# Last Modified By: Johan Vromans
# Last Modified On: Sun Jan 11 19:14:31 1998
# Update Count    : 69
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
my $inverb = 0;
while ( defined ( $line = <> ) ) {
    last if $line =~ /^;;/;
    $line =~ tr/<>/\201\202/;

    if ( $line =~ /^  (\201fixed\202)?/ ) {
	if ( $inenum ) {
	    $inenum = 0;
	    print STDOUT ("\\end{itemize}\n\n");
	}
	$line = "  ". $';
	$line =~ s/[ \t\n]*$//;
	$line =~ s/\201\/fixed\202$//;
	print STDOUT ("\\begin{verbatim}\n") unless $inverb;
	$inverb = 1;
    }
    elsif ( $line =~ /^ \* / ) {
	$line = $';
	$line =~ s/[ \t\n]+/ /g;
	if ( !$inenum ) {
	    $inenum = 1;
	    print STDOUT ("\\begin{itemize}\n\n");
	}
	print STDOUT ("\\item\n");
    }
    else {
	if ( $inverb ) {
	    $inverb = 0;
	    print STDOUT ("\\end{verbatim}\n\n");
	}
	if ( $inenum ) {
	    $inenum = 0;
	    print STDOUT ("\\end{itemize}\n\n");
	}
	$line =~ s/[ \t\n]+/ /g;
    }
    $line =~ s/\201italic\202(.*?)\201\/italic\202/\203textit\204$1\205/gs;
    $line =~ s/\201bold\202(.*?)\201\/bold\202/\203textbf\204$1\205/gs;
    $line =~ s/\201fixed\202(.*?)\201\/fixed\202/\203verb+$1+/gs;
    $line =~ s/\201\201/\201/g;
#    $line =~ s/C<<>>/C<E<lt>E<gt>>/g;

    if ( $line =~ /^\203textbf\204(.*?)\205/ ) {
	$line = $1.$';
	$line =~ s/\201/\\textless{}/g;
	$line =~ s/\202/\\textgreater{}/g;
	print STDOUT ("\\section{", tt($line), "}\n\n");
    }
    elsif ( $line =~ /^\203textit\204(.*?)\205/ ) {
	$line = $1.$';
	$line =~ s/\201/\\textless{}/g;
	$line =~ s/\202/\\textgreater{}/g;
	print STDOUT ("\\subsection{", tt($line), "}\n\n");
    }
    else {
	print STDOUT (tt($line), $inverb ? "\n" : "\n\n");
    }
}

exit 0;

################ Subroutines ################

sub tt ($) {
    my $line = shift;
    $line =~ s/([\#\$\%\^\&\\\{\}\<\>])/\\$1/g;
    if ( $inverb ) {
      $line =~ s/\201/</g;
      $line =~ s/\202/>/g;
    }
    else {
      $line =~ s/\201/\\textless{}/g;
      $line =~ s/\202/\\textgreater{}/g;
    }
    $line =~ s/\203/\\/g;
    $line =~ s/\204/{/g;
    $line =~ s/\205/}/g;
    $line;
}

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
