use Test::More tests => 2;

use slackget10::Base;

ok(my $sgb = new slackget10::Base);
ok($sgb->create_installed_packages_xml_file('/var/log/packages/'));