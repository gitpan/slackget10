package slackget10::MediaList;

use warnings;
use strict;

require slackget10::List;

=head1 NAME

slackget10::MediaList - A container of slackget10::Media object

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '0.9.11';
our @ISA = qw( slackget10::List );

=head1 SYNOPSIS

This class is used by slack-get to represent a list of medias store in the medias.xml file.

    use slackget10::MediaList;

    my $list = slackget10::MediaList->new();
    ...

=cut

sub new
{
	my ($class,%args) = @_ ;
	my $self={list_type => 'slackget10::Media','root-tag' => 'media-list'};
	foreach (keys(%args))
	{
		$self->{$_} = $args{$_};
	}
	bless($self,$class);
	return $self;
}

=head1 CONSTRUCTOR

=head2 new

Please read the L<slackget10::List> documentation for more informations on the list constructor.

=head1 FUNCTIONS

This class inheritate from slackget10::List, so have a look to this class for a complete list of methods.

=cut

=head2 index_list

Create an index on the MediaList. This index don't take many memory but speed a lot search, especially when you already have the media shortname !

The index is build with the media shortname.

	$list->index_list() ;

=cut

sub index_list
{
	my $self = shift ;
	$self->{INDEX} = {} ;
	foreach my $media (@{$self->{LIST}})
	{
		$self->{INDEX}->{$media->shortname()} = $media ;
	}
	return 1;
}

=head2 get_indexed

Return a media, as well as Get() do but use the index to return it quickly. You must provide a media shortname to this method.

	my $media = $list->get_indexed('slackware') ;

=cut

sub get_indexed
{
	my ($self, $id) = @_ ;
	return $self->{INDEX}->{$id} ;
}

=head1 AUTHOR

DUPUIS Arnaud, C<< <a.dupuis@infinityperl.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-slackget10@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=slackget10>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc slackget10


You can also look for information at:

=over 4

=item * Infinity Perl website

L<http://www.infinityperl.org>

=item * slack-get specific website

L<http://slackget.infinityperl.org>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=slackget10>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/slackget10>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/slackget10>

=item * Search CPAN

L<http://search.cpan.org/dist/slackget10>

=back

=head1 ACKNOWLEDGEMENTS

Thanks to Bertrand Dupuis (yes my brother) for his contribution to the documentation.

=head1 COPYRIGHT & LICENSE

Copyright 2005 DUPUIS Arnaud, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of slackget10::MediaList
