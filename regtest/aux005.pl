#!/usr/bin/perl -w

use Getopt::Long 2.3203 qw(HelpMessage);

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
    $res = close($fh);
    $res = $?;
    die("ret = $res, should be 1<<8\n")
      unless $res == 1<<8;
}
else {
    HelpMessage(1);
}

=head1 SYNOPSIS

This is a test message.

=cut
