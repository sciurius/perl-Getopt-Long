#!/usr/local/bin/perl -s
# testopt.pl -- Testbed for newgetopt.pl / Getopt::Long.pm .
# RCS Info        : $Id$
# Author          : Johan Vromans
# Created On      : ***
# Last Modified By: Johan Vromans
# Last Modified On: Wed Oct  1 13:28:37 1997
# Update Count    : 1
# Status          : Internal use only.

package foo;

unless ( defined &NGetOpt ) {
    unshift (@INC, ".");
    require "newgetopt.pl";
}

# perl -s variables
$debug = defined $main'debug; # ';
$verbose = defined $main'verbose; # ';
$numbered = defined $main'numbered; # ';

$newgetopt'debug = $debug; # ';
$single = 0;
$single = shift (@main'ARGV) if @main'ARGV == 1;
$all = $single == 0;
if ( $single ) {
    open (STDERR, ">&STDOUT");
}
select (STDERR); $| = 1;
select (STDOUT); $| = 1;
@stdopts = ("one!", 
	    "two=s", "three:s", 
	    "twos=s@", "threes:s@", 
	    "four=i", "five:i",
	    "fours=i@", "fives:i@",
	    "six=f", "seven:f",
	    "sixs=f@", "sevens:f@",
	    "eight|opt8=s",
	    "hi=i%", "hs=s%",
	    "opt-nine");

sub doit {
    @ARGV = @_;
    print STDOUT ($numbered ? "Test $test: " : "", "@ARGV\n") if $verbose;
    $newgetopt'debug = 1 if $test == $single;	#';
    $result = &NGetOpt (@stdopts);
}
sub doit1 {
    &doit;
    print STDOUT ("FT${test}a\n") unless $result;
}
sub doit0 {
    &doit;
    print STDOUT ("FT${test}a\n") if $result;
}

################ Setup ################

$test = 0;

################ No args ################

if ( ++$test == $single || $all ) {
    &doit1 ();
}

################ Non-opt args ################

if ( ++$test == $single || $all ) {
    &doit1 ("foo");
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    &doit1 ("--", "foo");
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

################ Simple args ################

if ( ++$test == $single || $all ) {
    undef $opt_one;
    &doit1 ("-one", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_one;
    print STDOUT ("FT${test}c = \"$opt_one\"\n") unless $opt_one == 1;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_one;
    &doit1 ("-one", "--", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_one;
    print STDOUT ("FT${test}c = \"$opt_one\"\n") unless $opt_one == 1;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_one;
    &doit1 ("-ONe", "--", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_one;
    print STDOUT ("FT${test}c = \"$opt_one\"\n") unless $opt_one == 1;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    { package newgetopt; $ignorecase = 0; }
    undef $opt_one;
    local (@stdopts) = ("one", "One", "ONe", "ONE");
    &doit1 ("-one", "-ONe", "--", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_one;
    print STDOUT ("FT${test}c = \"$opt_one\"\n") unless $opt_one == 1;
    print STDOUT ("FT${test}d\n") unless defined $opt_ONe;
    print STDOUT ("FT${test}e = \"$opt_ONe\"\n") unless $opt_ONe == 1;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
    { package newgetopt; $ignorecase = 1; }
}

if ( ++$test == $single || $all ) {
    undef $opt_one;
    print STDERR ("Expect: Option one does not take an argument\n");
    &doit0 ("--one=", "foo");
    print STDOUT ("FT${test}b = \"$opt_one\"\n") if defined $opt_one;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_one;
    &doit1 ("-one", "-one", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_one;
    print STDOUT ("FT${test}c = \"$opt_one\"\n") unless $opt_one == 1;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    $opt_one = 2;
    &doit1 ("-one", "-noone", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_one;
    print STDOUT ("FT${test}c = \"$opt_one\"\n") unless $opt_one == 0;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

################# String opt (mandatory) ################

if ( ++$test == $single || $all ) {
    undef $opt_two;
    &doit1 ("-two", "bar", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_two;
    print STDOUT ("FT${test}c = \"$opt_two\"\n") unless $opt_two eq "bar";
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_two;
    &doit1 ("-two", "-bar", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_two;
    print STDOUT ("FT${test}c = \"$opt_two\"\n") unless $opt_two eq "-bar";
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_two;
    &doit1 ("-two", "-bar", "-two", "blech", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_two;
    print STDOUT ("FT${test}c = \"$opt_two\"\n") unless $opt_two eq "blech";
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_two;
    &doit1 ("--two=-bar", "--two=blech", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_two;
    print STDOUT ("FT${test}c = \"$opt_two\"\n") unless $opt_two eq "blech";
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_two;
    &doit1 ("-two", "--");
    print STDOUT ("FT${test}b\n") unless defined $opt_two;
    print STDOUT ("FT${test}b = \"$opt_two\"\n") unless $opt_two eq "--";
}

if ( ++$test == $single || $all ) {
    undef $opt_two;
    &doit1 ("--two=--");
    print STDOUT ("FT${test}b\n") unless defined $opt_two;
    print STDOUT ("FT${test}b = \"$opt_two\"\n") unless  $opt_two eq "--";
}

if ( ++$test == $single || $all ) {
    undef $opt_two;
    print STDERR ("Expect: Option two requires an argument\n");
    &doit0 ("-two");
    print STDOUT ("FT${test}b = \"$opt_two\"\n") if defined $opt_two;
}

if ( ++$test == $single || $all ) {
    undef $opt_two;
    print STDERR ("Expect: Option two requires an argument\n");
    &doit0 ("--two=");
    print STDOUT ("FT${test}b = \"$opt_two\"\n") if defined $opt_two;
}

if ( ++$test == $single || $all ) {
    undef @opt_twos;
    &doit1 ("-twos", "-bar", "-twos", "blech", "foo");
    print STDOUT ("FT${test}b\n") unless defined @opt_twos;
    print STDOUT ("FT${test}c = \"$opt_twos[0]\@0\"\n") unless $opt_twos[0] eq "-bar";
    print STDOUT ("FT${test}c = \"$opt_twos[1]\@1\"\n") unless $opt_twos[1] eq "blech";
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

################ String opt (optional) ################

if ( ++$test == $single || $all ) {
    undef $opt_three;
    &doit1 ("-three", "bar", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_three;
    print STDOUT ("FT${test}c = \"$opt_three\"\n") unless $opt_three eq "bar";
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_three;
    undef $opt_one;
    &doit1 ("-three", "-one", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_three;
    print STDOUT ("FT${test}c = \"$opt_three\"\n") unless $opt_three eq "";
    print STDOUT ("FT${test}d\n") unless defined $opt_one;
    print STDOUT ("FT${test}e = \"$opt_one\"\n") unless $opt_one == 1;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_three;
    undef $opt_one;
    &doit1 ("-three", "blech", "-three", "-one", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_three;
    print STDOUT ("FT${test}c = \"$opt_three\"\n") unless $opt_three eq "";
    print STDOUT ("FT${test}d\n") unless defined $opt_one;
    print STDOUT ("FT${test}e = \"$opt_one\"\n") unless $opt_one == 1;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_three;
    &doit1 ("-three", "--");
    print STDOUT ("FT${test}b\n") unless defined $opt_three;
    print STDOUT ("FT${test}c = \"$opt_three\"\n") unless  $opt_three eq "";
}

if ( ++$test == $single || $all ) {
    undef $opt_three;
    &doit1 ("-three");
    print STDOUT ("FT${test}b\n") unless defined $opt_three;
    print STDOUT ("FT${test}c = \"$opt_three\"\n") unless  $opt_three eq "";
}

if ( ++$test == $single || $all ) {
    undef @opt_threes;
    undef $opt_one;
    &doit1 ("-threes", "-one", "-threes", "blech", "foo");
    print STDOUT ("FT${test}b\n") unless defined @opt_threes;
    print STDOUT ("FT${test}c [0] = \"$opt_threes[0]\"\n") unless $opt_threes[0] eq "";
    print STDOUT ("FT${test}c [1] = \"$opt_threes[1]\"\n") unless $opt_threes[1] eq "blech";
    print STDOUT ("FT${test}d\n") unless defined $opt_one;
    print STDOUT ("FT${test}e = \"$opt_one\"\n") unless $opt_one == 1;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

################ Int opt (mandatory) ################

if ( ++$test == $single || $all ) {
    undef $opt_four;
    &doit1 ("-four", "327", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_four;
    print STDOUT ("FT${test}c = \"$opt_four\"\n") unless $opt_four == 327;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_four;
    &doit1 ("-four", "327");
    print STDOUT ("FT${test}b\n") unless defined $opt_four;
    print STDOUT ("FT${test}c = \"$opt_four\"\n") unless $opt_four == 327;
    print STDOUT ("FT${test}z\n") if @ARGV != 0;
}

if ( ++$test == $single || $all ) {
    undef $opt_four;
    &doit1 ("-four", "-6", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_four;
    print STDOUT ("FT${test}c = \"$opt_four\"\n") unless $opt_four == -6;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_four;
    print STDERR ("Expect: Value \"bar\" invalid for option four",
		  " (number expected)\n");
    &doit0 ("-four", "bar", "foo");
    print STDOUT ("FT${test}b = \"$opt_four\"\n") if defined $opt_four;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_four;
    print STDERR ("Expect: Value \"-bar\" invalid for option four",
		  " (number expected)\n");
    &doit0 ("-four", "-bar", "foo");
    print STDOUT ("FT${test}b = \"$opt_four\"\n") if defined $opt_four;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_four;
    print STDERR ("Expect: Value \"--\" invalid for option four",
		  " (number expected)\n");
    &doit0 ("-four", "--");
    print STDOUT ("FT${test}b = \"$opt_four\"\n") if defined $opt_four;
}

if ( ++$test == $single || $all ) {
    undef $opt_four;
    print STDERR ("Expect: Option four requires an argument\n");
    &doit0 ("-four");
    print STDOUT ("FT${test}b = \"$opt_four\"\n") if defined $opt_four;
}

if ( ++$test == $single || $all ) {
    undef @opt_fours;
    &doit1 ("-fours", "-24", "-fours", "12", "foo");
    print STDOUT ("FT${test}b\n") unless defined @opt_fours;
    print STDOUT ("FT${test}c [0] = \"$opt_fours[0]\"\n") unless $opt_fours[0] == -24;
    print STDOUT ("FT${test}c [1] = \"$opt_fours[1]\"\n") unless $opt_fours[1] == 12;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

################ Int opt (optional) ################

if ( ++$test == $single || $all ) {
    undef $opt_five;
    &doit1 ("-five", "foo");
    print STDOUT ("FT${test}b = \"$opt_five\"\n") if $opt_five != 0;
}

if ( ++$test == $single || $all ) {
    undef $opt_five;
    &doit1 ("-five", "12", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_five;
    print STDOUT ("FT${test}c = \"$opt_five\"\n") unless $opt_five == 12;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_five;
    &doit1 ("-five", "12");
    print STDOUT ("FT${test}b\n") unless defined $opt_five;
    print STDOUT ("FT${test}c = \"$opt_five\"\n") unless $opt_five == 12;
    print STDOUT ("FT${test}z\n") if @ARGV != 0;
}

if ( ++$test == $single || $all ) {
    undef $opt_five;
    &doit1 ("-five", "-12", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_five;
    print STDOUT ("FT${test}c = \"$opt_five\"\n") unless $opt_five == -12;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_five;
    &doit1 ("-five", "-12");
    print STDOUT ("FT${test}b\n") unless defined $opt_five;
    print STDOUT ("FT${test}c = \"$opt_five\"\n") unless $opt_five == -12;
    print STDOUT ("FT${test}z\n") if @ARGV != 0;
}

if ( ++$test == $single || $all ) {
    undef $opt_five;
    undef $opt_one;
    &doit1 ("-five", "12", "-five", "-one", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_five;
    print STDOUT ("FT${test}c = \"$opt_five\"\n") unless $opt_five == 0;
    print STDOUT ("FT${test}d\n") unless defined $opt_one;
    print STDOUT ("FT${test}e = \"$opt_one\"\n") unless $opt_one == 1;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_five;
    &doit1 ("-five", "--");
    print STDOUT ("FT${test}b\n") unless defined $opt_five;
    print STDOUT ("FT${test}c = \"$opt_five\"\n") unless  $opt_five == 0;
}

if ( ++$test == $single || $all ) {
    undef $opt_five;
    &doit1 ("-five");
    print STDOUT ("FT${test}b\n") unless defined $opt_five;
    print STDOUT ("FT${test}c = \"$opt_five\"\n") unless  $opt_five == 0;
}

if ( ++$test == $single || $all ) {
    undef @opt_fives;
    undef $opt_one;
    &doit1 ("-fives", "-24", "-fives", "-one", "foo");
    print STDOUT ("FT${test}b\n") unless defined @opt_fives;
    print STDOUT ("FT${test}c [0] = \"$opt_fives[0]\"\n") unless $opt_fives[0] == -24;
    print STDOUT ("FT${test}c [1] = \"$opt_fives[1]\"\n") unless $opt_fives[1] == 0;
    print STDOUT ("FT${test}d\n") unless defined $opt_one;
    print STDOUT ("FT${test}e = \"$opt_one\"\n") unless $opt_one == 1;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

################ Int opt (mandatory) ################

if ( ++$test == $single || $all ) {
    undef $opt_six;
    &doit1 ("-six", "327", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_six;
    print STDOUT ("FT${test}c = \"$opt_six\"\n") unless $opt_six == 327;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_six;
    &doit1 ("-six", "3.27", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_six;
    print STDOUT ("FT${test}c = \"$opt_six\"\n") unless $opt_six == 3.27;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_six;
    &doit1 ("-six", "3.18");
    print STDOUT ("FT${test}b\n") unless defined $opt_six;
    print STDOUT ("FT${test}c = \"$opt_six\"\n") unless $opt_six == 3.18;
    print STDOUT ("FT${test}z\n") if @ARGV != 0;
}

if ( ++$test == $single || $all ) {
    undef $opt_six;
    &doit1 ("-six", "-6", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_six;
    print STDOUT ("FT${test}c = \"$opt_six\"\n") unless $opt_six == -6;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_six;
    &doit1 ("-six", "-6.4", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_six;
    print STDOUT ("FT${test}c = \"$opt_six\"\n") unless $opt_six == -6.4;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_six;
    &doit1 ("-six", "-6.4");
    print STDOUT ("FT${test}b\n") unless defined $opt_six;
    print STDOUT ("FT${test}c = \"$opt_six\"\n") unless $opt_six == -6.4;
    print STDOUT ("FT${test}z\n") if @ARGV != 0;
}

if ( ++$test == $single || $all ) {
    undef $opt_six;
    print STDERR ("Expect: Value \"bar\" invalid for option six",
		  " (real number expected)\n");
    &doit0 ("-six", "bar", "foo");
    print STDOUT ("FT${test}b = \"$opt_six\"\n") if defined $opt_six;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_six;
    print STDERR ("Expect: Value \"-bar\" invalid for option six",
		  " (real number expected)\n");
    &doit0 ("-six", "-bar", "foo");
    print STDOUT ("FT${test}b = \"$opt_six\"\n") if defined $opt_six;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_six;
    print STDERR ("Expect: Value \"--\" invalid for option six",
		  " (real number expected)\n");
    &doit0 ("-six", "--");
    print STDOUT ("FT${test}b = \"$opt_six\"\n") if defined $opt_six;
}

if ( ++$test == $single || $all ) {
    undef $opt_six;
    print STDERR ("Expect: Option six requires an argument\n");
    &doit0 ("-six");
    print STDOUT ("FT${test}b = \"$opt_six\"\n") if defined $opt_six;
}

if ( ++$test == $single || $all ) {
    undef @opt_sixs;
    &doit1 ("-sixs", "-.24", "-sixs", "1.2", "foo");
    print STDOUT ("FT${test}b\n") unless defined @opt_sixs;
    print STDOUT ("FT${test}c [0] = \"$opt_sixs[0]\"\n") unless $opt_sixs[0] == -0.24;
    print STDOUT ("FT${test}c [1] = \"$opt_sixs[1]\"\n") unless $opt_sixs[1] == 1.2;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

################ Int opt (optional) ################

if ( ++$test == $single || $all ) {
    undef $opt_seven;
    &doit1 ("-seven", "foo");
    print STDOUT ("FT${test}b = \"$opt_seven\"\n") if $opt_seven != 0;
}

if ( ++$test == $single || $all ) {
    undef $opt_seven;
    &doit1 ("-seven", "12", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_seven;
    print STDOUT ("FT${test}c = \"$opt_seven\"\n") unless $opt_seven == 12;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_seven;
    &doit1 ("-seven", "12");
    print STDOUT ("FT${test}b\n") unless defined $opt_seven;
    print STDOUT ("FT${test}c = \"$opt_seven\"\n") unless $opt_seven == 12;
    print STDOUT ("FT${test}z\n") if @ARGV != 0;
}

if ( ++$test == $single || $all ) {
    undef $opt_seven;
    &doit1 ("-seven", "1.2", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_seven;
    print STDOUT ("FT${test}c = \"$opt_seven\"\n") unless $opt_seven == 1.2;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_seven;
    &doit1 ("-seven", "-12", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_seven;
    print STDOUT ("FT${test}c = \"$opt_seven\"\n") unless $opt_seven == -12;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_seven;
    &doit1 ("-seven", "-1.42", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_seven;
    print STDOUT ("FT${test}c = \"$opt_seven\"\n") unless $opt_seven == -1.42;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_seven;
    &doit1 ("-seven", "-1.43");
    print STDOUT ("FT${test}b\n") unless defined $opt_seven;
    print STDOUT ("FT${test}c = \"$opt_seven\"\n") unless $opt_seven == -1.43;
    print STDOUT ("FT${test}z\n") if @ARGV != 0;
}

if ( ++$test == $single || $all ) {
    undef $opt_seven;
    undef $opt_one;
    &doit1 ("-seven", "1.3", "-seven", "-one", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_seven;
    print STDOUT ("FT${test}c = \"$opt_seven\"\n") unless $opt_seven == 0;
    print STDOUT ("FT${test}d\n") unless defined $opt_one;
    print STDOUT ("FT${test}e = \"$opt_one\"\n") unless $opt_one == 1;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_seven;
    &doit1 ("-seven", "--");
    print STDOUT ("FT${test}b\n") unless defined $opt_seven;
    print STDOUT ("FT${test}c = \"$opt_seven\"\n") unless  $opt_seven == 0;
}

if ( ++$test == $single || $all ) {
    undef $opt_seven;
    &doit1 ("-seven");
    print STDOUT ("FT${test}b\n") unless defined $opt_seven;
    print STDOUT ("FT${test}c = \"$opt_seven\"\n") unless  $opt_seven == 0;
}

if ( ++$test == $single || $all ) {
    undef @opt_sevens;
    undef $opt_one;
    &doit1 ("-sevens", "-2.74", "-sevens", "-one", "foo");
    print STDOUT ("FT${test}b\n") unless defined @opt_sevens;
    print STDOUT ("FT${test}c [0] = \"$opt_sevens[0]\"\n") unless $opt_sevens[0] == -2.74;
    print STDOUT ("FT${test}c [1] = \"$opt_sevens[1]\"\n") unless $opt_sevens[1] == 0;
    print STDOUT ("FT${test}d\n") unless defined $opt_one;
    print STDOUT ("FT${test}e = \"$opt_one\"\n") unless $opt_one == 1;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

################ Empty option ################

if ( ++$test == $single || $all ) {
    undef $opt_seven;
    undef $opt_;
    local (@stdopts) = ("", @stdopts);
    &doit1 ("-seven", "-1.42", "-", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_seven;
    print STDOUT ("FT${test}c = \"$opt_seven\"\n") unless $opt_seven == -1.42;
    print STDOUT ("FT${test}d\n") unless defined $opt_;
    print STDOUT ("FT${test}g = \"$opt_\"\n") unless $opt_ == 1;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef @opt_sevens;
    undef $opt_one;
    undef $opt_;
    local (@stdopts) = ("", @stdopts);
    &doit1 ("-sevens", "-2.74", "-sevens", "-", "-one", "--", "foo");
    print STDOUT ("FT${test}b\n") unless defined @opt_sevens;
    print STDOUT ("FT${test}c [0] = \"$opt_sevens[0]\"\n") unless $opt_sevens[0] == -2.74;
    print STDOUT ("FT${test}c [1] = \"$opt_sevens[1]\"\n") unless $opt_sevens[1] == 0;
    print STDOUT ("FT${test}d\n") unless defined $opt_one;
    print STDOUT ("FT${test}e = \"$opt_one\"\n") unless $opt_one == 1;
    print STDOUT ("FT${test}f\n") unless defined $opt_;
    print STDOUT ("FT${test}g = \"$opt_\"\n") unless $opt_ == 1;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

################ Other delimeters ################

if ( ++$test == $single || $all ) {
    undef $opt_seven;
    local (@stdopts) = ("/", @stdopts);
    &doit1 ("/seven", "-1.42", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_seven;
    print STDOUT ("FT${test}c = \"$opt_seven\"\n") unless $opt_seven == -1.42;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef @opt_sevens;
    undef $opt_one;
    local (@stdopts) = ("/", @stdopts);
    &doit1 ("/sevens", "-2.74", "/sevens", "/one", "--", "foo");
    print STDOUT ("FT${test}b\n") unless defined @opt_sevens;
    print STDOUT ("FT${test}c [0] = \"$opt_sevens[0]\"\n") unless $opt_sevens[0] == -2.74;
    print STDOUT ("FT${test}c [1] = \"$opt_sevens[1]\"\n") unless $opt_sevens[1] == 0;
    print STDOUT ("FT${test}d\n") unless defined $opt_one;
    print STDOUT ("FT${test}e = \"$opt_one\"\n") unless $opt_one == 1;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    local (@stdopts) = ("/", @stdopts);
    print STDERR ("Expect: Unknown option: /\n");
    &doit0 ("/sevens", "-2.74", "/sevens", "/one", "//", "foo");
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_seven;
    &doit1 ("--seven", "-1.42", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_seven;
    print STDOUT ("FT${test}c = \"$opt_seven\"\n") unless $opt_seven == -1.42;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef @opt_sevens;
    undef $opt_one;
    &doit1 ("--sevens", "-2.74", "+sevens", "-one", "--", "foo");
    print STDOUT ("FT${test}b\n") unless defined @opt_sevens;
    print STDOUT ("FT${test}c [0] = \"$opt_sevens[0]\"\n") unless $opt_sevens[0] == -2.74;
    print STDOUT ("FT${test}c [1] = \"$opt_sevens[1]\"\n") unless $opt_sevens[1] == 0;
    print STDOUT ("FT${test}d\n") unless defined $opt_one;
    print STDOUT ("FT${test}e = \"$opt_one\"\n") unless $opt_one == 1;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    print STDERR ("Expect: Unknown option: +\n");
    &doit0 ("--sevens", "-2.74", "+sevens", "-one", "++", "foo");
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

################ Auto-abbrev ################

if ( ++$test == $single || $all ) {
    undef $opt_six;
    undef $opt_seven;
    &doit1 ("-six", "-1.42", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_six;
    print STDOUT ("FT${test}c\n") if defined $opt_seven;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_eight;
    &doit1 ("-e", "xxx", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_eight;
    print STDOUT ("FT${test}c = \"$opt_eight\"\n") unless $opt_eight eq "xxx";
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_six;
    undef $opt_seven;
    print STDERR ("Expect: ",
		  "Option s is ambiguous (seven, sevens, six, sixs)\n",
		  "Expect: Unknown option: 1.42\n");
    &doit0 ("-s", "-1.42", "foo");
    print STDOUT ("FT${test}b\n") if defined $opt_six;
    print STDOUT ("FT${test}c\n") if defined $opt_seven;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

################ Aliases ################

if ( ++$test == $single || $all ) {
    undef $opt_eight;
    undef $opt_opt8t;
    &doit1 ("-opt8", "1", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_eight;
    print STDOUT ("FT${test}c\n") if defined $opt_opt8;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

# 2.12 Allow ? as an alias (not primary).
if ( ++$test == $single || $all ) {
    local (@stdopts) = ("help|?");
    undef $opt_help;
    &doit1 ("-help", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_help;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    local (@stdopts) = ("help", "?", "??", "?|help");
    undef $opt_help;
    print STDERR ("Expect: Error in option spec: \"?\"\n");
    print STDERR ("Expect: Error in option spec: \"??\"\n");
    print STDERR ("Expect: Error in option spec: \"?|help\"\n");
    &doit0 ("-?", "foo");
    print STDOUT ("FT${test}b\n") if defined $opt_help;
}

if ( ++$test == $single || $all ) {
    local (@stdopts) = ("help|?");
    undef $opt_help;
    &doit1 ("-?", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_help;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

################ Dashes in option name ################

if ( ++$test == $single || $all ) {
    undef $opt_s_ix;
    undef $opt_seven;
    &doit1 ("-opt-nine", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_opt_nine;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

################ Arguments between options ################

if ( ++$test == $single || $all ) {
    undef $opt_six;
    &doit1 ("foo", "-six", "1.2", "bar");
    print STDOUT ("FT${test}b\n") unless defined $opt_six;
    print STDOUT ("FT${test}z\n") if @ARGV != 2 || $ARGV[0] ne "foo"
                                        	|| $ARGV[1] ne "bar";
}

################ POSIX compliancy ################

{   package newgetopt;
    $getopt_compat = 0;
    $order = $REQUIRE_ORDER;
}

if ( ++$test == $single || $all ) {
    undef $opt_seven;
    &doit1 ("-seven", "1.2", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_seven;
    print STDOUT ("FT${test}c = \"$opt_seven\"\n") if $opt_seven != 1.2;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    undef $opt_seven;
    &doit1 ("foo", "-seven", "1.2");
    print STDOUT ("FT${test}b\n") if defined $opt_seven;
    print STDOUT ("FT${test}z\n") if @ARGV != 3 || $ARGV[0] ne "foo";
}

{   package newgetopt;
    $getopt_compat = 1;
    $order = $PERMUTE;
}

################ Bundling ################

{ package newgetopt; $bundling = 1;}

if ( ++$test == $single || $all ) {
    # Short options should not be case sensitive.
    local (@stdopts) = ('a!','A=i','b=s','Foo');
    undef $opt_a;
    undef $opt_A;
    undef $opt_b;
    undef $opt_Foo;
    undef $opt_foo;
    print STDOUT ("Expect: Ignoring '!' modifier for short option a\n");
    &doit1 ("foo", "-abseven", "-A2", "--foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_a;
    print STDOUT ("FT${test}c = $opt_a\n") unless $opt_a == 1;
    print STDOUT ("FT${test}d\n") unless defined $opt_b;
    print STDOUT ("FT${test}e = \"$opt_b\"\n") unless $opt_b eq "seven";
    print STDOUT ("FT${test}f\n") unless defined $opt_A;
    print STDOUT ("FT${test}g = $opt_A\n") unless $opt_A == 2;
    print STDOUT ("FT${test}h\n") unless defined $opt_Foo;
    print STDOUT ("FT${test}i\n") if defined $opt_foo;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    # Short options should not be case sensitive.
    # Unless ignorecase > 1
    { package newgetopt; $ignorecase = 2; }
    local (@stdopts) = ('A=i@','b=s','Foo');
    undef $opt_A;
    undef $opt_a;
    undef @opt_a;
    undef $opt_Foo;
    undef $opt_foo;
    &doit1 ("foo", "-A2", "-a", "3", "--foo");
    print STDOUT ("FT${test}b\n") unless defined @opt_A;
    print STDOUT ("FT${test}c = (@opt_a)\n") unless @opt_A == 2;
    print STDOUT ("FT${test}d = $opt_a[0]\n") unless $opt_A[0] == 2;
    print STDOUT ("FT${test}e = $opt_a[1]\n") unless $opt_A[1] == 3;
    print STDOUT ("FT${test}f\n") if defined $opt_a;
    print STDOUT ("FT${test}h\n") unless defined $opt_Foo;
    print STDOUT ("FT${test}i\n") if defined $opt_foo;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
    { package newgetopt; $ignorecase = 1; }
}

if ( ++$test == $single || $all ) {
    local (@stdopts) = ('a!','b=s','c:s','d=s@','e:s@','f=i','g:i');
    $opt_a = 1;
    undef $opt_b;
    print STDOUT ("Expect: Ignoring '!' modifier for short option a\n");
    &doit1 ("foo", "--noa", "-bseven");
    print STDOUT ("FT${test}b\n") unless defined $opt_a;
    print STDOUT ("FT${test}c = $opt_a\n") unless $opt_a == 0;
    print STDOUT ("FT${test}d\n") unless defined $opt_b;
    print STDOUT ("FT${test}e = \"$opt_b\"\n") unless $opt_b eq "seven";
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    local (@stdopts) = ('a','b=s','c:s','d=s@','e:s@','f=i','g:i');
    undef $opt_c;
    undef $opt_f;
    &doit1 ("foo", "-cseven", "-f24");
    print STDOUT ("FT${test}b\n") unless defined $opt_c;
    print STDOUT ("FT${test}c = $opt_a\n") unless $opt_c eq "seven";
    print STDOUT ("FT${test}d\n") unless defined $opt_f;
    print STDOUT ("FT${test}e = \"$opt_b\"\n") unless $opt_f == 24;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    local (@stdopts) = ('a','b=s','c:s','d=s@','e:s@','f=i','g:i');
    undef $opt_c;
    &doit1 ("foo", "-c--seven");
    print STDOUT ("FT${test}b\n") unless defined $opt_c;
    print STDOUT ("FT${test}c = \"$opt_c\"\n") unless $opt_c eq "--seven";
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    local (@stdopts) = ('a','b=s','c:s','d=s@','e:s@','f=i','g:i');
    undef $opt_a;
    undef $opt_g;
    &doit1 ("foo", "-ga");
    print STDOUT ("FT${test}b\n") unless defined $opt_g;
    print STDOUT ("FT${test}c = $opt_g\n") unless $opt_g == 0;
    print STDOUT ("FT${test}d\n") unless defined $opt_a;
    print STDOUT ("FT${test}e = $opt_a\n") unless $opt_a == 1;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    local (@stdopts) = ('a','b=s','c:s','d=s@','e:s@','f=i','g:i');
    undef $opt_a;
    undef $opt_f;
    print STDOUT ("Expect: Value \"a\" invalid for option f (number expected)\n");
    &doit0 ("foo", "-fa");
    print STDOUT ("FT${test}b\n") if defined $opt_f;
    print STDOUT ("FT${test}c\n") unless defined $opt_a;
    print STDOUT ("FT${test}d = $opt_a\n") unless $opt_a == 1;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    local (@stdopts) = ('a','b=s','c:s','d=s@','e:s@','f=i','g:i');
    undef $opt_f;
    undef $opt_x;
    print STDOUT ("Expect: Value \"x\" invalid for option f (number expected)\n");
    &doit0 ("foo", "-fx");
    print STDOUT ("FT${test}b\n") if defined $opt_f;
    print STDOUT ("FT${test}c\n") if defined $opt_x;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    local (@stdopts) = ('foo','a','b=s','c:s','d=s@','e:s@','g:i','f:s');
    undef $opt_foo;
    &doit1 ("foo", "--foo", "--fo", "--f", "-ga");
    print STDOUT ("FT${test}b\n") unless defined $opt_g;
    print STDOUT ("FT${test}c\n") unless defined $opt_a;
    print STDOUT ("FT${test}d\n") unless defined $opt_foo;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    local (@stdopts) = ('a','A=i','c:s','d=s@','e:s@','g:i','f:s');
    undef $opt_a;
    undef $opt_A;
    &doit1 ("-a", "-A2", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_a;
    print STDOUT ("FT${test}c = $opt_a\n") unless $opt_a == 1;
    print STDOUT ("FT${test}d\n") unless defined $opt_A;
    print STDOUT ("FT${test}e = $opt_A\n") unless $opt_A == 2;;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    local (@stdopts) = ('f=s', 'foo');
    undef $opt_f;
    undef $opt_foo;
    &doit1 ("-fxx", "-foo", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_f;
    print STDOUT ("FT${test}c = $opt_a\n") unless $opt_f eq 'oo';
    print STDOUT ("FT${test}d\n") if defined $opt_foo;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    $newgetopt'bundling = 2;	#';
    local (@stdopts) = ('f=s', 'foo');
    undef $opt_f;
    undef $opt_foo;
    &doit1 ("-fxx", "-foo", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_f;
    print STDOUT ("FT${test}c = $opt_a\n") unless $opt_f eq 'xx';
    print STDOUT ("FT${test}d\n") unless defined $opt_foo;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
    $newgetopt'bundling = 1;	#';
}

{ package newgetopt; $bundling = 0;}

################ Pass-Through ################

{ package newgetopt; $passthrough = 1;}

if ( ++$test == $single || $all ) {
    &doit1 ("-xx", "x1=foo");
    print STDOUT ("FT$ {test}b\n") unless @ARGV == 2;
    print STDOUT ("FT$ {test}c\n") unless "@ARGV" eq "-xx x1=foo";
}

if ( ++$test == $single || $all ) {
    { package newgetopt; $order = $REQUIRE_ORDER; }
    &doit1 ("-xx", "x1=foo");
    print STDOUT ("FT$ {test}b\n") unless @ARGV == 2;
    print STDOUT ("FT$ {test}c\n") unless "@ARGV" eq "-xx x1=foo";
    { package newgetopt; $order = $PERMUTE; }
}

if ( ++$test == $single || $all ) {
    &doit1 ("-four", "-blech", "-six=6.3");
    print STDOUT ("FT$ {test}b\n") unless @ARGV == 2;
    print STDOUT ("FT$ {test}c\n") unless "@ARGV" eq "-four -blech";
    print STDOUT ("FT$ {test}d\n") unless defined $opt_six;
    print STDOUT ("FT$ {test}e = ", $opt_six, "\n") unless $opt_six == 6.3;
}

if ( ++$test == $single || $all ) {
    &doit1 ("-six=blech", "-four", "6");
    print STDOUT ("FT$ {test}b\n") unless @ARGV == 1;
    print STDOUT ("FT$ {test}c\n") unless "@ARGV" eq "-six=blech";
    print STDOUT ("FT$ {test}d\n") unless defined $opt_four;
    print STDOUT ("FT$ {test}e = ", $opt_four, "\n") unless $opt_four == 6;
}

{ package newgetopt; $passthrough = 0;}

################ Option character case ################

if ( ++$test == $single || $all ) {
    local (@stdopts) = ("Help");
    undef $opt_Help;
    undef $opt_help;
    undef $opt_HeLp;
    &doit1 ("-HeLp");
    print STDOUT ("FT$ {test}b\n") unless defined $opt_Help;
    print STDOUT ("FT$ {test}c\n") if defined $opt_help;
    print STDOUT ("FT$ {test}d\n") if defined $opt_HeLp;
}

if ( ++$test == $single || $all ) {
    local (@stdopts) = ("Help", "HeLp");
    $newgetopt'ignorecase = 0;	#';
    undef $opt_Help;
    undef $opt_help;
    undef $opt_HeLp;
    &doit1 ("-HeLp");
    print STDOUT ("FT$ {test}b\n") if defined $opt_Help;
    print STDOUT ("FT$ {test}c\n") if defined $opt_help;
    print STDOUT ("FT$ {test}d\n") unless defined $opt_HeLp;
    $newgetopt'ignorecase = 1;	#';
}

# Bug report by Brian Wilson <bcwilson@VNET.IBM.COM>, Jan 1997:
# The other bug is that ignorecase is only evaluated with autoabbrev
# on during option processing.
# >>> solved in 2.06
if ( ++$test == $single || $all ) {
    local (@stdopts) = ("Help");
    $newgetopt'autoabbrev = 0;	#';
    undef $opt_Help;
    undef $opt_help;
    undef $opt_HeLp;
    &doit1 ("-HeLp");
    print STDOUT ("FT$ {test}b\n") unless defined $opt_Help;
    print STDOUT ("FT$ {test}c\n") if defined $opt_help;
    print STDOUT ("FT$ {test}d\n") if defined $opt_HeLp;
    $newgetopt'autoabbrev = 1;	#';
}

################ Hashes ################

if ( ++$test == $single || $all ) {
    # Basic string.
    undef %opt_hs;
    &doit1 ("-hs", "x1=foo");
    print STDOUT ("FT$ {test}b\n") unless defined $opt_hs{"x1"};
    print STDOUT ("FT$ {test}c\n") unless $opt_hs{"x1"} eq "foo";
}

if ( ++$test == $single || $all ) {
    # Basic integer.
    undef %opt_hi;
    &doit1 ("-hi", "x1=12");
    print STDOUT ("FT$ {test}b\n") unless defined $opt_hi{"x1"};
    print STDOUT ("FT$ {test}c\n") unless $opt_hi{"x1"} eq "12";
}

if ( ++$test == $single || $all ) {
    # Multiple + default.
    undef %opt_hi;
    &doit1 ("-hi", "x1=12", "-hi", "x2");
    print STDOUT ("FT$ {test}b\n") unless defined $opt_hi{"x1"};
    print STDOUT ("FT$ {test}c\n") unless $opt_hi{"x1"} eq "12";
    print STDOUT ("FT$ {test}d\n") unless defined $opt_hi{"x2"};
    print STDOUT ("FT$ {test}e\n") unless $opt_hi{"x2"} eq "1";
}

if ( ++$test == $single || $all ) {
    # Arg type check.
    undef %opt_hi;
    print STDOUT ("Expect: Value \"abc\" invalid for option hi",
		  " (number expected)\n");
    &doit0 ("-hi", "x1=abc");
    print STDOUT ("FT$ {test}b\n") if defined $opt_hi{"x1"};
}

if ( ++$test == $single || $all ) {
    # Empties.
    undef %opt_hs;
    &doit1 ("-hs", "x1=");
    print STDOUT ("FT$ {test}b\n") unless defined $opt_hs{"x1"};
    print STDOUT ("FT$ {test}c\n") unless $opt_hs{"x1"} eq "";
}

if ( ++$test == $single || $all ) {
    # Empties.
    undef %opt_hi;
    print STDOUT ("Expect: Value \"\" invalid for option hi",
		  " (number expected)\n");
    &doit0 ("-hi", "x2=");
    print STDOUT ("FT$ {test}b\n") if defined $opt_hi{"x2"};
}

################ Finish ################

print STDOUT ("Number of tests = ", $test, ".\n");

1;
