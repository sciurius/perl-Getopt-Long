use ExtUtils::MakeMaker;

require "./GetoptLong.pm";

WriteMakefile(
	VERSION   => $Getopt::Long::VERSION,
	NAME      => "Getopt::Long",
	SKIP      => [qw(static dynamic)],
	linkext   => {LINKTYPE => ''},
	PM 	  => { "newgetopt.pl"  => '$(INST_LIB)/newgetopt.pl',
		       "GetoptLong.pm" => '$(INST_LIB)/Getopt/Long.pm'
		     }

 );
