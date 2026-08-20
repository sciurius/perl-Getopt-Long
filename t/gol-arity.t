#!./perl -w

no strict;

BEGIN {
    if ($ENV{PERL_CORE}) {
	@INC = '../lib';
	chdir 't';
    }
}

use Getopt::Long qw(GetOptionsFromArray);
my $want_version="2.58";
die("Getopt::Long version $want_version required--this is only version ".
    $Getopt::Long::VERSION)
  unless $Getopt::Long::VERSION ge $want_version;

print "1..7\n";

# An option with a fixed arity and no single-character name cannot appear
# in a bundle, so bundling does not conflict with it.

Getopt::Long::Configure(qw(default no_ignore_case bundling permute));

my @argv = qw(--set a 1 --set b 2 -qT rest);
my %opt;
my $ok = eval {
    GetOptionsFromArray(\@argv, \%opt, "quiet|q", "trace|T", "set=s\@{2}");
};
my $err = $@;

my $values = join(",", @{$opt{set} || []});

print (($err eq '')                      ? "" : "not ", "ok 1\n");
print (($ok)                             ? "" : "not ", "ok 2\n");
print ((@{$opt{set} || []} == 4)         ? "" : "not ", "ok 3\n");
print (($values eq "a,1,b,2")            ? "" : "not ", "ok 4\n");

# The short options in the same invocation still unbundle.
print (($opt{quiet} && $opt{trace})      ? "" : "not ", "ok 5\n");

# Operands are left for the caller.
print ((join(",", @argv) eq "rest")      ? "" : "not ", "ok 6\n");

# A single-character option is the one case a bundle genuinely cannot be
# resolved for, and it stays rejected.
Getopt::Long::Configure(qw(default no_ignore_case bundling permute));
my @argv2 = qw(-s a 1);
my %opt2;
eval { GetOptionsFromArray(\@argv2, \%opt2, "s=s\@{2}") };
print (($@ =~ /Cannot repeat while bundling/) ? "" : "not ", "ok 7\n");
