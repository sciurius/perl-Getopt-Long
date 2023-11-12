#!/usr/bin/perl -w

use Getopt::Long;

my $parser = Getopt::Long::Parser->new;

$parser->configure("default");

@ARGV = qw(hello);

$parser->getoptions("foo");

__END__
From: "John JR Scott" <JJRSCOTT@uk.ibm.com>
To: jvromans@squirrel.nl
Subject: Bug with GetOpt::Long::Parser::configure
Date: Fri, 3 May 2002 15:27:33 +0100

I'm sorry to both you and apologise if this problem has already been 
found.

The fault is in the Getopt/Long.pm module where the function Configure 
from the Getopt::Long package is not fully qualified in 
Getopt::Long::Parser::configure function. 


package Getopt::Long::Parser;

...

sub configure {
    my ($self) = shift;

    &$_lock;

    # Restore settings, merge new settings in.
    my $save = Getopt::Long::Configure ($self->{settings}, @_);

    # Restore orig config and save the new config.
    $self->{settings} = Configure ($save);     #<<<<<
}

the #<<<<< should have

$self->{settings} = Getopt::Long::Configure ($save);

I've made the change in my code and it now ok. I use ActiveState 5.6.1 
build 631, but the problem seems to also be in Getopt::Long version 2.29.

Thanks



John Scott
Tel : [[+44 | 0] 1962 81 | 24] 7491
MQSeries System Test
MP 211, IBM Hursley, Winchester, SO21 2JN
jjrscott@uk.ibm.com
