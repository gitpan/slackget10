package slackget10::Plugin::Test2 ;

use Qt;
use strict;
use warnings;
use lib '/home/1024/progz/slack-get/V1.0/slack-get/lib/slackget10/lib/';
use slackget10::GUI::Qt::sb_plugin_test2 ;

our $PLUGIN_TYPE='GUI';

sub new
{
	my $ref = shift;
	my $self = {};
	bless($self,$ref);
	return $self;
}

sub hook_plugin_init_gui
{
	my $self = shift;
	my $main_window = shift;
	my $popup_menu = shift ;
	
	# Init windows if needed
	my $widget = slackget10::GUI::Qt::sb_plugin_test2($main_window);
	$widget->hide();
	
	# Init the menu
	my $plugin_root_action=Qt::Action($main_window,"pluginTest2Action");
	$plugin_root_action->addTo($popup_menu);
	$plugin_root_action->setText("plug-in->Test2");
	
	# Do signal connections
	Qt::Object::connect($plugin_root_action,SIGNAL "activated()", $widget, SLOT "show()");
}

1;