#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'SUSEDOC' ) || print "Bail out!
";
}

diag( "Testing SUSEDOC $SUSEDOC::VERSION, Perl $], $^X" );
