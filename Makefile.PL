# $Id$

use Config;
use ExtUtils::MakeMaker 5.0;

require "./lib/Getopt/Long.pm";

sub MY::postamble {
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
	    return <<EOD;
install ::
	\$(RM_F) "$obsolete"
EOD
	}
    }
    "";
}

if ( $Getopt::Long::VERSION_STRING =~ /_/ ) {
    print STDERR <<EOD;

WARNING: This is Getopt::Long version $Getopt::Long::VERSION_STRING.
The underscore in the version number indicates that this is
an intermediate, preview or beta release.
Please keep checking CPAN for the official release.

EOD
}

WriteMakefile(
	NAME      => "Getopt::Long",
	VERSION   => $Getopt::Long::VERSION_STRING,

	( $] < 5.005 ) ? () : (
	AUTHOR => 'Johan Vromans (jvromans@squirrel.nl)',
        ABSTRACT => 'Extended getopt function for command line parsing',
        ),

	INSTALLDIRS => 'perl',
	PM 	  => { "lib/newgetopt.pl"  => '$(INST_LIB)/newgetopt.pl',
		       "lib/Getopt/Long.pm" => '$(INST_LIB)/Getopt/Long.pm'
		     },
	dist      => { COMPRESS => 'gzip', SUFFIX => 'gz',
		     },
 );
