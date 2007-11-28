use Test::More tests => 25;

BEGIN {
use_ok( 'slackget10' );
use_ok( 'slackget10::Base' );
use_ok( 'slackget10::Config' );
use_ok( 'slackget10::Date' );
use_ok( 'slackget10::File' );
use_ok( 'slackget10::List' );
use_ok( 'slackget10::Local' );
use_ok( 'slackget10::Media' );
use_ok( 'slackget10::MediaList' );
use_ok( 'slackget10::Network' );
use_ok( 'slackget10::Network::Auth' );
use_ok( 'slackget10::Network::Connection' );
use_ok( 'slackget10::Network::Connection::FTP' );
use_ok( 'slackget10::Network::Connection::HTTP' );
use_ok( 'slackget10::Network::Message' );
use_ok( 'slackget10::Package' );
use_ok( 'slackget10::PackageList' );
use_ok( 'slackget10::PkgTools' );
use_ok( 'slackget10::Search' );
use_ok( 'slackget10::SpecialFileContainer' );
use_ok( 'slackget10::SpecialFileContainerList' );
use_ok( 'slackget10::SpecialFiles::CHECKSUMS' );
use_ok( 'slackget10::SpecialFiles::FILELIST' );
use_ok( 'slackget10::SpecialFiles::PACKAGES' );
use_ok( 'slackget10::Status' );
}

diag( "Testing slackget10 $slackget10::VERSION, Perl $], $^X" );
