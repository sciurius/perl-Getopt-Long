# GetOpt::Long.pm -- Universal options parsing

package Getopt::Long;

# RCS Status      : $Id$
# Author          : Johan Vromans
# Created On      : Tue Sep 11 15:00:12 1990
# Last Modified By: Johan Vromans
# Last Modified On: Sat Dec 27 17:49:29 1997
# Update Count    : 712
# Status          : Released

################ Copyright ################

# This program is Copyright 1990,1997 by Johan Vromans.
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# If you do not have a copy of the GNU General Public License write to
# the Free Software Foundation, Inc., 675 Mass Ave, Cambridge, 
# MA 02139, USA.

################ Module Preamble ################

use strict;

BEGIN {
    require 5.003;
    use Exporter ();
    use vars   qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
    $VERSION   = sprintf("%d.%02d", q$Revision$ =~ /(\d+)\.(\d+)/);

    @ISA       = qw(Exporter);
    @EXPORT    = qw(&GetOptions $REQUIRE_ORDER $PERMUTE $RETURN_IN_ORDER);
    %EXPORT_TAGS = ();
    @EXPORT_OK = qw();
}

use vars @EXPORT, @EXPORT_OK;
# User visible variables.
use vars qw($error $major_version $minor_version);
# Deprecated visible variables.
use vars qw($autoabbrev $debug $getopt_compat $ignorecase $bundling $order
	    $passthrough);

################ Local Variables ################

my $gen_prefix;			# generic prefix (option starters)
my $argend;			# option list terminator
my %opctl;			# table of arg.specs (long and abbrevs)
my %bopctl;			# table of arg.specs (bundles)
my @opctl;			# the possible long option names
my $pkg;			# current context. Needed if no linkage.
my %aliases;			# alias table
my $genprefix;			# so we can call the same module more 
my $opt;			# current option
my $arg;			# current option value, if any
my $array;			# current option is array typed
my $hash;			# current option is hash typed
my $key;			# hash key for a hash option
				# than once in differing environments
my $config_defaults;		# set config defaults
my $find_option;		# helper routine
my $croak;			# helper routine

# The private variables for configuration options.
# The global ones will be tied to these.
my $Debug;			# for debugging
my $AutoAbbrev;			# allow abbreviations for options
my $GetoptCompat;		# compatible with GNU getopt
my $IgnoreCase;			# ignore case
my $Bundling;			# old fashioned bundling
my $Order;			# mix options and other arguments
my $PassThrough;		# pass unknown options to caller

################ Subroutines ################

