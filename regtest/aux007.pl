#!/usr/bin/perl -w

# Auto-vivification of scalar ref into hash ref.

use Getopt::Long;

my $ref;

@ARGV = ();
GetOptions("foo=s%" => \$ref);
warn("\$ref defined\n") if defined($ref);

undef($ref);
@ARGV = qw(--foo=bar=blech);
GetOptions("foo=s%" => \$ref);
warn("\$ref defined\n") unless ref($ref) eq 'HASH';
warn("\$ref->{bar} not \"blech\"\n") unless $ref->{bar} eq 'blech';

undef($ref);
@ARGV = qw(--foo=x2=bar --foo=x3=blech);
GetOptions("foo=s%" => \$ref);
warn("\$ref defined\n") unless ref($ref) eq 'HASH';
warn("\$ref->{x2} not \"bar\"\n") unless $ref->{x2} eq 'bar';
warn("\$ref->{x3} not \"blech\"\n") unless $ref->{x3} eq 'blech';
