#!/usr/bin/perl -w

# Test driver for test Getopt::Long.
# Author          : Johan Vromans
# Created On      : Mon Aug  6 11:53:07 2001
# Last Modified By: Johan Vromans
# Last Modified On: Wed Feb 22 10:21:20 2017
# Update Count    : 459
# Status          : Unknown, Use with caution!

package MyTest;			# not main

################ Common stuff ################

use strict;

# Package name.
my $my_package = 'Sciurix';
# Program name and version.
my ($my_name, $my_version) = qw( driver1 1.15 );

################ Command line parameters ################

use Getopt::Long;
#require "newgetopt.pl";

# Command line options.
my $verbose = 0;		# verbose processing
my $fatal = 0;			# quit after first error
my $line = 0;			# only the test at this line

my $only;			# run only one test set
my $only_style;			# in this style
my $quick;			# quick(er) testing

# Development options (not shown with -help).
my $debug = 0;			# debugging
my $trace = 0;			# trace (show process)

# Process command line options.
app_options();

# Post-processing.
$trace |= ($debug);

if ( $line ) {
    if ( $line =~ /^(\d+)\@(\d+)/ ) {
	$only_style = $2;
	$line = $1;
    }
    $only = -1;
}
$only_style = 0 if $quick;

################ Presets ################

# Old Perls do not have Data::Dumper.
my $candump = 0;
eval { require Data::Dumper;
       $candump = 1;
       $Data::Dumper::Indent = 1;
       $Data::Dumper::Indent = 1; # no warning
};
use Text::ParseWords;

my $retval = 0;
my $skipped = 0;

################ The Process ################

# Local variables.
my ($v1, $v2, $v3, @a1, @a2, @a3, @argv, %h1, %h2, %h3);

# Global variables.
use vars ('$opt_v1', '$opt_v2', '$opt_v3', '$opt_', '$opt_a_b',
	  '@opt_a1', '@opt_a2', '@opt_a3',
	  '%opt_h1', '%opt_h2', '%opt_h3');

# Mapping of var names to the var themselves.
# No need for eval or symlinks.
my %refmap = ( '$v1'	  => \$v1,
	       '$v2'	  => \$v2,
	       '$v3'	  => \$v3,
	       '$opt_v1'  => \$opt_v1,
	       '$opt_v2'  => \$opt_v2,
	       '$opt_v3'  => \$opt_v3,
	       '$opt_'    => \$opt_,
	       '$opt_a_b' => \$opt_a_b,
	       '@a1'	  => \@a1,
	       '@a2'	  => \@a2,
	       '@a3'	  => \@a3,
	       '@opt_a1'  => \@opt_a1,
	       '@opt_a2'  => \@opt_a2,
	       '@opt_a3'  => \@opt_a3,
	       '@ARGV'	  => \@argv,
	       '%h1'	  => \%h1,
	       '%h2'	  => \%h2,
	       '%h3'	  => \%h3,
	       '%opt_h1'  => \%opt_h1,
	       '%opt_h2'  => \%opt_h2,
	       '%opt_h3'  => \%opt_h3,
	     );

# Default verification set: all variables must be undef.
my @def_vfy = ( map { $_, [] } sort keys %refmap );

$refmap{'@$v1'}     = \$v1;
$refmap{'%$v1'}     = \$v1;

$refmap{'&ok'}	    = \&cb1;
$refmap{'&warn'}    = \&cb2;
$refmap{'&die'}	    = \&cb3;
$refmap{'&finish'}  = \&cb4;

my $test = 0;
my $variants = 0;
my $phase = "";

# Test call styles.
use constant S_PLAIN	=> 1;
use constant S_OO	=> 2;
use constant S_LINKAGE	=> 4;

my %styles = ( plain    => S_PLAIN,
	       oo       => S_OO,
	       linkage  => S_LINKAGE,
	     );

if ( @ARGV && $ARGV[-1] =~ /^(\d+)(@(\d+))?$/ ) {
    $only = $1;
    $only_style = $3 if defined $2;
    pop(@ARGV);
}

# The primary test structure.
my $t = {
	 opts	 => [],
	 argv	 => [],
	 done	 => -1,		# bootstrap
	};

my @sticky_config  = ();
my @sticky_opts	   = ();
my @sticky_argv	   = ();
my $sticky_version = "";
my @sticky_styles  = (undef,undef);

