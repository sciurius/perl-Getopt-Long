#!./perl -w

no strict;

BEGIN {
    if ($ENV{PERL_CORE}) {
	@INC = '../lib';
	chdir 't';
    }
}

use Getopt::Long;

print "1..94\n";

##############################################################################
###  NOTE: This and `t/gnu-equals.t` are meant to be a "Before and After"  ###
###        comparison of `gnu_getopt` both with and without `gnu_equals`   ###
##############################################################################

{ ### -fv=2 ==> -f "v=2"
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-fv=2);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt");
  print +(GetOptions (
        'debug|d:s'   => \$DEBUG,
        'force|f:s'   => \$FORCE,
        'verbose|v:s' => \$VERBOSE,
  ) ? "" : "not ", "ok 1 (START=@START)\n");

  print (($FORCE eq "v=2")     ? "" : "not ", "ok 2 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "")      ? "" : "not ", "ok 3 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 4 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 0)          ? "" : "not ", "ok 5 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print ((!defined $ARGV[0])   ? "" : "not ", "ok 6\n");
}

{ ### -fv=2 ==> -f "v=2"
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-fv=2);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt");
  print +(GetOptions (
        'debug|d:s'   => \$DEBUG,
        'force|f=s'   => \$FORCE,    # FORCE is Required
        'verbose|v:s' => \$VERBOSE,
  ) ? "" : "not ", "ok 7 (START=@START)\n");

  print (($FORCE eq "v=2")     ? "" : "not ", "ok 8 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "")      ? "" : "not ", "ok 9 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 10 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 0)          ? "" : "not ", "ok 11 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print ((!defined $ARGV[0])   ? "" : "not ", "ok 12\n");
}

{ ### -fv=2 ==> -f -v="=2"
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-fv=2);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt");
  print +(GetOptions (
        'debug|d:s'   => \$DEBUG,
        'force|f+'    => \$FORCE,    # FORCE is Incremental
        'verbose|v:s' => \$VERBOSE,
  ) ? "" : "not ", "ok 13 (START=@START)\n");

  print (($FORCE == 1)         ? "" : "not ", "ok 14 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "=2")    ? "" : "not ", "ok 15 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 16 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 0)          ? "" : "not ", "ok 17 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print ((!defined $ARGV[0])   ? "" : "not ", "ok 18\n");
}

{ ### -fv=2 ==> -f -v -=2
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-fv=2);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt");
  print +(GetOptions (
        'debug|d:s'   => \$DEBUG,
        'force|f+'    => \$FORCE,    # FORCE is Incremental
        'verbose|v+'  => \$VERBOSE,  # VERBOSE is Incremental, Too
  ) ? "" : "not ", "ok 19 (START=@START)\n");

  print (($FORCE == 1)         ? "" : "not ", "ok 20 (FORCE=$FORCE)\n");
  print (($VERBOSE == 1)       ? "" : "not ", "ok 21 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 22 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 1)          ? "" : "not ", "ok 23 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print (($ARGV[0] eq "-=2")   ? "" : "not ", "ok 24\n");
}

{ ### -fv=2 ==> -f -v="=2"
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-fv=2);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt");
  print +(GetOptions (
        'debug|d:s'   => \$DEBUG,
        'force|f=i'   => \$FORCE,    # FORCE is a Required Integer
        'verbose|v:s' => \$VERBOSE,
  ) ? "" : "not ", "ok 25 (START=@START)\n");

  print (($FORCE eq "")        ? "" : "not ", "ok 26 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "=2")    ? "" : "not ", "ok 27 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 28 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 1)          ? "" : "not ", "ok 29 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print (($ARGV[0] eq "-fv=2") ? "" : "not ", "ok 30\n");
}

{ ### -fv=2 ==> -f -v="=2"
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-fv=2);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt");
  print +(GetOptions (
        'debug|d:s'   => \$DEBUG,
        'force|f=i'   => \$FORCE,    # FORCE is a Required Integer
        'verbose|v=i' => \$VERBOSE,  # VERBOSE is a Required Integer, Too
  ) ? "" : "not ", "ok 31 (START=@START)\n");

  print (($FORCE eq "")        ? "" : "not ", "ok 32 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "")      ? "" : "not ", "ok 33 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 34 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 3)          ? "" : "not ", "ok 35 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print (($ARGV[0] eq "-fv=2") ? "" : "not ", "ok 36\n");
  print (($ARGV[1] eq "-v=2")  ? "" : "not ", "ok 37\n");
  print (($ARGV[2] eq "-=2")   ? "" : "not ", "ok 38\n");
}

{ ### -f24v=2 ==> -f="24" -v="=2"
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-f24v=2);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt");
  print +(GetOptions (
        'debug|d:s'   => \$DEBUG,
        'force|f=i'   => \$FORCE,    # FORCE is a Required Integer
        'verbose|v=i' => \$VERBOSE,  # VERBOSE is a Required Integer, Too
  ) ? "" : "not ", "ok 39 (START=@START)\n");

  print (($FORCE eq "24")      ? "" : "not ", "ok 40 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "")      ? "" : "not ", "ok 41 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 42 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 2)          ? "" : "not ", "ok 43 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print (($ARGV[0] eq "-v=2")  ? "" : "not ", "ok 44\n");
  print (($ARGV[1] eq "-=2")   ? "" : "not ", "ok 45\n");
  print "ok 46\n";
}

