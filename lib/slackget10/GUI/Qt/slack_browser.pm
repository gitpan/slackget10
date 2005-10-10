

use strict;
use utf8;


package slackget10::GUI::Qt::slack_browser;
use Qt;
use Qt::isa qw(Qt::MainWindow);
use Qt::slots
    fileExit => [],
    helpIndex => [],
    helpAbout => [],
    initListViewHeader => ['QListView*'],
    createNewTab => [],
    removeTab => [],
    loadLocal => ['const QString&'],
    on_error => ['const QString&'],
    on_success => ['const QString&'],
    on_choice => ['const QString&'],
    on_unknow => ['const QString&'],
    newConnection => ['const QString&'],
    contextMenuRequested_handler => ['QListViewItem*', 'const QPoint&', 'int'],
    handle_link_clicked => ['const QString&'],
    ConfigureActionAction_activated => [],
    ViewByPackageNameAction_activated => [],
    ViewOnlyInstalledAction_activated => [],
    PackageInfoAction_activated => [],
    ViewBySourceAction_activated => [];
use Qt::attributes qw(
    messages
    main_tab
    tab
    table1
    local_view
    MenuBar
    fileMenu
    CacheMenu
    ViewMenu
    plug_inMenu
    helpMenu
    ConfigureMenu
    toolBar
    Toolbar
    fileExitAction
    helpIndexAction
    helpAboutAction
    ClearLocalCacheAction
    InstallAction
    ReInstallAction
    UpgradeAction
    RemoveAction
    RealoadPackageListAction
    BuildCacheAction
    SelectDependenciesAction
    ViewByPackageNameAction
    ViewBySourceAction
    ViewOnlyInstalledAction
    CreateNewTabAction
    RemoveTabAction
    PackageInfoAction
    ConfigureActionAction
);

use lib '@@INSTALLDIR@@/lib';
use slackget10::GUI::Qt::SGListViewItem ;
use Qt::attributes qw( button_add_tab button_remove_tab context_menu );
use slackget10::GUI::Qt::ImagesCollection ;
use slackget10::Local ;
use slackget10::Config ;
use IO::Socket::INET ;
use slackget10::Network ;
use slackget10::Package ;
use slackget10::PackageList ;
use slackget10::Base ;
use slackget10::File ;
use slackget10::Search ;
use slackget10 ;
use Time::HiRes ;
use slackget10::GUI::Qt::InfoViewer ;
use slackget10::GUI::Qt::slack_conf3 ;