# The main program.
my $skip = 0;
while ( <> ) {
    chomp;
    if ( /^\+\+$/ ) {
	$skip = 0;
	next;
    }
    next if $skip;

    next if /^\s*#/;

    # An empty line triggers the current test.
    unless ( /\S/ ) {
	do_test() unless $t->{done};
	$t->{done} = -1;
	next;
    }

    if ( /^--$/ ) {
	$skip++;
	next;
    }

    # Collect test information.
    gather();
}

# Perform pending tests.
do_test() unless $t->{done};

# Statistics.
if ( $verbose ) {
    print STDERR ("Number of tests sets = $test, tests = ",
		  4*$test, ", executed = $variants");
    print STDERR (", skipped = $skipped") if $skipped;
    print STDERR (".\n");
}

exit ($retval);

################ Subroutines ################

# Reset all variables to their default state.
sub reset_vars {
    foreach ( keys %refmap ) {
	if ( /^\$/ || /^[@%]\$/ ) {
	    undef ${$refmap{$_}};
	}
	elsif ( /^\@/ ) {
	    @{$refmap{$_}} = ();
	}
	elsif ( /^\%/ ) {
	    %{$refmap{$_}} = ();
	}
    }
}

# Gather a new line of test data.
sub gather {

    # T: title
    # New test.
    if ( /^T:\s*(\S.*)?/i ) {

	die(hdr(), "Test not executed (blank line missing?)\n"),
	  $retval = 1
	  unless $t->{done};

	$test++;
	my $id = "Test $test <$.>";
	$id .= " $1" if $1;
	$t->{id}	= $id;
	$t->{test}      = $test;
	$t->{warnings}	= [];
	$t->{errors}	= [];
	$t->{vfy}	= {};
	$t->{done}      = 0;
	$t->{argv}      = [ @sticky_argv ];
	$t->{opts}      = [ @sticky_opts ];
	$t->{config}    = [ @sticky_config ];
	$t->{styles}    = [ @sticky_styles ];
	$t->{version}   = $sticky_version;

	if ( $line ) {
	    if ( $line > $. ) {
		$t->{done}++;
	    }
	    else {
		$only = $test;
		$line = 0;
	    }
	}
	elsif ( $only ) {
	    if ( $only != $test ) {
		$t->{done}++;
	    }
	}
    }

    # O: opt1 opt2 ...
    # O+ opt3 opt4 ...
    # Configuration options.
    elsif ( /^O(:|\+)(\s+(.*)|$)/i ) {
	my @a = $2 ? shellwords($3) : ();
	if ( $t->{done} < 0 ) {
	    @sticky_config = () if $1 eq ":";
	    push (@sticky_config, @a);
	}
	else {
	    $t->{config} = [] if $1 eq ":";
	    push (@{$t->{config}}, @a);
	}
    }

    # A: arg1 arg2 ...
    # A+ arg3 arg4 ...
    # Call arguments (@ARGV).
    elsif ( /^A(:|\+)(\s+(.*)|$)/i ) {
	my @a = $2 ? shellwords($3) : ();
	if ( $t->{done} < 0 ) {
	    @sticky_argv = () if $1 eq ":";
	    push (@sticky_argv, @a);
	}
	else {
	    $t->{argv} = [] if $1 eq ":";
	    push (@{$t->{argv}}, @a);
	}
    }

    # P: arg1 arg2 ...
    # P+ arg3 arg4 ...
    # Arguments to GetOptions().
    elsif ( /^P(:|\+)(\s+(.*)|$)/i ) {
	my @a = $2 ? shellwords($3) : ();
	if ( $t->{done} < 0 ) {
	    @sticky_opts = () if $1 eq ":";
	}
	else {
	    $t->{opts} = [] if $1 eq ":";
	}
	foreach ( @a ) {
	    if ( /^\\(((\$v|\@a|\%h)[123])|(\&(ok|warn|die|finish)))$/
		 && exists($refmap{$1}) ) {
		$_ = $refmap{$1};
	    }
	}
	if ( $t->{done} < 0 ) {
	    @sticky_opts = () if $1 eq ":";
	    push (@sticky_opts, @a);
	}
	else {
	    $t->{opts} = [] if $1 eq ":";
	    push (@{$t->{opts}}, @a);
	}
    }

    # S: style1 !style2 ...
    # S+ style3 !style ...
    # Style(s) to inc/exclude.
    elsif ( /^S(:|\+)(\s+(.*)|$)/i ) {
	if ( $t->{done} < 0 ) {
	    @sticky_styles = (undef, undef) if $1 eq ":";
	}
	else {
	    $t->{styles} = [ undef, undef ] if $1 eq ":";
	}
	return unless $2;
	my @a = shellwords(lc($3));
	foreach my $style ( @a ) {
	    my $excl = 0;
	    if ( $style =~ /^!(.*)/ ) {
		$excl = 1;
		$style = $1;
	    }
	    if ( exists($styles{$style}) ) {
		if ( $t->{done} < 0 ) {
		    $sticky_styles[$excl] |= $styles{$style};
		}
		else {
		    $t->{styles}->[$excl] |= $styles{$style};
		}
	    }
	    else {
		print STDERR (hdr(), "<$.> Unknown style: $style\n");
		$retval = 1,
	    }
	}
    }

    # R: version
    # Require a specific version
    elsif ( /^R:(\s+(([<=]=?)?\s*\d\.\d\d(\d\d)?)|$)/i ) {
	if ( $t->{done} < 0 ) {
	    $sticky_version = $2 || "";
	}
	else {
	    $t->{version} = $2 || "";
	}
    }

    # W: text
    # W: /pattern
    # E: text
    # E: /pattern
    # Expected errors/warnings.
    elsif ( /^(W|E):\s+(.*)/i ) {
	my $type = $1;
	my $pat = $2;
	$pat = ( $pat =~ m:^/(.+): ) ? $1 : '^'.quotemeta($pat).'$';
	push(@{$t->{lc($type) eq 'w' ? "warnings" : "errors"}}, $pat);
    }

    # <space>var
    # <space>var value ...
    # Expected value(s) for variables.
    elsif ( /^\s+(.*)/ ) {

	my ($var,@a) = shellwords($1);
	map { $_ = '' if $_ eq "''" } @a;
	print STDERR ("<$.>: Explicit check for undefined value\n")
	  unless @a;
	$t->{vfy}->{$var} = [@a];

    }

    else {
	print STDERR ("<$.> ? $_\n");
    }
}

