use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'slackget10',
    license             => 'perl',
    dist_author         => 'Arnaud Dupuis <dupuisarn@cpan.org>',
    dist_version_from   => 'lib/slackget10.pm',
    build_requires => {
        'Test::More' => 0,
        'XML::Simple' => 0,
        'File::Copy' => 0,
        'perl' => '>= 5.8.5',
	'Net::FTP' => '>= 2.75',
	'LWP::Simple' => '>= 1.41',
	'Time::HiRes' => '>= 1.66',
	'HTTP::Status' => '>= 1.28',
	'HTTP::Request' => '>= 1.40',
	'File::Copy' => '>= 2.08',
	'Data::Dumper' => '>= 2.121_02',
	'Proc::Daemon' => 0,
	'Getopt::Long' => 0,
	'XML::Parser' => 0,
#	'POE::Component::Client::HTTP' => '>= 0.82',
#	'POE::Component::Client::DNS' => '>= 1.00',
    },
    add_to_cleanup      => [ 'slackget10-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
