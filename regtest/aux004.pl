#!/usr/bin/perl -w

use Getopt::Long 2.3203 qw(:config help);

if ( open (my $fh, "-|") ) {
    my $res = <$fh>;
    die("res1 = $res, should be Usage:\n")
      unless $res eq "Usage:\n";
    $res = <$fh>;
    die("res2 = $res, should be This is a test message.\n")
      unless $res eq "    This is a test message.\n";
    $res = <$fh>;
    die("res3 = $res, should be \n")
      unless $res eq "\n";
}
else {
    @ARGV = qw(--help);
    GetOptions("foo");
}

=head1 SYNOPSIS

This is a test message.

=cut
