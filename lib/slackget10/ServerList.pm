package slackget10::ServerList;

use warnings;
use strict;

require slackget10::List;

=head1 NAME

slackget10::ServerList - A container of slackget10::Server object

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '0.9.9';
our @ISA = qw( slackget10::List );

=head1 SYNOPSIS

This class is used by slack-get to represent a list of servers store in the servers.xml file.

    use slackget10::ServerList;

    my $foo = slackget10::ServerList->new();
    ...

=cut

sub new
{
	my ($class,%args) = @_ ;
	my $self={list_type => 'slackget10::Server','root-tag' => 'server-list'};
	foreach (keys(%args))
	{
		$self->{$_} = $args{$_};
	}
	bless($self,$class);
	return $self;
}

=head1 CONSTRUCTOR

=head2 new

Please read the L<slackget10::List> doscumentation for more information on the list constructor.

=head1 FUNCTIONS

This class inheritate from slackget10::List, so have a look to this class for a complete list of methods.

=cut

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

1; # End of slackget10::ServerList
