use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'slackget10',
    license             => 'gpl',
    dist_author         => 'DUPUIS Arnaud <a.dupuis@infinityperl.org>',
    dist_version_from   => 'lib/slackget10.pm',
    requires => {
    	'perl' => '>= 5.8.5',
	'Net::FTP' => '>= 2.75',
	'XML::Simple' => '>= 2.14',
	'Test::More' => '>= 0.47',
	'LWP::Simple' => '>= 1.41',
	'Time::HiRes' => '>= 1.66',
	'HTTP::Status' => '>= 1.28',
	'File::Copy' => '>= 2.08',
	'Data::Dumper' => '>= 2.121_02',
	'GnuPG'  => 0,
	'Proc::Daemon' => 0,
	'Getopt::Long' => 0
    },
    recommends => {
    	Qt => '3.008'
    },
    add_to_cleanup      => [ 'slackget10-*' ],
);

$builder->create_build_script();
