package slackget10::Server;

use warnings;
use strict;

=head1 NAME

slackget10::Server - A to represent a server from the servers.xml file.

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '1.0.0';

=head1 SYNOPSIS

This class is used by slack-get to represent a server store in the servers.xml file.

    use slackget10::Server;

    my $server = slackget10::Server->new();
    ...

=CONSTRUCTOR



=cut

sub new
{
	my ($class,$args) = @_ ;
	my $self={};
	$self->{DATA} = {%{$args}};
	unless(defined($self->{DATA}->{id}) && defined($self->{DATA}->{'update-url'}) ){
		warn "[slackget10::Server] cannot build the server object because one of the following argument is undefined : \n\tid, \n\tupdate-url\n";
		return undef;
	}
	if(ref($self->{DATA}->{'update-url'}) ne 'HASH'){
		warn "[slackget10::Server] cannot build the server object because the update-url argument is not a HASH reference.\n";
		return undef;
	}
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

=head3 ACCESSORS

Some accessors for the current object/

=cut

=head2 host

return the current host :

	my $host = $server->host

=cut

sub host {
	return $_[0]->{DATA}->{host};
}

=head2 description

return the description of the server.

	my $descr = $server->description ;

=cut

sub description {
	return $_[0]->{DATA}->{description};
}

=head2 url

return the URL of the website for the server.

	system("$config->{common}->{'default-browser'} $server->url &");

=cut

sub url {
	return $_[0]->{DATA}->{'web-link'};
}

=head2 shortname

Return the shortname of the server. The shortname is the name of the id attribute of the server tag in servers.xml => <server id="the_shortname">

	my $id = $server->shortname ;

=cut

sub shortname {
	return $_[0]->{DATA}->{id};
}

=head3 FORMATTED OUTPUT

Different methods to properly output a server.

=head2 to_XML

return the server info as an XML encoded string.

	$xml = $server->to_XML();

=cut

sub to_XML
{
	my $self = shift;
	return undef unless(defined($self->{DATA}->{id}));
	my $xml = "\t<server id=\"$self->{DATA}->{id}\">\n";
	foreach my $key (keys(%{$self->{DATA}})){
		if($key eq 'update-repository')
		{
			foreach my $key2 (keys(%{$self->{DATA}->{'update-repository'}}))
			{
				if($key2 eq 'fast' or $key2 eq 'slow' && ref($self->{DATA}->{'update-repository'}->{$key2}) eq 'HASH' && defined($self->{DATA}->{'update-repository'}->{$key2}->{li}) && ref($self->{DATA}->{'update-repository'}->{$key2}->{li}) eq 'ARRAY' ) {
					$xml .= "\t\t<$key2>\n";
					foreach (@{$self->{DATA}->{'update-repository'}->{$key2}->{li}}){
						$xml .= "\t\t\t<li>$_</li>\n";
					}
					$xml .= "\t\t</$key2>\n";
				}
			}
		}
		else
		{
			$xml .= "\t\t<$key>$self->{DATA}->{$key}</$key>\n";
		}
	}
	$xml .= "\t</server>\n";
	return $xml;
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

1; # End of slackget10::Server
