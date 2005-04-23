use Test::More tests => 4;

BEGIN {
use_ok( 'slackget10' );
use_ok( 'slackget10::Base' );
use_ok( 'slackget10::Networking' );
use_ok( 'slackget10::File' );
}

diag( "Testing slackget10 $slackget10::VERSION, Perl 5.008006, /usr/bin/perl5.8.6" );
