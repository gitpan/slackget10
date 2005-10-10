

use strict;
use utf8;


package slackget10::GUI::Qt::slack_conf3;
use Qt;
use Qt::isa qw(Qt::Dialog);
use Qt::slots
    configFile => ['const QString&'],
    open_config_file_button_clicked => [],
    showInfo => ['const QString&'],
    apply_button_clicked => [],
    ok_button_clicked => [],
    default_button_clicked => [],
    lv_doubleClicked => ['QListViewItem*'];
use Qt::attributes qw(
    cmd_group
    ok_button
    cancel_button
    default_button
    apply_button
    open_config_file_button
    tabWidget3
    tab
    common_lv
    tab_2
    daemon_lv
    TabPage
    gui_lv
    TabPage_2
    command_lv
    TabPage_3
    plugin_lv
    info_frame
    info_label
);

use lib '@@INSTALLDIR@@/lib' ;
use slackget10::Config;
use slackget10::GUI::Qt::ImagesCollection ;
use slackget10::File ;

sub NEW
{
    shift->SUPER::NEW(@_[0..3]);

    if ( name() eq "unnamed" )
    {
        setName("slack_conf3" );
    }
    setMinimumSize(Qt::Size(500, 300) );
    Qt::ToolTip::add( this, undef);

    my $slack_conf3Layout = Qt::GridLayout(this, 1, 1, 11, 6, '$slack_conf3Layout');

    cmd_group = Qt::ButtonGroup(this, "cmd_group");
    cmd_group->setMinimumSize( Qt::Size(580, 63) );
    cmd_group->setMaximumSize( Qt::Size(32767, 120) );
    cmd_group->setColumnLayout( 0, &Vertical );
    cmd_group->layout()->setSpacing(6);
    cmd_group->layout()->setMargin(11);
    my $cmd_groupLayout = Qt::GridLayout(cmd_group->layout() );
    $cmd_groupLayout->setAlignment( &AlignTop );

    ok_button = Qt::PushButton(cmd_group, "ok_button");
    ok_button->setIconSet( Qt::IconSet(Qt::Pixmap::fromMimeSource("button_ok.png")) );

    $cmd_groupLayout->addWidget(ok_button, 0, 3);

    cancel_button = Qt::PushButton(cmd_group, "cancel_button");
    cancel_button->setIconSet( Qt::IconSet(Qt::Pixmap::fromMimeSource("button_cancel.png")) );

    $cmd_groupLayout->addWidget(cancel_button, 0, 4);

    default_button = Qt::PushButton(cmd_group, "default_button");
    default_button->setIconSet( Qt::IconSet(Qt::Pixmap::fromMimeSource("reload.png")) );

    $cmd_groupLayout->addWidget(default_button, 0, 2);

    apply_button = Qt::PushButton(cmd_group, "apply_button");
    apply_button->setIconSet( Qt::IconSet(Qt::Pixmap::fromMimeSource("filesave.png")) );

    $cmd_groupLayout->addWidget(apply_button, 0, 1);

    open_config_file_button = Qt::PushButton(cmd_group, "open_config_file_button");
    open_config_file_button->setMaximumSize( Qt::Size(30, 30) );
    open_config_file_button->setPixmap( Qt::Pixmap::fromMimeSource("fileopen.png") );

    $cmd_groupLayout->addWidget(open_config_file_button, 0, 0);

    $slack_conf3Layout->addWidget(cmd_group, 2, 0);

    tabWidget3 = Qt::TabWidget(this, "tabWidget3");

    tab = Qt::Widget(tabWidget3, "tab");
    my $tabLayout = Qt::GridLayout(tab, 1, 1, 11, 6, '$tabLayout');

    common_lv = Qt::ListView(tab, "common_lv");
    common_lv->addColumn(trUtf8("__OPT"));
    common_lv->addColumn(trUtf8("__VAL"));
    common_lv->addColumn(trUtf8("__HELP"));
    common_lv->setAllColumnsShowFocus( 1 );
    common_lv->setShowSortIndicator( 1 );
    common_lv->setRootIsDecorated( 1 );

    $tabLayout->addWidget(common_lv, 0, 0);
    tabWidget3->insertTab( tab, "" );

    tab_2 = Qt::Widget(tabWidget3, "tab_2");
    my $tabLayout_2 = Qt::GridLayout(tab_2, 1, 1, 11, 6, '$tabLayout_2');

    daemon_lv = Qt::ListView(tab_2, "daemon_lv");
    daemon_lv->addColumn(trUtf8("__OPT"));
    daemon_lv->addColumn(trUtf8("__VAL"));
    daemon_lv->addColumn(trUtf8("__HELP"));
    daemon_lv->setAllColumnsShowFocus( 1 );
    daemon_lv->setShowSortIndicator( 1 );
    daemon_lv->setRootIsDecorated( 1 );

    $tabLayout_2->addWidget(daemon_lv, 0, 0);
    tabWidget3->insertTab( tab_2, "" );

    TabPage = Qt::Widget(tabWidget3, "TabPage");
    my $TabPageLayout = Qt::GridLayout(TabPage, 1, 1, 11, 6, '$TabPageLayout');

    gui_lv = Qt::ListView(TabPage, "gui_lv");
    gui_lv->addColumn(trUtf8("__OPT"));
    gui_lv->addColumn(trUtf8("__VAL"));
    gui_lv->addColumn(trUtf8("__HELP"));
    gui_lv->setAllColumnsShowFocus( 1 );
    gui_lv->setShowSortIndicator( 1 );
    gui_lv->setRootIsDecorated( 1 );

    $TabPageLayout->addWidget(gui_lv, 0, 0);
    tabWidget3->insertTab( TabPage, "" );

    TabPage_2 = Qt::Widget(tabWidget3, "TabPage_2");
    my $TabPageLayout_2 = Qt::GridLayout(TabPage_2, 1, 1, 11, 6, '$TabPageLayout_2');

    command_lv = Qt::ListView(TabPage_2, "command_lv");
    command_lv->addColumn(trUtf8("__OPT"));
    command_lv->addColumn(trUtf8("__VAL"));
    command_lv->addColumn(trUtf8("__HELP"));
    command_lv->setAllColumnsShowFocus( 1 );
    command_lv->setShowSortIndicator( 1 );
    command_lv->setRootIsDecorated( 1 );

    $TabPageLayout_2->addWidget(command_lv, 0, 0);
    tabWidget3->insertTab( TabPage_2, "" );

    TabPage_3 = Qt::Widget(tabWidget3, "TabPage_3");
    my $TabPageLayout_3 = Qt::GridLayout(TabPage_3, 1, 1, 11, 6, '$TabPageLayout_3');

    plugin_lv = Qt::ListView(TabPage_3, "plugin_lv");
    plugin_lv->addColumn(trUtf8("__OPT"));
    plugin_lv->addColumn(trUtf8("__VAL"));
    plugin_lv->addColumn(trUtf8("__HELP"));
    plugin_lv->setResizePolicy( &Qt::ScrollView::Manual() );
    plugin_lv->setAllColumnsShowFocus( 1 );
    plugin_lv->setShowSortIndicator( 1 );
    plugin_lv->setRootIsDecorated( 1 );

    $TabPageLayout_3->addWidget(plugin_lv, 0, 0);
    tabWidget3->insertTab( TabPage_3, "" );

    $slack_conf3Layout->addWidget(tabWidget3, 1, 0);

    info_frame = Qt::Frame(this, "info_frame");
    info_frame->setFrameShape( &Qt::Frame::StyledPanel() );
    info_frame->setFrameShadow( &Qt::Frame::Raised() );

    info_label = Qt::Label(info_frame, "info_label");
    info_label->setGeometry( Qt::Rect(10, 10, 230, 40) );

    $slack_conf3Layout->addWidget(info_frame, 0, 0);
    languageChange();
    my $resize = Qt::Size(598, 469);
    $resize = $resize->expandedTo(minimumSizeHint());
    resize( $resize );
    clearWState( &Qt::WState_Polished );

    Qt::Object::connect(cancel_button, SIGNAL "clicked()", this, SLOT "close()");
    Qt::Object::connect(open_config_file_button, SIGNAL "clicked()", this, SLOT "open_config_file_button_clicked()");
    Qt::Object::connect(apply_button, SIGNAL "clicked()", this, SLOT "apply_button_clicked()");
    Qt::Object::connect(ok_button, SIGNAL "clicked()", this, SLOT "ok_button_clicked()");
    Qt::Object::connect(default_button, SIGNAL "clicked()", this, SLOT "default_button_clicked()");
    Qt::Object::connect(common_lv, SIGNAL "doubleClicked(QListViewItem*)", this, SLOT "lv_doubleClicked(QListViewItem*)");
    Qt::Object::connect(daemon_lv, SIGNAL "doubleClicked(QListViewItem*)", this, SLOT "lv_doubleClicked(QListViewItem*)");
    Qt::Object::connect(gui_lv, SIGNAL "doubleClicked(QListViewItem*)", this, SLOT "lv_doubleClicked(QListViewItem*)");
    Qt::Object::connect(command_lv, SIGNAL "doubleClicked(QListViewItem*)", this, SLOT "lv_doubleClicked(QListViewItem*)");
    Qt::Object::connect(plugin_lv, SIGNAL "doubleClicked(QListViewItem*)", this, SLOT "lv_doubleClicked(QListViewItem*)");

    init();
}


