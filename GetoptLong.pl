# GetOpt::Long.pm -- Universal options parsing

package Getopt::Long;

# RCS Status      : $Id$
# Author          : Johan Vromans
# Created On      : Tue Sep 11 15:00:12 1990
# Last Modified By: Johan Vromans
# Last Modified On: Sun Jun 14 13:17:22 1998
# Update Count    : 705
# Status          : Released

################ Copyright ################

# This program is Copyright 1990,1998 by Johan Vromans.
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
    require 5.004;
    use Exporter ();
    use vars     qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
#   $VERSION     = sprintf("%d.%02d", q$Revision$ =~ /(\d+)\.(\d+)/);
    $VERSION     = "2.1602";

    @ISA         = qw(Exporter);
    @EXPORT      = qw(&GetOptions $REQUIRE_ORDER $PERMUTE $RETURN_IN_ORDER);
    %EXPORT_TAGS = qw();
    @EXPORT_OK   = qw();
    use AutoLoader qw(AUTOLOAD);
}

# User visible variables.
use vars @EXPORT, @EXPORT_OK;
use vars qw($error $debug $major_version $minor_version);
# Deprecated visible variables.
use vars qw($autoabbrev $getopt_compat $ignorecase $bundling $order
	    $passthrough);
# Official invisible variables.
use vars qw($genprefix);

# Public subroutines. 
sub Configure (@);
sub config (@);			# deprecated name
sub GetOptions;

# Private subroutines. 
sub ConfigDefaults ();
sub FindOption ($$$$$$$);
sub Croak (@);			# demand loading the real Croak

################ Local Variables ################

################ Resident subroutines ################

sub ConfigDefaults () {
    # Handle POSIX compliancy.
    if ( defined $ENV{"POSIXLY_CORRECT"} ) {
	$genprefix = "(--|-)";
	$autoabbrev = 0;		# no automatic abbrev of options
	$bundling = 0;			# no bundling of single letter switches
	$getopt_compat = 0;		# disallow '+' to start options
	$order = $REQUIRE_ORDER;
    }
    else {
	$genprefix = "(--|-|\\+)";
	$autoabbrev = 1;		# automatic abbrev of options
	$bundling = 0;			# bundling off by default
	$getopt_compat = 1;		# allow '+' to start options
	$order = $PERMUTE;
    }
    # Other configurable settings.
    $debug = 0;			# for debugging
    $error = 0;			# error tally
    $ignorecase = 1;		# ignore case when matching options
    $passthrough = 0;		# leave unrecognized options alone
}

################ Initialization ################

# Values for $order. See GNU getopt.c for details.
($REQUIRE_ORDER, $PERMUTE, $RETURN_IN_ORDER) = (0..2);
# Version major/minor numbers.
($major_version, $minor_version) = $VERSION =~ /^(\d+)\.(\d+)/;

# Set defaults.
ConfigDefaults ();

################ Package return ################

1;

__END__

