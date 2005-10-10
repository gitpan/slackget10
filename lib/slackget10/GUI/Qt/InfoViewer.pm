

use strict;
use utf8;


package slackget10::GUI::Qt::InfoViewer;
use Qt;
use Qt::isa qw(Qt::Dialog);
use Qt::slots
    linkClicked_handler => ['const QString&'];
use Qt::signals
    info_viewer_link_clicked => ['const QString&'];
use Qt::attributes qw(
    text_area
    close_button
);


sub NEW
{
    shift->SUPER::NEW(@_[0..3]);

    if ( name() eq "unnamed" )
    {
        setName("InfoViewer" );
    }

    my $InfoViewerLayout = Qt::GridLayout(this, 1, 1, 11, 6, '$InfoViewerLayout');

    text_area = Qt::TextBrowser(this, "text_area");
    text_area->setTextFormat( &Qt::TextBrowser::RichText() );
    text_area->setAutoFormatting( int(&Qt::TextBrowser::AutoAll) );

    $InfoViewerLayout->addWidget(text_area, 0, 0);

    close_button = Qt::PushButton(this, "close_button");

    $InfoViewerLayout->addWidget(close_button, 1, 0);
    languageChange();
    my $resize = Qt::Size(600, 480);
    $resize = $resize->expandedTo(minimumSizeHint());
    resize( $resize );
    clearWState( &Qt::WState_Polished );

    Qt::Object::connect(text_area, SIGNAL "linkClicked(const QString&)", this, SLOT "linkClicked_handler(const QString&)");
    Qt::Object::connect(close_button, SIGNAL "clicked()", this, SLOT "close()");

    init();
}


sub DESTROY
{
    destroy();
    SUPER->DESTROY()
}


sub languageChange
{
    setCaption(trUtf8("slack-get GUI info viewer") );
    text_area->setText( undef );
    close_button->setText( trUtf8("Close") );
}



my $INSTALLDIR = '@@INSTALLDIR@@' ;

sub init
{
}


sub destroy
{

}

sub add_package
{
    my $pkg = shift ;
    # name, version, archi, pkg ver, pkg maintener, (un)compressed-size, location, required, suggest, description, info-destination-slackware, info-homepage, info-packager-mail, info-packager-tool, info-packager-tool-version
    my $msg = '<center><table cellpadding="4" cellspacing="2" border="0" height="100%">' ;
    my @colors = ("#f0f0f0","#d0d0d0") ;
    my $idx=0;
    $msg .= '<tr bgcolor="#009cc9"><td valign="middle" colspan="2"><font size="5" color="#ffffff"><b>'.
	    $pkg->name().
	    '</b></font></td></tr>';
    foreach my $field ( $pkg->get_fields_list() )
    {
	next if($field eq 'description' or $field eq 'name' or $field eq 'info-packager-mail' or $field eq 'info-homepage');
	if($field eq 'date')
	{
	    $msg .= "<tr bgcolor=".$colors[$idx%2].">".
		    "<td valign=\"middle\"><tt>$field</tt></td>".
		    "<td valign=\"middle\"><tt>".$pkg->getValue($field)->to_string()."</tt></td>".
		    "</tr>";
	}
	else
	{
	    $msg .= "<tr bgcolor=".$colors[$idx%2].">".
		    "<td valign=\"middle\"><tt>$field</tt></td>".
		    "<td valign=\"middle\"><tt>".$pkg->getValue($field)."</tt></td>".
		    "</tr>";
	}
	$idx++ ;
    }
    $msg .= '<tr bgcolor="'.$colors[$idx%2].'"><td valign="middle" colspan="2">'.
	    $pkg->description().
	    '</td></tr>';
    $idx++;
    $msg .= "<tr bgcolor=".$colors[$idx%2].">".
		"<td valign=\"middle\"><tt>External links</tt></td>".
		"<td valign=\"middle\"><tt>";
    $msg .= '<a href="'.$pkg->getValue('info-homepage').'"  title="Homepage"><img src="'.$INSTALLDIR.'/share/slack-get/images/gohome.png"></a>&nbsp;&nbsp;' if($pkg->getValue('info-homepage'));
    $msg .= '<a href="'.$pkg->getValue('info-packager-mail').'"  title="Mail"><img src="'.$INSTALLDIR.'/share/slack-get/images/mail_generic.png"></a>&nbsp;&nbsp;' if($pkg->getValue('info-packager-mail'));
    $msg.="</tt></td></tr></table></center><br/>";
    text_area->append($msg);
}

sub linkClicked_handler # SLOT: ( const QString & )
{
    my $link = shift ;
    emit( info_viewer_link_clicked($link) ) ;
}


1;