sub NEW
{
    shift->SUPER::NEW(@_[0..2]);
    statusBar();

    if ( name() eq "unnamed" )
    {
        setName("slack_browser" );
    }
    setMinimumSize(Qt::Size(802, 597) );
    setIcon(Qt::Pixmap::fromMimeSource("slack-get-favicon-pre-alpha.png") );

    setCentralWidget(Qt::Widget(this, "qt_central_widget"));
    my $slack_browserLayout = Qt::GridLayout(centralWidget(), 1, 1, 11, 6, '$slack_browserLayout');

    messages = Qt::TextBrowser(centralWidget(), "messages");
    messages->setMinimumSize( Qt::Size(780, 100) );
    messages->setMaximumSize( Qt::Size(32767, 100) );
    messages->setTextFormat( &Qt::TextBrowser::RichText() );

    $slack_browserLayout->addWidget(messages, 1, 0);

    main_tab = Qt::TabWidget(centralWidget(), "main_tab");
    main_tab->setMinimumSize( Qt::Size(780, 390) );

    tab = Qt::Widget(main_tab, "tab");
    my $tabLayout = Qt::GridLayout(tab, 1, 1, 11, 6, '$tabLayout');

    table1 = Qt::Table(tab, "table1");
    table1->setNumRows( int(3) );
    table1->setNumCols( int(3) );

    $tabLayout->addWidget(table1, 0, 0);

    local_view = Qt::ListView(tab, "local_view");
    local_view->setSelectionMode( &Qt::ListView::Extended() );
    local_view->setAllColumnsShowFocus( 1 );
    local_view->setShowSortIndicator( 1 );

    $tabLayout->addWidget(local_view, 0, 0);
    main_tab->insertTab( tab, "" );

    $slack_browserLayout->addWidget(main_tab, 0, 0);

    fileExitAction= Qt::Action(this, "fileExitAction");
    fileExitAction->setIconSet( Qt::IconSet(Qt::Pixmap::fromMimeSource("exit.png")) );
    helpIndexAction= Qt::Action(this, "helpIndexAction");
    helpIndexAction->setIconSet( Qt::IconSet(Qt::Pixmap::fromMimeSource("help.png")) );
    helpAboutAction= Qt::Action(this, "helpAboutAction");
    ClearLocalCacheAction= Qt::Action(this, "ClearLocalCacheAction");
    InstallAction= Qt::Action(this, "InstallAction");
    InstallAction->setIconSet( Qt::IconSet(Qt::Pixmap::fromMimeSource("make_kdevelop.png")) );
    ReInstallAction= Qt::Action(this, "ReInstallAction");
    ReInstallAction->setIconSet( Qt::IconSet(Qt::Pixmap::fromMimeSource("rebuild.png")) );
    UpgradeAction= Qt::Action(this, "UpgradeAction");
    UpgradeAction->setIconSet( Qt::IconSet(Qt::Pixmap::fromMimeSource("up.png")) );
    RemoveAction= Qt::Action(this, "RemoveAction");
    RemoveAction->setIconSet( Qt::IconSet(Qt::Pixmap::fromMimeSource("fileclose.png")) );
    RealoadPackageListAction= Qt::Action(this, "RealoadPackageListAction");
    RealoadPackageListAction->setIconSet( Qt::IconSet(Qt::Pixmap::fromMimeSource("reload.png")) );
    BuildCacheAction= Qt::Action(this, "BuildCacheAction");
    SelectDependenciesAction= Qt::Action(this, "SelectDependenciesAction");
    SelectDependenciesAction->setIconSet( Qt::IconSet(Qt::Pixmap::fromMimeSource("connect_established.png")) );
    ViewByPackageNameAction= Qt::Action(this, "ViewByPackageNameAction");
    ViewBySourceAction= Qt::Action(this, "ViewBySourceAction");
    ViewOnlyInstalledAction= Qt::Action(this, "ViewOnlyInstalledAction");
    CreateNewTabAction= Qt::Action(this, "CreateNewTabAction");
    CreateNewTabAction->setIconSet( Qt::IconSet(Qt::Pixmap::fromMimeSource("tab_new_raised.png")) );
    RemoveTabAction= Qt::Action(this, "RemoveTabAction");
    RemoveTabAction->setIconSet( Qt::IconSet(Qt::Pixmap::fromMimeSource("tab_remove.png")) );
    PackageInfoAction= Qt::Action(this, "PackageInfoAction");
    PackageInfoAction->setIconSet( Qt::IconSet(Qt::Pixmap::fromMimeSource("")) );
    ConfigureActionAction= Qt::Action(this, "ConfigureActionAction");
    ConfigureActionAction->setIconSet( Qt::IconSet(Qt::Pixmap::fromMimeSource("configure.png")) );


    toolBar = Qt::ToolBar("", this, &DockTop);

    toolBar->addSeparator;
    InstallAction->addTo(toolBar);
    UpgradeAction->addTo(toolBar);
    RemoveAction->addTo(toolBar);
    RealoadPackageListAction->addTo(toolBar);
    SelectDependenciesAction->addTo(toolBar);
    toolBar->addSeparator;
    fileExitAction->addTo(toolBar);
    ConfigureActionAction->addTo(toolBar);
    helpIndexAction->addTo(toolBar);
    Toolbar = Qt::ToolBar("", this, &DockTop);

    CreateNewTabAction->addTo(Toolbar);
    RemoveTabAction->addTo(Toolbar);


    MenuBar= Qt::MenuBar( this, "MenuBar");


    fileMenu = Qt::PopupMenu( this );
    UpgradeAction->addTo( fileMenu );
    InstallAction->addTo( fileMenu );
    ReInstallAction->addTo( fileMenu );
    RemoveAction->addTo( fileMenu );
    SelectDependenciesAction->addTo( fileMenu );
    fileMenu->insertSeparator();
    RealoadPackageListAction->addTo( fileMenu );
    fileMenu->insertSeparator();
    fileExitAction->addTo( fileMenu );
    MenuBar->insertItem( "", fileMenu, 1 );

    CacheMenu = Qt::PopupMenu( this );
    BuildCacheAction->addTo( CacheMenu );
    ClearLocalCacheAction->addTo( CacheMenu );
    MenuBar->insertItem( "", CacheMenu, 2 );

    ViewMenu = Qt::PopupMenu( this );
    ViewByPackageNameAction->addTo( ViewMenu );
    ViewBySourceAction->addTo( ViewMenu );
    ViewOnlyInstalledAction->addTo( ViewMenu );
    MenuBar->insertItem( "", ViewMenu, 3 );

    plug_inMenu = Qt::PopupMenu( this );
    MenuBar->insertItem( "", plug_inMenu, 4 );

    helpMenu = Qt::PopupMenu( this );
    helpIndexAction->addTo( helpMenu );
    helpMenu->insertSeparator();
    helpAboutAction->addTo( helpMenu );
    MenuBar->insertItem( "", helpMenu, 5 );

    ConfigureMenu = Qt::PopupMenu( this );
    ConfigureActionAction->addTo( ConfigureMenu );
    MenuBar->insertItem( "", ConfigureMenu, 6 );

    languageChange();
    my $resize = Qt::Size(802, 602);
    $resize = $resize->expandedTo(minimumSizeHint());
    resize( $resize );
    clearWState( &Qt::WState_Polished );

    Qt::Object::connect(fileExitAction, SIGNAL "activated()", this, SLOT "fileExit()");
    Qt::Object::connect(helpIndexAction, SIGNAL "activated()", this, SLOT "helpIndex()");
    Qt::Object::connect(helpAboutAction, SIGNAL "activated()", this, SLOT "helpAbout()");
    Qt::Object::connect(CreateNewTabAction, SIGNAL "activated()", this, SLOT "createNewTab()");
    Qt::Object::connect(RemoveTabAction, SIGNAL "activated()", this, SLOT "helpIndex()");
    Qt::Object::connect(local_view, SIGNAL "contextMenuRequested(QListViewItem*,const QPoint&,int)", this, SLOT "contextMenuRequested_handler(QListViewItem*,const QPoint&,int)");
    Qt::Object::connect(ConfigureActionAction, SIGNAL "activated()", this, SLOT "ConfigureActionAction_activated()");
    Qt::Object::connect(ViewByPackageNameAction, SIGNAL "activated()", this, SLOT "ViewByPackageNameAction_activated()");
    Qt::Object::connect(ViewOnlyInstalledAction, SIGNAL "activated()", this, SLOT "ViewOnlyInstalledAction_activated()");
    Qt::Object::connect(PackageInfoAction, SIGNAL "activated()", this, SLOT "PackageInfoAction_activated()");
    Qt::Object::connect(ViewBySourceAction, SIGNAL "activated()", this, SLOT "ViewBySourceAction_activated()");

    init();
}


sub DESTROY
{
    destroy();
    SUPER->DESTROY()
}


