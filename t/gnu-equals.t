#!./perl -w

no strict;
$|++;

BEGIN {
    if ($ENV{PERL_CORE}) {
	@INC = '../lib';
	chdir 't';
    }
}

use Getopt::Long;

print "1..92\n";

##############################################################################
###  NOTE: This and `t/gnu-getopt.t` are meant to be a "Before and After"  ###
###        comparison of `gnu_getopt` both with and without `gnu_equals`   ###
##############################################################################

{ ### -fv=2 ==> -f="" -v="2"
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-fv=2);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt", "gnu_equals");
  print +(GetOptions (
        'debug|d:s'   => \$DEBUG,
        'force|f:s'   => \$FORCE,
        'verbose|v:s' => \$VERBOSE,
  ) ? "" : "not ", "ok 1 (START=@START)\n");

  print (($FORCE eq "")        ? "" : "not ", "ok 2 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "2")     ? "" : "not ", "ok 3 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 4 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 0)          ? "" : "not ", "ok 5 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print ((!defined $ARGV[0])   ? "" : "not ", "ok 6\n");
}

{ ### -fv=2 ==> -f="" -v="2"
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-fv=2);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt", "gnu_equals");
  print +(GetOptions (
        'debug|d:s'   => \$DEBUG,
        'force|f=s'   => \$FORCE,    # FORCE is Required
        'verbose|v:s' => \$VERBOSE,
  ) ? "" : "not ", "ok 7 (START=@START)\n");

  print (($FORCE eq "")        ? "" : "not ", "ok 8 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "2")     ? "" : "not ", "ok 9 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 10 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 0)          ? "" : "not ", "ok 11 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print ((!defined $ARGV[0])   ? "" : "not ", "ok 12\n");
}

{ ### -fv=2 ==> -f -v="2"
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-fv=2);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt", "gnu_equals");
  print +(GetOptions (
        'debug|d:s'   => \$DEBUG,
        'force|f+'    => \$FORCE,    # FORCE is Incremental
        'verbose|v:s' => \$VERBOSE,
  ) ? "" : "not ", "ok 13 (START=@START)\n");

  print (($FORCE eq "1")       ? "" : "not ", "ok 14 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "2")     ? "" : "not ", "ok 15 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 16 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 0)          ? "" : "not ", "ok 17 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print ((!defined $ARGV[0])   ? "" : "not ", "ok 18\n");
}

{ ### -fv=2 ==> -f -- "-v=2"  (pass through)
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-fv=2);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt", "gnu_equals");
  print +(GetOptions (
        'debug|d:s'   => \$DEBUG,
        'force|f+'    => \$FORCE,    # FORCE is Incremental
        'verbose|v+'  => \$VERBOSE,  # VERBOSE is Incremental, Too
  ) ? "" : "not ", "ok 19 (START=@START)\n");

  print (($FORCE eq "1")       ? "" : "not ", "ok 20 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "")      ? "" : "not ", "ok 21 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 22 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 1)          ? "" : "not ", "ok 23 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print (($ARGV[0] eq "-v=2")  ? "" : "not ", "ok 24\n");
}

{ ### -fv=2 ==> -f="0" -v="2"
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-fv=2);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt", "gnu_equals");
  print +(GetOptions (
        'debug|d:s'   => \$DEBUG,
        'force|f=i'   => \$FORCE,    # FORCE is a Required Integer
        'verbose|v:s' => \$VERBOSE,
  ) ? "" : "not ", "ok 25 (START=@START)\n");

  print (($FORCE eq "0")       ? "" : "not ", "ok 26 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "2")     ? "" : "not ", "ok 27 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 28 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 0)          ? "" : "not ", "ok 29 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print ((!defined $ARGV[0])   ? "" : "not ", "ok 30\n");
}

{ ### -fv=2 ==> -f="0" -v="2"
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-fv=2);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt", "gnu_equals");
  print +(GetOptions (
        'debug|d:s'   => \$DEBUG,
        'force|f=i'   => \$FORCE,    # FORCE is a Required Integer
        'verbose|v=i' => \$VERBOSE,  # VERBOSE is a Required Integer, Too
  ) ? "" : "not ", "ok 31 (START=@START)\n");

  print (($FORCE eq "0")       ? "" : "not ", "ok 32 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "2")     ? "" : "not ", "ok 33 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 34 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 0)          ? "" : "not ", "ok 35 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print ((!defined $ARGV[0])   ? "" : "not ", "ok 36\n");
  print "ok 37\n";
  print "ok 38\n";
}

