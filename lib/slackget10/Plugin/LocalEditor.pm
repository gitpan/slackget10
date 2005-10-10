package slackget10::Plugin::LocalEditor ;

use Qt;
use strict;
use warnings;
use lib '@@INSTALLDIR@@/lib';
use lib '/home/1024/progz/slack-get/V1.0/slack-get/lib/slackget10/lib/';
use slackget10::Plugin::Qt::LocalEditorWidget ;
use slackget10::Plugin::Qt::LocalEditorObject ;

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
	my $widget = Qt::Widget($main_window->main_tab,"langpack_editor");
	my $tabLayout = Qt::GridLayout($widget, 1, 1, 11, 6, "tabLayout_langpack_editor");
	my $editor = slackget10::Plugin::Qt::LocalEditorWidget($widget);
	$tabLayout->addWidget($editor, 1, 0);
	$main_window->main_tab->addTab($widget,"Create/Edit Langpack");
# 	my $leo = slackget10::Plugin::Qt::LocalEditorObject($main_window);
# 	print "[Plugin] (debug) slackget10::Plugin::Qt::LocalEditor \$leo => '$leo' \n";
# 	$leo->setMainWindowObject($main_window);
# 	$leo->setMenuObject($popup_menu);
# 	$leo->init ;
	
	# Init the menu
	my $plugin_root_action=Qt::Action($main_window,"LocalEditorWidgetAction");
	$plugin_root_action->addTo($popup_menu);
	$plugin_root_action->setText("Create/Edit langpack");
	
	# Do signal connections
	Qt::Object::connect($plugin_root_action,SIGNAL "activated()", $editor, SLOT "about_editor()");
	print "[Plugin] (debug) slackget10::Plugin::LocalEditor => end of initialisation \n";
}

1;