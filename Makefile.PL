# $Id$

use Config;
use ExtUtils::MakeMaker 5.0;

require "./lib/Getopt/Long.pm";
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
#		       "perlcmdline.pod" => '$(INST_LIB)/pod/perlcmdline.pod',
		     },
#	MAN1PODS  => { "perlcmdline.pod" => 'blib/man1/perlcmdline.1', },
#	MAN3PODS  => { "lib/Getopt/Long.pm" => 'blib/man3/Getopt::Long.3', },
	dist      => { COMPRESS => 'gzip', SUFFIX => 'gz',
		     },
 );
