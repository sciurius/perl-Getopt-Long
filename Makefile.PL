# $Id$

use ExtUtils::MakeMaker 5.0;

require "./GetoptLong.pm";

my $preop_cmd = 
  "rm -f GetoptLong-$Getopt::Long::VERSION/GetoptLong.pm;".
  "cat GetoptLong.pm GetoptLong.pod ".
  "> GetoptLong-$Getopt::Long::VERSION/GetoptLong.pm;".
  "chmod u-w GetoptLong-$Getopt::Long::VERSION/GetoptLong.pm; ";

WriteMakefile(
	NAME      => "Getopt::Long",
	DISTNAME  => 'GetoptLong',
	VERSION   => $Getopt::Long::VERSION,

	INSTALLDIRS => 'perl',
	PM 	  => { "newgetopt.pl"  => '$(INST_LIB)/newgetopt.pl',
		       "GetoptLong.pm" => '$(INST_LIB)/Getopt/Long.pm'
		     },
	dist      => { COMPRESS => 'gzip', SUFFIX => 'gz', 
		       PREOP => $preop_cmd,
		     },
 );
