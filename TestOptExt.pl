#!/usr/bin/perl

# TestOptExt.pl -- Testbed for Getopt::Long.pm (extended features).
# RCS Info        : $Id$
# Author          : Johan Vromans
# Created On      : ***
# Last Modified By: Johan Vromans
# Last Modified On: Fri Jul 28 19:29:02 2000
# Update Count    : 117
# Status          : Internal use only

package foo;
use blib;
use Getopt::Long;
use strict;

my $all = 1;
my $single = 0;
$single = shift (@ARGV) if @ARGV == 1;
my @defcfg = qw(default);
if ( $single ) {
    Getopt::Long::config ("debug");
    open (STDERR, ">&STDOUT");
    push (@defcfg, "debug");
    $all = 0;
}
select (STDERR); $| = 1;
select (STDOUT); $| = 1;

################ Setup ################

my $test = 0;
use vars qw($opt_one $opt_two $opt_three @opt_three);

################ Testing internal linkage ################

if ( ++$test == $single || $all ) {

    my %linkage = ();
    my $o_one;
    my $o_two;
    my @o_three;

    @ARGV = qw( -one -two 2 -three 1 -three 4 foo );
    print STDOUT ("FT${test}a\n") 
	unless GetOptions ("one" => \$o_one,
			   "two=i" => \$o_two,
			   "three=i@" => \@o_three);
    print STDOUT ("FT${test}c\n") if defined $opt_one;
    print STDOUT ("FT${test}d\n") unless defined $o_one;
    print STDOUT ("FT${test}e\n") unless $o_one == 1;
    print STDOUT ("FT${test}f\n") if defined $opt_two;
    print STDOUT ("FT${test}g\n") unless defined $o_two;
    print STDOUT ("FT${test}h\n") unless $o_two == 2;
    print STDOUT ("FT${test}i\n") if defined $opt_three;
    print STDOUT ("FT${test}j\n") if @opt_three;
    print STDOUT ("FT${test}k\n") unless @o_three;
    print STDOUT ("FT${test}l\n") unless @o_three == 2;
    print STDOUT ("FT${test}m\n") unless $o_three[0] == 1 && $o_three[1] == 4;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

################ Passing but not using user linkage ################

if ( ++$test == $single || $all ) {

    my %linkage = ();
    my $o_one;
    my $o_two;
    my @o_three;

    @ARGV = qw( -one -two 2 -three 1 -three 4 foo );
    print STDOUT ("FT${test}a\n") 
	unless GetOptions (\%linkage,
			   "one" => \$o_one,
			   "two=i" => \$o_two,
			   "three=i@" => \@o_three);
    print STDOUT ("FT${test}c\n") if defined $opt_one;
    print STDOUT ("FT${test}d\n") unless defined $o_one;
    print STDOUT ("FT${test}e\n") unless $o_one == 1;
    print STDOUT ("FT${test}f\n") if defined $opt_two;
    print STDOUT ("FT${test}g\n") unless defined $o_two;
    print STDOUT ("FT${test}h\n") unless $o_two == 2;
    print STDOUT ("FT${test}i\n") if defined $opt_three;
    print STDOUT ("FT${test}j\n") if @opt_three;
    print STDOUT ("FT${test}k\n") unless @o_three;
    print STDOUT ("FT${test}l\n") unless @o_three == 2;
    print STDOUT ("FT${test}m\n") unless $o_three[0] == 1 && $o_three[1] == 4;
    my @k = keys(%linkage);
    print STDOUT ("FT${test}n (@k)\n") unless @k == 0;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

################ Using user linkage ################

if ( ++$test == $single || $all ) {

    my %linkage = ();
    my $o_one;
    my $o_two;
    my @o_three;

    @ARGV = qw( -one -three 1 -three 4 foo );
    print STDOUT ("FT${test}a\n") 
	unless GetOptions (\%linkage,
			   "one",
			   "two=i",
			   "three=i@");
    print STDOUT ("FT${test}a\n") if defined $opt_one;
    print STDOUT ("FT${test}b\n") if defined $opt_two;
    print STDOUT ("FT${test}c\n") if defined $opt_three;
    print STDOUT ("FT${test}d\n") if @opt_three;
    my @k = keys(%linkage);
    print STDOUT ("FT${test}e (@k)\n") unless @k == 2;
    print STDOUT ("FT${test}f\n") unless (exists $linkage{"one"});
    print STDOUT ("FT${test}g\n") unless (defined $linkage{"one"});
    print STDOUT ("FT${test}h\n") if (exists $linkage{"two"});
    print STDOUT ("FT${test}i\n") if (defined $linkage{"two"});
    print STDOUT ("FT${test}j\n") unless (exists $linkage{"three"});
    print STDOUT ("FT${test}k\n") unless (defined $linkage{"three"});
    print STDOUT ("FT${test}m\n") unless $linkage{"one"} == 1;
    print STDOUT ("FT${test}n\n") unless ref($linkage{"three"}) eq 'ARRAY';
    my @a = @{$linkage{"three"}};
    print STDOUT ("FT${test}o -- ",scalar(@a), "\n") unless scalar(@a) == 2;
    print STDOUT ("FT${test}p\n") unless $a[0] == 1 && $a[1] == 4;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

################ Using user linkage with an Object ################

if ( ++$test == $single || $all ) {

    {	package Foo;
	sub new () { return bless {}; }
    }

    my $linkage = Foo->new();
    my $o_one;
    my $o_two;
    my @o_three;

    @ARGV = qw( -one -three 1 -three 4 foo );
    print STDOUT ("FT${test}a\n") 
	unless GetOptions ($linkage,
			   "one",
			   "two=i",
			   "three=i@");
    print STDOUT ("FT${test}a\n") if defined $opt_one;
    print STDOUT ("FT${test}b\n") if defined $opt_two;
    print STDOUT ("FT${test}c\n") if defined $opt_three;
    print STDOUT ("FT${test}d\n") if @opt_three;
    my @k = keys(%$linkage);
    print STDOUT ("FT${test}e (@k)\n") unless @k == 2;
    print STDOUT ("FT${test}f\n") unless (exists $linkage->{"one"});
    print STDOUT ("FT${test}g\n") unless (defined $linkage->{"one"});
    print STDOUT ("FT${test}h\n") if (exists $linkage->{"two"});
    print STDOUT ("FT${test}i\n") if (defined $linkage->{"two"});
    print STDOUT ("FT${test}j\n") unless (exists $linkage->{"three"});
    print STDOUT ("FT${test}k\n") unless (defined $linkage->{"three"});
    print STDOUT ("FT${test}m\n") unless $linkage->{"one"} == 1;
    print STDOUT ("FT${test}n\n") unless ref($linkage->{"three"}) eq 'ARRAY';
    my @a = @{$linkage->{"three"}};
    print STDOUT ("FT${test}o -- ",scalar(@a), "\n") unless scalar(@a) == 2;
    print STDOUT ("FT${test}p\n") unless $a[0] == 1 && $a[1] == 4;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

################ Mixing internal and user linkage ################

if ( ++$test == $single || $all ) {

    my %linkage = ();
    my $o_one;
    my $o_two;
    my @o_three;

    @ARGV = qw( -one -two 2 -three 1 -three 4 foo );
    print STDOUT ("FT${test}a\n") 
	unless GetOptions (\%linkage,
			   "one",
			   "two=i", \$o_two,
			   "three=i@");
    print STDOUT ("FT${test}a\n") if defined $opt_one;
    print STDOUT ("FT${test}b\n") if defined $opt_two;
    print STDOUT ("FT${test}c\n") if defined $opt_three;
    print STDOUT ("FT${test}d\n") if @opt_three;
    my @k = keys(%linkage);
    print STDOUT ("FT${test}e (@k)\n") unless @k == 2;
    print STDOUT ("FT${test}f\n") unless (exists $linkage{"one"});
    print STDOUT ("FT${test}g\n") unless (defined $linkage{"one"});
    print STDOUT ("FT${test}h\n") if (exists $linkage{"two"});
    print STDOUT ("FT${test}i\n") if (defined $linkage{"two"});
    print STDOUT ("FT${test}j\n") unless (exists $linkage{"three"});
    print STDOUT ("FT${test}k\n") unless (defined $linkage{"three"});
    print STDOUT ("FT${test}l\n") unless $linkage{"one"} == 1;
    print STDOUT ("FT${test}m\n") unless $o_two == 2;
    print STDOUT ("FT${test}n\n") unless ref($linkage{"three"}) eq 'ARRAY';
    my @a = @{$linkage{"three"}};
    print STDOUT ("FT${test}o -- ",scalar(@a), "\n") unless scalar(@a) == 2;
    print STDOUT ("FT${test}p\n") unless $a[0] == 1 && $a[1] == 4;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

################ Some error situations ################

if ( ++$test == $single || $all ) {

    my %linkage = ();
    @ARGV = qw( -one -two 2 -three 1 -three 4 foo );
    eval { GetOptions (\%linkage,
		       "one",
		       "<>", \%linkage,
		       "three=i@");
       };
    print STDERR ("FT${test}a\n") unless $@;
    print STDERR ("FT${test}b '$@'\n")
      unless $@ =~ /^Option spec <> requires a reference to a subroutine\nError in option spec: "HASH\(0x/;
}

if ( ++$test == $single || $all ) {

    my $foo;
    my %linkage = ('<>' => \$foo);
    @ARGV = qw( -one -two 2 -three 1 -three 4 foo );
    @ARGV = qw( -one -two 2 -three 1 -three 4 foo );
    eval { GetOptions (\%linkage,
		       "one",
		       "<>",
		       "three=i@");
       };
    print STDERR ("FT${test}a\n") unless $@;
    print STDERR ("FT${test}b '$@'\n")
      unless $@ =~ /^Option spec <> requires a reference to a subroutine\nError in option spec: "SCALAR\(0x/;
}

################ Callbacks ################

my %xx;

sub cb {
    print STDOUT ("Callback($_[0],$_[1])\n") if $single;
    $xx{$_[0]} = $_[1];
}

sub cbx {
    &cb;
    warn ("Option fail for \"$_[0]\"\n");
    $Getopt::Long::error++;
}

sub cby {
    &cb;
    die ("Option fail for \"$_[0]\"\n");
}

sub process {
    print STDOUT ("Process($_[0])\n") if $single;
    $xx{$_[0]} = -1;
}

if ( ++$test == $single || $all ) {

    my %linkage = ('one', \&cb);
    my $o_one;
    my $o_two;
    my @o_three;
    %xx = ();

    Getopt::Long::config(@defcfg);
    @ARGV = qw( -one -two 2 -three 1 -three 4 foo );
    print STDOUT ("FT${test}a\n") 
	unless GetOptions (\%linkage,
			   "one",
			   "two=i", \&cb,
			   "three=i@");
    print STDOUT ("FT${test}a\n") if defined $opt_one;
    print STDOUT ("FT${test}b\n") if defined $opt_two;
    print STDOUT ("FT${test}c\n") if defined $opt_three;
    print STDOUT ("FT${test}d\n") if @opt_three;
    my @k = keys(%linkage);
    print STDOUT ("FT${test}e (@k)\n") unless @k == 2;
    print STDOUT ("FT${test}f\n") unless (exists $linkage{"one"});
    print STDOUT ("FT${test}g\n") unless (defined $linkage{"one"});
    print STDOUT ("FT${test}h\n") if (exists $linkage{"two"});
    print STDOUT ("FT${test}i\n") if (defined $linkage{"two"});
    print STDOUT ("FT${test}j\n") unless (exists $linkage{"three"});
    print STDOUT ("FT${test}k\n") unless (defined $linkage{"three"});
    print STDOUT ("FT${test}l\n") unless $xx{"one"} == 1;
    print STDOUT ("FT${test}m\n") unless $xx{"two"} == 2;
    print STDOUT ("FT${test}n\n") unless ref($linkage{"three"}) eq 'ARRAY';
    my @a = @{$linkage{"three"}};
    print STDOUT ("FT${test}o -- ",scalar(@a), "\n") unless scalar(@a) == 2;
    print STDOUT ("FT${test}p\n") unless $a[0] == 1 && $a[1] == 4;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {

    my %linkage = ('one', \&cb);
    my $o_one;
    my $o_two;
    my @o_three;
    %xx = ();

    Getopt::Long::config(@defcfg);
    @ARGV = qw( -one -two 2 -three 1 bar -three 4 foo );
    print STDOUT ("FT${test}a\n") 
	unless GetOptions (\%linkage,
			   "one",
			   "<>", \&process,
			   "two=i", \&cb,
			   "three=i@");
    print STDOUT ("FT${test}a\n") if defined $opt_one;
    print STDOUT ("FT${test}b\n") if defined $opt_two;
    print STDOUT ("FT${test}c\n") if defined $opt_three;
    print STDOUT ("FT${test}d\n") if @opt_three;
    my @k = keys(%linkage);
    print STDOUT ("FT${test}e (@k)\n") unless @k == 2;
    print STDOUT ("FT${test}f\n") unless (exists $linkage{"one"});
    print STDOUT ("FT${test}g\n") unless (defined $linkage{"one"});
    print STDOUT ("FT${test}h\n") if (exists $linkage{"two"});
    print STDOUT ("FT${test}i\n") if (defined $linkage{"two"});
    print STDOUT ("FT${test}j\n") unless (exists $linkage{"three"});
    print STDOUT ("FT${test}k\n") unless (defined $linkage{"three"});
    print STDOUT ("FT${test}l\n") unless $xx{"one"} == 1;
    print STDOUT ("FT${test}m\n") unless $xx{"two"} == 2;
    print STDOUT ("FT${test}n\n") unless ref($linkage{"three"}) eq 'ARRAY';
    my @a = @{$linkage{"three"}};
    print STDOUT ("FT${test}o -- ",scalar(@a), "\n") unless scalar(@a) == 2;
    print STDOUT ("FT${test}p\n") unless $a[0] == 1 && $a[1] == 4;
    print STDOUT ("FT${test}x\n") unless $xx{"bar"} == -1;
    print STDOUT ("FT${test}y\n") unless $xx{"foo"} == -1;
    print STDOUT ("FT${test}z\n") if @ARGV > 0;
}

if ( ++$test == $single || $all ) {

    my %linkage = ('one', \&cb);
    my $o_one;
    my $o_two;
    my @o_three;
    %xx = ();

    Getopt::Long::config(@defcfg);
    @ARGV = qw( -one -two 2 -three 1 bar -three 4 -- foo );
    print STDOUT ("FT${test}a\n") 
	unless GetOptions (\%linkage,
			   "one",
			   "<>", \&process,
			   "two=i", \&cb,
			   "three=i@");
    print STDOUT ("FT${test}a\n") if defined $opt_one;
    print STDOUT ("FT${test}b\n") if defined $opt_two;
    print STDOUT ("FT${test}c\n") if defined $opt_three;
    print STDOUT ("FT${test}d\n") if @opt_three;
    my @k = keys(%linkage);
    print STDOUT ("FT${test}e (@k)\n") unless @k == 2;
    print STDOUT ("FT${test}f\n") unless (exists $linkage{"one"});
    print STDOUT ("FT${test}g\n") unless (defined $linkage{"one"});
    print STDOUT ("FT${test}h\n") if (exists $linkage{"two"});
    print STDOUT ("FT${test}i\n") if (defined $linkage{"two"});
    print STDOUT ("FT${test}j\n") unless (exists $linkage{"three"});
    print STDOUT ("FT${test}k\n") unless (defined $linkage{"three"});
    print STDOUT ("FT${test}l\n") unless $xx{"one"} == 1;
    print STDOUT ("FT${test}m\n") unless $xx{"two"} == 2;
    print STDOUT ("FT${test}n\n") unless ref($linkage{"three"}) eq 'ARRAY';
    my @a = @{$linkage{"three"}};
    print STDOUT ("FT${test}o -- ",scalar(@a), "\n") unless scalar(@a) == 2;
    print STDOUT ("FT${test}p\n") unless $a[0] == 1 && $a[1] == 4;
    print STDOUT ("FT${test}x\n") unless $xx{"bar"} == -1;
    print STDOUT ("FT${test}y\n") if exists $xx{"foo"};
    print STDOUT ("FT${test}z\n") unless @ARGV == 1;
}

if ( ++$test == $single || $all ) {

    my %linkage = ('one', \&cb);
    my $o_one;
    my $o_two;
    my @o_three;
    %xx = ();

    @ARGV = qw( -one -two 2 -three 1 bar -three 4 -- foo );
    Getopt::Long::config (@defcfg, "require_order");
    print STDOUT ("FT${test}a\n") 
	unless GetOptions (\%linkage,
			   "one",
			   "<>", \&process,
			   "two=i", \&cb,
			   "three=i@");
    print STDOUT ("FT${test}a\n") if defined $opt_one;
    print STDOUT ("FT${test}b\n") if defined $opt_two;
    print STDOUT ("FT${test}c\n") if defined $opt_three;
    print STDOUT ("FT${test}d\n") if @opt_three;
    my @k = keys(%linkage);
    print STDOUT ("FT${test}e (@k)\n") unless @k == 2;
    print STDOUT ("FT${test}f\n") unless (exists $linkage{"one"});
    print STDOUT ("FT${test}g\n") unless (defined $linkage{"one"});
    print STDOUT ("FT${test}h\n") if (exists $linkage{"two"});
    print STDOUT ("FT${test}i\n") if (defined $linkage{"two"});
    print STDOUT ("FT${test}j\n") unless (exists $linkage{"three"});
    print STDOUT ("FT${test}k\n") unless (defined $linkage{"three"});
    print STDOUT ("FT${test}l\n") unless $xx{"one"} == 1;
    print STDOUT ("FT${test}m\n") unless $xx{"two"} == 2;
    print STDOUT ("FT${test}n\n") unless ref($linkage{"three"}) eq 'ARRAY';
    my @a = @{$linkage{"three"}};
    print STDOUT ("FT${test}o -- ",scalar(@a), "\n") unless scalar(@a) == 1;
    print STDOUT ("FT${test}p\n") unless $a[0] == 1;
    print STDOUT ("FT${test}x\n") if exists $xx{"bar"};
    print STDOUT ("FT${test}y\n") if exists $xx{"foo"};
    print STDOUT ("FT${test}z\n") unless @ARGV == 5
	&& "@ARGV" eq "bar -three 4 -- foo";
}

if ( ++$test == $single || $all ) {

    my %linkage = ('one', \&cbx);
    my $o_one;
    my $o_two;
    my @o_three;
    %xx = ();
    my $msg = '';
    local ($SIG{__WARN__}) = sub { $msg .= "@_" };

    @ARGV = qw( -one -two 2 -three 1 bar -three 4 -- foo );
    Getopt::Long::config (@defcfg, "require_order");
    print STDOUT ("FT${test}a\n") 
	if GetOptions (\%linkage,
		       "<>", \&process,
		       "one",
		       "two=i", \&cb,
		       "three=i@");
    print STDOUT ("FT${test}a\n") if defined $opt_one;
    print STDOUT ("FT${test}b\n") if defined $opt_two;
    print STDOUT ("FT${test}c\n") if defined $opt_three;
    print STDOUT ("FT${test}d\n") if @opt_three;
    my @k = keys(%linkage);
    print STDOUT ("FT${test}e (@k)\n") unless @k == 2;
    print STDOUT ("FT${test}f\n") unless (exists $linkage{"one"});
    print STDOUT ("FT${test}g\n") unless (defined $linkage{"one"});
    print STDOUT ("FT${test}h\n") if (exists $linkage{"two"});
    print STDOUT ("FT${test}i\n") if (defined $linkage{"two"});
    print STDOUT ("FT${test}j\n") unless (exists $linkage{"three"});
    print STDOUT ("FT${test}k\n") unless (defined $linkage{"three"});
    print STDOUT ("FT${test}l\n") unless $xx{"one"} == 1;
    print STDOUT ("FT${test}m\n") unless $xx{"two"} == 2;
    print STDOUT ("FT${test}n\n") unless ref($linkage{"three"}) eq 'ARRAY';
    my @a = @{$linkage{"three"}};
    print STDOUT ("FT${test}o -- ",scalar(@a), "\n") unless scalar(@a) == 1;
    print STDOUT ("FT${test}p\n") unless $a[0] == 1;
    print STDOUT ("FT${test}q\n")
      unless $msg eq "Option fail for \"one\"\n";
    print STDOUT ("FT${test}x\n") if exists $xx{"bar"};
    print STDOUT ("FT${test}y\n") if exists $xx{"foo"};
    print STDOUT ("FT${test}z\n") unless @ARGV == 5
	&& "@ARGV" eq "bar -three 4 -- foo";
}

if ( ++$test == $single || $all ) {

    my %linkage = ('one', \&cby);
    my $o_one;
    my $o_two;
    my @o_three;
    %xx = ();
    my $msg = '';
    local ($SIG{__WARN__}) = sub { $msg .= "@_" };

    @ARGV = qw( >one >two 2 <three 1 bar <three 4 -- foo );
    Getopt::Long::config (@defcfg, "require_order");
    print STDOUT ("FT${test}a\n")
	if GetOptions (\%linkage,
		       "<>", "<>", \&process,
		       "one",
		       "two=i", \&cb,
		       "three=i@");
    print STDOUT ("FT${test}a\n") if defined $opt_one;
    print STDOUT ("FT${test}b\n") if defined $opt_two;
    print STDOUT ("FT${test}c\n") if defined $opt_three;
    print STDOUT ("FT${test}d\n") if @opt_three;
    my @k = keys(%linkage);
    print STDOUT ("FT${test}e (@k)\n") unless @k == 2;
    print STDOUT ("FT${test}f\n") unless (exists $linkage{"one"});
    print STDOUT ("FT${test}g\n") unless (defined $linkage{"one"});
    print STDOUT ("FT${test}h\n") if (exists $linkage{"two"});
    print STDOUT ("FT${test}i\n") if (defined $linkage{"two"});
    print STDOUT ("FT${test}j\n") unless (exists $linkage{"three"});
    print STDOUT ("FT${test}k\n") unless (defined $linkage{"three"});
    print STDOUT ("FT${test}l\n") unless $xx{"one"} == 1;
    print STDOUT ("FT${test}m\n") unless $xx{"two"} == 2;
    print STDOUT ("FT${test}n\n") unless ref($linkage{"three"}) eq 'ARRAY';
    my @a = @{$linkage{"three"}};
    print STDOUT ("FT${test}o -- ",scalar(@a), "\n") unless scalar(@a) == 1;
    print STDOUT ("FT${test}p\n") unless $a[0] == 1;
    print STDOUT ("FT${test}q\n")
      unless $msg eq "Option fail for \"one\"\n";
    print STDOUT ("FT${test}x\n") if exists $xx{"bar"};
    print STDOUT ("FT${test}y\n") if exists $xx{"foo"};
    print STDOUT ("FT${test}z\n") unless @ARGV == 5
	&& "@ARGV" eq "bar <three 4 -- foo";
}

################ Hashes ################

if ( ++$test == $single || $all ) {

    my %hi = ();

    Getopt::Long::config(@defcfg);
    @ARGV = qw( -hi one=2 -- foo );
    print STDOUT ("FT${test}a\n") 
	unless GetOptions ("hi=i", \%hi);

    print STDOUT ("FT${test}a\n") unless defined $hi{"one"};
    print STDOUT ("FT${test}b\n") unless $hi{"one"} == 2;
    print STDOUT ("FT${test}z\n") unless @ARGV == 1
	&& "@ARGV" eq "foo";
}

################ Multiple Options ################

if ( ++$test == $single || $all ) {

    my @v = ();

    Getopt::Long::config(@defcfg);
    @ARGV = qw( -v -verbose -- foo );
    print STDOUT ("FT${test}a\n") 
	unless GetOptions ("verbose|v" => \@v);

    print STDOUT ("FT${test}a\n") unless @v == 2;
    print STDOUT ("FT${test}z\n") unless @ARGV == 1
	&& "@ARGV" eq "foo";
}

################ Bundling ################

if ( ++$test == $single || $all ) {

    # If bundling, it is not allowed to split on aa=bb.
    # Also, prevent warnings for undefind $bopctl{$o}.

    my @v = ();
    my %w = ();

    Getopt::Long::config(@defcfg, "bundling");
    @ARGV = qw( -vwv=vw -wvv=vw -- foo );
    print STDOUT ("FT${test}a\n") 
	unless GetOptions ("v=s" => \@v, "vee=s" => \@v, "w=s" => \%w, "wee=s" => \%w);

    print STDOUT ("FT${test}a\n") unless @v == 1;
    print STDOUT ("FT${test}b\n") unless $v[0] eq 'wv=vw';
    print STDOUT ("FT${test}c\n") unless scalar(keys(%w)) == 1;
    print STDOUT ("FT${test}d\n") unless $w{vv} eq 'vw';
    print STDOUT ("FT${test}z\n") unless @ARGV == 1
	&& "@ARGV" eq "foo";
}

################ Prefix ################

if ( ++$test == $single || $all ) {

    my $o_foo;
    my $o_bar;

    Getopt::Long::config(@defcfg, "prefix=--");
    @ARGV = qw( --foo -bar -- foo );
    print STDOUT ("FT${test}a\n") 
	unless GetOptions ("foo" => \$o_foo, "bar=s" => \$o_bar);

    print STDOUT ("FT${test}a\n") unless $o_foo == 1;
    print STDOUT ("FT${test}b=$o_bar\n") if defined $o_bar;
    print STDOUT ("FT${test}z\n") unless @ARGV == 2
	&& "@ARGV" eq "-bar foo";
}

if ( ++$test == $single || $all ) {

    eval {
	Getopt::Long::config(@defcfg, "prefix_pattern=+--",);
    };
    print STDOUT ("FT${test}a\n") unless $@;
    print STDOUT ("FT${test}b '$@'\n")
      unless $@ =~ /^\QGetopt::Long: invalid pattern "(+--)" at /;
}

################ Faking POSIXLY_CORRECT ################

if ( ++$test == $single || $all ) {
#    showtest();
    my $o_seven;
    my $o_foo;
    Getopt::Long::Configure (@defcfg, "posix_default");
    @ARGV = qw(-seven 1.2 foo);
    print STDOUT ("FT${test}a\n") 
	unless GetOptions ("foo" => \$o_foo, "seven=f" => \$o_seven);
    print STDOUT ("FT${test}b\n") unless defined $o_seven;
    print STDOUT ("FT${test}c = \"$o_seven\"\n") if $o_seven != 1.2;
    print STDOUT ("FT${test}z\n") if @ARGV != 1 || $ARGV[0] ne "foo";
}

if ( ++$test == $single || $all ) {
#    showtest();
    my $o_seven;
    my $o_foo;
    Getopt::Long::Configure (@defcfg, "posix_default");
    @ARGV = qw(foo -seven 1.2);
    print STDOUT ("FT${test}a\n") 
	unless GetOptions ("foo" => \$o_foo, "seven=f" => \$o_seven);
    print STDOUT ("FT${test}b\n") if defined $o_seven;
    print STDOUT ("FT${test}z\n") if @ARGV != 3 || $ARGV[0] ne "foo";
}

################ OO ################

if ( ++$test == $single || $all ) {

    # If bundling, it is not allowed to split on aa=bb.
    # Also, prevent warnings for undefind $bopctl{$o}.

    my @v = ();
    my %w = ();
    my $p = new Getopt::Long::Parser (config => [@defcfg, "bundling"]);
    @ARGV = qw( -vwv=vw -wvv=vw -- foo );
    print STDOUT ("FT${test}a\n") 
	unless $p->getoptions ("v=s" => \@v, "vee=s" => \@v, "w=s" => \%w, "wee=s" => \%w);

    print STDOUT ("FT${test}a\n") unless @v == 1;
    print STDOUT ("FT${test}b\n") unless $v[0] eq 'wv=vw';
    print STDOUT ("FT${test}c\n") unless scalar(keys(%w)) == 1;
    print STDOUT ("FT${test}d\n") unless $w{vv} eq 'vw';
    print STDOUT ("FT${test}z\n") unless @ARGV == 1
	&& "@ARGV" eq "foo";
}

################ Interrupting ################

if ( ++$test == $single || $all ) {

    # Use die(!FINISH) to interrupt the options handling.

    my $a;
    Getopt::Long::config(@defcfg, "bundling");
    @ARGV = qw( -amenu foo );
    print STDOUT ("FT${test}a\n")
	unless GetOptions ("a" => \$a, "m" => sub { die("!FINISH here") });
    print STDOUT ("FT${test}b\n") unless defined $a;
    print STDOUT ("FT${test}c\n") unless $a == 1;
    print STDOUT ("FT${test}z\n") unless @ARGV == 2
	&& "@ARGV" eq "-enu foo";
}

################ GNU Getopt Compatibility ################
#
# Basically, this means that if 'file' takes an optional argument, you
# always need to specify the '=', e.g. --file=blah. A mere --file blah
# will not work.
# Also, if 'file' takes a mandatory argument, --file= is allowed and
# will provide an empty argument.

if ( ++$test == $single || $all ) {
    my $a;
    Getopt::Long::config(@defcfg);
    @ARGV = qw( --file foo );
    print STDOUT ("FT${test}a\n")
	unless GetOptions ("file:s" => \$a);
    print STDOUT ("FT${test}b\n") unless defined $a;
    print STDOUT ("FT${test}c\n") unless $a eq 'foo';
    print STDOUT ("FT${test}z\n") unless @ARGV == 0;
}

if ( ++$test == $single || $all ) {
    my $a;
    Getopt::Long::config(@defcfg, "gnu_getopt");
    @ARGV = qw( --file foo );
    print STDOUT ("FT${test}a\n")
	unless GetOptions ("file:s" => \$a);
    print STDOUT ("FT${test}b\n") unless defined $a;
    print STDOUT ("FT${test}c\n") unless $a eq '';
    print STDOUT ("FT${test}z\n") unless @ARGV == 1
	&& "@ARGV" eq "foo";
}

if ( ++$test == $single || $all ) {
    my $a;
    Getopt::Long::config(@defcfg);
    @ARGV = qw( --file foo );
    print STDOUT ("FT${test}a\n")
	unless GetOptions ("file=s" => \$a);
    print STDOUT ("FT${test}b\n") unless defined $a;
    print STDOUT ("FT${test}c\n") unless $a eq 'foo';
    print STDOUT ("FT${test}z\n") unless @ARGV == 0;
}

if ( ++$test == $single || $all ) {
    my $a;
    Getopt::Long::config(@defcfg, "gnu_getopt");
    @ARGV = qw( --file foo );
    print STDOUT ("FT${test}a\n")
	unless GetOptions ("file=s" => \$a);
    print STDOUT ("FT${test}b\n") unless defined $a;
    print STDOUT ("FT${test}c\n") unless $a eq 'foo';
    print STDOUT ("FT${test}z\n") unless @ARGV == 0;
}

if ( ++$test == $single || $all ) {
    my $a;
    my $msg;
    Getopt::Long::config(@defcfg);
    @ARGV = qw( --file= foo );
    local ($SIG{__WARN__}) = sub { $msg .= "@_"; };
    print STDOUT ("FT${test}a\n")
	if GetOptions ("file=s" => \$a);
    print STDOUT ("FT${test}b '$msg'\n")
      unless $msg eq "Option file requires an argument\n";
}

if ( ++$test == $single || $all ) {
    my $a;
    Getopt::Long::config(@defcfg, "gnu_getopt");
    @ARGV = qw( --file= foo );
    print STDOUT ("FT${test}a\n")
	unless GetOptions ("file=s" => \$a);
    print STDOUT ("FT${test}b\n") unless defined $a;
    print STDOUT ("FT${test}c\n") unless $a eq '';
    print STDOUT ("FT${test}z\n") unless @ARGV == 1
      && "@ARGV" eq "foo";
}

################ Wrap Up ################

print STDOUT ("Number of tests = ", $test, ".\n");

1;