# Print output header.
my $prev_test;
sub hdr {
    unless ( $prev_test && $prev_test == $test ) {
	$prev_test = $test;
	return "[$test $phase] ", $t->{id}, "\n[$test $phase] ";
    }
    "[$test $phase] ";
}

# Run all variants of a test set.
sub do_test {
    if ( $t->{version} ) {
	my $v = $t->{version};
	my $vv = $v;
	if ( ($v =~ /^<=\s*(.*)/) ? ($Getopt::Long::VERSION gt ($vv = $1)) :
	     ($v =~ /^==\s*(.*)/) ? ($Getopt::Long::VERSION ne ($vv = $1)) :
	     ($v =~ /^<\s*(.*)/)  ? ($Getopt::Long::VERSION ge ($vv = $1)) :
	                            ($Getopt::Long::VERSION lt $v) ) {
	    $skipped += 4;
	    # warn("skip: ", $t->{test}, " $Getopt::Long::VERSION $v\n");
	    return;
	}
	# warn("accept: ", $t->{test}, " $Getopt::Long::VERSION $v\n");
	# To obtain side effects...
	Getopt::Long->VERSION($vv);
    }
    if ( $only ) {
	unshift (@{$t->{config}}, "debug");
    }
    if ( defined $only_style ) {
	exec_plain ($only_style);
	die("Quit\n") if $fatal && $retval;
    }
    else {
	foreach my $i1 ( 0, S_OO ) {
	    foreach my $i2 ( 0, S_LINKAGE ) {
		exec_plain (S_PLAIN|$i1|$i2);
		die("Quit\n") if $fatal && $retval;
	    }
	}
    }
    $t->{done}++;
}