{ ### -fv=2 ==> -f -v="=2"
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-fv=2);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt");
  print +(GetOptions (
        'debug|d:s'   => \$DEBUG,
        'force|f:i'   => \$FORCE,    # FORCE is an Optional Integer
        'verbose|v:s' => \$VERBOSE,
  ) ? "" : "not ", "ok 47 (START=@START)\n");

  print (($FORCE eq "0")       ? "" : "not ", "ok 48 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "=2")    ? "" : "not ", "ok 49 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 50 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 0)          ? "" : "not ", "ok 51 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print ((!defined $ARGV[0])   ? "" : "not ", "ok 52\n");
}

{ ### -fv=2 ==> -f -v="=2"
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-fv=2);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt");
  print +(GetOptions (
        'debug|d:s'   => \$DEBUG,
        'force|f:i'   => \$FORCE,    # FORCE is an Optional Integer
        'verbose|v:i' => \$VERBOSE,  # VERBOSE is an Optional Interger, Too
  ) ? "" : "not ", "ok 53 (START=@START)\n");

  print (($FORCE eq "0")       ? "" : "not ", "ok 54 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "0")     ? "" : "not ", "ok 55 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 56 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 1)          ? "" : "not ", "ok 57 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print (($ARGV[0] eq "-=2")   ? "" : "not ", "ok 58\n");
}

{ ### -fv 2 ==> -f="v" "2"
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-fv 2);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt");
  print +(GetOptions (
        'debug|d:s'   => \$DEBUG,
        'force|f:s'   => \$FORCE,
        'verbose|v:s' => \$VERBOSE,
  ) ? "" : "not ", "ok 59 (START=@START)\n");

  print (($FORCE eq "v")       ? "" : "not ", "ok 60 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "")      ? "" : "not ", "ok 61 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 62 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 1)          ? "" : "not ", "ok 63 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print (($ARGV[0] eq "2")     ? "" : "not ", "ok 64\n");
}

{ ### -fv=-1 ==> -f "v=-1"
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-fv=-1);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt");
  print +(GetOptions (
        'debug|d:s'   => \$DEBUG,
        'force|f:s'   => \$FORCE,
        'verbose|v:s' => \$VERBOSE,
  ) ? "" : "not ", "ok 65 (START=@START)\n");

  print (($FORCE eq "v=-1")    ? "" : "not ", "ok 66 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "")      ? "" : "not ", "ok 67 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 68 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 0)          ? "" : "not ", "ok 69 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print ((!defined $ARGV[0])   ? "" : "not ", "ok 70\n");
}

{ ### -fv -1 ==> -f="v" "-1"
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-fv -1);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt");
  print +(GetOptions (
        'debug|d:s'   => \$DEBUG,
        'force|f:s'   => \$FORCE,
        'verbose|v:s' => \$VERBOSE,
  ) ? "" : "not ", "ok 71 (START=@START)\n");

  print (($FORCE eq "v")       ? "" : "not ", "ok 72 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "")      ? "" : "not ", "ok 73 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 74 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 1)          ? "" : "not ", "ok 75 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print (($ARGV[0] eq "-1")    ? "" : "not ", "ok 76\n");
}

{ ### -v=+3 ==> -v="=+3"
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-v=+3);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt");
  print +(GetOptions (
        'debug|d:s'   => \$DEBUG,
        'force|f:s'   => \$FORCE,
        'verbose|v:s' => \$VERBOSE,
  ) ? "" : "not ", "ok 77 (START=@START)\n");

  print (($FORCE eq "")        ? "" : "not ", "ok 78 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "=+3")   ? "" : "not ", "ok 79 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 80 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 0)          ? "" : "not ", "ok 81 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print ((!defined $ARGV[0])   ? "" : "not ", "ok 82\n");
}

{ ### -v +3 ==> -v="+3"
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-v +3);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt");
  print +(GetOptions (
        'debug|d:s'   => \$DEBUG,
        'force|f:s'   => \$FORCE,
        'verbose|v:s' => \$VERBOSE,
  ) ? "" : "not ", "ok 83 (START=@START)\n");

  print (($FORCE eq "")        ? "" : "not ", "ok 84 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "+3")    ? "" : "not ", "ok 85 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 86 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 0)          ? "" : "not ", "ok 87 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print ((!defined $ARGV[0])   ? "" : "not ", "ok 88\n");
}

{ ### -v=2 -v=+3 ==> -v="=+3"
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-v=2 -v=+3);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt");
  print +(GetOptions (
        'debug|d:s'   => \$DEBUG,
        'force|f:s'   => \$FORCE,
        'verbose|v:s' => \$VERBOSE,
  ) ? "" : "not ", "ok 89 (START=@START)\n");

  print (($FORCE eq "")        ? "" : "not ", "ok 90 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "=+3")   ? "" : "not ", "ok 91 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 92 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 0)          ? "" : "not ", "ok 93 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print ((!defined $ARGV[0])   ? "" : "not ", "ok 94\n");
}
