# $Id$

use ExtUtils::MakeMaker 5.0;

require "./GetoptLong.pm";

WriteMakefile(
	NAME      => "Getopt::Long",
	DISTNAME  => 'GetoptLong',
	VERSION   => $Getopt::Long::VERSION,

	INSTALLDIRS => 'perl',
	PM 	  => { "newgetopt.pl"  => '$(INST_LIB)/newgetopt.pl',
		       "GetoptLong.pm" => '$(INST_LIB)/Getopt/Long.pm'
		     },
	dist      => { COMPRESS => 'gzip', SUFFIX => 'gz' },
 );