sub DESTROY
{
    destroy();
    SUPER->DESTROY()
}


sub languageChange
{
    setCaption(trUtf8("Configure - slack-get") );
    cmd_group->setTitle( trUtf8("__WIDG_SC2_CMDGRP_TITLE") );
    ok_button->setText( trUtf8("__OK") );
    cancel_button->setText( trUtf8("__CANCEL") );
    default_button->setText( trUtf8("__DEFAULT") );
    apply_button->setText( trUtf8("__APPLY") );
    open_config_file_button->setText( undef );
    Qt::ToolTip::add(open_config_file_button, trUtf8("Open a different configuration file"));
    Qt::WhatsThis::add(open_config_file_button, trUtf8("Open a different configuration file"));
    common_lv->header()->setLabel( 0, trUtf8("__OPT") );
    common_lv->header()->setLabel( 1, trUtf8("__VAL") );
    common_lv->header()->setLabel( 2, trUtf8("__HELP") );
    tabWidget3->changeTab( tab, trUtf8("common") );
    daemon_lv->header()->setLabel( 0, trUtf8("__OPT") );
    daemon_lv->header()->setLabel( 1, trUtf8("__VAL") );
    daemon_lv->header()->setLabel( 2, trUtf8("__HELP") );
    tabWidget3->changeTab( tab_2, trUtf8("daemon") );
    gui_lv->header()->setLabel( 0, trUtf8("__OPT") );
    gui_lv->header()->setLabel( 1, trUtf8("__VAL") );
    gui_lv->header()->setLabel( 2, trUtf8("__HELP") );
    tabWidget3->changeTab( TabPage, trUtf8("GUI") );
    command_lv->header()->setLabel( 0, trUtf8("__OPT") );
    command_lv->header()->setLabel( 1, trUtf8("__VAL") );
    command_lv->header()->setLabel( 2, trUtf8("__HELP") );
    tabWidget3->changeTab( TabPage_2, trUtf8("command") );
    plugin_lv->header()->setLabel( 0, trUtf8("__OPT") );
    plugin_lv->header()->setLabel( 1, trUtf8("__VAL") );
    plugin_lv->header()->setLabel( 2, trUtf8("__HELP") );
    tabWidget3->changeTab( TabPage_3, trUtf8("plug-in") );
    info_label->setText( undef );
}


