#! perl -T

# Please call the program this way: $0 -T -opt1 value1 -opt2=value2

use strict;
use warnings;

use Getopt::Long;
use Scalar::Util qw(tainted);

my %options;

GetOptions(\%options, 'opt1=s', 'opt2=s');

my $ret = 0;
for ( keys( %options ) ) {
    print( "# The value of --$_ is ",
	   tainted( $options{$_} )
	   ? ''
	   : 'not ',
	   "tainted.\n"), $ret++
	     unless tainted( $options{$_} );
}
exit($ret);
