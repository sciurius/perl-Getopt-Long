#!/usr/local/bin/perl5 -s

# TestOptExt.pl -- Testbed for Getopt::Long.pm (extended features).
# RCS Info        : $Id$
# Author          : Johan Vromans
# Created On      : ***
# Last Modified By: Johan Vromans
# Last Modified On: Thu Dec 25 15:17:36 1997
# Update Count    : 23
# Status          : Internal use only

package foo;
BEGIN { require "./GetoptLong.pm"; import Getopt::Long; }

# perl -s variables
$debug = defined $main'debug ? $main'debug : 0;
#$verbose = defined $main'verbose ? $main'verbose : 0;
#$numbered = defined $main'numbered ? $main'numbered : 0;

Getopt::Long::config ("debug") if $debug;
$single = 0;
$single = shift (@main::ARGV) if @main::ARGV == 1;
$all = $single == 0;
if ( $single ) {
    Getopt::Long::config ("debug");
    open (STDERR, ">&STDOUT");
}
select (STDERR); $| = 1;
select (STDOUT); $| = 1;

################ Setup ################

$test = 0;

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
    print STDOUT ("FT${test}j\n") if defined @opt_three;
    print STDOUT ("FT${test}k\n") unless defined @o_three;
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
    print STDOUT ("FT${test}j\n") if defined @opt_three;
    print STDOUT ("FT${test}k\n") unless defined @o_three;
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
    print STDOUT ("FT${test}d\n") if defined @opt_three;
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
    print STDOUT ("FT${test}d\n") if defined @opt_three;
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
    print STDOUT ("FT${test}d\n") if defined @opt_three;
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

# if ( ++$test == $single || $all ) {
# 
#     my %linkage = ();
# 
#     print STDERR ("Expect: Invalid option linkage for \"two=i\"\n",
# 		  "Expect: Error in option spec: \"HASH(0x...)\"\n");
# 
# 
#     @ARGV = qw( -one -two 2 -three 1 -three 4 foo );
#     print STDOUT ("FT${test}a\n") 
# 	if GetOptions ("one",
# 		       "two=i", \%linkage,
# 		       "three=i@");
# }

# if ( ++$test == $single || $all ) {
# 
#     my %linkage = ();
# 
#     print STDERR ("Expect: Invalid option linkage for \"two=i\"\n",
# 		  "Expect: Error in option spec: \"HASH(0x...)\"\n");
# 
# 
#     @ARGV = qw( -one -two 2 -three 1 -three 4 foo );
#     print STDOUT ("FT${test}a\n") 
# 	if GetOptions (\%linkage,
# 		       "one",
# 		       "two=i", \%linkage,
# 		       "three=i@");
# }

if ( ++$test == $single || $all ) {

    my %linkage = ();

    print STDERR ("Expect: Option spec <> requires a reference to a subroutine\n",
		  "Expect: Error in option spec: \"HASH(0x...)\"\n");


    @ARGV = qw( -one -two 2 -three 1 -three 4 foo );
    if ( defined eval { GetOptions (\%linkage,
				    "one",
				    "<>", \%linkage,
				    "three=i@");
		    } ) {
	print STDOUT ("FT${test}a\n");
    }
    else {
	print STDOUT ($@);
    }
}

if ( ++$test == $single || $all ) {

    my $foo;
    my %linkage = ('<>' => \$foo);

    print STDERR ("Expect: Option spec <> requires a reference to a subroutine\n",
		  "Expect: Error in option spec: \"SCALAR(0x...)\"\n");


    @ARGV = qw( -one -two 2 -three 1 -three 4 foo );
    if ( defined eval { GetOptions (\%linkage,
				    "one",
				    "<>", 
				    "three=i@");
		    } ) {
	print STDOUT ("FT${test}a\n");
    }
    else {
	print STDOUT ($@);
    }
}

################ Callbacks ################

local (%xx);

sub cb {
    print STDOUT ("Callback($_[0],$_[1])\n") if $single;
    $xx{$_[0]} = $_[1];
}