sub languageChange
{
    setCaption(trUtf8("slack-browser: GUI for slack-get 1.0.0") );
    main_tab->changeTab( tab, trUtf8("localhost") );
    fileExitAction->setText( trUtf8("__EXIT") );
    fileExitAction->setMenuText( trUtf8("E&xit") );
    fileExitAction->setAccel( Qt::KeySequence( undef ) );
    helpIndexAction->setText( trUtf8("__HELP_INDEX") );
    helpIndexAction->setMenuText( trUtf8("&Index...") );
    helpIndexAction->setAccel( Qt::KeySequence( undef ) );
    helpAboutAction->setText( trUtf8("__HELP_ABOUT") );
    helpAboutAction->setMenuText( trUtf8("&About") );
    helpAboutAction->setAccel( Qt::KeySequence( undef ) );
    ClearLocalCacheAction->setText( trUtf8("__CLEAR_CACHE") );
    InstallAction->setText( trUtf8("__INSTALL") );
    ReInstallAction->setText( trUtf8("__FILE_REINSTALL") );
    UpgradeAction->setText( trUtf8("__UPGRADE") );
    RemoveAction->setText( trUtf8("__REMOVE") );
    RealoadPackageListAction->setText( trUtf8("__FILE_RELOAD_PKG_LIST") );
    BuildCacheAction->setText( trUtf8("__BUILD_CACHE") );
    SelectDependenciesAction->setText( trUtf8("__FILE_SELECT_DEP") );
    SelectDependenciesAction->setToolTip( trUtf8("__FILE_SELECT_DEP_TOOLTIP") );
    ViewByPackageNameAction->setText( trUtf8("By package name") );
    ViewByPackageNameAction->setToolTip( trUtf8("Sort all packages by their names") );
    ViewBySourceAction->setText( trUtf8("By source") );
    ViewBySourceAction->setToolTip( trUtf8("Sort all packages by their source (slackware, linuxpackages,etc.)") );
    ViewOnlyInstalledAction->setText( trUtf8("Only installed") );
    ViewOnlyInstalledAction->setToolTip( trUtf8("Show only installed packages with their updates (if availables)") );
    CreateNewTabAction->setText( trUtf8("__CREATE_NEW_TAB") );
    CreateNewTabAction->setToolTip( trUtf8("__CREATE_NEW_TAB_TOOLTIP") );
    CreateNewTabAction->setAccel( Qt::KeySequence( trUtf8("Ctrl+T") ) );
    RemoveTabAction->setText( trUtf8("__REMOVE_TAB") );
    RemoveTabAction->setToolTip( trUtf8("__REMOVE_TAB_TOOLTIP") );
    PackageInfoAction->setText( trUtf8("Get info on package") );
    ConfigureActionAction->setText( trUtf8("__CONFIGURE") );
    toolBar->setLabel( trUtf8("Tools") );
    Toolbar->setLabel( trUtf8("Toolbar") );
    MenuBar->findItem( 1 )->setText( trUtf8("&File") );
    MenuBar->findItem( 2 )->setText( trUtf8("&Cache") );
    MenuBar->findItem( 3 )->setText( trUtf8("&View") );
    MenuBar->findItem( 4 )->setText( trUtf8("plug-in") );
    MenuBar->findItem( 5 )->setText( trUtf8("&Help") );
    MenuBar->findItem( 6 )->setText( trUtf8("Configure") );
}



my $lv_ref = {};
my $Local;
my $config ;
my $sockets ;
my $packages;
my $base;
my $sgo;
my $config_file;
my $INSTALLDIR = '@@INSTALLDIR@@' ;
my $VERSION = '1.0.0_18-pre-alpha-4';
my $splash;
my $current_mouse_position;
my $GUI_HOOKS = ['HOOK_PLUGIN_INIT_GUI','HOOK_PLUGIN_QUIT','HOOK_PACKAGE_INFO_REQUESTED'];

