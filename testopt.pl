#!/usr/local/bin/perl -s
# testopt.pl -- Testbed for newgetopt.pl / Getopt::Long.pm .
# RCS Info        : $Id$
# Author          : Johan Vromans
# Created On      : ***
# Last Modified By: Johan Vromans
# Last Modified On: Sat Aug  4 17:29:40 2001
# Update Count    : 122
# Status          : Internal use only.

package foo;

unless ( defined &NGetOpt ) {
    use blib;
    unshift (@INC, ".");
    require "newgetopt.pl";
}

# perl -s variables
$debug = defined $main'debug ? $main'debug : 0;
$verbose = defined $main'verbose ? $main'verbose : 0;
$numbered = defined $main'numbered ? $main'numbered : 0;

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
	    "fourx=o", "fivex:o",
	    "fourxs=o@", "fivexs:o@",
	    "six=f", "seven:f",
	    "sixs=f@", "sevens:f@",
	    "eight|opt8=s",
	    "hi=i%", "hs=s%",
	    "opt-nine",
	    "v+");

sub showtest {
    print STDOUT ("#[$_[0]] test $test\n") if $verbose;
}

sub doit {
    @ARGV = @_;
    print STDOUT ($numbered ? "Test $test: " : "", "@ARGV\n") if $verbose;
    $newgetopt'debug = 1 if $test == $single;	#';
    undef $result;
    eval {$result = &NGetOpt (@stdopts);};
#    unless ( defined $result ) {
#	print STDERR ($@);
#    }
}
sub doit1 {
    my $msg = '';
    local $SIG{__WARN__} = sub { $msg .= "@_" };
    local $SIG{__DIE__} = sub { $msg .= "FATAL: @_" };
    &doit;
    print STDOUT ("FT${test}a\n") unless $result;
    if ( $msg ) {
	chomp($msg);
	print STDOUT ("FT${test}a '$msg'\n");
    }
}
sub doit0 {
    my $exp = shift;
    my $msg = '';
    local $SIG{__WARN__} = sub { $msg .= "@_" };
    local $SIG{__DIE__} = sub { $msg .= "FATAL: @_" };
    &doit;
    print STDOUT ("FT${test}a\n") if $result;
    unless ( $msg eq $exp ) {
	chomp($msg);
	print STDOUT ("FT${test}a '$msg'\n");
    }
}

################ Setup ################

$test = 0;

################ No args ################

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    &doit1 ();
}

################ Non-opt args ################

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    &doit1 ("foo");
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    &doit1 ("--", "foo");
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