sub cbx {
    &cb;
    print STDERR ("Option fail for \"$_[0]\"\n");
    $Getopt::Long::error++;
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

    @ARGV = qw( -one -two 2 -three 1 -three 4 foo );
    print STDOUT ("FT${test}a\n") 
	unless GetOptions (\%linkage,
			   "one",
			   "two=i", \&cb,
			   "three=i@");
    print STDOUT ("FT${test}a\n") if defined $opt_one;
    print STDOUT ("FT${test}b\n") if defined $opt_two;
    print STDOUT ("FT${test}c\n") if defined $opt_three;
    print STDOUT ("FT${test}d\n") if defined @opt_three;
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
    print STDOUT ("FT${test}d\n") if defined @opt_three;
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
    print STDOUT ("FT${test}d\n") if defined @opt_three;
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
    Getopt::Long::config ("require_order");
    print STDOUT ("FT${test}a\n") 
	unless GetOptions (\%linkage,
			   "one",
			   "<>", \&process,
			   "two=i", \&cb,
			   "three=i@");
    print STDOUT ("FT${test}a\n") if defined $opt_one;
    print STDOUT ("FT${test}b\n") if defined $opt_two;
    print STDOUT ("FT${test}c\n") if defined $opt_three;
    print STDOUT ("FT${test}d\n") if defined @opt_three;
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
    Getopt::Long::config ("permute");
}

if ( ++$test == $single || $all ) {

    my %linkage = ('one', \&cbx);
    my $o_one;
    my $o_two;
    my @o_three;
    %xx = ();

    @ARGV = qw( -one -two 2 -three 1 bar -three 4 -- foo );
    Getopt::Long::config ("require_order");
    print STDOUT ("FT${test}a\n") 
	if GetOptions (\%linkage,
		       "one",
		       "<>", \&process,
		       "two=i", \&cb,
		       "three=i@");
    print STDOUT ("FT${test}a\n") if defined $opt_one;
    print STDOUT ("FT${test}b\n") if defined $opt_two;
    print STDOUT ("FT${test}c\n") if defined $opt_three;
    print STDOUT ("FT${test}d\n") if defined @opt_three;
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
    Getopt::Long::config ("permute");
}

################ Hashes ################

if ( ++$test == $single || $all ) {

    my %hi = ();

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

    Getopt::Long::config("bundling");
    @ARGV = qw( -vwv=vw -wvv=vw -- foo );
    print STDOUT ("FT${test}a\n") 
	unless GetOptions ("v=s" => \@v, "vee=s" => \@v, "w=s" => \%w, "wee=s" => \%w);

    print STDOUT ("FT${test}a\n") unless @v == 1;
    print STDOUT ("FT${test}b\n") unless $v[0] eq 'wv=vw';
    print STDOUT ("FT${test}c\n") unless scalar(keys(%w)) == 1;
    print STDOUT ("FT${test}d\n") unless $w{vv} eq 'vw';
    print STDOUT ("FT${test}z\n") unless @ARGV == 1
	&& "@ARGV" eq "foo";
    Getopt::Long::config("nobundling");
}

################ OO ################

if ( 0 and ++$test == $single || $all ) {

    # If bundling, it is not allowed to split on aa=bb.
    # Also, prevent warnings for undefind $bopctl{$o}.

    my @v = ();
    my %w = ();
    my $p = new Getopt::Long ("bundling");
    @ARGV = qw( -vwv=vw -wvv=vw -- foo );
    print STDOUT ("FT${test}a\n") 
	unless $p->GetOptions ("v=s" => \@v, "vee=s" => \@v, "w=s" => \%w, "wee=s" => \%w);

    print STDOUT ("FT${test}a\n") unless @v == 1;
    print STDOUT ("FT${test}b\n") unless $v[0] eq 'wv=vw';
    print STDOUT ("FT${test}c\n") unless scalar(keys(%w)) == 1;
    print STDOUT ("FT${test}d\n") unless $w{vv} eq 'vw';
    print STDOUT ("FT${test}z\n") unless @ARGV == 1
	&& "@ARGV" eq "foo";
}

################ Wrap Up ################

print STDOUT ("Number of tests = ", $test, ".\n");

1;
