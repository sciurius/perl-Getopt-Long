# GetOpt::Long.pm -- Universal options parsing

package Getopt::Long;

# RCS Status      : $Id$
# Author          : Johan Vromans
# Created On      : Tue Sep 11 15:00:12 1990
# Last Modified By: Johan Vromans
# Last Modified On: Mon Jul 31 21:21:13 2000
# Update Count    : 739
# Status          : Released

################ Copyright ################

# This program is Copyright 1990,2000 by Johan Vromans.
# This program is free software; you can redistribute it and/or
# modify it under the terms of the Perl Artistic License or the
# GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any
# later version.
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
    $VERSION     = "2.22";

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
use vars qw($genprefix $caller $gnu_compat);

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
    $gnu_compat = 0;		# require --opt=val if value is optional
}

# Override import.
sub import {
    my $pkg = shift;		# package
    my @syms = ();		# symbols to import
    my @config = ();		# configuration
    my $dest = \@syms;		# symbols first
    for ( @_ ) {
	if ( $_ eq ':config' ) {
	    $dest = \@config;	# config next
	    next;
	}
	push (@$dest, $_);	# push
    }
    # Hide one level and call super.
    local $Exporter::ExportLevel = 1;
    $pkg->SUPER::import(@syms);
    # And configure.
    Configure (@config) if @config;
}

################ Initialization ################

# Values for $order. See GNU getopt.c for details.
($REQUIRE_ORDER, $PERMUTE, $RETURN_IN_ORDER) = (0..2);
# Version major/minor numbers.
($major_version, $minor_version) = $VERSION =~ /^(\d+)\.(\d+)/;

ConfigDefaults();

################ OO Interface ################

package Getopt::Long::Parser;

# NOTE: The object oriented routines use $error for thread locking.
my $_lock = sub {
    lock ($Getopt::Long::error) if $] >= 5.005
};

# Store a copy of the default configuration. Since ConfigDefaults has
# just been called, what we get from Configure is the default.
my $default_config = do {
    &$_lock;
    Getopt::Long::Configure ()
};

sub new {
    my $that = shift;
    my $class = ref($that) || $that;
    my %atts = @_;

    # Register the callers package.
    my $self = { caller => (caller)[0] };

    bless ($self, $class);

    # Process config attributes.
    if ( defined $atts{config} ) {
	&$_lock;
	my $save = Getopt::Long::Configure ($default_config, @{$atts{config}});
	$self->{settings} = Getopt::Long::Configure ($save);
	delete ($atts{config});
    }
    # Else use default config.
    else {
	$self->{settings} = $default_config;
    }

    if ( %atts ) {		# Oops
	Getopt::Long::Croak(__PACKAGE__.": unhandled attributes: ".
			    join(" ", sort(keys(%atts))));
    }

    $self;
}

sub configure {
    my ($self) = shift;

    &$_lock;

    # Restore settings, merge new settings in.
    my $save = Getopt::Long::Configure ($self->{settings}, @_);

    # Restore orig config and save the new config.
    $self->{settings} = Configure ($save);
}

sub getoptions {
    my ($self) = shift;

    &$_lock;

    # Restore config settings.
    my $save = Getopt::Long::Configure ($self->{settings});

    # Call main routine.
    my $ret = 0;
    $Getopt::Long::caller = $self->{caller};
    eval { $ret = Getopt::Long::GetOptions (@_); };

    # Restore saved settings.
    Getopt::Long::Configure ($save);

    # Handle errors and return value.
    die ($@) if $@;
    return $ret;
}

package Getopt::Long;

################ Package return ################

1;

__END__

