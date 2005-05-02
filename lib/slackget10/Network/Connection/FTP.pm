package slackget10::Network::Connection::FTP;

use warnings;
use strict;

require slackget10::Network::Connection ;
use Time::HiRes ;
require Net::FTP ;

=head1 NAME

slackget10::Network::Connection::FTP - This class encapsulate LWP::Simple

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '1.0.0';
our @ISA = qw() ;

=head1 SYNOPSIS

This class encapsulate Net::FTP, and provide some methods for the treatment of FTP requests.

This class need the following extra CPAN modules :

	- Net::FTP
	- Time::HiRes

    use slackget10::Network::Connection::FTP;

    my $foo = slackget10::Network::Connection::FTP->new();
    ...

=cut

sub new
{
	my ($class,$url,$config) = @_ ;
	my $self = {};
	return undef if(!defined($config) && ref($config) ne 'HASH');
	return undef unless (is_url($self,$url));
	bless($self,$class);
	$self->parse_url($url) ;
	return $self;
}

=head1 CONSTRUCTOR


=head1 FUNCTIONS

=head2 test_server

This method test the rapidity of the mirror, by timing a head request on the FILELIST.TXT file.

	my $time = $self->test_server() ;

=cut

sub test_server {
	my $self = shift ;
	print "Testing a FTP server\n";
	my $orig_time = Time::HiRes::time();
	#my $head = head($self->{}) or return undef;
}

# =head2 function2
# 
# =cut
# 
# sub function2 {
# }

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

1; # End of slackget10::Network::Connection::FTP
