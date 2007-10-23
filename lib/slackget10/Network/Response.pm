package slackget10::Network::Response ;

use warnings;
use strict;

=head1 NAME

slackget10::Network::Reponse - The response object for slackget10::Network class

=head1 VERSION

Version 0.9.2

=cut

our $VERSION = '0.9.2';

=head1 SYNOPSIS

This class is the response object used by the slackget10::Network class to return informations from the connection.

=cut

=head2 new

the constructor take no argument.

=cut

sub new
{
	shift;
	my $self = {@_};
	bless $self;
	return $self;
}

=head2 is_success

true if the operation is a success

=cut

sub is_success {
	my $self = shift;
	return $self->{is_success} ;
}

=head2 is_error

true if the operation is an error

=cut

sub is_error {
	my $self = shift;
	return !$self->{is_success} ;
}

=head2 error_msg

return a string containing an error message. Works only if $response->is_error() is true.

=cut

sub error_msg {
	my $self = shift;
	return $self->{ERROR_MSG} ;
}

=head2 have_choice

true if the daemon return a choice

=cut

sub have_choice {
	my $self = shift;
	return $self->{have_choice} ;
}

=head2 data

return all raw data returned by the remote daemon

=cut

sub data {
	my $self = shift;
	return $self->{DATA} ;
}




=head1 AUTHOR

DUPUIS Arnaud, C<< <a.dupuis@infinityperl.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-slackget10@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=slackget10>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2005 DUPUIS Arnaud, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of slackget10::Network::Response