{ ### -fv=2 ==> -f="0" -v="2"
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-fv=2);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt", "gnu_equals");
  print +(GetOptions (
        'debug|d:s'   => \$DEBUG,
        'force|f:i'   => \$FORCE,    # FORCE is an Optional Integer
        'verbose|v:s' => \$VERBOSE,
  ) ? "" : "not ", "ok 39 (START=@START)\n");

  print (($FORCE eq "0")       ? "" : "not ", "ok 40 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "2")     ? "" : "not ", "ok 41 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 42 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 0)          ? "" : "not ", "ok 43 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print ((!defined $ARGV[0])   ? "" : "not ", "ok 44\n");
}

{ ### -fv=2 ==> -f="0" -v="2"
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-fv=2);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt", "gnu_equals");
  print +(GetOptions (
        'debug|d:s'   => \$DEBUG,
        'force|f:i'   => \$FORCE,    # FORCE is an Optional Integer
        'verbose|v:i' => \$VERBOSE,  # VERBOSE is an Optional Integer, Too
  ) ? "" : "not ", "ok 45 (START=@START)\n");

  print (($FORCE eq "0")       ? "" : "not ", "ok 46 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "2")     ? "" : "not ", "ok 47 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 48 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 0)          ? "" : "not ", "ok 49 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print ((!defined $ARGV[0])   ? "" : "not ", "ok 50\n");
}

{ ### -fv 2 ==> -f="" -v="" -- "2"
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-fv 2);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt", "gnu_equals");
  print +(GetOptions (
        'debug|d:s'   => \$DEBUG,
        'force|f:s'   => \$FORCE,
        'verbose|v:s' => \$VERBOSE,
  ) ? "" : "not ", "ok 51 (START=@START)\n");

  print (($FORCE eq "")        ? "" : "not ", "ok 52 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "")      ? "" : "not ", "ok 53 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 54 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 1)          ? "" : "not ", "ok 55 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print (($ARGV[0] eq "2")     ? "" : "not ", "ok 56\n");
}

{ ### -fv=-1 ==> -f="" -v="-1"
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-fv=-1);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt", "gnu_equals");
  print +(GetOptions (
        'debug|d:s'   => \$DEBUG,
        'force|f:s'   => \$FORCE,
        'verbose|v:s' => \$VERBOSE,
  ) ? "" : "not ", "ok 57 (START=@START)\n");

  print (($FORCE eq "")        ? "" : "not ", "ok 58 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "-1")    ? "" : "not ", "ok 59 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 60 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 0)          ? "" : "not ", "ok 61 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print ((!defined $ARGV[0])   ? "" : "not ", "ok 62\n");
}

{ ### -fv -1 ==> -f="" -v="" -- "-1"
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-fv -1);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt", "gnu_equals");
  print +(GetOptions (
        'debug|d:s'   => \$DEBUG,
        'force|f:s'   => \$FORCE,
        'verbose|v:s' => \$VERBOSE,
  ) ? "" : "not ", "ok 63 (START=@START)\n");

  print (($FORCE eq "")        ? "" : "not ", "ok 64 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "")      ? "" : "not ", "ok 65 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 66 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 1)          ? "" : "not ", "ok 67 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print (($ARGV[0] eq "-1")    ? "" : "not ", "ok 68\n");
}

{ ### -v=+3 ==> -v="+3"
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-v=+3);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt", "gnu_equals");
  print +(GetOptions (
        'debug|d:s'   => \$DEBUG,
        'force|f:s'   => \$FORCE,
        'verbose|v:s' => \$VERBOSE,
  ) ? "" : "not ", "ok 69 (START=@START)\n");

  print (($FORCE eq "")        ? "" : "not ", "ok 70 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "+3")    ? "" : "not ", "ok 71 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 72 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 0)          ? "" : "not ", "ok 73 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print ((!defined $ARGV[0])   ? "" : "not ", "ok 74\n");
}

