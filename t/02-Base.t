use Test::More tests => 3;

use slackget10::Base;
use slackget10::Config;

my $config = slackget10::Config->new('t/config.xml');
ok($config);

diag("\n\nThe test of the slackget10::Base class can success only if the followings class are running well : slackget10::PackageList, slackget10::Package, slackget10::File, slackget10::Media, slackget10::MediaList, slackget10::Date\n\n");

my $sgb = new slackget10::Base($config);
ok($sgb);
diag("\n\nWe are now compiling the /var/log/packages/ directory.\nIt will takes some time (from 5 secondes to 10 minutes depending of your system configuration)\n\n");
ok($sgb->compil_packages_directory('/var/log/packages/'));