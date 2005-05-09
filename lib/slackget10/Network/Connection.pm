package slackget10::Network::Connection;

use warnings;
use strict;

use lib '/home/1024/progz/slack-get/V1.0/slack-get/lib/slackget10/lib'; # ONLY FOR DEBUG !!!

require slackget10::Network::Connection::FTP ;
require slackget10::Network::Connection::HTTP ;

=head1 NAME

slackget10::Network::Connection - A wrapper for network operation in slack-get

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '1.0.0';

# my %equiv = (
# 	'normal' => 'IO::Socket::INET',
# 	'secure' => 'IO::Socket::SSL',
# 	'ftp' => 'Net::FTP',
# 	'http' => 'LWP::Simple'
# );

our @ISA = qw();

=head1 SYNOPSIS

This class is anoter wrapper for slack-get. It will encapsulate all nework operation. This class can chang a lot before the release and it may be rename in slackget10::NetworkConnection.

=head2 Some words about subclass

This class is a wrapper for subclass like slackget10::Network::Connection::HTTP or slackget10::Network::Connection::FTP. You can add a class for a new protocol (and update this constructor) very simply but you must know that all class the slackget10::Network::Connection::* must have the following methods (the format is : <method name(<arguments>)> : <returned value>, parmaeters between [] are optionnals):

	- test_server : a float (the server response time)
	- fetch_file([$remote_filename],[$local_file]) : a boolean (1 or 0). NOTE: this method store the fetched file on the hard disk. If $local_file is not defined, fetch() must store the file in <update-directory>.
	- fetch_all : a boolean (1 or 0)
	- get_file([$remote_filename]) : the file content
	

=head1 CONSTRUCTOR

	use slackget10::Network::Connection;
	
	(1)
	my $connection = slackget10::Network::Connection->new('http://www.nymphomatic.org/mirror/linuxpackages/Slackware-10.1/');
	my $file = $connection->get_file('FILELIST.TXT');
	
	or :
	
	(2)
	my $connection = slackget10::Network::Connection->new('http://www.nymphomatic.org/mirror/linuxpackages/Slackware-10.1/FILELIST.TXT');
	my $file = $connection->get_file;
	
	or :
	
	(3)
	my $connection = slackget10::Network::Connection->new(
			host => 'http://www.nymphomatic.org',
			path => '/mirror/linuxpackages/Slackware-10.1/',
			files => ['FILELIST.TXT','PACKAGES.TXT','CHECKSUMS.md5'], # Be carefull that it's the files parameter not file. file is the current working file.
			config => $config,
			mode => 'normal'
	);
	$connection->fetch_all or die "An error occur during the download\n";
	
	or (the recommended way) :
	
	(4)
	my $connection = slackget10::Network::Connection->new(
			host => 'http://www.nymphomatic.org',
			path => '/mirror/linuxpackages/Slackware-10.1/',
			config => $config,
			mode => 'normal'
	);
	my $file = $connection->get_file('FILELIST.TXT') or die "[ERROR] unable to download FILELIST.TXT\n";
	
	or :
	
	my $status = $connection->fetch('FILELIST.TXT',"$config->{common}->{'update-directory'}/".$server->shortname."/cache/FILELIST.TXT");
	ie "[ERROR] unable to download FILELIST.TXT\n" unless ($status);

The global way (3) is not recommended because of the lake of control on the downloaded file. For example, if there is only 1 download which fail, fetch_all will return undef and you don't know which download have failed.

The simpliest ways (1) and (2) are not recommended because you didn't give a slackget10::Config object to the connection. So you have to manage by yourself all tasks needed to a proper work (like charset encoding, moving file to proper destination, etc.). In this case don't forget that the download methods file save file in the current directory.