{ ### -v +3 ==> -v -- "+3"
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-v +3);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt", "gnu_equals");
  print +(GetOptions (
        'debug|d:s'   => \$DEBUG,
        'force|f:s'   => \$FORCE,
        'verbose|v:s' => \$VERBOSE,
  ) ? "" : "not ", "ok 75 (START=@START)\n");

  print (($FORCE eq "")        ? "" : "not ", "ok 76 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "")      ? "" : "not ", "ok 77 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 78 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 1)          ? "" : "not ", "ok 79 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print (($ARGV[0] eq "+3")    ? "" : "not ", "ok 80\n");
}

### Increment/Decrement Flags
#
#   Usage:   cmd -v          # Increments `$VERBOSE`
#   Usage:   cmd -v=2        # Sets `$VERBOSE` To Exactly Two
#   Usage:   cmd -v=-2       # Sets `$VERBOSE` To Exactly Negative Two
#   Usage:   cmd -vvv        # Increments `$VERBOSE` By Three
#   Usage:   cmd -v=+3       # Increments `$VERBOSE` By Three
#   Usage:   cmd -v=-3       # Increments `$VERBOSE` By Negative Three
#                            # (i.e., **Decrements** By Three)

{ ### -v=2 -v -v=+3 ==> -v="6"  (2   + 1   + 3)
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-v=2 -v -v=+3);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt", "gnu_equals");
  print +(GetOptions (
        'debug|d:s'   => sub { $DEBUG   = ! length $_[1] ? ( $DEBUG   || 0 ) + 1 : $_[1] =~ /^\+(.+)/ ? ( $DEBUG   || 0 ) + $1 : $_[1] },
        'force|f:s'   => sub { $FORCE   = ! length $_[1] ? ( $FORCE   || 0 ) + 1 : $_[1] =~ /^\+(.+)/ ? ( $FORCE   || 0 ) + $1 : $_[1] },
        'verbose|v:s' => sub { $VERBOSE = ! length $_[1] ? ( $VERBOSE || 0 ) + 1 : $_[1] =~ /^\+(.+)/ ? ( $VERBOSE || 0 ) + $1 : $_[1] },
  ) ? "" : "not ", "ok 81 (START=@START)\n");

  print (($FORCE eq "")        ? "" : "not ", "ok 82 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "6")     ? "" : "not ", "ok 83 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 84 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 0)          ? "" : "not ", "ok 85 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print ((!defined $ARGV[0])   ? "" : "not ", "ok 86\n");
}

{ ### -v=-2 -v -v=+-3 ==> -v="-4"  ( -2   + 1   - 3 )
  my $DEBUG = my $FORCE = my $VERBOSE = "";
  my @START = @ARGV = qw(-v=-2 -v -v=+-3);
  Getopt::Long::Configure ("default", "pass_through", "gnu_getopt", "gnu_equals");
  print +(GetOptions (
        'debug|d:s'   => sub { $DEBUG   = ! length $_[1] ? ( $DEBUG   || 0 ) + 1 : $_[1] =~ /^\+(.+)/ ? ( $DEBUG   || 0 ) + $1 : $_[1] },
        'force|f:s'   => sub { $FORCE   = ! length $_[1] ? ( $FORCE   || 0 ) + 1 : $_[1] =~ /^\+(.+)/ ? ( $FORCE   || 0 ) + $1 : $_[1] },
        'verbose|v:s' => sub { $VERBOSE = ! length $_[1] ? ( $VERBOSE || 0 ) + 1 : $_[1] =~ /^\+(.+)/ ? ( $VERBOSE || 0 ) + $1 : $_[1] },
  ) ? "" : "not ", "ok 87 (START=@START)\n");

  print (($FORCE eq "")        ? "" : "not ", "ok 88 (FORCE=$FORCE)\n");
  print (($VERBOSE eq "-4")    ? "" : "not ", "ok 89 (VERBOSE=$VERBOSE)\n");
  print (($DEBUG eq "")        ? "" : "not ", "ok 90 (DEBUG=$DEBUG)\n");
  print ((@ARGV == 0)          ? "" : "not ", "ok 91 (ARGV[@{[ scalar @ARGV ]}]=@ARGV)\n");
  print ((!defined $ARGV[0])   ? "" : "not ", "ok 92\n");
}
