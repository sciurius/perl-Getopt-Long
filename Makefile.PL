# $Id$

use ExtUtils::MakeMaker 5.0;

require "./GetoptLong.pm";

WriteMakefile(
	NAME      => "Getopt::Long",
	VERSION   => $Getopt::Long::VERSION,

	( $[ < 5.005 ) ? () : (
	AUTHOR => 'Johan Vromans (jvromans@squirrel.nl)',
        ABSTRACT => 'Extended getopt function for command line parsing',
        ),

	INSTALLDIRS => 'perl',
	PM 	  => { "newgetopt.pl"  => '$(INST_LIB)/newgetopt.pl',
		       "GetoptLong.pm" => '$(INST_LIB)/Getopt/Long.pm'
		     },
	dist      => { COMPRESS => 'gzip', SUFFIX => 'gz',
		     },
 );
