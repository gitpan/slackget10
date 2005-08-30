package slackget10::GUI::Qt::SGListView;

use warnings;
use strict;
use utf8 ;

use Qt;
use Qt::isa qw(Qt::ListView);
use Qt::attributes qw();
# use Qt::slots
#     add_package     => [];
use Qt::signals
    add_package_status   => ['int'];

=head1 NAME

slackget10::GUI::Qt::SGListView - A wrapper for network operation in slack-get

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '1.0.0';

=head1 SYNOPSIS

This class is anoter wrapper for slack-get. It will encapsulate all nework operation. This class can chang a lot before the release and it may be rename in slackget10::GUI::Qt::SGListViewConnection.

    use Qt;
    use slackget10::GUI::Qt::SGListView;

    sglistview = slackget10::GUI::Qt::SGListView(this,'packages_listview');
    ...

=cut

my $TEST = 1;

sub NEW
{
	shift->SUPER::NEW(@_[0..2]);
	this->addColumn("__PACKAGES");
	this->addColumn("__LOCAL_VERSION");
	this->addColumn("__REMOTE_VERSION");
	this->addColumn("__PACK_SIZE");
	this->addColumn("__SOURCE");
	this->addColumn("package_id");
	this->hideColumn(5);
	this->adjustColumn(0);
	this->adjustColumn(1);
	this->adjustColumn(2);
	this->adjustColumn(3);
	this->adjustColumn(4);
	this->setSelectionMode(&Qt::ListView::Extended);
	this->setShowSortIndicator(1);
	this->setAllColumnsShowFocus(1);
	this->setRootIsDecorated(1);
	this->setSortColumn(0);
}

=head1 CONSTRUCTOR

This class heritate from Qt::ListView, so you must construct the object in the Qt way :

	use Qt;
	use slackget10::GUI::Qt::SGListView;
	use Qt::attributes qw(sglistview);
	
	sglistview = slackget10::GUI::Qt::SGListView (this,'sglistview');

You might be aware that this QListView contain a hide column (number 5), which contain the package id (like aaa_base-10.0.0-noarch-1). So if you add a column with addColumn(), the first column id you can use will be the 6th.

=head1 METHODS

=head2 add_installed_package

Take a slackget10::Package and a Qt::ListViewItem as arguments and add it to the QListView.

	my $item = sg_listview->add_package($package,$item_above) ;

This method return the new Qt::ListViewItem build in the process and update the ListView. $item will be place immediatly after $item_above (but it is possible that this order will be perturbate when the ListView will be sort). This is highly recommended to give a valid item. If $item_above is undefined the new item will be place at the end of the ListView (out of the tree).

In most you can call this method like that :

	my $item = sg_listview->add_package($package,$a_root_item->firstChild);

IMPORTANT: $package must be a part of a slackget10::PackageList (for later operation like download, etc.)

=cut

sub add_installed_package {
	my $package = shift ;
	return undef if(ref($package) ne 'slackget10::Package');
	my $after = shift;
	$after = this->lastItem unless $after;
	my $item = Qt::ListViewItem(this,$after);
	$item->setText(0,$package->name) ;
	$item->setText(1,$package->version);
	return $item ;
}


=head1 AUTHOR

DUPUIS Arnaud, C<< <a.dupuis@infinityperl.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-slackget10-networking@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=slackget10>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2005 DUPUIS Arnaud, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of slackget10::GUI::Qt::SGListView
