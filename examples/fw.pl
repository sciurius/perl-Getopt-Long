#!/usr/bin/perl

use strict;
use warnings;

die("Usage: $0 <applicationname>\n") unless @ARGV == 1;

use lib qw(inc);
our $app = {
	    name => lc($ARGV[0]) || "appname",
	    version => "0.01",
	    clo => [],
	   };
require "appdefs.pl";

open(STDOUT, ">", shift) or die("Cannot create: $!\n");

print <<'EndOfTheProgramData';
#!/usr/bin/perl

# Author          : Johan Vromans
# Created On      : Tue Sep 15 15:59:04 1992
# Last Modified By: Johan Vromans
# Last Modified On: Fri Jul  9 14:43:32 2010
# Update Count    : 202
# Status          : Unknown, Use with caution!

################ Common stuff ################

use strict;
use warnings;

# Package or program libraries, if appropriate.
# $LIBDIR = $ENV{'LIBDIR'} || '/usr/share/lib/sample';
# use lib qw($LIBDIR);
# require 'common.pl';

################ Setup  ################

# Process command line options, config files, and such.
EndOfTheProgramData
print("my \$options = app_setup(\"",
      $app->{name},
      "\", \"",
      $app->{version},
      "\");\n");
print <<'EndOfTheProgramData';

################ Presets ################

$options->{trace} = 1   if $options->{debug};
$options->{verbose} = 1 if $options->{trace};

################ Activate ################

main($options);

################ The Process ################

sub main {
    my ($options) = @_;
    use Data::Dumper;
    print Dumper($options);
}

################ Options and Configuration ################

use Getopt::Long 2.13;
use File::Spec;
use Carp;

# Package name.
my $my_package;
# Program name and version.
my ($my_name, $my_version);
my %configs;

