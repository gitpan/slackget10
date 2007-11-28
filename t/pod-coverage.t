#!perl -T

use Test::More;
eval "use Test::Pod::Coverage 1.04";
plan skip_all => "Test::Pod::Coverage 1.04 required for testing POD coverage" if $@;
plan tests => 22;
#all_pod_coverage_ok();

pod_coverage_ok( "slackget10" );
pod_coverage_ok( "slackget10::Base" );
pod_coverage_ok( "slackget10::Config" );
pod_coverage_ok( "slackget10::Date" );
pod_coverage_ok( "slackget10::File" );
pod_coverage_ok( "slackget10::List" );
#pod_coverage_ok( "slackget10::Local" ); # Pending deletion....
pod_coverage_ok( "slackget10::Network" );
pod_coverage_ok( "slackget10::Network::Auth" );
pod_coverage_ok( "slackget10::Network::Connection" );
pod_coverage_ok( "slackget10::Network::Connection::FTP" );
pod_coverage_ok( "slackget10::Network::Connection::HTTP" );
pod_coverage_ok( "slackget10::Network::Message" );
pod_coverage_ok( "slackget10::Package" );
pod_coverage_ok( "slackget10::PackageList" );
pod_coverage_ok( "slackget10::PkgTools" );
pod_coverage_ok( "slackget10::Search" );
pod_coverage_ok( "slackget10::SpecialFileContainer" );
pod_coverage_ok( "slackget10::SpecialFileContainerList" );
pod_coverage_ok( "slackget10::SpecialFiles::CHECKSUMS" );
pod_coverage_ok( "slackget10::SpecialFiles::FILELIST" );
pod_coverage_ok( "slackget10::SpecialFiles::PACKAGES" );
pod_coverage_ok( "slackget10::Status" );