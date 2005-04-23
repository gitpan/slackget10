use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'slackget10',
    license             => 'gpl',
    dist_author         => 'DUPUIS Arnaud <a.dupuis@infinityperl.org>',
    dist_version_from   => 'lib/slackget10.pm',
    requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'slackget10-*' ],
);

$builder->create_build_script();
