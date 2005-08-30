package slackget10::GUI::Qt::SGListViewItem;

use warnings;
use strict;
use utf8 ;

use Qt;
use Qt::isa qw(Qt::ListViewItem);
use Qt::attributes qw(status);
# use Qt::slots
#     add_package     => [];
use Qt::signals
    add_package_status   => ['int'];

=head1 NAME

slackget10::GUI::Qt::SGListViewItem - A wrapper for network operation in slack-get

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '1.0.0';

=head1 SYNOPSIS

This class is anoter wrapper for slack-get. It will encapsulate all nework operation. This class can chang a lot before the release and it may be rename in slackget10::GUI::Qt::SGListViewItemConnection.

    use Qt;
    use slackget10::GUI::Qt::SGListViewItem;

    sglistview = slackget10::GUI::Qt::SGListViewItem(this,'packages_listview');
    ...

=cut

sub NEW
{
	shift->SUPER::NEW(@_);
	status=0 ;
}

=head1 CONSTRUCTOR

This class heritate from Qt::ListView, so you must construct the object in the Qt way :

	use Qt;
	use slackget10::GUI::Qt::SGListViewItem;
	use Qt::attributes qw(sglistview);
	
	sglistview = slackget10::GUI::Qt::SGListViewItem (this,'sglistview');

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

=head2 status

Accessor to get/set the package status.

=cut

sub state
{
	my $status = shift;
	return status unless($status);
	if($status==0 or $status==1 or $status==2 or $status==3)
	{
		status=$status ;
	}
	else
	{
		warn "A SGListViewItem state must be in 0,1 (upgrade available),2 (remote version older than local one) or (package is not installed on the system). '$status' is not valid\n";
		return undef;
	}
	
}

=head2 paintCell

=cut

sub paintCell {
	my ($p, $cg, $column, $width, $alignment) = @_ ;
# 	print "paintCell() : status=",status,"\n";
	my $cg2 = Qt::ColorGroup ( $cg );
	my $c = $cg2->base();
	if(status == 1)
	{
		$cg2->setColor( &Qt::ColorGroup::Base, Qt::Color(161,244,152) );
		$cg2->setColor( &Qt::ColorGroup::Highlight, &Qt::green );
	}
	elsif(status == 2)
	{
		$cg2->setColor( &Qt::ColorGroup::Base, Qt::Color(237,133,133) );
		$cg2->setColor( &Qt::ColorGroup::Highlight, &Qt::red );
	}
	elsif(status == 3)
	{
		$cg2->setColor( &Qt::ColorGroup::Base, Qt::Color(195, 254, 255) );
		$cg2->setColor( &Qt::ColorGroup::Highlight, Qt::Color(0,156,201) );
	}
	else
	{
		$cg2->setColor( &Qt::ColorGroup::Highlight, Qt::Color(246,244,44) );
	}
	
	Qt::ListViewItem::paintCell( $p, $cg2, $column, $width, $alignment );

	$cg2->setColor( &Qt::ColorGroup::Base, $c );
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

1; # End of slackget10::GUI::Qt::SGListViewItem
