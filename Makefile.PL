use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'slackget10',
    AUTHOR              => 'DUPUIS Arnaud <a.dupuis@infinityperl.org>',
    VERSION_FROM        => 'lib/slackget10.pm',
    ABSTRACT_FROM       => 'lib/slackget10.pm',
    PL_FILES            => {},
    PREREQ_PM => {
	'Net::FTP' => '2.75',
	'XML::Simple' => '2.14',
	'Test::More' => '0.47',
	'LWP::Simple' => '1.41',
	'Time::HiRes' => '1.66',
	'HTTP::Status' => '1.28',
	'File::Copy' => '2.08',
	'Data::Dumper' => '2.121_02',
	'Qt' => '3.008',
	'GnuPG'  => 0,
	'Proc::Daemon' => 0,
	'Getopt::Long' => 0
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'slackget10-*' },
);