my $config_file = '/etc/slack-get/config.xml' ;
my $config_object;
my $VERSION = '0.3';
my $SELF_DESCRIPTION="A part of the GUI, slack_conf3 is the configuration widget.";
my $INSTALLDIR = '@@INSTALLDIR@@';
my $local;

sub init
{
    _load_config() ;
    my $rect = info_frame->geometry();
    $rect->setWidth(0);
    $rect->setHeight(0);
    $rect->setLeft(0);
    $rect->setTop(0);
    info_frame->setGeometry($rect) ;
    info_frame->hide();
}


sub destroy
{

}


sub configFile # SLOT: ( const QString & )
{
    my $tmp_config_file = shift(@_) if( -e $_[0] );
    print "[DEBUG] (slack_conf3) in slot configFile( const QString & ) receiving \"$tmp_config_file\" as new config file\n";
    if($tmp_config_file && $tmp_config_file ne $config_file)
    {
	$config_file = $tmp_config_file;
	_load_config();
    }
}


sub configObject
{
    my $tmp = shift;
    if(ref($tmp) eq 'slackget10::Config')
    {
	$config_object = $tmp ;
    }
}

sub _add_all
{
	my ($parent,$ref) = @_;
	foreach my $key (keys(%{ $ref } ))
	{
	    my $item = Qt::ListViewItem($parent);
	    $item->setText(0,$key);
	    if(ref($ref->{$key}) ne '')
	    {
		_add_all($item,$ref->{$key}) ;
	    }
	    else
	    {
		$item->setText(1,$ref->{$key}) ;
	    }
	}
}
sub _load_config
{

    $config_object = new slackget10::Config($config_file) ;
    common_lv->clear();
    daemon_lv->clear();
    gui_lv->clear();
    command_lv->clear() ;
    plugin_lv->clear();
    _add_all(common_lv,$config_object->{'common'}) ;
    _add_all(daemon_lv,$config_object->{'daemon'}) ;
    _add_all(gui_lv,$config_object->{'gui'}) ;
    _add_all(command_lv,$config_object->{'command'}) ;
    _add_all(plugin_lv,$config_object->{'plug-in'}) ;
    setCaption(trUtf8("Configure - slack-get - [$config_file]") );
}


