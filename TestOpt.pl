#!/usr/local/bin/perl5 -s

# TestOpt.pl -- Testbed for Getopt::Long.pm .
# RCS Info        : $Id$
# Author          : Johan Vromans
# Created On      : ***
# Last Modified By: Johan Vromans
# Last Modified On: Fri Mar 27 13:29:55 1998
# Update Count    : 9
# Status          : Internal use only

package foo;
use blib;
use Getopt::Long;

$newgetopt::REQUIRE_ORDER = $Getopt::Long::REQUIRE_ORDER;
$newgetopt::REQUIRE_ORDER = $Getopt::Long::REQUIRE_ORDER;
$newgetopt::PERMUTE = $Getopt::Long::PERMUTE;
$newgetopt::PERMUTE = $Getopt::Long::PERMUTE;

sub NGetOpt {
    my $debug = $single;
    $debug = $single;
    my @config = ();
    if ( defined $newgetopt::debug || $main::debug ) {
	push (@config, $newgetopt::debug || $main::debug ? "debug" : "no_debug");
    }
    if ( defined $newgetopt::order ) {
	if ( $newgetopt::order == $newgetopt::REQUIRE_ORDER ) {
	    push (@config, "require_order");
	}
	else {
	    push (@config, "permute");
	}
    }
    if ( defined $newgetopt::bundling ) {
	if ( $newgetopt::bundling == 2 ) {
	    push (@config, "bundling_override");
	}
	elsif ( $newgetopt::bundling == 1 ) {
	    push (@config, "bundling");
	}
	else {
	    push (@config, "no_bundling");
	}
    }
    if ( defined $newgetopt::getopt_compat ) {
	push (@config, 
	      $newgetopt::getopt_compat ? "getopt_compat" : "no_getopt_compat");
    }
    if ( defined $newgetopt::passthrough ) {
	push (@config, 
	      $newgetopt::passthrough ? "pass_through" : "no_pass_through");
    }
    if ( defined $newgetopt::autoabbrev ) {
	push (@config, 
	      $newgetopt::autoabbrev ? "auto_abbrev" : "no_auto_abbrev");
    }
    if ( defined $newgetopt::ignorecase ) {
	if ( $newgetopt::ignorecase == 0 ) {
	    push (@config, "no_ignore_case");
	}
	elsif ( $newgetopt::ignorecase == 1 ) {
	    push (@config, "ignore_case");
	}
	elsif ( $newgetopt::ignorecase == 2 ) {
	    push (@config, "ignore_case_always");
	}
    }
    Getopt::Long::Configure (@config);

    unless ( defined $main::use_linkage ) {
	return GetOptions (@_);
    }
    unless ( defined $main::use_linkage ) {
	return GetOptions (@_);
    }

    my $ret;
    my %link;
    $ret = GetOptions (\%link, @_);
    while ( ($k,$v) = each(%link) ) {
	my $K;
	($K = $k) =~ tr/-/_/;
	if ( defined $v ) {
	    print STDERR ("linkage for \"$k\" -> $v\n") if $debug;
	    if ( ref($v) ) {
		if ( ref($v) eq 'ARRAY' ) {
		    if ( scalar(@$v) > 0 ) {
			print STDERR ("-> eval: \@opt_$K = (\"",
				      join('","',@$v), "\");\n") if $debug;
			eval ("\@opt_$K = \@\$v;");
		    }
		    else {
			print STDERR ("   \@opt_$K = ();\n") if $debug;
		    }
		}
		elsif ( ref($v) eq 'HASH' ) {
		    my $did = 0;
		    my $lk;
		    local $lv;
		    while ( ($lk,$lv) = each(%$v) ) {
			print STDERR ("-> eval: \$opt_$K\{\"$lk\"} = \"$lv\"",
				      "\n") if $debug;
			eval ("\$opt_$K\{$lk} = \$lv;");
			$did++;
		    }
		    print STDERR ("   \%opt_$K = ();\n") if $debug && !$did;
		}
		else {
		    print STDERR ("-> eval: \$opt_$K = \"$v\";\n") if $debug;
		    eval ("\$opt_$K = \$v;");
		}
	    }
	    else {
		print STDERR ("-> eval: \$opt_$K = \"$v\";\n") if $debug;
		eval ("\$opt_$K = \$v;");
	    }
	}
	else {
	    print STDERR ("linkage for \"$k\" -> <undef>\n") if $debug;
	}
    }
    $ret;
}

require "testopt.pl";
