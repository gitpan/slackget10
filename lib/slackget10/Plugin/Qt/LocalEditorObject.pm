package slackget10::Plugin::Qt::LocalEditorObject;

use slackget10::Plugin::Qt::LocalEditorWidget;
use strict;
use warnings;
use Qt;
use Qt::isa qw(Qt::Object);
use Qt::slots
	addEditorTab => [],
	setMainWindowObject => ['QMainWindow*'],
	setMenuObject => ['QPopupMenu*'],
	init => [],
	addWidgetTab => ['QMainWindow*', 'QWidget*', 'const QString&'];
use Qt::attributes qw( addLocalEditorObjectTabAction );
my $mw_object;
my $menu_object;

sub NEW
{
	print "[Plugin] (debug) create new slackget10::Plugin::Qt::LocalEditorObject\n";
	my $super_object = shift;
	print "[Plugin] (debug) slackget10::Plugin::Qt::LocalEditorObject SUPER => '$super_object'\n";
	$super_object->SUPER::NEW(@_[0..2]);
	print "[Plugin] (debug) slackget10::Plugin::Qt::LocalEditorObject SUPER() finished\n";
	if ( name() eq "unnamed" )
	{
		setName("LocalEditorObject" );
	}
	print "[Plugin] (debug) slackget10::Plugin::Qt::LocalEditorObject created\n";
}

sub init
{
	print "[Plugin] (debug) slackget10::Plugin::Qt::LocalEditorObject::init()\n";
	addLocalEditorObjectTabAction=Qt::Action($mw_object,"LocalEditorObjectAction");
	print "[Plugin] (debug) slackget10::Plugin::Qt::LocalEditorObject::init action => ",addLocalEditorObjectTabAction,"\n";
	print "[Plugin] (debug) slackget10::Plugin::Qt::LocalEditorObject::init main_window_object => $mw_object\n";
	print "[Plugin] (debug) slackget10::Plugin::Qt::LocalEditorObject::init Trying to add action to '",$menu_object,"'\n";
	addLocalEditorObjectTabAction->addTo($menu_object);
	print "[Plugin] (debug) slackget10::Plugin::Qt::LocalEditorObject::init action added to menu\n";
	addLocalEditorObjectTabAction->setText("Add langpack editor tab");
	print "[Plugin] (debug) slackget10::Plugin::Qt::LocalEditorObject::init action text set\n";
	print "[Plugin] (debug) slackget10::Plugin::Qt::LocalEditorObject::init Qt::Object::connect(",addLocalEditorObjectTabAction,",SIGNAL \"activated()\", this, SLOT \"addEditorTab()\")\n";
	Qt::Object::connect(addLocalEditorObjectTabAction,SIGNAL "activated()", this, SLOT "addEditorTab()");
	print "[Plugin] (debug) slackget10::Plugin::Qt::LocalEditorObject::init action is now connected\n";
}

sub addWidgetTab
{
	my ($main_window, $widget,$title) = @_ ;
	print "[Plugin] (debug) slackget10::Plugin::Qt::LocalEditorObject::addWidgetTab($main_window, $widget,$title)\n";
	$main_window->main_tab->addTab($widget,$title);
	$main_window->main_tab->showPage($widget);
}

sub setMainWindowObject
{
	$mw_object = shift;
	print "[Plugin] (debug) slackget10::Plugin::Qt::LocalEditorObject::setMainWindowObject($mw_object)\n";
}

sub setMenuObject
{
	$menu_object = shift;
	print "[Plugin] (debug) slackget10::Plugin::Qt::LocalEditorObject::setMenuObject($menu_object)\n";
}

sub addEditorTab
{
	print "[Plugin] (debug) slackget10::Plugin::Qt::LocalEditorObject::addEditorTab()\n";
# 	srand (time ^ $$ ^ unpack "%L*", `ps axww | gzip`);
# 	my $name = "langpack_editor".int(rand(100));
# 	print "[Plugin] (debug) slackget10::Plugin::Qt::LocalEditorObject::addEditorTab name => $name\n";
# 	my $widget = Qt::Widget($mw_object->main_tab,$name);
# 	print "[Plugin] (debug) slackget10::Plugin::Qt::LocalEditorObject::addEditorTab widget => $widget\n";
# 	my $tabLayout = Qt::GridLayout($widget, 1, 1, 11, 6, "tabLayout_langpack_editor");
# 	print "[Plugin] (debug) slackget10::Plugin::Qt::LocalEditorObject::addEditorTab layout => $tabLayout\n";
# 	my $editor = slackget10::Plugin::Qt::LocalEditorWidget($widget);
# 	print "[Plugin] (debug) slackget10::Plugin::Qt::LocalEditorObject::addEditorTab editor => $editor\n";
# 	addWidgetTab($mw_object,$widget,"Create/Edit Langpack");
}

1;