

use strict;
use utf8;


package slackget10::GUI::Qt::sb_plugin_test2;
use Qt;
use Qt::isa qw(Qt::Dialog);
use Qt::slots
    hide_button_clicked => [];
use Qt::attributes qw(
    textLabel2
    hide_button
);


sub NEW
{
    shift->SUPER::NEW(@_[0..3]);

    if ( name() eq "unnamed" )
    {
        setName("sb_plugin_test2" );
    }

    my $sb_plugin_test2Layout = Qt::GridLayout(this, 1, 1, 11, 6, '$sb_plugin_test2Layout');

    textLabel2 = Qt::Label(this, "textLabel2");

    $sb_plugin_test2Layout->addWidget(textLabel2, 0, 0);

    hide_button = Qt::PushButton(this, "hide_button");

    $sb_plugin_test2Layout->addWidget(hide_button, 1, 0);
    languageChange();
    my $resize = Qt::Size(462, 200);
    $resize = $resize->expandedTo(minimumSizeHint());
    resize( $resize );
    clearWState( &Qt::WState_Polished );

    Qt::Object::connect(hide_button, SIGNAL "clicked()", this, SLOT "hide_button_clicked()");

    init();
}


sub DESTROY
{
    destroy();
    SUPER->DESTROY()
}


sub languageChange
{
    setCaption(trUtf8("slackget10::Plugin::Test2") );
    textLabel2->setText( trUtf8("This is a test plug-in for slack-get GUI.<br>\n" .
    "Coder can look at the code for an example of how to code GUI plug-ins.<br>\n" .
    "<u>Info :</u><br>\n" .
    "This plug-in use 2 class :<br>\n" .
    "1) slackget10::Plugin::Test2.pm : the handler class.<br>\n" .
    "2) slackget10::GUI::Qt::sb_plugin_test2.pm : the QDialog class.<br>") );
    hide_button->setText( trUtf8("Hide") );
}



sub init
{

}


sub destroy
{

}


sub hide_button_clicked
{
    this->hide();
}

1;
