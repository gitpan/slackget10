package slackget10::SpecialFileContainerList;

use warnings;
use strict;

require slackget10::Package;

=head1 NAME

slackget10::SpecialFileContainerList - This class is a container of slackget10::Package object

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '1.0.0';

=head1 SYNOPSIS

This class is a container of slackget10::SpecialFileContainer object, and allow you to perform some operations on this packages list. As the SpecialFileContainer class, it is a slack-get's internal representation of data.

    use slackget10::SpecialFileContainerList;

    my $containerlist = slackget10::SpecialFileContainerList->new();
    $containerlist->add($container);
    my $conainer = $containerlist->get($index);
    my $container = $containerlist->Shift();
    

=head1 CONSTRUCTOR

This class constructor don't take any parameters.

	my $containerlist = new slackget10::SpecialFileContainerList ();

=cut

sub new
{
	my ($class) = @_ ;
	my $self={};
	$self->{LIST} = [] ;
	bless($self);#,$class
	return $self;
}

=head1 FUNCTIONS

=head2 add

Add the package passed in argument to the list. The argument must be a slackget10::Package object

	$containerlist->add($package);

=cut

sub add {
	my ($self,$container) = @_ ;
	
	return undef if(ref($container) ne 'slackget10::SpecialFileContainer');
	push @{$self->{LIST}}, $container;
	return 1;
}

=head2 get

return the $index slackget10::Package object in the list

	$containerlist->get($index);

=cut

sub get {
	my ($self,$idx) = @_ ;
	return $self->{LIST}->[$idx];
}

=head2 get_all

return a reference on an array containing all packages.

	$arrayref = $containerlist->get_all();

=cut

sub get_all {
	my $self = shift ;
	return $self->{LIST};
}

=head2 Shift

Same as the Perl shift. Shifts of and return the first slackget10::SpecialFileContainer of the slackget10::SpecialFileContainerList;

	$package = $containerlist->Shift();

=cut

sub Shift {
	my ($self) = @_ ;
	return shift(@{$self->{LIST}});
}

=head2 to_XML

return an XML encoded string.

	$xml = $containerlist->to_XML();

=cut

sub to_XML
{
	my $self = shift;
	my $xml = "<slack-get>\n";
	foreach (@{$self->{LIST}}){
		$xml .= $_->to_XML();
	}
	$xml .= "</slack-get>\n";
	return $xml;
}

=head2 to_string

Alias for to_XML()

=cut

sub to_string{
	my $self = shift;
	$self->to_XML();
}


=head1 AUTHOR

DUPUIS Arnaud, C<< <a.dupuis@infinityperl.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-slackget10-PackageList@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=slackget10>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2005 DUPUIS Arnaud, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of slackget10::SpecialFileContainerList
