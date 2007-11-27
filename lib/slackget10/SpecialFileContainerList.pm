package slackget10::SpecialFileContainerList;

use warnings;
use strict;

require slackget10::List ;

=head1 NAME

slackget10::SpecialFileContainerList - This class is a container of slackget10::SpecialFileContainer object

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '0.9.0';
our @ISA = qw( slackget10::List );

=head1 SYNOPSIS

This class is a container of slackget10::SpecialFileContainer object, and allow you to perform some operations on this packages list. As the SpecialFileContainer class, it is a slack-get's internal representation of data.

    use slackget10::SpecialFileContainerList;

    my $containerlist = slackget10::SpecialFileContainerList->new();
    $containerlist->add($container);
    my $conainer = $containerlist->get($index);
    my $container = $containerlist->Shift();

Please read the slackget10::List documentation for more informations (L<slackget10::List>).

=head1 CONSTRUCTOR

=head2 new

This class constructor don't take any parameters.

	my $containerlist = new slackget10::SpecialFileContainerList ();

=cut

sub new
{
	my ($class,%args) = @_ ;
	my $self={list_type => 'slackget10::SpecialFileContainer','root-tag' => 'slack-get'};
	foreach (keys(%args))
	{
		$self->{$_} = $args{$_};
	}
	$self->{LIST} = [] ;
	$self->{ENCODING} = 'utf8' ;
	$self->{ENCODING} = $args{'encoding'} if(defined($args{'encoding'})) ;
	bless($self);#,$class
	return $self;
}

=head2

return a list of all id of the SpecialFileContainers.

=cut

sub get_all_media_id {
	my $self = shift;
	my %shortnames=();
	foreach my $obj (@{$self->get_all}){
		$shortnames{$obj->id}=1;
	}
	return keys(%shortnames);
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

L<http://www.infinityperl.org/category/slack-get>

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

1; # End of slackget10::SpecialFileContainerList
