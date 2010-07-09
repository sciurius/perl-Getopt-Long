# Makefile.PL -- Makefile generator for Getopt::Long
# Author          : Johan Vromans
# Created On      : Sat Mar 16 11:43:21 1996
# Last Modified By: Johan Vromans
# Last Modified On: Fri Jul  9 14:23:45 2010
# Update Count    : 112
# Status          : Unknown, Use with caution!

use Config;
use ExtUtils::MakeMaker 5.0;

use lib "./lib";
use Getopt::Long;
my $version = $Getopt::Long::VERSION_STRING || $Getopt::Long::VERSION;

sub MY::postamble {
    my $ret = "";
    my $mandir = $Config{installman3dir};
    my $obsolete = "$mandir/Getopt::GetoptLong.3";
    if ( -e $obsolete ) {
	print STDERR (<<EOD);

I found a left-over manual page from a previous version of Getopt::Long.
This manual page has a wrong name, and should be removed.
I can add instructions to the Makefile to remove it when you
install this version.
EOD
	my $ans = prompt ("Shall I add the remove instructions?");
	if ( $ans =~ /^y/i ) {
	    $ret .= <<EOD;
install ::
	\$(RM_F) "$obsolete"

EOD
	}
    }
    my $libdir = $Config{installprivlib};
    my $obsolete = "$libdir/auto/Getopt/Long";
    if ( -d $obsolete ) {
	print STDERR (<<EOD);

I found left-over files from a previous version of Getopt::Long.
These should be removed.
I can add instructions to the Makefile to remove them when you
install this version.
EOD
	my $ans = prompt ("Shall I add the remove instructions?");
	if ( $ans =~ /^y/i ) {
	    $ret .= <<EOD;
install ::
	\$(RM_RF) "$libdir/auto/Getopt/Long"
EOD
	}
    }
    $ret;
}

if ( $version =~ /_/ ) {
    print STDERR <<EOD;

WARNING: This is Getopt::Long version $version.
The underscore in the version number indicates that this is
an intermediate, preview or beta release.
Please keep checking CPAN for the official release.
EOD
}

unless ( eval { require Pod::Usage } ) {
    print STDERR <<EOD;

WARNING: Getopt::Long needs the module Pod::Usage for its built-in
help facility. Pod::Usage seems not to be installed on this system.
That is not a problem as long as the new help facility is not used.
However, please consider installing Pod::Usage from CPAN as soon as
convenient.
EOD
}

print STDERR ("\n");

my $x =
WriteMakefile(
	NAME      => "Getopt::Long",
	VERSION   => $version,

	( $] < 5.005 ) ? () : (
	AUTHOR => 'Johan Vromans (jvromans@squirrel.nl)',
        ABSTRACT => 'Module to handle parsing command line options',
        ),

	INSTALLDIRS => 'perl',
	PM 	  => { "lib/newgetopt.pl"  => '$(INST_LIB)/newgetopt.pl',
		       "lib/Getopt/Long.pm" => '$(INST_LIB)/Getopt/Long.pm',
		     },
	dist      => { COMPRESS => 'gzip', SUFFIX => 'gz',
		     },
	PREREQ_PM => { "Pod::Usage" => 1.14 },
 );

# Write .spec file.
# Note that $x->{...} is not supported in older Perls.
WriteSpecfile($x->{DISTNAME}, $x->{VERSION}) if $] >= 5.008;

sub WriteSpecfile {
    my $name    = shift;
    my $version = shift;

    if ( open (FH, "rpm/$name.spec.in") ) {
	print "Writing RPM spec file...\n";
	open (NEWFH, ">perl-$name.spec");
	while ( <FH> ) {
	    s/%define modname [\w---]+/%define modname $name/;
	    s/%define modversion \d+\.\d+/%define modversion $version/;
	    print NEWFH $_;
	}
	close(NEWFH);
	close(FH);
    }
}