sub GetOptions {

    my @optionlist = @_;	# local copy of the option descriptions
    $argend = '--';		# option list terminator
    %opctl = ();		# table of arg.specs (long and abbrevs)
    %bopctl = ();		# table of arg.specs (bundles)
    $pkg = (caller)[0];		# current context
				# Needed if linkage is omitted.
    %aliases= ();		# alias table
    my @ret = ();		# accum for non-options
    my %linkage;		# linkage
    my $userlinkage;		# user supplied HASH
    $genprefix = $gen_prefix;	# so we can call the same module many times
    $error = '';

    print STDERR ('GetOptions $Revision$ ',
		  "[GetOpt::Long $Getopt::Long::VERSION] -- ",
		  "called from package \"$pkg\".\n",
		  "  (@ARGV)\n",
		  "  AutoAbbrev=$AutoAbbrev".
		  ",Bundling=$Bundling",
		  ",GetoptCompat=$GetoptCompat",
		  ",Order=$Order",
		  ",\n  IgnoreCase=$IgnoreCase",
		  ",PassThrough=$PassThrough",
		  ",genprefix=\"$genprefix\"",
		  ".\n")
	if $Debug;

    # Check for ref HASH as first argument. 
    # First argument may be an object. It's OK to use this as long
    # as it is really a hash underneath. 
    $userlinkage = undef;
    if ( ref($optionlist[0]) and
	 "$optionlist[0]" =~ /^(?:.*\=)?HASH\([^\(]*\)$/ ) {
	$userlinkage = shift (@optionlist);
	print STDERR ("=> user linkage: $userlinkage\n") if $Debug;
    }

    # See if the first element of the optionlist contains option
    # starter characters.
    if ( $optionlist[0] =~ /^\W+$/ ) {
	warn ("Getopt::Long: Deprecated setting of option starter, use config() instead\n");
	$genprefix = shift (@optionlist);
	# Turn into regexp. Needs to be parenthesized!
	$genprefix =~ s/(\W)/\\$1/g;
	$genprefix = "([" . $genprefix . "])";
    }

    # Verify correctness of optionlist.
    %opctl = ();
    %bopctl = ();
    while ( @optionlist > 0 ) {
	my $opt = shift (@optionlist);

	# Strip leading prefix so people can specify "--foo=i" if they like.
	$opt = $+ if $opt =~ /^$genprefix+(.*)$/s;

	if ( $opt eq '<>' ) {
	    if ( (defined $userlinkage)
		&& !(@optionlist > 0 && ref($optionlist[0]))
		&& (exists $userlinkage->{$opt})
		&& ref($userlinkage->{$opt}) ) {
		unshift (@optionlist, $userlinkage->{$opt});
	    }
	    unless ( @optionlist > 0 
		    && ref($optionlist[0]) && ref($optionlist[0]) eq 'CODE' ) {
		$error .= "GetOptions: Option spec `<>' ".
		          "requires a reference to a subroutine\n";
		next;
	    }
	    $linkage{'<>'} = shift (@optionlist);
	    next;
	}

	# Match option spec. Allow '?' as an alias.
	if ( $opt !~ /^((\w+[-\w]*)(\|(\?|\w[-\w]*)?)*)?(!|[=:][infse][@%]?)?$/ ) {
	    $error .= "GetOptions: Error in option spec: `$opt'\n";
	    next;
	}
	my ($o, $c, $a) = ($1, $5);
	$c = '' unless defined $c;

	if ( ! defined $o ) {
	    # empty -> '-' option
	    $opctl{$o = ''} = $c;
	}
	else {
	    # Handle alias names
	    my @o =  split (/\|/, $o);
	    my $linko = $o = $o[0];
	    # Force an alias if the option name is not locase.
	    $a = $o unless $o eq lc($o);
	    $o = lc ($o)
		if $IgnoreCase > 1 
		    || ($IgnoreCase
			&& ($Bundling ? length($o) > 1  : 1));

	    foreach ( @o ) {
		if ( $Bundling && length($_) == 1 ) {
		    $_ = lc ($_) if $IgnoreCase > 1;
		    if ( $c eq '!' ) {
			$opctl{"no$_"} = $c;
			warn ("Ignoring `!' modifier for short option `$_'\n");
			$c = '';
		    }
		    $opctl{$_} = $bopctl{$_} = $c;
		}
		else {
		    $_ = lc ($_) if $IgnoreCase;
		    if ( $c eq '!' ) {
			$opctl{"no$_"} = $c;
			$c = '';
		    }
		    $opctl{$_} = $c;
		}
		if ( defined $a ) {
		    # Note alias.
		    $aliases{$_} = $a;
		}
		else {
		    # Set primary name.
		    $a = $_;
		}
	    }
	    $o = $linko;
	}

	# If no linkage is supplied in the @optionlist, copy it from
	# the userlinkage if available.
	if ( defined $userlinkage ) {
	    unless ( @optionlist > 0 && ref($optionlist[0]) ) {
		if ( exists $userlinkage->{$o} && ref($userlinkage->{$o}) ) {
		    print STDERR ("=> found userlinkage for \"$o\": ",
				  "$userlinkage->{$o}\n")
			if $Debug;
		    unshift (@optionlist, $userlinkage->{$o});
		}
		else {
		    # Do nothing. Being undefined will be handled later.
		    next;
		}
	    }
	}

	# Copy the linkage. If omitted, link to global variable.
	if ( @optionlist > 0 && ref($optionlist[0]) ) {
	    print STDERR ("=> link \"$o\" to $optionlist[0]\n")
		if $Debug;
	    if ( ref($optionlist[0]) =~ /^(SCALAR|CODE)$/ ) {
		$linkage{$o} = shift (@optionlist);
	    }
	    elsif ( ref($optionlist[0]) =~ /^(ARRAY)$/ ) {
		$linkage{$o} = shift (@optionlist);
		$opctl{$o} .= '@'
		  if $opctl{$o} ne '' and $opctl{$o} !~ /\@$/;
		$bopctl{$o} .= '@'
		  if $Bundling and defined $bopctl{$o} and 
		    $bopctl{$o} ne '' and $bopctl{$o} !~ /\@$/;
	    }
	    elsif ( ref($optionlist[0]) =~ /^(HASH)$/ ) {
		$linkage{$o} = shift (@optionlist);
		$opctl{$o} .= '%'
		  if $opctl{$o} ne '' and $opctl{$o} !~ /\%$/;
		$bopctl{$o} .= '%'
		  if $Bundling and defined $bopctl{$o} and 
		    $bopctl{$o} ne '' and $bopctl{$o} !~ /\%$/;
	    }
	    else {
		$error .= "GetOptions: Invalid option linkage for `$opt'\n";
	    }
	}
	else {
	    # Link to global $opt_XXX variable.
	    # Make sure a valid perl identifier results.
	    my $ov = $o;
	    $ov =~ s/\W/_/g;
	    if ( $c =~ /@/ ) {
		print STDERR ("=> link \"$o\" to \@$pkg","::opt_$ov\n")
		    if $Debug;
		eval ("\$linkage{\$o} = \\\@".$pkg."::opt_$ov;");
	    }
	    elsif ( $c =~ /%/ ) {
		print STDERR ("=> link \"$o\" to \%$pkg","::opt_$ov\n")
		    if $Debug;
		eval ("\$linkage{\$o} = \\\%".$pkg."::opt_$ov;");
	    }
	    else {
		print STDERR ("=> link \"$o\" to \$$pkg","::opt_$ov\n")
		    if $Debug;
		eval ("\$linkage{\$o} = \\\$".$pkg."::opt_$ov;");
	    }
	}
    }

    # Bail out if errors found.
    &$croak ($error) if $error;
    $error = 0;

    # Sort the possible long option names.
    @opctl = sort(keys (%opctl)) if $AutoAbbrev;

    # Show the options tables if debugging.
    if ( $Debug ) {
	my ($arrow, $k, $v);
	$arrow = "=> ";
	while ( ($k,$v) = each(%opctl) ) {
	    print STDERR ($arrow, "\$opctl{\"$k\"} = \"$v\"\n");
	    $arrow = "   ";
	}
	$arrow = "=> ";
	while ( ($k,$v) = each(%bopctl) ) {
	    print STDERR ($arrow, "\$bopctl{\"$k\"} = \"$v\"\n");
	    $arrow = "   ";
	}
    }

    # Process argument list
    while ( @ARGV > 0 ) {

	#### Get next argument ####

	$opt = shift (@ARGV);
	$arg = undef;
	$array = $hash = 0;
	print STDERR ("=> option \"", $opt, "\"\n") if $Debug;

	#### Determine what we have ####

	# Double dash is option list terminator.
	if ( $opt eq $argend ) {
	    # Finish. Push back accumulated arguments and return.
	    unshift (@ARGV, @ret) 
		if $Order == $PERMUTE;
	    return ($error == 0);
	}

	my $tryopt = $opt;

	# find_option operates on the GLOBAL $opt and $arg!
	if ( &$find_option () ) {
	    
	    # find_option undefines $opt in case of errors.
	    next unless defined $opt;

	    if ( defined $arg ) {
		$opt = $aliases{$opt} if defined $aliases{$opt};

		if ( defined $linkage{$opt} ) {
		    print STDERR ("=> ref(\$L{$opt}) -> ",
				  ref($linkage{$opt}), "\n") if $Debug;

		    if ( ref($linkage{$opt}) eq 'SCALAR' ) {
			print STDERR ("=> \$\$L{$opt} = \"$arg\"\n") if $Debug;
			${$linkage{$opt}} = $arg;
		    }
		    elsif ( ref($linkage{$opt}) eq 'ARRAY' ) {
			print STDERR ("=> push(\@{\$L{$opt}, \"$arg\")\n")
			    if $Debug;
			push (@{$linkage{$opt}}, $arg);
		    }
		    elsif ( ref($linkage{$opt}) eq 'HASH' ) {
			print STDERR ("=> \$\$L{$opt}->{$key} = \"$arg\"\n")
			    if $Debug;
			$linkage{$opt}->{$key} = $arg;
		    }
		    elsif ( ref($linkage{$opt}) eq 'CODE' ) {
			print STDERR ("=> &L{$opt}(\"$opt\", \"$arg\")\n")
			    if $Debug;
			&{$linkage{$opt}}($opt, $arg);
		    }
		    else {
			print STDERR ("Invalid REF type \"", ref($linkage{$opt}),
				      "\" in linkage\n");
			&$croak ("Getopt::Long -- internal error!\n");
		    }
		}
		# No entry in linkage means entry in userlinkage.
		elsif ( $array ) {
		    if ( defined $userlinkage->{$opt} ) {
			print STDERR ("=> push(\@{\$L{$opt}}, \"$arg\")\n")
			    if $Debug;
			push (@{$userlinkage->{$opt}}, $arg);
		    }
		    else {
			print STDERR ("=>\$L{$opt} = [\"$arg\"]\n")
			    if $Debug;
			$userlinkage->{$opt} = [$arg];
		    }
		}
		elsif ( $hash ) {
		    if ( defined $userlinkage->{$opt} ) {
			print STDERR ("=> \$L{$opt}->{$key} = \"$arg\"\n")
			    if $Debug;
			$userlinkage->{$opt}->{$key} = $arg;
		    }
		    else {
			print STDERR ("=>\$L{$opt} = {$key => \"$arg\"}\n")
			    if $Debug;
			$userlinkage->{$opt} = {$key => $arg};
		    }
		}
		else {
		    print STDERR ("=>\$L{$opt} = \"$arg\"\n") if $Debug;
		    $userlinkage->{$opt} = $arg;
		}
	    }
	}

	# Not an option. Save it if we $PERMUTE and don't have a <>.
	elsif ( $Order == $PERMUTE ) {
	    # Try non-options call-back.
	    my $cb;
	    if ( (defined ($cb = $linkage{'<>'})) ) {
		&$cb ($tryopt);
	    }
	    else {
		print STDERR ("=> saving \"$tryopt\" ",
			      "(not an option, may permute)\n") if $Debug;
		push (@ret, $tryopt);
	    }
	    next;
	}

	# ...otherwise, terminate.
	else {
	    # Push this one back and exit.
	    unshift (@ARGV, $tryopt);
	    return ($error == 0);
	}

    }

    # Finish.
    if ( $Order == $PERMUTE ) {
	#  Push back accumulated arguments
	print STDERR ("=> restoring \"", join('" "', @ret), "\"\n")
	    if $Debug && @ret > 0;
	unshift (@ARGV, @ret) if @ret > 0;
    }

    return ($error == 0);
}

sub config (@) {
    my (@options) = @_;
    while ( @options ) {
	my $opt = shift (@options);
	my $try = lc ($opt);
	my $action = 1;
	if ( $try =~ /^no_?(.*)$/s ) {
	    $action = 0;
	    $try = $+;
	}
	if ( $try eq 'default' or $try eq 'defaults' ) {
	    &$config_defaults () if $action;
	}
	elsif ( $try eq 'auto_abbrev' or $try eq 'autoabbrev' ) {
	    $AutoAbbrev = $action;
	}
	elsif ( $try eq 'getopt_compat' ) {
	    $GetoptCompat = $action;
	}
	elsif ( $try eq 'ignorecase' or $try eq 'ignore_case' ) {
	    $IgnoreCase = $action;
	}
	elsif ( $try eq 'ignore_case_always' ) {
	    $IgnoreCase = $action ? 2 : 0;
	}
	elsif ( $try eq 'bundling' ) {
	    $Bundling = $action;
	}
	elsif ( $try eq 'bundling_override' ) {
	    $Bundling = $action ? 2 : 0;
	}
	elsif ( $try eq 'require_order' ) {
	    $Order = $action ? $REQUIRE_ORDER : $PERMUTE;
	}
	elsif ( $try eq 'permute' ) {
	    $Order = $action ? $PERMUTE : $REQUIRE_ORDER;
	}
	elsif ( $try eq 'pass_through' or $try eq 'passthrough' ) {
	    $PassThrough = $action;
	}
	elsif ( $try eq 'prefix' and @options > 0 ) {
	    $gen_prefix = shift (@options);
	    # Turn into regexp. Needs to be parenthesized!
	    $gen_prefix =~ s/(\W)/\\$1/g;
	    $gen_prefix = "([" . $gen_prefix . "])";
	}
	elsif ( $try eq 'debug' ) {
	    $Debug = $action;
	}
	else {
	    &$croak ("config: unknown config parameter \"$opt\"\n")
	}
    }
}

# To prevent Carp from being loaded unnecessarily.
$croak = sub {
    require 'Carp.pm';
    $Carp::CarpLevel = 1;
    Carp::croak ( map { s/^/Getopt::Long::/;
			s/$/\n/; 
			$_ } split ("\n", join('',@_)));
};

################ Private Subroutines ################

$find_option = sub {

    print STDERR ("=> find \"$opt\", genprefix=\"$genprefix\"\n") if $Debug;

    return 0 unless $opt =~ /^$genprefix(.*)$/s;

    $opt = $+;
    my ($starter) = $1;		# $genprefix is ()-ed

    print STDERR ("=> split \"$starter\"+\"$opt\"\n") if $Debug;

    my $optarg = undef;	# value supplied with --opt=value
    my $rest = undef;	# remainder from unbundling

    # If it is a long option, it may include the value.
    if (($starter eq "--" || ($GetoptCompat && !$Bundling))
	&& $opt =~ /^([^=]+)=(.*)$/s ) {
	$opt = $1;
	$optarg = $2;
	print STDERR ("=> option \"", $opt, 
		      "\", optarg = \"$optarg\"\n") if $Debug;
    }

    #### Look it up ###

    my $tryopt = $opt;		# option to try
    my $optbl = \%opctl;	# table to look it up (long names)
    my $type;

    if ( $Bundling && $starter eq '-' ) {
	# Unbundle single letter option.
	$rest = substr ($tryopt, 1);
	$tryopt = substr ($tryopt, 0, 1);
	$tryopt = lc ($tryopt) if $IgnoreCase > 1;
	print STDERR ("=> $starter$tryopt unbundled from ",
		      "$starter$tryopt$rest\n") if $Debug;
	$rest = undef unless $rest ne '';
	$optbl = \%bopctl;	# look it up in the short names table

	# If bundling == 2, long options can override bundles.
	if ( $Bundling == 2 and
	     defined ($type = $opctl{$tryopt.$rest}) ) {
	    print STDERR ("=> $starter$tryopt rebundled to ",
			  "$starter$tryopt$rest\n") if $Debug;
	    $tryopt .= $rest;
	    undef $rest;
	}
    } 

    # Try auto-abbreviation.
    elsif ( $AutoAbbrev ) {
	# Downcase if allowed.
	$tryopt = $opt = lc ($opt) if $IgnoreCase;
	# Turn option name into pattern.
	my $pat = quotemeta ($opt);
	# Look up in option names.
	my @hits = grep (/^$pat/, @opctl);
	print STDERR ("=> ", scalar(@hits), " hits (@hits) with \"$pat\" ",
		      "out of ", scalar(@opctl), "\n") if $Debug;

	# Check for ambiguous results.
	unless ( (@hits <= 1) || (grep ($_ eq $opt, @hits) == 1) ) {
	    # See if all matches are for the same option.
	    my %hit;
	    foreach ( @hits ) {
		$_ = $aliases{$_} if defined $aliases{$_};
		$hit{$_} = 1;
	    }
	    # Now see if it really is ambiguous.
	    unless ( keys(%hit) == 1 ) {
		return 0 if $PassThrough;
		warn ("Option `$opt' is ambiguous (",
		      join(", ", @hits), ")\n");
		$error++;
		undef $opt;
		return 1;
	    }
	    @hits = keys(%hit);
	}

	# Complete the option name, if appropriate.
	if ( @hits == 1 && $hits[0] ne $opt ) {
	    $tryopt = $hits[0];
	    $tryopt = lc ($tryopt) if $IgnoreCase;
	    print STDERR ("=> option \"$opt\" -> \"$tryopt\"\n")
		if $Debug;
	}
    }

    # Map to all lowercase if ignoring case.
    elsif ( $IgnoreCase ) {
	$tryopt = lc ($opt);
    }

    # Check validity by fetching the info.
    $type = $optbl->{$tryopt} unless defined $type;
    unless  ( defined $type ) {
	return 0 if $PassThrough;
	warn ("Unknown option: `$opt'\n");
	$error++;
	return 1;
    }
    # Apparently valid.
    $opt = $tryopt;
    print STDERR ("=> found \"$type\" for ", $opt, "\n") if $Debug;

    #### Determine argument status ####

    # If it is an option w/o argument, we're almost finished with it.
    if ( $type eq '' || $type eq '!' ) {
	if ( defined $optarg ) {
	    return 0 if $PassThrough;
	    warn ("Option `$opt' does not take an argument\n");
	    $error++;
	    undef $opt;
	}
	elsif ( $type eq '' ) {
	    $arg = 1;		# supply explicit value
	}
	else {
	    substr ($opt, 0, 2) = ''; # strip NO prefix
	    $arg = 0;		# supply explicit value
	}
	unshift (@ARGV, $starter.$rest) if defined $rest;
	return 1;
    }

    # Get mandatory status and type info.
    my $mand;
    ($mand, $type, $array, $hash) = $type =~ /^(.)(.)(@?)(%?)$/;

    # Check if there is an option argument available.
    if ( defined $optarg ? ($optarg eq '') 
	 : !(defined $rest || @ARGV > 0) ) {
	# Complain if this option needs an argument.
	if ( $mand eq "=" ) {
	    return 0 if $PassThrough;
	    warn ("Option `$opt' requires an argument\n");
	    $error++;
	    undef $opt;
	}
	if ( $mand eq ":" ) {
	    $arg = $type eq "s" ? '' : 0;
	}
	return 1;
    }

    # Get (possibly optional) argument.
    $arg = (defined $rest ? $rest
	    : (defined $optarg ? $optarg : shift (@ARGV)));

    # Get key if this is a "name=value" pair for a hash option.
    $key = undef;
    if ($hash && defined $arg) {
	($key, $arg) = ($arg =~ /^(.*)=(.*)$/s) ? ($1, $2) : ($arg, 1);
    }

    #### Check if the argument is valid for this option ####

    if ( $type eq "s" ) {	# string
	# A mandatory string takes anything. 
	return 1 if $mand eq "=";

	# An optional string takes almost anything. 
	return 1 if defined $optarg || defined $rest;
	return 1 if $arg eq "-"; # ??

	# Check for option or option list terminator.
	if ($arg eq $argend ||
	    $arg =~ /^$genprefix.+/) {
	    # Push back.
	    unshift (@ARGV, $arg);
	    # Supply empty value.
	    $arg = '';
	}
    }

    elsif ( $type eq "n" || $type eq "i" ) { # numeric/integer
	if ( $Bundling && defined $rest && $rest =~ /^(-?[0-9]+)(.*)$/s ) {
	    $arg = $1;
	    $rest = $+;
	    unshift (@ARGV, $starter.$rest) if defined $rest && $rest ne '';
	}
	elsif ( $arg !~ /^-?[0-9]+$/ ) {
	    if ( defined $optarg || $mand eq "=" ) {
		if ( $PassThrough ) {
		    unshift (@ARGV, defined $rest ? $starter.$rest : $arg)
		      unless defined $optarg;
		    return 0;
		}
		warn ("Value `$arg' invalid for option `$opt'",
		      " (number expected)\n");
		$error++;
		undef $opt;
		# Push back.
		unshift (@ARGV, $starter.$rest) if defined $rest;
	    }
	    else {
		# Push back.
		unshift (@ARGV, defined $rest ? $starter.$rest : $arg);
		# Supply default value.
		$arg = 0;
	    }
	}
    }

    elsif ( $type eq "f" ) { # real number, int is also ok
	# We require at least one digit before a point or 'e',
	# and at least one digit following the point and 'e'.
	# [-]NN[.NN][eNN]
	if ( $Bundling && defined $rest &&
	     $rest =~ /^(-?[0-9]+(\.[0-9]+)?([eE]-?[0-9]+)?)(.*)$/s ) {
	    $arg = $1;
	    $rest = $+;
	    unshift (@ARGV, $starter.$rest) if defined $rest && $rest ne '';
	}
	elsif ( $arg !~ /^-?[0-9.]+(\.[0-9]+)?([eE]-?[0-9]+)?$/ ) {
	    if ( defined $optarg || $mand eq "=" ) {
		if ( $PassThrough ) {
		    unshift (@ARGV, defined $rest ? $starter.$rest : $arg)
		      unless defined $optarg;
		    return 0;
		}
		warn ("Value `$arg' invalid for option `$opt'",
		      " (real number expected)\n");
		$error++;
		undef $opt;
		# Push back.
		unshift (@ARGV, $starter.$rest) if defined $rest;
	    }
	    else {
		# Push back.
		unshift (@ARGV, defined $rest ? $starter.$rest : $arg);
		# Supply default value.
		$arg = 0.0;
	    }
	}
    }
    else {
	&$croak ("GetOpt::Long internal error (Can't happen)\n");
    }
    return 1;
};

$config_defaults = sub {
    # Handle POSIX compliancy.
    if ( defined $ENV{"POSIXLY_CORRECT"} ) {
	$gen_prefix = "(--|-)";
	$AutoAbbrev = 0;		# no automatic abbrev of options
	$Bundling = 0;			# no bundling of single letter switches
	$GetoptCompat = 0;		# disallow '+' to start options
	$Order = $REQUIRE_ORDER;
    }
    else {
	$gen_prefix = "(--|-|\\+)";
	$AutoAbbrev = 1;		# automatic abbrev of options
	$Bundling = 0;			# bundling off by default
	$GetoptCompat = 1;		# allow '+' to start options
	$Order = $PERMUTE;
    }
    # Other configurable settings.
    $Debug = 0;			# for debugging
    $error = 0;			# error tally
    $IgnoreCase = 1;		# ignore case when matching options
    $PassThrough = 0;		# leave unrecognized options alone
};

my $tie_vars = sub {
    # Tie the obsolete variables so we can issue warnings.
    tie ($autoabbrev, 'Getopt::Long::TieVars', 
	 \$AutoAbbrev, $AutoAbbrev, 'autoabbrev');
    tie ($getopt_compat, 'Getopt::Long::TieVars',
	 \$GetoptCompat, $GetoptCompat, 'getopt_compat');
    tie ($ignorecase, 'Getopt::Long::TieVars', 
	 \$IgnoreCase, $IgnoreCase, 'ignorecase');
    tie ($bundling, 'Getopt::Long::TieVars',
	 \$Bundling, $Bundling, 'bundling');
    tie ($order, 'Getopt::Long::TieVars',
	 \$Order, $Order, 'order');
    tie ($passthrough, 'Getopt::Long::TieVars',
	 \$PassThrough, $PassThrough, 'passthrough');
    tie ($debug, 'Getopt::Long::TieVars',
	 \$Debug, $Debug, 'debug');
};

################ Initialization ################

# Values for $order. See GNU getopt.c for details.
($REQUIRE_ORDER, $PERMUTE, $RETURN_IN_ORDER) = (0..2);
# Version major/minor numbers.
($major_version, $minor_version) = $VERSION =~ /^(\d+)\.(\d+)/;

# Set defaults.
&$config_defaults ();

# Tie variables.
&$tie_vars ();

################ Tie public variables to private ones ################

package Getopt::Long::TieVars;

use vars ('%tbl');

sub TIESCALAR ($@) {
    my $classname = shift;	# class (Getopt::Long::TieVars)
    my $var = shift;		# ref to private variable
    $$var = shift;		# default value
    $tbl{"$classname=$var"} = shift;
    # print STDERR ("TIESCALAR \$", $tbl{"$classname=$var"}, 
    # 		  " $classname=$var -> $$var\n");
    return bless $var, $classname;
}

sub DESTROY ($) {
    my $this = shift;
}

sub FETCH ($) {
    my $this = shift;
    # print STDERR ("FETCH $tbl{$this} $this -> $$this\n");
    warn ("Getopt::Long: Deprecated use of variable `\$".$tbl{$this}."'\n")
      if $^W;
    return $$this;
}

sub STORE ($$) {
    my $this = shift;
    $$this = shift;
    # print STDERR ("STORE $tbl{$this} $this -> $$this\n");
    warn ("Getopt::Long: Deprecated setting of variable `\$".$tbl{$this}."',".
	  " use config() instead\n") if $^W;
}

################ Package return ################

1;

__END__

