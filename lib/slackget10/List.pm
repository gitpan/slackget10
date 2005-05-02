package slackget10::List;

use warnings;
use strict;

=head1 NAME

slackget10::List - This class is a general List class.

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '1.0.0';

=head1 SYNOPSIS

This class is a container of slackget10::Package object, and allow you to perform some operations on this packages list. As the Package class, it is a slack-get's internal representation of data.

    use slackget10::List;

    my $list = slackget10::List->new();
    $list->add($element);
    $list->get($index);
    my $element = $list->Shift();
    

=head1 CONSTRUCTOR

This class constructor take only one argument : list_type. You must provide a string which will specialize your list. Ex:

	For a slackget10::Package list :
		my $packagelist = new slackget10::List (list_type => 'slackget10::Package') ;

But look at special class slackget10::*List before creating your own list : maybe I have already do the work :)

=cut

sub new
{
	my ($class,%args) = @_ ;
	return undef unless(defined($args{list_type}));
	my $self={%args};
	$self->{LIST} = [] ;
	bless($self,$class);
	return $self;
}

=head1 FUNCTIONS

=head2 add

Add the element passed in argument to the list. The argument must be an object of the list_type type.

	$list->add($element);

=cut

sub add {
	my ($self,$pack) = @_ ;
	
	return undef if(ref($pack) ne "$self->{list_type}");
	push @{$self->{LIST}}, $pack;
	return 1;
}

=head2 get

return the $index slackget10::Package object in the list

	$list->get($index);

=cut

sub get {
	my ($self,$idx) = @_ ;
	return $self->{LIST}->[$idx];
}

=head2 get_all

return a reference on an array containing all packages.

	$arrayref = $list->get_all();

=cut

sub get_all {
	my $self = shift ;
	return $self->{LIST};
}

=head2 Shift

Same as the Perl shift. Shifts of and return the first slackget10::Package of the slackget10::List;

	$element = $list->Shift();

=cut

sub Shift {
	my ($self) = @_ ;
	return shift(@{$self->{LIST}});
}

=head2 to_XML

return an XML encoded string.

	$xml = $list->to_XML();

=cut

sub to_XML
{
	my $self = shift;
	my $xml = '';
	$xml .= "<packagelist>\n" unless($self->{'no-root-tag'});
	foreach (@{$self->{LIST}}){
		$xml .= $_->to_XML();
	}
	$xml .= "</packagelist>\n" unless($self->{'no-root-tag'});
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

1; # End of slackget10::List