sub init
{
    # Setting the splashscreen
    my $img = Qt::Pixmap("$INSTALLDIR/share/slack-get/images/slack-get-pre-alpha-splashscreen.png",Qt::Pixmap::DefaultOptim(),Qt::Pixmap::Auto());
    $splash = Qt::SplashScreen( $img );
    $splash->show;
    $splash->repaint();
    if(defined( $ENV{SG_CONF_FILE} ))
    {
        #$config = new slackget10::Config ("$ENV{SG_CONF_FILE}");
        $config_file = $ENV{SG_CONF_FILE} ;
    }
    elsif( -e "$INSTALLDIR/etc/slack-get/config.xml")
    {
         $config_file = "$INSTALLDIR/etc/slack-get/config.xml";
    }
    elsif( -e '/etc/slack-get/config.xml')
    {
        #$config = new slackget10::Config ("/etc/slack-get/config.xml");
        $config_file = '/etc/slack-get/config.xml' ;
    }
    elsif( -e '/usr/local/etc/slack-get/config.xml')
    {
        #$config = new slackget10::Config ("/usr/local/etc/config.xml");
        $config_file = '/usr/local/etc/slack-get/config.xml' ;
    }
    else
    {
         Qt::MessageBox::critical ( this, "FATAL", "A fatal error occured : I can't find a configuration file in my search path.\nIf you have a configuration file (config.xml) please use the SG_CONF_FILE environement variable to tell slack-browser where this file is.\nTry to re-launch slack-browser by typing in a terminal :\nSG_CONF_FILE=/path/to/your/config.xml slack-browser\n","Ok", undef, undef, 0, 0);
         exit(-1);
    }
    print "using \"$config_file\" as configuration file\n";
    $splash->message("Creating new \nslack-get instance",&Qt::AlignBottom|&Qt::AlignLeft,&Qt::white);
    $splash->repaint();
    $sgo = slackget10->new(
               -config => $config_file,
               -name => 'slack-browser',
               -version => $VERSION
    ) or die "[FATAL] Unable to create the slackget10 (main slack-get library) object: \n$!\n$@\n";

    $splash->message("Loading plug-in(s)",&Qt::AlignBottom|&Qt::AlignLeft,&Qt::white);
    $splash->repaint();
    $sgo->load_plugins($GUI_HOOKS,'GUI');
    $sgo->log()->Log(2,"new slackget10 object correctly created.\n");
    #$base = new slackget10::Base ($config);
    $sgo->log()->Log(1,"Loading local '".$sgo->config()->{gui}->{language}."' for GUI.\n");
    $splash->message("Loading locales",&Qt::AlignBottom|&Qt::AlignLeft,&Qt::white);
    $splash->repaint();
    loadLocal($sgo->config()->{gui}->{language});
    
    print "master daemon is at ",$sgo->config()->{'common'}->{'master-daemon'},"\n";
    $sgo->log()->Log(1,"The master daemon is at ".$sgo->config()->{'common'}->{'master-daemon'}.".\n");
    $splash->message("Connecting to \nmaster daemon",&Qt::AlignBottom|&Qt::AlignLeft,&Qt::white);
    $splash->repaint();
    unless(newConnection($sgo->config()->{'common'}->{'master-daemon'}))
    {
        my $resp = Qt::MessageBox::warning ( this, $Local->Get('__ERR'), $Local->Get('__ASK_LAUNCH_LOCAL_DAEMON'),&Qt::MessageBox::Yes, &Qt::MessageBox::No, &Qt::MessageBox::NoButton );
        if($resp == &Qt::MessageBox::No) 
        {
            fileExit() ;
            # In case the GUI have some problems to exit, we'll force the end of the application
            exit(0);
        }
        elsif($resp == &Qt::MessageBox::Yes)
        {
print "[DEBUG] syscall => perl $INSTALLDIR/bin/slack-getd --config-file=$config_file start\n";
            exec("perl $INSTALLDIR/bin/slack-getd --config-file=$config_file start && sleep 1 && $INSTALLDIR/bin/slack-browser"); # we assume that the daemon is well configured, and the configuration file is findable by the daemon.
            sleep 2;
print "[DEBUG] actual master-daemon is at ",$sgo->config()->{'common'}->{'master-daemon'},"\n";
print "[DEBUG] relocate it at ",$sgo->config()->{'daemon'}->{'listenning-adress'}.":".$sgo->config()->{'daemon'}->{'listenning-port'},"\n";
            $sgo->config()->{'common'}->{'master-daemon'} = $sgo->config()->{'daemon'}->{'listenning-adress'}.":".$sgo->config()->{'daemon'}->{'listenning-port'};
print "[DEBUG] actual master-daemon is now at ",$sgo->config()->{'common'}->{'master-daemon'},"\n";
            newConnection($sgo->config()->{'common'}->{'master-daemon'});
        }
    }
    messages->append("Getting the list of new packages from master daemon");
    my $ret = $sockets->{$sgo->config()->{'common'}->{'master-daemon'}}->{'network'}->get_packages_list();
    if($ret->is_success())
    {
        unlink $sgo->config()->{'common'}->{'update-directory'}."/gui-packages-cache.xml" if ( -e $sgo->config()->{'common'}->{'update-directory'}."/gui-packages-cache.xml" ) ;
        my $file = new slackget10::File($sgo->config()->{'common'}->{'update-directory'}."/gui-packages-cache.xml",encoding=>'utf8','no-auto-load' => 1);
        $file->Add($ret->data());
        $file->Write() ;
        $splash->message("Loading packages list",&Qt::AlignBottom|&Qt::AlignLeft,&Qt::white);
        $splash->repaint();

        $packages = $sgo->base()->load_packages_list_from_xml_file($sgo->config()->{'common'}->{'update-directory'}."/gui-packages-cache.xml");
        foreach (keys(%{$packages}))
        {
            $packages->{$_}->index_list ;
        }
        # print "PACKAGES: $packages\n";
    }
    else
    {
 Qt::MessageBox::critical ( this, "FATAL", "A fatal error occured : Unable to retrieve the new packages list from the master daemon","Ok", undef, undef, 0, 0);
        messages->append("<font color='red'>Cannot retrieve the new packages list from the master daemon</font>");
        fileExit();
        return undef;
    }
    $splash->message("Initializing GUI",&Qt::AlignBottom|&Qt::AlignLeft,&Qt::white);
    $splash->repaint();
    initListViewHeader(local_view);
    local_view->hideColumn(5);
    button_add_tab = Qt::ToolButton(main_tab,'button_add_tab');
    button_add_tab->setIconSet( Qt::IconSet(Qt::Pixmap::fromMimeSource("tab_new_raised.png")) );
    button_add_tab->setTextLabel($Local->Get('__CREATE_NEW_TAB_TOOLTIP'));
    Qt::Object::connect(button_add_tab, SIGNAL "clicked()", this, SLOT "createNewTab()");
    main_tab->setCornerWidget(button_add_tab);
    button_remove_tab = Qt::ToolButton(main_tab,'button_remove_tab');
    button_remove_tab->setIconSet( Qt::IconSet(Qt::Pixmap::fromMimeSource("tab_remove.png")) );
    button_remove_tab->setTextLabel( trUtf8($Local->Get('__REMOVE_TAB_TOOLTIP')) );
    Qt::Object::connect(button_remove_tab, SIGNAL "clicked()", this, SLOT "removeTab()");
    main_tab->setCornerWidget(button_remove_tab, &Qt::TopLeft);
    my ($server,$port) = split(/:/,$sgo->config()->{'gui'}->{'connect-to'});
    $port = 42000 unless($port);
    messages->append("Going to connect to $server on port $port");
    $sockets->{'localhost'}->{'socket'} = new IO::Socket::INET (
                 PeerAddr => $server,
                 PeerPort => $port
            );
    unless($sockets->{'localhost'}->{'socket'})
    {
                Qt::MessageBox::warning ( this, $Local->Get('__CANNOT_CONNECT_TO'), $Local->Get('__CANNOT_CONNECT_TO')." $server:$port",&Qt::MessageBox::Ok, &Qt::MessageBox::NoButton, &Qt::MessageBox::NoButton );
                messages->append("<font color='red'>Cannot connect to $server on port $port</font>");
                fileExit();
                return undef ;
    }
    else
    {
        messages->append("Successfully connected to $server");
        $sockets->{'localhost'}->{'network'} = slackget10::Network->new(
         'socket' => $sockets->{'localhost'}->{'socket'},
         'on_error' => \&on_error,
         'on_success' => \&on_success,
         'on_choice' => \&on_choice,
         'on_unknow' => \&on_unknow,
        );
        unless($sockets->{'localhost'}->{'network'})
        {
            Qt::MessageBox::warning ( this, "__CANNOT_CREATE_NETWORK_OBJECT", "__CANNOT_CREATE_NETWORK_OBJECT_FOR $server:$port",&Qt::MessageBox::Ok, &Qt::MessageBox::NoButton, &Qt::MessageBox::NoButton );
            messages->append("<font color='red'>Cannot create the slackget10::Network object (it maybe an internal error please send all informations you can to bugtraq\@infinityperl.org</font>");
        }
        else
        {
            $splash->message("Processing data from \nmaster daemon",&Qt::AlignBottom|&Qt::AlignLeft,&Qt::white);
            $splash->repaint();
            fillListViewFromXML(local_view,$sockets->{'localhost'}->{'network'}->get_installed_list()->data());
        }
    }
    context_menu = Qt::PopupMenu( this );
    CreateNewTabAction->addTo( context_menu );
    PackageInfoAction->addTo( context_menu ) ;

$sgo->call_plugins('HOOK_PLUGIN_INIT_GUI',this,plug_inMenu);

    $splash->destroy();
    undef($splash);
}


sub destroy
{
    $sgo->call_plugins('HOOK_PLUGIN_QUIT');
    fileExit() ;
}

sub fileExit
{
     unlink $sgo->config()->{'common'}->{'update-directory'}."/gui-packages-cache.xml" if ( -e $sgo->config()->{'common'}->{'update-directory'}."/gui-packages-cache.xml" ) ;
     foreach (keys(%{$sockets}))
     {
          $sockets->{$_}->{'network'}->quit("quit: GUI exiting") if( $sockets && $sockets->{$_} && $sockets->{$_}->{'network'} );
          delete($sockets->{$_});
     }
     this->close(1) ;
     exit(0);
}


