package slackget10::Network::Daemon;

use warnings;
use strict;

=head1 NAME

slackget10::Network::Daemon - A wrapper for network operation in slack-getd

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '1.0.0';

=head1 SYNOPSIS

This class is anoter wrapper for slack-getd. It will encapsulate all daemon nework operation.

    use slackget10::Network::Daemon;

    my $foo = slackget10::Network::Daemon->new();
    ...

=cut

sub new
{
	my ($class,$file) = @_ ;
	my $self={};
	bless($self,$class);
	
	return $self;
}

=head1 CONSTRUCTOR


=head1 FUNCTIONS

=head2 function1

=cut

sub function1 {
}

=head2 function2

=cut

sub function2 {
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

1; # End of slackget10::Network::Daemon
