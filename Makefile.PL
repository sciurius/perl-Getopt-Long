# $Id$

use ExtUtils::MakeMaker 5.0;

require "./GetoptLong.pl";

sub MY::postamble {
    '
GetoptLong.pm: GetoptLong.pl GetoptLongAl.pl GetoptLong.pod
	$(RM_F) GetoptLong.pm
	$(PERL) -e \'open(STDOUT,">GetoptLong.pm");\' \\
		-e \'print while <>; close(STDOUT);\' \\
		GetoptLong.pl GetoptLongAl.pl GetoptLong.pod 
';
}

WriteMakefile(
	NAME      => "Getopt::Long",
	DISTNAME  => 'GetoptLong',
	VERSION   => $Getopt::Long::VERSION,

	INSTALLDIRS => 'perl',
	PM 	  => { "newgetopt.pl"  => '$(INST_LIB)/newgetopt.pl',
		       "GetoptLong.pm" => '$(INST_LIB)/Getopt/Long.pm'
		     },
	dist      => { COMPRESS => 'gzip', SUFFIX => 'gz', 
		     },
	clean     => { FILES => "GetoptLong.pm"
		     },
 );