# Run selected variant of test set.
sub exec_plain {
    my ($call) = @_;
    $phase = ($call & S_LINKAGE) ? "link" : "plain";
    $phase .= "-oo" if $call & S_OO;

    if ( defined(my $mask = $t->{styles}->[0]) ) {
	$skipped++, return unless $call & $mask;
    }
    if ( defined(my $mask = $t->{styles}->[1]) ) {
	$skipped++, return if $call & $mask;
    }

    print STDERR (hdr()) if $only;

    $variants++;

    # Messages delivered by GetOptions.
    my $errors   = [];
    my $warnings = [];

    # Expected message patterns. These will be modified, so copy them.
    my @errors   = @{$t->{errors}};
    my @warnings = @{$t->{warnings}};

    if ( $debug && $candump ) {
	print STDERR (hdr(), Data::Dumper->Dump([$t], ["t"]), "\n");
    }
    reset_vars();

    my $ret;
    my @opts = @{$t->{opts}};
    my %linkage;
    unshift (@opts, \%linkage) if $call & S_LINKAGE;

    {
	local ($SIG{__DIE__})  = sub { push (@$errors,   "@_"); };
	local ($SIG{__WARN__}) = sub { push (@$warnings, "@_");
				       print STDERR "@_" if $only;
				     };
	local (@ARGV) = @{$t->{argv}};

	if ( $call & S_OO ) {
	    my $p = Getopt::Long::Parser->new( config => $t->{config} );
	    $ret = eval { $p->getoptions(@opts); } || '';
	    # print STDERR (hdr(), $@) if $@;
	}
	else {
	    Getopt::Long::Configure (@{$t->{config}}) if @{$t->{config}};
	    $ret = eval { GetOptions(@opts); } || '';
	    # print STDERR (hdr(), $@) if $@;
	    Getopt::Long::Configure ("default") if @{$t->{config}};
	}
	@argv = @ARGV;
    };

    if ( !$ret && !(@errors || @warnings) ) {
	print STDERR (hdr(), "Call failed\n");
	$retval = 1;
    }

    xp_check ("error",   \@errors,   $errors);
    xp_check ("warning", \@warnings, $warnings);

    my %vfy = ( @def_vfy, %{$t->{vfy}});
    delete $vfy{'$v1'} if defined $vfy{'@$v1'};
    delete $vfy{'$v1'} if defined $vfy{'%$v1'};

    return unless $ret && %vfy;

    while ( my ($var,$vfy) = each (%vfy) ) {

	unless ( exists ($refmap{$var})
	       || (($call & S_LINKAGE)
		   && $var =~ /^[\$\@\%]opt_(.*)/
		   && exists $linkage{$1})
	       ) {
	    print STDERR (hdr(), "Unhandled variable $var\n");
	    $retval = 1;
	    next;
	}

	my @a = @$vfy;
	my $ref = $refmap{$var};

	if ( $call & S_LINKAGE ) {
	    if ( $var =~ /^\$opt_(.*)/ ) {
		$ref = \$linkage{$1};
		# $var = "\$linkage{$1}";
	    }
	    elsif ( $var =~ /^([\@\%])opt_(.*)/ ) {
		$ref = $linkage{$2};
		# $var = "$1\$linkage{$2}";
	    }
	}

	# VFY scalar
	if ( $var =~ /^\$/ ) {
	    if ( @a < 2  ) {
		vfy_scalar($var, $$ref, $a[0]);
	    }
	    elsif ( @a == 2 && $a[0] eq "==" ) {
		vfy_numeric($var, $$ref, $a[1]);
	    }
	    else {
		print STDERR (hdr(), "VFY scalar takes zero or one values\n");
		$retval = 1;
	    }
	}

	# VFY array(ref)
	elsif ( $var =~ /^\@(\$?)/ ) {
	    if ( $call & S_LINKAGE ) {
		$$ref = [] if $1 eq '$' && !defined($$ref);
		$ref = [] if !defined($ref);
	    }
	    vfy_array($var, $1 eq '$' ? $$ref : $ref, \@a);
	}

	# VFY hash
	elsif ( $var =~ /^\%(\$?)/ ) {
	    next if @a == 0 && (!$ref || !%$ref);
	    if ( $call & S_LINKAGE ) {
		$$ref = {} if $1 eq '$' && !defined($$ref);
		$ref = {} if !defined($ref);
	    }
	    # Verify as array. Sort on keys.
	    my $a = [];
	    my $r = $1 eq '$' ? $$ref : $ref;
	    foreach ( sort keys %$r ) {
		push(@$a, $_, $r->{$_});
	    }
	    vfy_array($var, $a, \@a);
	}

	else {
	    print STDERR (hdr(), "Unknow VFY\n");
	    $retval = 1;
	}
    }
}