sub helpIndex
{
     system($sgo->config()->{common}->{'default-browser'}." $INSTALLDIR/share/slack-get/doc/slack-browser/en/slack-browser.html &") ;
}


sub helpAbout
{
     Qt::MessageBox::about( this, "About slack-get", "slack-get/slack-browser ver. $VERSION\n\nGUI for slack-get.\n\nBy Arnaud DUPUIS <a.dupuis\@infinityperl.org>\n\nTHIS PROGRAM IS PROVIDED AS IT WITHOUT ANY KIND OF WARRANTY.\n\n");
}


sub initListViewHeader # SLOT: ( QListView * )
{
    my $lv = shift ;
    $lv->addColumn($Local->Get("__PACKAGES"));
    $lv->addColumn($Local->Get("__LOCAL_VERSION"));
    $lv->addColumn($Local->Get("__REMOTE_VERSION"));
    $lv->addColumn($Local->Get("__PACK_SIZE"));
    $lv->addColumn($Local->Get("__SOURCE"));
    $lv->addColumn("package_id");
    $lv->adjustColumn(0);
    $lv->adjustColumn(1);
    $lv->adjustColumn(2);
    $lv->adjustColumn(3);
    $lv->adjustColumn(4);
    $lv->setSelectionMode(&Qt::ListView::Extended);
    $lv->setShowSortIndicator(1);
    $lv->setAllColumnsShowFocus(1);
    $lv->setRootIsDecorated(1);
    $lv->setSortColumn(0);
    $lv->hideColumn(5);
}


sub createNewTab
{
    my $ok;
    my $text;
    if(defined($Local))
    {
        $text = Qt::InputDialog::getText("slack-browser", $Local->Get('__WIDG_SB_GET_REMOTE_DAEMON_ADDR'), &Qt::LineEdit::Normal,'127.0.0.1', $ok, this );
    }
    else
    {
        $text = Qt::InputDialog::getText("slack-browser", "Enter the adress of the remote slack-getd :", &Qt::LineEdit::Normal,'127.0.0.1', $ok, this );
    }
    if($ok)
    {
        my ($server,$port) = split(/:/,$text);
        $port = 42000 unless($port);
        messages->append("Going to connect to $server on port $port");
        messages->update();
        $sockets->{$text}->{'socket'} = new IO::Socket::INET (
                 PeerAddr => $server,
                 PeerPort => $port
            );
        unless($sockets->{$text}->{'socket'})
        {
                Qt::MessageBox::warning ( this, "__CANNOT_CONNECT_TO", "__CANNOT_CONNECT_TO $server:$port",&Qt::MessageBox::Ok, &Qt::MessageBox::NoButton, &Qt::MessageBox::NoButton );
                messages->append("<font color='red'>Cannot connect to $server on port $port</font>");
                return undef ;
        }
        messages->append("<font color='blue'>Successfully connected to $server</font>");
        messages->update();
        $sockets->{$text}->{'network'} = slackget10::Network->new(
             'socket' => $sockets->{$text}->{'socket'},
             'on_error' => \&on_error,
             'on_success' => \&on_success,
             'on_choice' => \&on_choice,
             'on_unknow' => \&on_unknow,

        );
        unless($sockets->{$text}->{'network'})
        {
        Qt::MessageBox::warning ( this, "__CANNOT_CREATE_NETWORK_OBJECT", "__CANNOT_CREATE_NETWORK_OBJECT_FOR $server:$port",&Qt::MessageBox::Ok, &Qt::MessageBox::NoButton, &Qt::MessageBox::NoButton );
                return undef ;
        }
        my $widget = Qt::Widget(main_tab,"$text");
        my $tabLayout = Qt::GridLayout($widget, 1, 1, 11, 6, "tabLayout_$text");
        my $lv = Qt::ListView($widget,"lv_$text");
        Qt::Object::connect($lv, SIGNAL "contextMenuRequested(QListViewItem*,const QPoint&,int)", this, SLOT "contextMenuRequested_handler(QListViewItem*,const QPoint&,int)");
        initListViewHeader($lv);
        messages->append("Getting the installed packages list on $server");
        messages->update();
        fillListViewFromXML($lv,$sockets->{$text}->{'network'}->get_installed_list()->data());
        $tabLayout->addWidget($lv, 1, 0);
        main_tab->addTab($widget,$text);
        main_tab->showPage($widget);

    }
}


sub removeTab
{
    if( main_tab->currentPageIndex() == 0)
    {
        Qt::MessageBox::warning ( this, "__REMOVE_LAST_TAB_WARNING_TITLE", "__REMOVE_LAST_TAB_WARNING_TEXT",&Qt::MessageBox::Ok, &Qt::MessageBox::NoButton, &Qt::MessageBox::NoButton );
        return 0;
    }
    my $tname = main_tab->tabLabel(main_tab->currentPage()) ;
    if(defined($tname) && defined($sockets->{$tname}) && defined($sockets->{$tname}->{'network'}) && $sockets->{$tname}->{'network'})
    {
        $sockets->{$tname}->{'network'}->quit("GUI remove tab");
        delete($sockets->{$tname});
    }
    main_tab->removePage( main_tab->currentPage() );

}