################ Simple args ################

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_one;
    &doit1 ("-one", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_one;
    print STDOUT ("FT${test}c = \"$opt_one\"\n") unless $opt_one == 1;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_one;
    &doit1 ("-one", "--", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_one;
    print STDOUT ("FT${test}c = \"$opt_one\"\n") unless $opt_one == 1;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_one;
    &doit1 ("-ONe", "--", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_one;
    print STDOUT ("FT${test}c = \"$opt_one\"\n") unless $opt_one == 1;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
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
    showtest(__LINE__);
    undef $opt_one;
    &doit0 ("Option one does not take an argument\n",
	    "--one=", "foo");
    print STDOUT ("FT${test}b = \"$opt_one\"\n") if defined $opt_one;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_one;
    &doit1 ("-one", "-one", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_one;
    print STDOUT ("FT${test}c = \"$opt_one\"\n") unless $opt_one == 1;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    $opt_one = 2;
    &doit1 ("-one", "-noone", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_one;
    print STDOUT ("FT${test}c = \"$opt_one\"\n") unless $opt_one == 0;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

# Negation with aliases.
if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    $opt_one = 2;
    local (@stdopts) = ("one|two!");
    &doit1 ("-one", "-noone", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_one;
    print STDOUT ("FT${test}c = \"$opt_one\"\n") unless $opt_one == 0;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

# Must apply to all of them.
if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    $opt_one = 2;
    local (@stdopts) = ("one|two!");
    &doit1 ("-one", "-notwo", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_one;
    print STDOUT ("FT${test}c = \"$opt_one\"\n") unless $opt_one == 0;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}


################# String opt (mandatory) ################

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_two;
    &doit1 ("-two", "bar", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_two;
    print STDOUT ("FT${test}c = \"$opt_two\"\n") unless $opt_two eq "bar";
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_two;
    &doit1 ("-two", "-bar", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_two;
    print STDOUT ("FT${test}c = \"$opt_two\"\n") unless $opt_two eq "-bar";
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_two;
    &doit1 ("-two", "-bar", "-two", "blech", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_two;
    print STDOUT ("FT${test}c = \"$opt_two\"\n") unless $opt_two eq "blech";
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_two;
    &doit1 ("--two=-bar", "--two=blech", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_two;
    print STDOUT ("FT${test}c = \"$opt_two\"\n") unless $opt_two eq "blech";
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_two;
    &doit1 ("-two", "--");
    print STDOUT ("FT${test}b\n") unless defined $opt_two;
    print STDOUT ("FT${test}b = \"$opt_two\"\n") unless $opt_two eq "--";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_two;
    &doit1 ("--two=--");
    print STDOUT ("FT${test}b\n") unless defined $opt_two;
    print STDOUT ("FT${test}b = \"$opt_two\"\n") unless  $opt_two eq "--";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_two;
    &doit0 ("Option two requires an argument\n",
	    "-two");
    print STDOUT ("FT${test}b = \"$opt_two\"\n") if defined $opt_two;
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_two;
    &doit0 ("Option two requires an argument\n",
	    "--two=");
    print STDOUT ("FT${test}b = \"$opt_two\"\n") if defined $opt_two;
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef @opt_twos;
    &doit1 ("-twos", "-bar", "-twos", "blech", "foo");
    print STDOUT ("FT${test}b\n") unless defined @opt_twos;
    print STDOUT ("FT${test}c = \"$opt_twos[0]\@0\"\n") unless $opt_twos[0] eq "-bar";
    print STDOUT ("FT${test}c = \"$opt_twos[1]\@1\"\n") unless $opt_twos[1] eq "blech";
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

################ String opt (optional) ################

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_three;
    &doit1 ("-three", "bar", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_three;
    print STDOUT ("FT${test}c = \"$opt_three\"\n") unless $opt_three eq "bar";
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
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
    showtest(__LINE__);
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
    showtest(__LINE__);
    undef $opt_three;
    &doit1 ("-three", "--");
    print STDOUT ("FT${test}b\n") unless defined $opt_three;
    print STDOUT ("FT${test}c = \"$opt_three\"\n") unless  $opt_three eq "";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_three;
    &doit1 ("-three");
    print STDOUT ("FT${test}b\n") unless defined $opt_three;
    print STDOUT ("FT${test}c = \"$opt_three\"\n") unless  $opt_three eq "";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
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
    showtest(__LINE__);
    undef $opt_four;
    &doit1 ("-four", "327", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_four;
    print STDOUT ("FT${test}c = \"$opt_four\"\n") unless $opt_four == 327;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_four;
    &doit1 ("-four", "327");
    print STDOUT ("FT${test}b\n") unless defined $opt_four;
    print STDOUT ("FT${test}c = \"$opt_four\"\n") unless $opt_four == 327;
    print STDOUT ("FT${test}z\n") if @ARGV != 0;
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_four;
    &doit1 ("-four", "-6", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_four;
    print STDOUT ("FT${test}c = \"$opt_four\"\n") unless $opt_four == -6;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_four;
    &doit0 ("Value \"bar\" invalid for option four (number expected)\n",
	    "-four", "bar", "foo");
    print STDOUT ("FT${test}b = \"$opt_four\"\n") if defined $opt_four;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_four;
    &doit0 ("Value \"-bar\" invalid for option four (number expected)\n",
	    "-four", "-bar", "foo");
    print STDOUT ("FT${test}b = \"$opt_four\"\n") if defined $opt_four;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_four;
    &doit0 ("Value \"--\" invalid for option four (number expected)\n",
	    "-four", "--");
    print STDOUT ("FT${test}b = \"$opt_four\"\n") if defined $opt_four;
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_four;
    &doit0 ("Option four requires an argument\n",
	    "-four");
    print STDOUT ("FT${test}b = \"$opt_four\"\n") if defined $opt_four;
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef @opt_fours;
    &doit1 ("-fours", "-24", "-fours", "12", "foo");
    print STDOUT ("FT${test}b\n") unless defined @opt_fours;
    print STDOUT ("FT${test}c [0] = \"$opt_fours[0]\"\n") unless $opt_fours[0] == -24;
    print STDOUT ("FT${test}c [1] = \"$opt_fours[1]\"\n") unless $opt_fours[1] == 12;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

################ Int opt (optional) ################

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_five;
    &doit1 ("-five", "foo");
    print STDOUT ("FT${test}b = \"$opt_five\"\n") if $opt_five != 0;
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_five;
    &doit1 ("-five", "12", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_five;
    print STDOUT ("FT${test}c = \"$opt_five\"\n") unless $opt_five == 12;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_five;
    &doit1 ("-five", "12");
    print STDOUT ("FT${test}b\n") unless defined $opt_five;
    print STDOUT ("FT${test}c = \"$opt_five\"\n") unless $opt_five == 12;
    print STDOUT ("FT${test}z\n") if @ARGV != 0;
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_five;
    &doit1 ("-five", "-12", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_five;
    print STDOUT ("FT${test}c = \"$opt_five\"\n") unless $opt_five == -12;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_five;
    &doit1 ("-five", "+12", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_five;
    print STDOUT ("FT${test}c = \"$opt_five\"\n") unless $opt_five == +12;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_five;
    &doit1 ("-five", "-12");
    print STDOUT ("FT${test}b\n") unless defined $opt_five;
    print STDOUT ("FT${test}c = \"$opt_five\"\n") unless $opt_five == -12;
    print STDOUT ("FT${test}z\n") if @ARGV != 0;
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
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
    showtest(__LINE__);
    undef $opt_five;
    &doit1 ("-five", "--");
    print STDOUT ("FT${test}b\n") unless defined $opt_five;
    print STDOUT ("FT${test}c = \"$opt_five\"\n") unless  $opt_five == 0;
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_five;
    &doit1 ("-five");
    print STDOUT ("FT${test}b\n") unless defined $opt_five;
    print STDOUT ("FT${test}c = \"$opt_five\"\n") unless  $opt_five == 0;
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
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

################ Ext Int opt (mandatory) ################

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_fourx;
    &doit1 ("-fourx", "327", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_fourx;
    print STDOUT ("FT${test}c = \"$opt_fourx\"\n") unless $opt_fourx == 327;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_fourx;
    &doit1 ("-fourx", "0b00101001");
    print STDOUT ("FT${test}b\n") unless defined $opt_fourx;
    print STDOUT ("FT${test}c = \"$opt_fourx\"\n") unless $opt_fourx == 0b00101001;
    print STDOUT ("FT${test}z\n") if @ARGV != 0;
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_fourx;
    &doit1 ("-fourx", "0327", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_fourx;
    print STDOUT ("FT${test}c = \"$opt_fourx\"\n") unless $opt_fourx == 0327;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_fourx;
    &doit1 ("-fourx", "0x327");
    print STDOUT ("FT${test}b\n") unless defined $opt_fourx;
    print STDOUT ("FT${test}c = \"$opt_fourx\"\n") unless $opt_fourx == 0x327;
    print STDOUT ("FT${test}z\n") if @ARGV != 0;
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_fourx;
    &doit1 ("-fourx", "-6", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_fourx;
    print STDOUT ("FT${test}c = \"$opt_fourx\"\n") unless $opt_fourx == -6;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_fourx;
    &doit0 ("Value \"019\" invalid for option fourx (extended number expected)\n",
	    "-fourx", "019", "foo");
    print STDOUT ("FT${test}b = \"$opt_fourx\"\n") if defined $opt_fourx;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_fourx;
    &doit0 ("Value \"0xefg\" invalid for option fourx (extended number expected)\n",
	    "-fourx", "0xefg", "foo");
    print STDOUT ("FT${test}b = \"$opt_fourx\"\n") if defined $opt_fourx;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_fourx;
    &doit0 ("Value \"0b12\" invalid for option fourx (extended number expected)\n",
	    "-fourx", "0b12");
    print STDOUT ("FT${test}b = \"$opt_fourx\"\n") if defined $opt_fourx;
}

################ Float opt (mandatory) ################

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_six;
    &doit1 ("-six", "327", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_six;
    print STDOUT ("FT${test}c = \"$opt_six\"\n") unless $opt_six == 327;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_six;
    &doit1 ("-six", "3.27", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_six;
    print STDOUT ("FT${test}c = \"$opt_six\"\n") unless $opt_six == 3.27;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_six;
    &doit1 ("-six", "3.18e2");
    print STDOUT ("FT${test}b\n") unless defined $opt_six;
    print STDOUT ("FT${test}c = \"$opt_six\"\n") unless $opt_six == 318;
    print STDOUT ("FT${test}z\n") if @ARGV != 0;
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_six;
    &doit1 ("-six", "+3.18e2");
    print STDOUT ("FT${test}b\n") unless defined $opt_six;
    print STDOUT ("FT${test}c = \"$opt_six\"\n") unless $opt_six == 318;
    print STDOUT ("FT${test}z\n") if @ARGV != 0;
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_six;
    &doit1 ("-six", "3.18e+2");
    print STDOUT ("FT${test}b\n") unless defined $opt_six;
    print STDOUT ("FT${test}c = \"$opt_six\"\n") unless $opt_six == 318;
    print STDOUT ("FT${test}z\n") if @ARGV != 0;
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_six;
    &doit1 ("-six", "+3.18e+2");
    print STDOUT ("FT${test}b\n") unless defined $opt_six;
    print STDOUT ("FT${test}c = \"$opt_six\"\n") unless $opt_six == 318;
    print STDOUT ("FT${test}z\n") if @ARGV != 0;
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_six;
    &doit1 ("-six", "-6", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_six;
    print STDOUT ("FT${test}c = \"$opt_six\"\n") unless $opt_six == -6;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_six;
    &doit1 ("-six", "-6.4", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_six;
    print STDOUT ("FT${test}c = \"$opt_six\"\n") unless $opt_six == -6.4;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_six;
    &doit1 ("-six", "-6.4e-1");
    print STDOUT ("FT${test}b\n") unless defined $opt_six;
    print STDOUT ("FT${test}c = \"$opt_six\"\n") unless $opt_six == -.64;
    print STDOUT ("FT${test}z\n") if @ARGV != 0;
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_six;
    &doit0 ("Value \"bar\" invalid for option six (real number expected)\n",
	    "-six", "bar", "foo");
    print STDOUT ("FT${test}b = \"$opt_six\"\n") if defined $opt_six;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_six;
    &doit0 ("Value \"-bar\" invalid for option six (real number expected)\n",
	    "-six", "-bar", "foo");
    print STDOUT ("FT${test}b = \"$opt_six\"\n") if defined $opt_six;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_six;
    &doit0 ("Value \"--\" invalid for option six (real number expected)\n",
	    "-six", "--");
    print STDOUT ("FT${test}b = \"$opt_six\"\n") if defined $opt_six;
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_six;
    &doit0 ("Option six requires an argument\n",
	    "-six");
    print STDOUT ("FT${test}b = \"$opt_six\"\n") if defined $opt_six;
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef @opt_sixs;
    &doit1 ("-sixs", "-.24", "-sixs", "1.2", "foo");
    print STDOUT ("FT${test}b\n") unless defined @opt_sixs;
    print STDOUT ("FT${test}c [0] = \"$opt_sixs[0]\"\n") unless $opt_sixs[0] == -0.24;
    print STDOUT ("FT${test}c [1] = \"$opt_sixs[1]\"\n") unless $opt_sixs[1] == 1.2;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

################ Float opt (optional) ################

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_seven;
    &doit1 ("-seven", "foo");
    print STDOUT ("FT${test}b = \"$opt_seven\"\n") if $opt_seven != 0;
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_seven;
    &doit1 ("-seven", "12", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_seven;
    print STDOUT ("FT${test}c = \"$opt_seven\"\n") unless $opt_seven == 12;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_seven;
    &doit1 ("-seven", "12");
    print STDOUT ("FT${test}b\n") unless defined $opt_seven;
    print STDOUT ("FT${test}c = \"$opt_seven\"\n") unless $opt_seven == 12;
    print STDOUT ("FT${test}z\n") if @ARGV != 0;
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_seven;
    &doit1 ("-seven", "1.2", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_seven;
    print STDOUT ("FT${test}c = \"$opt_seven\"\n") unless $opt_seven == 1.2;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_seven;
    &doit1 ("-seven", "-12", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_seven;
    print STDOUT ("FT${test}c = \"$opt_seven\"\n") unless $opt_seven == -12;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_seven;
    &doit1 ("-seven", "-1.42", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_seven;
    print STDOUT ("FT${test}c = \"$opt_seven\"\n") unless $opt_seven == -1.42;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_seven;
    &doit1 ("-seven", "-1.43");
    print STDOUT ("FT${test}b\n") unless defined $opt_seven;
    print STDOUT ("FT${test}c = \"$opt_seven\"\n") unless $opt_seven == -1.43;
    print STDOUT ("FT${test}z\n") if @ARGV != 0;
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
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
    showtest(__LINE__);
    undef $opt_seven;
    &doit1 ("-seven", "--");
    print STDOUT ("FT${test}b\n") unless defined $opt_seven;
    print STDOUT ("FT${test}c = \"$opt_seven\"\n") unless  $opt_seven == 0;
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_seven;
    &doit1 ("-seven");
    print STDOUT ("FT${test}b\n") unless defined $opt_seven;
    print STDOUT ("FT${test}c = \"$opt_seven\"\n") unless  $opt_seven == 0;
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
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
    showtest(__LINE__);
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
    showtest(__LINE__);
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

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_;
    local (@stdopts) = ("", @stdopts);
    &doit1 ("-", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_;
    &doit1 ("-", "foo");
    print STDOUT ("FT${test}b\n") if defined $opt_;
    print STDOUT ("FT${test}z\n") if @ARGV != 2 || "@ARGV" ne "- foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    { package newgetopt; $bundling = 1; }
    undef $opt_;
    local (@stdopts) = ("", @stdopts);
    &doit1 ("-", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
    { package newgetopt; $bundling = 0; }
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    { package newgetopt; $bundling = 1; }
    undef $opt_;
    &doit1 ("-", "foo");
    print STDOUT ("FT${test}b\n") if defined $opt_;
    print STDOUT ("FT${test}z\n") if @ARGV != 2 || "@ARGV" ne "- foo";
    { package newgetopt; $bundling = 0; }
}

################ Other delimeters ################

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_seven;
    local (@stdopts) = ("/", @stdopts);
    &doit1 ("/seven", "-1.42", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_seven;
    print STDOUT ("FT${test}c = \"$opt_seven\"\n") unless $opt_seven == -1.42;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
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
    showtest(__LINE__);
    local (@stdopts) = ("/", @stdopts);
    &doit0 ("Unknown option: /\n",
	    "/sevens", "-2.74", "/sevens", "/one", "//", "foo");
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_seven;
    &doit1 ("--seven", "-1.42", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_seven;
    print STDOUT ("FT${test}c = \"$opt_seven\"\n") unless $opt_seven == -1.42;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
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
    showtest(__LINE__);
    &doit0 ("Unknown option: +\n",
	    "--sevens", "-2.74", "+sevens", "-one", "++", "foo");
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

################ Auto-abbrev ################

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_six;
    undef $opt_seven;
    &doit1 ("-six", "-1.42", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_six;
    print STDOUT ("FT${test}c\n") if defined $opt_seven;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_eight;
    &doit1 ("-e", "xxx", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_eight;
    print STDOUT ("FT${test}c = \"$opt_eight\"\n") unless $opt_eight eq "xxx";
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_six;
    undef $opt_seven;
    &doit0 ("Option s is ambiguous (seven, sevens, six, sixs)\n".
	    "Unknown option: 1.42\n",
	    "-s", "-1.42", "foo");
    print STDOUT ("FT${test}b\n") if defined $opt_six;
    print STDOUT ("FT${test}c\n") if defined $opt_seven;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

################ Aliases ################

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_eight;
    undef $opt_opt8;
    &doit1 ("-opt8", "1", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_eight;
    print STDOUT ("FT${test}c\n") if defined $opt_opt8;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

# 2.12 Allow ? as an alias (not primary).
if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    local (@stdopts) = ("help|?");
    undef $opt_help;
    &doit1 ("-help", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_help;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    local (@stdopts) = ("help", "?", "??", "?|help");
    undef $opt_help;
    &doit0 ("FATAL: Error in option spec: \"?\"\n".
	    "Error in option spec: \"??\"\n".
	    "Error in option spec: \"?|help\"\n",
	    "-?", "foo");
    print STDOUT ("FT${test}b\n") if defined $opt_help;
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    local (@stdopts) = ("help|?");
    undef $opt_help;
    &doit1 ("-?", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_help;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

################ Dashes in option name ################

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_opt_nine;
    &doit1 ("-opt-nine", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_opt_nine;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

################ Arguments between options ################

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
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
    showtest(__LINE__);
    undef $opt_seven;
    &doit1 ("-seven", "1.2", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_seven;
    print STDOUT ("FT${test}c = \"$opt_seven\"\n") if $opt_seven != 1.2;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
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
    showtest(__LINE__);
    # Short options should not be case sensitive.
    local (@stdopts) = ('a!','A=i','b=s','Foo');
    undef $opt_a;
    undef $opt_A;
    undef $opt_b;
    undef $opt_Foo;
    undef $opt_foo;
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
    showtest(__LINE__);
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
    showtest(__LINE__);
    local (@stdopts) = ('a!','b=s','c:s','d=s@','e:s@','f=i','g:i');
    $opt_a = 1;
    undef $opt_b;
    &doit1 ("foo", "--noa", "-bseven");
    print STDOUT ("FT${test}b\n") unless defined $opt_a;
    print STDOUT ("FT${test}c = $opt_a\n") unless $opt_a == 0;
    print STDOUT ("FT${test}d\n") unless defined $opt_b;
    print STDOUT ("FT${test}e = \"$opt_b\"\n") unless $opt_b eq "seven";
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
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
    showtest(__LINE__);
    local (@stdopts) = ('a','b=s','c:s','d=s@','e:s@','f=i','g:i');
    undef $opt_c;
    &doit1 ("foo", "-c--seven");
    print STDOUT ("FT${test}b\n") unless defined $opt_c;
    print STDOUT ("FT${test}c = \"$opt_c\"\n") unless $opt_c eq "--seven";
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
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
    showtest(__LINE__);
    local (@stdopts) = ('a','b=s','c:s','d=s@','e:s@','f=i','g:i');
    undef $opt_a;
    undef $opt_f;
    &doit0 ("Value \"a\" invalid for option f (number expected)\n",
	    "foo", "-fa");
    print STDOUT ("FT${test}b\n") if defined $opt_f;
    print STDOUT ("FT${test}c\n") unless defined $opt_a;
    print STDOUT ("FT${test}d = $opt_a\n") unless $opt_a == 1;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    local (@stdopts) = ('a','b=s','c:s','d=s@','e:s@','f=i','g:i');
    undef $opt_f;
    undef $opt_x;
    &doit0 ("Value \"x\" invalid for option f (number expected)\n".
	    "Unknown option: x\n",
	    "foo", "-fx");
    print STDOUT ("FT${test}b\n") if defined $opt_f;
    print STDOUT ("FT${test}c\n") if defined $opt_x;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    local (@stdopts) = ('foo','a','b=s','c:s','d=s@','e:s@','g:i','f:s');
    undef $opt_foo;
    &doit1 ("foo", "--foo", "--fo", "--f", "-ga");
    print STDOUT ("FT${test}b\n") unless defined $opt_g;
    print STDOUT ("FT${test}c\n") unless defined $opt_a;
    print STDOUT ("FT${test}d\n") unless defined $opt_foo;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
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
    showtest(__LINE__);
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
    showtest(__LINE__);
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

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    local (@stdopts) = ('a', 'l=i', 'w=i', 'f', 'foo');
    undef $opt_a;
    undef $opt_l;
    undef $opt_w;
    undef $opt_f;
    &doit1 ("-al24fw80", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_a;
    print STDOUT ("FT${test}c = $opt_l\n") unless $opt_l eq '24';
    print STDOUT ("FT${test}d = $opt_w\n") unless $opt_w eq '80';
    print STDOUT ("FT${test}e\n") unless defined $opt_f;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    local (@stdopts) = ('a', 'l=i', 'w=f', 'f', 'foo');
    undef $opt_a;
    undef $opt_l;
    undef $opt_w;
    undef $opt_f;
    &doit1 ("-al24w80e3f", "foo");
    print STDOUT ("FT${test}b\n") unless defined $opt_a;
    print STDOUT ("FT${test}c = $opt_l\n") unless $opt_l == 24;
    print STDOUT ("FT${test}d = $opt_w\n") unless $opt_w == 80000;
    print STDOUT ("FT${test}e\n") unless defined $opt_f;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    local (@stdopts) = ('a=o', 'b=o', 'x=o');
    undef $opt_a;
    undef $opt_b;
    undef $opt_x;
    &doit1 ("-a24b0b10x0x10", "foo");
    print STDOUT ("FT${test}b = $opt_a\n") unless $opt_a == 24;
    print STDOUT ("FT${test}c = $opt_b\n") unless $opt_b == 0b10;
    print STDOUT ("FT${test}d = $opt_x\n") unless $opt_x == 0x10;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

{ package newgetopt; $bundling = 0;}

################ Bundling + getopt_compat ################

{ package newgetopt; $bundling = 0; $getopt_compat = 0; }

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    &doit0 ("Unknown option: two=bar\n",
	    "+two=bar");
}

{ package newgetopt; $bundling = 0; $getopt_compat = 1; }

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    &doit1 ("+two=bar", "foo" );
    print STDOUT ("FT${test}b\n") unless defined $opt_two;
    print STDOUT ("FT${test}c = $opt_two\n") unless $opt_two eq "bar";
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

{ package newgetopt; $bundling = 1; $getopt_compat = 1; }

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    &doit0 ("Unknown option: two=bar\n",
	    "+two=bar");
}

{ package newgetopt; $bundling = 2; $getopt_compat = 1; }

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    &doit1 ("+two=bar", "foo" );
    print STDOUT ("FT${test}b\n") unless defined $opt_two;
    print STDOUT ("FT${test}c = $opt_two\n") unless $opt_two eq "bar";
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

{ package newgetopt; $bundling = 0; $getopt_compat = 1; }

################ Pass-Through ################

{ package newgetopt; $passthrough = 1;}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    &doit1 ("-xx", "x1=foo");
    print STDOUT ("FT$ {test}b\n") unless @ARGV == 2;
    print STDOUT ("FT$ {test}c\n") unless "@ARGV" eq "-xx x1=foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    { package newgetopt; $order = $REQUIRE_ORDER; }
    &doit1 ("-xx", "x1=foo");
    print STDOUT ("FT$ {test}b\n") unless @ARGV == 2;
    print STDOUT ("FT$ {test}c\n") unless "@ARGV" eq "-xx x1=foo";
    { package newgetopt; $order = $PERMUTE; }
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    &doit1 ("-four", "-blech", "-six=6.3");
    print STDOUT ("FT$ {test}b\n") unless @ARGV == 2;
    print STDOUT ("FT$ {test}c\n") unless "@ARGV" eq "-four -blech";
    print STDOUT ("FT$ {test}d\n") unless defined $opt_six;
    print STDOUT ("FT$ {test}e = ", $opt_six, "\n") unless $opt_six == 6.3;
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    &doit1 ("-six=blech", "-four", "6");
    print STDOUT ("FT$ {test}b\n") unless @ARGV == 1;
    print STDOUT ("FT$ {test}c\n") unless "@ARGV" eq "-six=blech";
    print STDOUT ("FT$ {test}d\n") unless defined $opt_four;
    print STDOUT ("FT$ {test}e = ", $opt_four, "\n") unless $opt_four == 6;
}

{ package newgetopt; $passthrough = 0;}

################ Option character case ################

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
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
    showtest(__LINE__);
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
    showtest(__LINE__);
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

# Bug report from tmohr@schleim.qwe.de (Torsten Mohr).
# It is incorrect use, but a bug nevertheless.
if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    my @INCS;
    my %DEFS;
    local (@stdopts) = ("I=s@" => \@INCS, "D=s%" => \%DEFS);
    # This generates warnings. It shouldn't.
    &doit1 ("-I", "foo", "-d", "aa=bb");
    print STDOUT ("FT$ {test}b (@INCS)\n") unless "@INCS" eq "foo";
    print STDOUT ("FT$ {test}c\n") unless keys(%DEFS) == 1;
    print STDOUT ("FT$ {test}d\n") unless $DEFS{aa} eq "bb";
}

################ Hashes ################

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    # Basic string.
    undef %opt_hs;
    &doit1 ("-hs", "x1=foo");
    print STDOUT ("FT$ {test}b\n") unless defined $opt_hs{"x1"};
    print STDOUT ("FT$ {test}c\n") unless $opt_hs{"x1"} eq "foo";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    # Basic integer.
    undef %opt_hi;
    &doit1 ("-hi", "x1=12");
    print STDOUT ("FT$ {test}b\n") unless defined $opt_hi{"x1"};
    print STDOUT ("FT$ {test}c\n") unless $opt_hi{"x1"} eq "12";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    # Multiple + default.
    undef %opt_hi;
    &doit1 ("-hi", "x1=12", "-hi", "x2");
    print STDOUT ("FT$ {test}b\n") unless defined $opt_hi{"x1"};
    print STDOUT ("FT$ {test}c\n") unless $opt_hi{"x1"} eq "12";
    print STDOUT ("FT$ {test}d\n") unless defined $opt_hi{"x2"};
    print STDOUT ("FT$ {test}e\n") unless $opt_hi{"x2"} eq "1";
}

# if ( ++$test == $single || $all ) {
#     showtest(__LINE__);
#     local (%opt_hi);
# 
#     # TODO : hi gets =s%, but D gets only =s.
# 
#     local (@stdopts) = ("hi|D=s", \%opt_hi);
#     &doit1 ("-hi", "x1=12", "-D", "x2");
#     print STDOUT ("FT$ {test}b\n") unless defined $opt_hi{"x1"};
#     print STDOUT ("FT$ {test}c\n") unless $opt_hi{"x1"} eq "12";
#     print STDOUT ("FT$ {test}d\n") unless defined $opt_hi{"x2"};
#     print STDOUT ("FT$ {test}e\n") unless $opt_hi{"x2"} eq "1";
# }

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    # Arg type check.
    undef %opt_hi;
    &doit0 ("Value \"abc\" invalid for option hi (number expected)\n",
	    "-hi", "x1=abc");
    print STDOUT ("FT$ {test}b\n") if defined $opt_hi{"x1"};
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    # Empties.
    undef %opt_hs;
    &doit1 ("-hs", "x1=");
    print STDOUT ("FT$ {test}b\n") unless defined $opt_hs{"x1"};
    print STDOUT ("FT$ {test}c\n") unless $opt_hs{"x1"} eq "";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    # Greedyness
    undef %opt_hs;
    &doit1 ("-hs", "x1=x1=x1");
    print STDOUT ("FT$ {test}b\n") unless defined $opt_hs{"x1"};
    print STDOUT ("FT$ {test}c ", $opt_hs{"x1"}, "\n") unless $opt_hs{"x1"} eq "x1=x1";
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    # Empties.
    undef %opt_hi;
    &doit0 ("Value \"\" invalid for option hi (number expected)\n",
	    "-hi", "x2=");
    print STDOUT ("FT$ {test}b\n") if defined $opt_hi{"x2"};
}

################ Increments ################

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_v;
    &doit1 ("-v", "foo");
    print STDOUT ("FT$ {test}b\n") unless defined $opt_v;
    print STDOUT ("FT$ {test}c\n") unless $opt_v == 1;
    print STDOUT ("FT$ {test}d\n") unless @ARGV == 1 && $ARGV[0] eq 'foo';
}

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    $opt_v = 3;
    &doit1 ("-v", "-v", "-v", "foo", "-v");
    print STDOUT ("FT$ {test}b\n") unless defined $opt_v;
    print STDOUT ("FT$ {test}c\n") unless $opt_v == 7;
    print STDOUT ("FT$ {test}d\n") unless @ARGV == 1 && $ARGV[0] eq 'foo';
}

{ package newgetopt; $bundling = 1;}
if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    undef $opt_v;
    &doit1 ("-vvv", "foo");
    print STDOUT ("FT$ {test}b\n") unless defined $opt_v;
    print STDOUT ("FT$ {test}c\n") unless $opt_v == 3;
    print STDOUT ("FT$ {test}d\n") unless @ARGV == 1 && $ARGV[0] eq 'foo';
}
{ package newgetopt; $bundling = 0;}

################ Miscellaneous ################

#  From: "Epstein, Caleb" <cepstein@Montgomery.com>
#  Subject: Strict warning from Getopt::Long under
#  Date: Thu, 11 Feb 1999 08:37:00 -0500
#
#  I get warnings from perl with Getopt::Long and code like this:
#
#  		#!/usr/local/bin/perl -w
#  		use strict;
#  		use Getopt::Long;
#  		my @ARY;
#  		my $retval = GetOptions ("A|apple=s@" => \@ARY);
#  		print join ("\n", @ARY), "\n";
#
#  The warning message is:
#
#  	Use of uninitialized value at
#  /home/cepstein/lib/perl5/auto/Getopt/Long/GetOptions.al line 173.

if ( ++$test == $single || $all ) {
    showtest(__LINE__);
    # Option names that are not lowercase give warnings unless 
    # ignorecase is switched off.
    $newgetopt'debug = 1 if $test == $single;	#';
    $newgetopt'ignorecase = 0;
    my @ARY;
    my $retval = NGetOpt ("A|apple=s@" => \@ARY);
}

################ Finish ################

print STDOUT ("Number of tests = ", $test, ".\n");

1;
