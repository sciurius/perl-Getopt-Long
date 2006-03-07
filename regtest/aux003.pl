#!/usr/bin/perl -w

use Getopt::Long 2.3203 qw(:config version);

if ( open (my $fh, "-|") ) {
    my $res = <$fh>;
    die("res = $res, should be $0\n")
      unless $res eq "$0\n";
    $res = <$fh>;
    my $exp = "(Getopt::Long::GetOptions version ".
      ($Getopt::Long::VERSION_STRING||$Getopt::Long::VERSION) . "; Perl version " .
	($] >= 5.006 ? sprintf("%vd", $^V) : $]) . ")";
    die("res = $res, should be $exp\n")
      unless $res eq "$exp\n";
}
else {
    @ARGV = qw(--version);
    GetOptions("foo");
}

