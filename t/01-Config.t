use Test::More tests => 1;

use slackget10::Config;

my $config = slackget10::Config->new('t/config.xml');
ok($config);
diag("slack-get's configuration loaded - version is $config->{common}->{'conf-version'}");