sub loadLocal # SLOT: ( const QString & )
{
    my $local = shift ;
    $local = 'english' unless($local or -e "$INSTALLDIR/share/slack-get/local/$local.xml");
    $Local = new slackget10::Local ();
    $Local->Load("$INSTALLDIR/share/slack-get/local/$local.xml") or print "Unable to load local\n";
    BuildCacheAction->setText( trUtf8($Local->Get('__SET_PKG_CACHE')) ) ;
    ClearLocalCacheAction->setText( trUtf8($Local->Get('__CACHE_CLEAR_CACHE')) ) ;
    ConfigureActionAction->setText( trUtf8($Local->Get('__CONFIGURE')) ) ;
    ConfigureActionAction->setToolTip( trUtf8($Local->Get('__CONFIGURE')) ) ;
    CreateNewTabAction->setText( trUtf8($Local->Get('__CREATE_NEW_TAB')) );
    CreateNewTabAction->setToolTip( trUtf8($Local->Get('__CREATE_NEW_TAB_TOOLTIP')) );
    fileExitAction->setText( trUtf8($Local->Get('__FILE_EXIT')) );
    fileExitAction->setMenuText( trUtf8($Local->Get('__FILE_EXIT2')) );
    fileExitAction->setAccel( Qt::KeySequence( trUtf8($Local->Get('__FILE_EXIT_ACCEL')) ) );
    helpIndexAction->setText( trUtf8($Local->Get('__HELP_INDEX')) );
    helpIndexAction->setMenuText( trUtf8($Local->Get('__HELP_INDEX2')) );
    helpIndexAction->setAccel( Qt::KeySequence( trUtf8($Local->Get('__HELP_INDEX_ACCEL')) ) );
    helpAboutAction->setText( trUtf8($Local->Get('__HELP_ABOUT')) );
    helpAboutAction->setMenuText( trUtf8($Local->Get('__HELP_ABOUT2')) );
    helpAboutAction->setAccel( Qt::KeySequence( $Local->Get('__HELP_ABOUT_ACCEL') ) );
    PackageInfoAction->setText( trUtf8($Local->Get('__GET_PACKAGE_INFO')) );
    PackageInfoAction->setToolTip( trUtf8($Local->Get('__GET_PACKAGE_INFO_TOOLTIP')) );
    UpgradeAction->setText( trUtf8($Local->Get('__FILE_UPGRADE')) );
    UpgradeAction->setAccel( Qt::KeySequence( trUtf8($Local->Get('__FILE_UPGRADE_ACCEL')) ) );
    RemoveAction->setText( trUtf8($Local->Get('__FILE_REMOVE')) );
    RemoveAction->setAccel( Qt::KeySequence( trUtf8($Local->Get('__FILE_REMOVE_ACCEL')) ) );
    InstallAction->setText( trUtf8($Local->Get('__FILE_INSTALL2')) );
    InstallAction->setMenuText( trUtf8($Local->Get('__FILE_INSTALL2')) );
    InstallAction->setToolTip( trUtf8($Local->Get('__FILE_INSTALL')) );
    InstallAction->setAccel( Qt::KeySequence( trUtf8($Local->Get('__FILE_INSTALL_ACCEL')) ) );
    ReInstallAction->setText( trUtf8($Local->Get('__FILE_REINSTALL')) );
    RealoadPackageListAction->setText( trUtf8($Local->Get('__FILE_RELOAD_PKG_LIST')) );
    RealoadPackageListAction->setAccel( Qt::KeySequence( trUtf8($Local->Get('__FILE_RELOAD_PKG_LIST_ACCEL')) ) );
    RemoveTabAction->setText( trUtf8($Local->Get('__REMOVE_TAB')) );
    RemoveTabAction->setToolTip( trUtf8($Local->Get('__REMOVE_TAB_TOOLTIP')) );
    SelectDependenciesAction->setText( trUtf8($Local->Get('__FILE_SELECT_DEP')) );
    SelectDependenciesAction->setToolTip( trUtf8($Local->Get('__FILE_SELECT_DEP_TOOLTIP')) );
    ViewOnlyInstalledAction->setText( trUtf8($Local->Get('__VIEW_ONLY_INSTALLED')) );
    ViewOnlyInstalledAction->setToolTip( trUtf8($Local->Get('__VIEW_ONLY_INSTALLED_TOOLTIP')) );
    ViewByPackageNameAction->setText( trUtf8($Local->Get('__VIEW_PACKAGES_BY_NAME')) );
    ViewByPackageNameAction->setToolTip( trUtf8($Local->Get('__VIEW_PACKAGES_BY_NAME_TOOLTIP')) );
    ViewBySourceAction->setText( trUtf8($Local->Get('__VIEW_PACKAGES_BY_SOURCE')) );
    ViewBySourceAction->setToolTip( trUtf8($Local->Get('__VIEW_PACKAGES_BY_SOURCE_TOOLTIP')) );
    MenuBar->findItem( 1 )->setText( trUtf8($Local->Get('__FILES')) );
    MenuBar->findItem( 2 )->setText( trUtf8($Local->Get('__CACHE')) );
    MenuBar->findItem( 3 )->setText( trUtf8($Local->Get('__VIEW')) );
    MenuBar->findItem( 5 )->setText( trUtf8($Local->Get('__HELP')) );
    MenuBar->findItem( 6 )->setText( trUtf8($Local->Get('__CONFIGURE')) );
}


sub fillListViewFromXML # SLOT: ( QListView *, const QString & )
{
     my ($lv,$xml) = @_ ;
     $lv->clear();
     my $list = new slackget10::PackageList ;
     $list->fill_from_xml($xml) ;
    ## $packages contains packages.xml (update list)

     my $lv_data = {} ;
     foreach ( @{ $list->get_all() } ) # while there is something in this list
     {
               next if(!defined($_) or !defined($_->name()));
               $lv_data->{$_->name()} = {
                     'local' => $_,
                     'remote' => []
               };
     }

     foreach my $sublist (values(%{$packages}))
     {
               next if(!defined($sublist));
               foreach (@{$sublist->get_all()} )
               {
                         next if(!defined($_) or !defined($_->name()));
                         push @{ $lv_data->{$_->name()}->{'remote'} }, $_ ;
               }
     }

     foreach my $pkg ( keys( %{ $lv_data } ) )
     {
          if(defined($splash) )
          {
               $splash->message("process: $pkg",&Qt::AlignBottom|&Qt::AlignLeft,&Qt::white);
               $splash->repaint();
          }
               my $parent ;
               if( defined( $lv_data->{$pkg}->{'local'} ) )
               {
                         $parent = slackget10::GUI::Qt::SGListViewItem ($lv,$lv_data->{$pkg}->{'local'}->name());
                         $parent->setText(0,$lv_data->{$pkg}->{'local'}->name());
                         $parent->setText(1,$lv_data->{$pkg}->{'local'}->version());
                         $parent->setText(4,'Local machine');
                         $parent->setOpen(1);
               }
               if(@{ $lv_data->{$pkg}->{'remote'} })
               {
                         my $ref;
                         if($parent) {
                                   $ref=$parent;
                         } else {
                                   $ref=$lv;
                         }
                         foreach ( @{ $lv_data->{$pkg}->{'remote'} } )
                         {
                                   my $item = slackget10::GUI::Qt::SGListViewItem ($ref);
                                   $item->setText(0,$_->name());
                                   $item->setText(2,$_->version());
                                   $item->setText(3,$_->compressed_size());
                                   $item->setText(4,$_->getValue('package-source'));
                                   $item->setText(5,$_->get_id());
                                   if( defined( $lv_data->{$pkg}->{'local'} ) )
                                   {
                                         $item->setText(1,$lv_data->{$pkg}->{'local'}->version());
                                         my $ver_ret_code = $_->compare_version( $lv_data->{$pkg}->{'local'} ) ;
                                         if($ver_ret_code == 1)
                                         {
                                                   $item->state(1);
                                                   $item->repaint();
                                         }
                                         if($ver_ret_code == -1)
                                         {
                                                   $item->state(2);
                                                   $item->repaint();
                                         }
                                   }
                         }
               }
     }
     $lv_data = undef; # this free 0.1 % of memory on my system, i.e 1 Mo
}


