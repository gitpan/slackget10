package slackget10::Network::Connection::HTTP;

use warnings;
use strict;

use LWP::Simple ;
require slackget10::Network::Connection ;
require Time::HiRes ;

=head1 NAME

slackget10::Network::Connection::HTTP - This class encapsulate LWP::Simple

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '1.0.0';
# our @ISA = qw( slackget10::Network::Connection ) ;

=head1 SYNOPSIS

This class encapsulate LWP::Simple, and provide some methods for the treatment of HTTP requests.

You can't use this class without the slackget10::Network::Connection one.

This class need the following extra CPAN modules :

	- LWP::Simple
	- Time::HiRes

    use slackget10::Network::Connection::HTTP;

    my $foo = slackget10::Network::Connection::HTTP->new();
    ...

This module require the following modules from CPAN : LWP::Simple, Time::HiRes.

=cut

sub new
{
	my ($class,$url,$config) = @_ ;
	my $self = {};
# 	return undef if(!defined($config) && ref($config) ne 'HASH');
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
# 	print "[debug http] protocol : $self->{DATA}->{protocol}\n";
# 	print "[debug http] host : $self->{DATA}->{host}\n";
	my $server = "$self->{DATA}->{protocol}://$self->{DATA}->{host}/";
	$server .= $self->{DATA}->{path}.'/' if($self->{DATA}->{path});
	$server .= 'FILELIST.TXT';
# 	print "[debug http] Testing a HTTP server: $server\n";
	my $start_time = Time::HiRes::time();
# 	print "[debug http] \$start_time : $start_time\n";
	my @head = head($server) or return undef;
	my $stop_time = Time::HiRes::time();
# 	print "[debug http] \$stop_time: $stop_time\n";
	return ($stop_time - $start_time);
}

=head2 get_file

Download and return a given file.

	my $file = $connection->get('PACKAGES.TXT') ;

=cut

sub get_file {
	my ($self,$remote_file) = @_ ;
	$remote_file = $self->file unless(defined($remote_file)) ;
	return get($self->protocol().'://'.$self->host().'/'.$self->path().'/'.$remote_file);
}

=head2 fetch_file

Download and store a given file.

	$connection->fetch_file() ; # download the file $connection->file and store it at $config->{common}->{'update-directory'}/$connection->file, this way is not recommended
	or
	$connection->fetch_file($remote_file) ; # download the file $remote_file and store it at $config->{common}->{'update-directory'}/$connection->file, this way is not recommended
	or
	$connection->fetch_file('PACKAGES.TXT',"$config->{common}->{'update-directory'}/".$current_specialfilecontainer_object->id."/PACKAGES.TXT") ; # This is the recommended way.
	# This is equivalent to : $connection->fetch_file($remote_file,$local_file) ;

This method return 1 if all goaes well, else return undef.
=cut

sub fetch_file {
	my ($self,$remote_file,$local_file) = @_ ;
	$remote_file = $self->file unless(defined($remote_file));
	unless(defined($local_file)){
		if(defined($self->{DATA}->{config})){
			$remote_file=~ /([^\/]*)$/;
			$local_file = $self->{DATA}->{config}->{common}->{'update-directory'}.'/'.$1 ;
		}
		else{
			warn "[slackget10::Network::Connection::HTTP] No \"config\" parameter detected, I can't determine a path to save $remote_file.\n";
			return undef;
		}
	}
	print "[debug http] save the fetched file (",$self->protocol().'://'.$self->host().'/'.$self->path().'/'.$remote_file,") to $local_file\n";
	if(is_success(getstore($self->protocol().'://'.$self->host().'/'.$self->path().'/'.$remote_file,$local_file))){
		return 1;
	}
	else
	{
		return undef;
	}
}

=head2 fetch_all

This method fetch all files declare in the "files" parameter of the constructor.

	$connection->fetch_all or die "Unable to fetch all files\n";

This method save all files in the $config->{common}->{'update-directory'} directory (so you have to manage yourself the files deletion/replacement problems)
=cut

sub fetch_all {
	my $self = shift ;
	foreach (@{$self->files}){
		$self->fetch($_) or return undef;
	}
	return 1 ;
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

1; # End of slackget10::Network::Connection::HTTP
