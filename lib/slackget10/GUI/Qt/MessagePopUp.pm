package slackget10::GUI::Qt::MessagePopUp;

use warnings;
use strict;
use utf8 ;

use Qt;
use Qt::isa qw(Qt::Dialog);
use Qt::attributes qw(text);
our $VERSION = '1.0.0';

sub NEW
{
	shift->SUPER::NEW(@_);
	status='' ;
}

sub set_text
{
	
}

1;