sub open_config_file_button_clicked
{
    $config_file = Qt::FileDialog::getOpenFileName( $INSTALLDIR,"XML (*.xml)", this,"open file dialog","Choose a configuration file to open" );
    _load_config() if($config_file);
}


sub showInfo # SLOT: ( const QString & )
{
    my $msg = shift;
    info_label->setText(trUtf8($msg));
    my $rect = info_frame->geometry();
    $rect->setLeft(0);
    $rect->setTop(0);
    $rect->setWidth(0);
    $rect->setHeight(0);
    info_frame->setGeometry($rect) ;
    info_frame->show();
    info_frame->update();
    info_label->setGeometry($rect);
    info_label->show();
    info_label->update();
    for(my $k = 0; $k<=360; $k++)
    {
        $rect->setWidth($k);
        $rect->setHeight(int($k/3));
        info_frame->setGeometry($rect) ;
        info_frame->update();
        info_label->setGeometry($rect);
        info_label->update();
        this->update();
    }
    info_label->setGeometry($rect);
    info_frame->update();
    info_label->update();
    this->update();
}


sub apply_button_clicked
{
    unlink $config_file;
    my $file_object = slackget10::File->new($config_file,'no-auto-load' => 1);
    $file_object->Add(_all_lv_to_xml());
    unless($file_object->Write())
    {
        Qt::MessageBox::critical ( this, "FATAL", $local->Get("__CONFIG_FILE_WRITE_ERROR")."","Ok", undef, undef, 0, 0);
    }
}


sub ok_button_clicked
{
    apply_button_clicked();
    this->close(1);
}


sub default_button_clicked
{
    common_lv->clear();
    daemon_lv->clear();
    gui_lv->clear();
    command_lv->clear() ;
    plugin_lv->clear();
    _add_all(common_lv,$config_object->{'common'}) ;
    _add_all(daemon_lv,$config_object->{'daemon'}) ;
    _add_all(gui_lv,$config_object->{'gui'}) ;
    _add_all(command_lv,$config_object->{'command'}) ;
    _add_all(plugin_lv,$config_object->{'plug-in'}) ;
}