sub on_error # SLOT: ( const QString & )
{
      my $str=shift;
      messages->append("<font color='red'>$str</font>");
      messages->update();
      Qt::MessageBox::warning ( this, "Error", "remote slack-getd say:\n$str",&Qt::MessageBox::Ok, &Qt::MessageBox::NoButton, &Qt::MessageBox::NoButton );
}


sub on_success # SLOT: ( const QString & )
{
     my $text = shift;
     messages->append("<font color='green'>$text</font>");
     messages->update();
print "GUI on_succes handler receive msg : $text\n";
}


sub on_choice # SLOT: ( const QString & )
{
     my $text = shift;
     messages->append("<font color='magenta'>ON_CHOICE MESSAGE HANDLER IS NOT YET IMPLEMENTED</font>");
     messages->update();
}


sub on_unknow # SLOT: ( const QString & )
{
     my $text = shift;
     messages->append("<font color='orange'>$text</font>");
     messages->update();
}


sub newConnection # SLOT: ( const QString & )
{
     my $str = shift;
     my ($server,$port) = split(/:/,$str);
     $port = 42000 unless($port);
     messages->append("Going to connect to $server on port $port");
     $sockets->{$str}->{'socket'} = new IO::Socket::INET (
                 PeerAddr => $server,
                 PeerPort => $port
     );
     unless($sockets->{$str}->{'socket'})
     {
          Qt::MessageBox::warning ( this, $Local->Get('__CANNOT_CONNECT_TO'), $Local->Get('__CANNOT_CONNECT_TO')." $server:$port",&Qt::MessageBox::Ok, &Qt::MessageBox::NoButton, &Qt::MessageBox::NoButton );
          messages->append("<font color='red'>Cannot connect to $server on port $port</font>");
          eval {$sockets->{$str}->{'socket'}->close };
          delete($sockets->{$str});
          return undef ;
     }
     else
     {
          messages->append("<font color='blue'>Successfully connected to $server</font>");
          $sockets->{$str}->{'network'} = slackget10::Network->new(
               'socket' => $sockets->{$str}->{'socket'},
               'on_error' => \&on_error,
               'on_success' => \&on_success,
               'on_choice' => \&on_choice,
               'on_unknow' => \&on_unknow,

        );
        unless($sockets->{$str}->{'network'})
        {
             Qt::MessageBox::warning ( this, "__CANNOT_CREATE_NETWORK_OBJECT", "__CANNOT_CREATE_NETWORK_OBJECT_FOR $server:$port",&Qt::MessageBox::Ok, &Qt::MessageBox::NoButton, &Qt::MessageBox::NoButton );
          messages->append("<font color='red'>Cannot create the slackget10::Network object (it maybe an internal error please send all informations you can to bugtraq\@infinityperl.org</font>");
          eval {$sockets->{$str}->{'socket'}->close };
          delete($sockets->{$str});
          return undef;
        }
     }
}


sub newConnection2 # SLOT: ( const QString &, QListView * )
{
     my $str = shift;
     my ($server,$port) = split(/:/,$str);
     $port = 42000 unless($port);
     messages->append("Going to connect to $server on port $port");
     $sockets->{$str}->{'socket'} = new IO::Socket::INET (
                 PeerAddr => $server,
                 PeerPort => $port
     );
     unless($sockets->{$str}->{'socket'})
     {
          Qt::MessageBox::warning ( this, $Local->Get('__CANNOT_CONNECT_TO'), $Local->Get('__CANNOT_CONNECT_TO')." $server:$port",&Qt::MessageBox::Ok, &Qt::MessageBox::NoButton, &Qt::MessageBox::NoButton );
          messages->append("<font color='red'>Cannot connect to $server on port $port</font>");
          return undef ;
     }
     else
     {
          messages->append("<font color='blue'>Successfully connected to $server</font>");
          $sockets->{$str}->{'network'} = slackget10::Network->new(
               'socket' => $sockets->{$str}->{'socket'},
               'on_error' => \&on_error,
               'on_success' => \&on_success,
               'on_choice' => \&on_choice,
               'on_unknow' => \&on_unknow,

        );
        unless($sockets->{$str}->{'network'})
        {
             Qt::MessageBox::warning ( this, "__CANNOT_CREATE_NETWORK_OBJECT", "__CANNOT_CREATE_NETWORK_OBJECT_FOR $server:$port",&Qt::MessageBox::Ok, &Qt::MessageBox::NoButton, &Qt::MessageBox::NoButton );
          messages->append("<font color='red'>Cannot create the slackget10::Network object (it maybe an internal error please send all informations you can to bugtraq\@infinityperl.org</font>");
          return undef;
        }
        else
        {
                my $widget = Qt::Widget(main_tab,"$str");
                my $tabLayout = Qt::GridLayout($widget, 1, 1, 11, 6, "tabLayout_$str");
                my $lv = Qt::ListView($widget,"lv_$str");
                initListViewHeader($lv);
                messages->append("Getting the installed packages list on $server");
                fillListViewFromXML($lv,$sockets->{$str}->{'network'}->get_installed_list()->data());
                $tabLayout->addWidget($lv, 1, 0);
                main_tab->addTab($widget,$str);
                main_tab->showPage($widget);
        }
     }
}


sub contextMenuRequested_handler # SLOT: ( QListViewItem *, const QPoint &, int )
{
     my ($item, $pos, $int) = @_ ;
     $current_mouse_position = $pos;
     context_menu->popup($pos) if($item) ;
}


sub handle_link_clicked # SLOT: ( const QString & )
{
     my $str = shift ;
     system($sgo->config()->{common}->{'default-browser'}." $str &") ;
}


