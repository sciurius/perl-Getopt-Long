#!/usr/bin/perl -w

use Getopt::Long 2.3203 qw(:config version);

if ( pipe_from_fork('FH') ) {
    # parent
    my $res = <FH>;
    die("res = $res, should be $0\n")
      unless $res eq "$0\n";
    $res = <FH>;
    my $exp = "(Getopt::Long::GetOptions version $Getopt::Long::VERSION, Perl version " .
	($] >= 5.006 ? sprintf("%vd", $^V) : $]) . ")";
    die("res = $res, should be $exp\n")
      unless $res eq "$exp\n";
}
else {
    # child
    @ARGV = qw(--version);
    GetOptions("foo");
}

#### SUBs

# simulate open(FH, "-|") ## from "perldoc perlfork"
sub pipe_from_fork ## ($FH_NAME): $CHILD_PID
{
    use open IO => ':crlf';
    my $parent = shift;
    pipe $parent, my $child or die;
    my $pid = fork();
    die "fork() failed: $!" unless defined $pid;
    if ($pid) {
        close $child;
    }
    else {
        close $parent;
        open(STDOUT, ">&=" . fileno($child)) or die;
    }
    $pid;
}