sub app_setup {
    my ($appname, $appversion, %args) = @_;
    my $help = 0;		# handled locally
    my $ident = 0;		# handled locally

    # Package name.
    $my_package = $args{package};
    # Program name and version.
    if ( defined $appname ) {
	($my_name, $my_version) = ($appname, $appversion);
    }
    else {
	($my_name, $my_version) = qw( MyProg 0.00 );
    }

    %configs = (
EndOfTheProgramData

sub qfn {
    my ($fn) = @_;
    $fn =~ s/(['"\\])/\\$1/g;
    '"'.$fn.'"';
}

sub do_cfg {
    my ($type, $def) = @_;
    return if exists $app->{configs} && !defined($app->{configs});
    if ( exists $app->{configs}->{$type} ) {
	my $t = $app->{configs}->{$type};
	if ( UNIVERSAL::isa($t, 'ARRAY') ) {
	    printf("        %-10s => File::Spec->catfile(%s),\n",
		   $type,
		   join(", ", map { qfn($_) } @$t));
	}
	elsif ( defined $t ) {
	    printf("        %-10s => %s,\n", $type, qfn($t));
	}
	else {
	    return;
	}
    }
    else {
	printf("        %-10s => %s,\n", $type, $def);
    }
    1;
}

my $cfg_code = 0;
use constant CFG_PROJECT => 0x01;
use constant CFG_USER    => 0x02;
use constant CFG_SYSTEM  => 0x04;

do_cfg("sysconfig",  'File::Spec->catfile ("/", "etc", lc($my_name) . ".conf")')
  and $cfg_code |= CFG_SYSTEM;
do_cfg("userconfig", 'File::Spec->catfile($ENV{HOME}, ".".lc($my_name), "conf")')
  and $cfg_code |= CFG_USER;
do_cfg("config",     '"." . lc($my_name) . ".conf"')
  and $cfg_code |= CFG_PROJECT;

print <<'EndOfTheProgramData';
      );
    my $options =
      {
       verbose		=> 0,		# verbose processing
EndOfTheProgramData
foreach my $o ( @{$app->{clo}} ) {
    my $t = $o->[0];
    $t = $1 if $t =~ s/^([\w-]+).*//;
    $t = '"'.$t.'"' if $t =~ /\W/;
    my $v = $o->[1];
    $v = "'".$v."'" unless $v =~ /^\d+$/;
    printf("       %-16s => %s,\n", $t, $v);
}
print <<'EndOfTheProgramData';

       # Development options (not shown with -help).
       debug		=> 0,		# debugging
       trace		=> 0,		# trace (show process)

       # Service.
       _package		=> $my_package,
       _name		=> $my_name,
       _version		=> $my_version,
       _stdin		=> \*STDIN,
       _stdout		=> \*STDOUT,
       _stderr		=> \*STDERR,
       _argv		=> [ @ARGV ],
      };

    # Colled command line options in a hash, for they will be needed
    # later.
    my $clo = {};

    # Sorry, layout is a bit ugly...
    if ( !GetOptions
	 ($clo,

EndOfTheProgramData
foreach my $o ( @{$app->{clo}} ) {
    printf("         %s,\n", "'".$o->[0]."'");
}
print <<'EndOfTheProgramData' if $cfg_code;

	  # Configuration handling.
EndOfTheProgramData
print <<'EndOfTheProgramData' if $cfg_code & CFG_PROJECT;
	  'config=s',
	  'noconfig',
EndOfTheProgramData
print <<'EndOfTheProgramData' if $cfg_code & CFG_SYSTEM;
	  'sysconfig=s',
	  'nosysconfig',
EndOfTheProgramData
print <<'EndOfTheProgramData' if $cfg_code & CFG_USER;
	  'userconfig=s',
	  'nouserconfig',
EndOfTheProgramData
print <<'EndOfTheProgramData' if $cfg_code;
	  'define|D=s%' => sub { $clo->{$_[1]} = $_[2] },
EndOfTheProgramData
print <<'EndOfTheProgramData';

	  # Standard options.
	  'ident'		=> \$ident,
	  'help|?'		=> \$help,
	  'verbose',
	  'trace',
	  'debug',
	 ) )
    {
	# GNU convention: message to STDERR upon failure.
	app_usage(\*STDERR, 2);
    }
    # GNU convention: message to STDOUT upon request.
    app_usage(\*STDOUT, 0) if $help;
    app_ident(\*STDOUT) if $ident;

EndOfTheProgramData
my @a = ();
push(@a, "sysconfig") if $cfg_code & CFG_SYSTEM;
push(@a, "userconfig") if $cfg_code & CFG_USER;
push(@a, "config") if $cfg_code & CFG_PROJECT;
print <<EndOfTheProgramData if $cfg_code;
    # If the user specified a config, it must exist.
    # Otherwise, set to a default.
    for my \$config ( qw(@a) ) {
EndOfTheProgramData
print <<'EndOfTheProgramData' if $cfg_code;
	for ( $clo->{$config} ) {
	    if ( defined($_) ) {
		croak("$_: $!\n") if ! -r $_;
		next;
	    }
	    $_ = $configs{$config};
	    undef($_) unless defined($_) && -r $_;
	}
	app_config($options, $clo, $config);
    }

EndOfTheProgramData
print <<'EndOfTheProgramData';
    # Plug in command-line options.
    @{$options}{keys %$clo} = values %$clo;

    $options;
}

sub app_ident {
    my ($fh) = @_;
    print {$fh} ("This is ",
		 $my_package
		 ? "$my_package [$my_name $my_version]"
		 : "$my_name version $my_version",
		 "\n");
}

sub app_usage {
    my ($fh, $exit) = @_;
    app_ident($fh);
    print ${fh} <<EndOfUsage;
Usage: $0 [options]
EndOfTheProgramData
foreach my $o ( @{$app->{clo}} ) {
    foreach my $x (split(/\|/, $o->[0]) ) {
	$x = $1 if $x =~ s/^([\w-]+).*//;
	$x = "--" . $x;
	my $desc = $o->[2];
	if ( $o->[0] =~ /[=:](.)/ ) {
            my $tag = $1 eq "i" ? "NN" : "XXX";
	    while ( $desc =~ /^(.*?)<([^>]+)>(.*)/ ) {
		my ($p1, $t, $p2) = ($1, $2, $3);
		if ( $t =~ /^(.+?):(.*)/ ) {
		    $tag = $1;
		    $desc = $p1 . $2 . $p2;
		}
		else {
		    $tag = $t;
		    $desc = $p1 . $t . $p2;
		}
	    }
	    $x .= "=$tag";
        }
	printf("    %-19s %s\n", $x, $desc);
    }
}
print <<'EndOfTheProgramData' if $cfg_code;

Configuration options:
EndOfTheProgramData
print <<'EndOfTheProgramData' if $cfg_code & CFG_PROJECT;
    --config=CFG	project specific config file ($configs{config})
    --noconfig		don't use a project specific config file
EndOfTheProgramData
print <<'EndOfTheProgramData' if $cfg_code & CFG_USER;
    --userconfig=CFG	user specific config file ($configs{userconfig})
    --nouserconfig	don't use a user specific config file
EndOfTheProgramData
print <<'EndOfTheProgramData' if $cfg_code & CFG_SYSTEM;
    --sysconfig=CFG	system specific config file ($configs{sysconfig})
    --nosysconfig	don't use a system specific config file
EndOfTheProgramData
print <<'EndOfTheProgramData' if $cfg_code;
    --define key=value  define or override a configuration option
Missing default configuration files are silently ignored.
EndOfTheProgramData
print <<'EndOfTheProgramData';

Miscellaneous options:
    --help		this message
    --ident		show identification
    --verbose		verbose information
EndOfUsage
    exit $exit if defined $exit;
}

sub app_config {
    my ($options, $opts, $config) = @_;
    return if $opts->{"no$config"};
    my $cfg = $opts->{$config};
    return unless defined $cfg && -s $cfg;
    my $verbose = $opts->{verbose} || $opts->{trace} || $opts->{debug};
    warn("Loading $config: $cfg\n") if $verbose;

    # Process config data, filling $options ...
}
EndOfTheProgramData