sub _all_lv_to_xml
{
    our $indent = "\t\t";
    our $xml = "<slack-get>\n";
    sub _lv_to_xml
    {
        my $object = shift;
        return unless(defined($object));
        my $item = $object->firstChild();
        return unless(defined($item));
        if(defined($item->firstChild()))
        {
            if($item->text(0) =~ /(\d+)\.(\d+)\.(\d+)\.(\d+)/)
            {
                $xml .= "$indent<host id=\"".$item->text(0)."\">\n";
                $indent .= "\t";
            }
            elsif($item->text(0) ne 'host')
            {
                $xml .= "$indent<".$item->text(0).">\n";
                $indent .= "\t";
            }

            _lv_to_xml($item);
            if($item->text(0) =~ /(\d+)\.(\d+)\.(\d+)\.(\d+)/)
            {
                chop $indent;
                $xml .= "$indent</host>\n";
            }
            elsif($item->text(0) ne 'host')
            {
                chop $indent;
                $xml .= "$indent</".$item->text(0).">\n";
            }
        }
        else
        {
            $xml .= "$indent<".$item->text(0)."><![CDATA[".$item->text(1)."]]></".$item->text(0).">\n";
        }
        while($item = $item->nextSibling())
        {
            if(defined($item->firstChild()))
            {
                if($item->text(0) =~ /(\d+)\.(\d+)\.(\d+)\.(\d+)/)
                {
                    $xml .= "$indent<host id=\"".$item->text(0)."\">\n";
                    $indent .= "\t";
                }
                elsif($item->text(0) ne 'host')
                {
                    $xml .= "$indent<".$item->text(0).">\n";
                    $indent .= "\t";
                }

                _lv_to_xml($item);
                if($item->text(0) =~ /(\d+)\.(\d+)\.(\d+)\.(\d+)/)
                {
                    chop $indent;
                    $xml .= "$indent</host>\n";
                }
                elsif($item->text(0) ne 'host')
                {
                    chop $indent;
                    $xml .= "$indent</".$item->text(0).">\n";
                }
            }
            else
            {
                $xml .= "$indent<".$item->text(0)."><![CDATA[".$item->text(1)."]]></".$item->text(0).">\n";
            }
        }
    }
    $xml .= "\t<common>\n";
    _lv_to_xml(common_lv);
    $xml .= "\t</common>\n";
    $xml .= "\t<daemon>\n";
    _lv_to_xml(daemon_lv);
    $xml .= "\t</daemon>\n";
    $xml .= "\t<gui>\n";
    _lv_to_xml(gui_lv);
    $xml .= "\t</gui>\n";
    $xml .= "\t<command>\n";
    _lv_to_xml(command_lv);
    $xml .= "\t</command>\n";
    $xml .= "\t<plug-in>\n";
    _lv_to_xml(plugin_lv);
    $xml .= "\t</plug-in>\n";
    $xml .= "</slack-get>\n";

    return $xml;
}

sub lv_doubleClicked # SLOT: ( QListViewItem * )
{
    my $item = shift;
    my $ok=1;
    my $text = Qt::InputDialog::getText("slack-conf", "Enter a value for option \"".$item->text(0)."\" :", &Qt::LineEdit::Normal,$item->text(1), $ok, this );
    $item->setText(1,trUtf8($text)) if($text);
}


sub loadLocal
{
    $local = shift ;
    cmd_group->setTitle( trUtf8($local->Get("__WIDG_SC2_CMDGRP_TITLE")) );
    ok_button->setText( trUtf8($local->Get("__OK")) );
    cancel_button->setText( trUtf8($local->Get("__CANCEL")) );
    default_button->setText( trUtf8($local->Get("__DEFAULT")) );
    apply_button->setText( trUtf8($local->Get("__APPLY")) );
    open_config_file_button->setText( undef );
    Qt::ToolTip::add(open_config_file_button, trUtf8("Open a different configuration file"));
    Qt::WhatsThis::add(open_config_file_button, trUtf8("Open a different configuration file"));
    common_lv->header()->setLabel( 0, trUtf8($local->Get("__OPT")) );
    common_lv->header()->setLabel( 1, trUtf8($local->Get("__VAL")) );
    common_lv->header()->setLabel( 2, trUtf8($local->Get("__HELP")) );
    tabWidget3->changeTab( tab, trUtf8("common") );
    daemon_lv->header()->setLabel( 0, trUtf8($local->Get("__OPT")) );
    daemon_lv->header()->setLabel( 1, trUtf8($local->Get("__VAL")) );
    daemon_lv->header()->setLabel( 2, trUtf8($local->Get("__HELP")) );
    tabWidget3->changeTab( tab_2, trUtf8("daemon") );
    gui_lv->header()->setLabel( 0, trUtf8($local->Get("__OPT")) );
    gui_lv->header()->setLabel( 1, trUtf8($local->Get("__VAL")) );
    gui_lv->header()->setLabel( 2, trUtf8($local->Get("__HELP")) );
    tabWidget3->changeTab( TabPage, trUtf8("GUI") );
    command_lv->header()->setLabel( 0, trUtf8($local->Get("__OPT")) );
    command_lv->header()->setLabel( 1, trUtf8($local->Get("__VAL")) );
    command_lv->header()->setLabel( 2, trUtf8($local->Get("__HELP")) );
    tabWidget3->changeTab( TabPage_2, trUtf8("command") );
    plugin_lv->header()->setLabel( 0, trUtf8($local->Get("__OPT")) );
    plugin_lv->header()->setLabel( 1, trUtf8($local->Get("__VAL")) );
    plugin_lv->header()->setLabel( 2, trUtf8($local->Get("__HELP")) );
    tabWidget3->changeTab( TabPage_3, trUtf8("plug-in") );
}

1;