# Verify a list of messages with a list of expected message patterns.
sub xp_check {

    my ($tag, $expected, $got) = @_;
    $got = join("\n", @$got);
    $got =~ s/\n\t/ /g;
    foreach my $msg ( split(/\n/, $got) ) {
	next unless $msg;
	my $ok = 0;
	foreach ( @$expected ) {
	    next unless $_;
	    if ( $msg =~ $_ ) {
		$ok++;
		$_ = '';
		last;
	    }
	}
	unless ( $ok ) {
	    print STDERR (hdr(), "Unexpected $tag: $msg\n");
	    $retval = 1;
	}
    }
    foreach ( @$expected ) {
	next unless $_;
	print STDERR (hdr(), "Expected $tag: $_\n");
	$retval = 1;
    }
}

# Verify the value of a scalar.
sub vfy_scalar {
    my ($var, $ist, $soll) = @_;
    $retval = 1,
    print STDERR (hdr(), "$var is ",
		  defined($ist) ? "'$ist'" : "undef",
		  ", not ",
		  defined($soll) ? "'$soll'" : "undef",
		  "\n")
      unless (defined($ist) && defined($soll) && $ist eq $soll)
	|| (!defined($ist) && !defined($soll));
}

# Verify the value of a scalar, numerically.
sub vfy_numeric {
    my ($var, $ist, $soll) = @_;
    $ist  = oct($ist)
      if $ist && $ist =~ /^0([0-7]+|b[01]+|x[0-9a-f]+)$/i;
    $soll = oct($soll)
      if $soll && $soll =~ /^0([0-7]+|b[01]+|x[0-9a-f]+)$/i;
    $retval = 1,
    print STDERR (hdr(), "$var is ",
		  defined($ist) ? "$ist" : "undef",
		  ", not ",
		  defined($soll) ? "$soll" : "undef",
		  "\n")
      unless (defined($ist) && defined($soll) && $ist == $soll)
	|| (!defined($ist) && !defined($soll));
}

# Verify the value of an array.
sub vfy_array {
    my ($var, $ist, $soll) = @_;
    return if !defined $ist && !(defined $soll || @$soll);
    return if !defined $soll && !(defined $ist || @$ist);
    return if defined($ist) && defined($soll)
      && join("\0",@$ist) eq join("\0",@$soll);
    print STDERR (hdr(), "$var is ",
		  !defined($ist) ? "undef" :
		  (@$ist ? ("'".join("' '",@$ist)."'") : "()"),
		  ", not ",
		  !defined($soll) ? "undef" :
		  (@$soll ? ("'".join("' '",@$soll)."'") : "()"),
		  "\n");
    $retval = 1;
}

sub cb1 {
    # EXPERIMENTAL. The first arg to <> cannot be the CallBack object
    # since it may be passed to other modules that get confused (e.g.,
    # Archive::Tar).
    # Pass it as second arg instead.
    pop if UNIVERSAL::isa($_[-1], 'Getopt::Long::CallBack');
    if ( @_ == 1 ) {
	$v1 = 'x';
    }
    elsif ( @_ == 2 ) {
	$v1 = $_[1];
    }
    else {
	$v1 = join("|", @_[1..$#_]);
    }
}

sub cb2 {
    &cb1;
    warn ("Callback warning for \"$_[0]\"\n");
    $Getopt::Long::error++;
}

sub cb3 {
    &cb1;
    die ("Callback died for \"$_[0]\"\n");
}

sub cb4 {
    &cb1;
    die ("!FINISH");
}

################ Subroutines ################

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
		     'line=s'	=> \$line,
		     'fatal'	=> \$fatal,
		     'quick'	=> \$quick,
		     'help|?'	=> \$help,
		     'debug'	=> \$debug,
		    ) or $help )
    {
	app_usage(2);
    }
    app_ident() if $ident;
}

sub app_ident {
    print STDERR ("This is $my_package [$my_name $my_version]\n");
}

sub app_usage {
    my ($exit) = @_;
    app_ident();
    print STDERR <<EndOfUsage;
Usage: $0 [options] [file ...] [test[\@variant]]
    -fatal		stop after first error
    -line NN[\@variant]	only the test at this line, with debug
    -quick		quick, just one variant
    -help		this message
    -ident		show identification
    -verbose		verbose information
    -debug		you get what you asked for
EndOfUsage
    exit $exit if defined $exit && $exit != 0;
}