sub ConfigureActionAction_activated
{
     my $obj = slackget10::GUI::Qt::slack_conf3( this );
     $obj->configFile($config_file);
     $obj->loadLocal($Local) ;
     $obj->show ;
}


sub ViewByPackageNameAction_activated
{
     my $lv = getListViewObjectFromTab() ;
     $lv->clear();
     my $tab_name = main_tab->tabLabel(main_tab->currentPage()) ;
     fillListViewFromXML($lv,$sockets->{$tab_name}->{'network'}->get_installed_list()->data());
}


sub ViewOnlyInstalledAction_activated
{
     my $lv = getListViewObjectFromTab() ;
     $lv->clear();
     my $tab_name = main_tab->tabLabel(main_tab->currentPage()) ;
     my $xml = $sockets->{$tab_name}->{'network'}->get_installed_list()->data();

     #my $start_time = Time::HiRes::time();
     my $list = new slackget10::PackageList ;
     $list->fill_from_xml($xml) ;
    ## $packages contains packages.xml (update list)

     my $lv_data = {} ;
     foreach ( @{ $list->get_all() } ) # while there is something in this list
     {
               next if(!defined($_) or !defined($_->name()));
               $lv_data->{$_->name()} = {
                     'local' => $_,
                     'remote' => []
               };
     }

     foreach my $sublist (values(%{$packages}))
     {
               next if(!defined($sublist));
               foreach (@{$sublist->get_all()} )
               {
                         next if(!defined($_) or !defined($_->name()));
                         push @{ $lv_data->{$_->name()}->{'remote'} }, $_ ;
               }
     }

     foreach my $pkg ( keys( %{ $lv_data } ) )
     {
               my $parent ;
               if( defined( $lv_data->{$pkg}->{'local'} ) )
               {
                         $parent = slackget10::GUI::Qt::SGListViewItem ($lv,$lv_data->{$pkg}->{'local'}->name());
                         $parent->setText(0,$lv_data->{$pkg}->{'local'}->name());
                         $parent->setText(1,$lv_data->{$pkg}->{'local'}->version());
                         $parent->setText(4,'Local machine');
                         $parent->setOpen(1);
               }
               if(@{ $lv_data->{$pkg}->{'remote'} })
               {
                         my $ref;
                         if($parent) {
                                   $ref=$parent;
                         } else {
                                   $ref=$lv;
                         }
                         foreach ( @{ $lv_data->{$pkg}->{'remote'} } )
                         {

                                   if( defined( $lv_data->{$pkg}->{'local'} ) )
                                   {
                                         my $item = slackget10::GUI::Qt::SGListViewItem ($ref);
                                         $item->setText(0,$_->name());
                                         $item->setText(2,$_->version());
                                         $item->setText(3,$_->compressed_size());
                                         $item->setText(4,$_->getValue('package-source'));
                                         $item->setText(5,$_->get_id());
                                         $item->setText(1,$lv_data->{$pkg}->{'local'}->version());
                                         my $ver_ret_code = $_->compare_version( $lv_data->{$pkg}->{'local'} ) ;
                                         if($ver_ret_code == 1)
                                         {
                                                   $item->state(1);
                                                   $item->repaint();
                                         }
                                         if($ver_ret_code == -1)
                                         {
                                                   $item->state(2);
                                                   $item->repaint();
                                         }
                                   }
                         }
               }
     }
     $lv_data = undef;
}


sub PackageInfoAction_activated
{
     my $info_view = slackget10::GUI::Qt::InfoViewer(this) ;
     $info_view->show() ;
     this->update();
     Qt::Object::connect($info_view, SIGNAL "info_viewer_link_clicked(const QString&)", this, SLOT "handle_link_clicked(const QString&)");
     my $lv = getListViewObjectFromTab() ;
      my $it = Qt::ListViewItemIterator( $lv );
     while ( $it->current() ) 
     {
          if ( $it->current()->isSelected() )
          {
               if($it->current()->text(4) ne 'Local machine') 
               {
                    $sgo->call_plugins('HOOK_PACKAGE_INFO_REQUESTED',$packages->{$it->current()->text(4)}->get_indexed( $it->current()->text(5) ));
                    $info_view->add_package( $packages->{$it->current()->text(4)}->get_indexed( $it->current()->text(5) ) ) ;
                    $info_view->update();
               }
          }
        ++$it;
    }
}


sub getListViewObjectFromTab
{
     foreach (@{main_tab->currentPage()->children()})
     {
          return $_ if($_ =~ /Qt::ListView/) ;
     }
}


sub ViewBySourceAction_activated
{
     my $lv = getListViewObjectFromTab() ;
     $lv->clear();
     my $tab_name = main_tab->tabLabel(main_tab->currentPage()) ;
     print "[DEBUG] tab name is : \"$tab_name\"\n";
     my $xml = $sockets->{$tab_name}->{'network'}->get_installed_list()->data();

     #my $start_time = Time::HiRes::time();
     my $list = new slackget10::PackageList ;
     $list->fill_from_xml($xml) ;
    ## $packages contains packages.xml (update list)

     my $lv_data = {} ;
     my $lv_data_template = {} ;
     foreach ( @{ $list->get_all() } ) # while there is something in this list
     {
               next if(!defined($_) or !defined($_->name()));
               $lv_data_template->{$_->name()} = {
                     'local' => $_
               };
     }
     foreach my $source (keys(%{$packages}))
     {
          my $parent ;
          $parent = slackget10::GUI::Qt::SGListViewItem ($lv);
          $parent->setText(0,$source);
          foreach (@{$packages->{$source}->get_all()})
          {
               my $item = slackget10::GUI::Qt::SGListViewItem ($parent);
               $item->setText(0,$_->name());
               if($lv_data_template->{$_->name()})
               {
                    $item->setText(1,$lv_data_template->{$_->name()}->{'local'}->version());
                    my $ver_ret_code = $_->compare_version( $lv_data_template->{$_->name()}->{'local'} ) ;
                    if($ver_ret_code == 1)
                    {
                           $item->state(1);
                           $item->repaint();
                     }
                    if($ver_ret_code == -1)
                    {
                          $item->state(2);
                          $item->repaint();
                    }
               }
               $item->setText(2,$_->version());
               $item->setText(3,$_->compressed_size());
               $item->setText(4,$_->getValue('package-source'));
               $item->setText(5,$_->get_id());
               
}
     }

     $lv_data = undef;
     $lv_data_template = undef;
}

1;