The recommended way is to give to the constructor the following arguments :

	host : the host (with the protocol, do not provide 'ftp.lip6.fr' provide ftp://ftp.lip6.fr. The protocol will be automatically extract)
	path : the path to the working directory on the server (Ex: '/pub/linux/distributions/slackware/slackware-10.1/'). Don't provide a 'file' argument.
	config : the slackget10::Config object of the application
	mode : a mode between 'normal' or 'secure'. This is only when you attempt to connect to a daemon (front-end/daemon or daemon/daemon connection). 'secure' use SSL connection.

=cut

sub new
{
	my ($class,@args) = @_ ;
	my $self={};
	bless($self,$class);
# 	print "scalar: ",scalar(@args),"\n";
	if(scalar(@args) < 1){
		warn "[slackget10::Network::Connection] you must provide at least one argument to my constructor\n" ;
		return undef ;
	}
	elsif(scalar(@args) == 1){
		if(is_url($self,$args[0])){
			parse_url($self,$args[0]) or return undef; # here is a really paranoid test because if this test fail it fail before (at is_url), so the "or return undef" is "de trop"
			_load_network_module($self) or return undef;
		}
		else{
			return undef;
		}
	}
	else{
		my %args = @args;
		warn "[slackget10::Network::Connection] You need to provide a \"config\" parameter with a valid slackget10::Config object reference.\n" && return undef if(!defined($args{config}) && ref($args{config}) ne 'slackget10::Config') ;
		if(exists($args{host}) && (exists($args{path}) || exists($args{file}) ) && exists($args{config}) && ref($args{config}) eq 'slackget10::Config' ){
			parse_url($self,$args{host}) or return undef;
			_load_network_module($self) or return undef;
			_fill_data_section($self,\%args);
			
		}
		else
		{
			warn "[slackget10::Network::Connection] you must provide the following parameters to the constructor :\n\thost\n\tpath\n\tconfig\n" ;
			return undef ;
		}
		%args = ();
	}
	@args = ();
	
	
	return $self;
}

=head1 FUNCTIONS

=head2 is_url

Take a string as argument and return TRUE (1) if $string is an http or ftp URL and FALSE (0) else

	print "$string is a valid URL\n" if($connection->is_url($string)) ;

=cut

sub is_url {
	my ($self,$url)=@_;
	
	if($url=~ /^([fhtps]{3,5}):\/\/([^\/]+){1}(\/.*)?$/){
		return 1;
	}
	else{
		return 0 ;
	}
}

=head2 parse_url

extract the following informations from $url :

	- the protocol 
	- the server
	- the file (with its total path)

For example :

	$connection->pars_url("ftp://ftp.lip6.fr/pub/linux/distributions/slackware/slackware-current/slackware/n/dhcp-3.0.1-i486-1.tgz");

Will extract :

	- protocol = ftp
	- host = ftp.lip6.fr
	- file = /pub/linux/distributions/slackware/slackware-current/slackware/n/dhcp-3.0.1-i486-1.tgz

This method return TRUE (1) if all goes well, else return FALSE (0)

=cut

sub parse_url {
	my ($self,$url)=@_;
	
	if(my @tmp = $url=~ /^([fhtps]{3,5}):\/\/([^\/]+){1}(\/.*)?$/){
		$self->{DATA}->{protocol} = $1;
# 		print "[debug] setting host to : $2\n";
		$self->{DATA}->{host} = $2;
# 		print "[debug] host is set to $self->{DATA}->{host} fo object $self\n";
		$self->{DATA}->{file} = $3;
# 		print "[debug] file is set to $self->{DATA}->{file} fo object $self\n";
		#if we can extract a file name and a directory path we do.
		if(defined($self->{DATA}->{file}) && $self->{DATA}->{file}=~ /^(.*\/)([^\/]+)$/i)
		{
			$self->{DATA}->{path} = $1;
			$self->{DATA}->{file} = $2;
		}
		
		return 1;
	}
	else{
		return 0 ;
	}
}

sub _load_network_module {
	my $self = shift;
	if($self->{DATA}->{protocol} eq 'ftp'){
# 		print "[debug] derivation de slackget10::Network::Connection::FTP\n";
		@ISA = qw( slackget10::Network::Connection::FTP ) ;
	}
	elsif($self->{DATA}->{protocol} eq 'http'){
# 		print "[debug] derivation de slackget10::Network::Connection::HTTP\n";
		@ISA = qw( slackget10::Network::Connection::HTTP ) ;
	}
	else{
		warn "[slackget10::Network::Connection] Network protocol '$self->{protocol}' is not available\n" ;
		return undef ;
	}
	return 1;
}

sub _fill_data_section {
	my $self = shift;
	my $args = shift;
	foreach (keys(%{$args})){
		$self->{DATA}->{$_} = $args->{$_} if(!(defined($self->{DATA}->{$_})));
	}
}

sub DEBUG_show_data_section
{
	my $self = shift;
	print "===> DATA section of $self <===\n";
	foreach (keys(%{$self->{DATA}}))
	{
		print "$_ : $self->{DATA}->{$_}";
	}
	print "===> END DATA section <===\n";
}

=head1 ACCESSORS

The common accessors are :

=cut

=head2 protocol

return the protocol of the current Connection object as a string :

	my $proto = $connection->protocol ;

=cut

sub protocol {
	my $self = shift ;
	return $self->{DATA}->{protocol} ;
}

=head2 host

return the host of the current Connection object as a string :

	my $host = $connection->host ;

=cut

sub host {
	my $self = shift ;
	return $self->{DATA}->{host} ;
}

=head2 file

return the file of the current Connection object as a string :

	my $file = $connection->file ;

=cut

sub file {
	my $self = shift ;
	return $self->{DATA}->{file} ;
}

=head2 files

return the list of files of the current Connection object as an array reference :

	my $arrayref = $connection->files ;

=cut

sub files {
	my $self = shift ;
	return $self->{DATA}->{files} ;
}

=head2 path

return the path of the current Connection object as a string :

	my $path = $connection->path ;

=cut

sub path {
	my $self = shift ;
	return $self->{DATA}->{path} ;
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

1; # End of slackget10::Network::Connection
