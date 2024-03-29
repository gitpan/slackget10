package slackget10::Network;

use warnings;
use strict;
use constant {
	SLACK_GET_PROTOCOL_VERSION => 0.5,
};
require slackget10::Network::Message ;
require XML::Simple;

=head1 NAME

slackget10::Network - A class for network communication

=head1 VERSION

Version 0.8.0

=cut

our $VERSION = '1.0.0';
our @ISA;

=head1 SYNOPSIS

WARNING WARNING : this module's API and behaviour changed a lot since the 0.12 release ! Please take good care of this : WARNING WARNING

This class' purpose is to make all network dialog transparent. You give to this class the raw (XML) network message sent to (or from) a slack-get daemon (sg_daemon) and slackget10::Network decode and wrap it for you.
The "plus" of this system is that sg_daemon (or any slack-get client) developpers are safe if something change in the network protocol : it will never change the API.

    use slackget10::Network;

    my $net = slackget10::Network->new();
    my $message_object = new slackget10::Network::Message ;
    $message_object->action('get_connection_id');
    my $xml_msg = $net->encode($message_object);
    my $response_object = $net->decode($xml_msg);
    # $message_object and $response_object are equals in term of values

All methods from this module return a slackget10::Network::Message (L<slackget10::Network::Message>) object.

Since the 0.12 release of this module this module is nothing more than a encoder/decoder for slack-get's network messages. So no more network handling nor automatic response sent directly through the socket passed as argument.

=cut

sub new
{
	my ($class,%args) = @_ ;
	sub _create_random_id
	{
		my $newpass='';
		for (my $k=1;$k<=56;$k++)
		{
			my $lettre = ('a'...'z',1...9)[35*rand];
			$newpass.=$lettre;
		}
		return $newpass;
	}
	my $self = {};
	my $backend = 'slackget10::Network::Backend::XML';
	$backend = $args{backend} if(defined($args{backend}));
	eval "require $backend;";
	if($@){
		warn "[slackget10::Network] backend \"$backend\" do not seems to be available. Fall back to slackget10::Network::Backend::XML.\n" ;
		$backend = 'slackget10::Network::Backend::XML';
		eval "require $backend;";
		if($@){
			warn "[slackget10::Network] backend $backend is not available either. This is critical we can't continue.\n" ;
			return undef;
		}
	}
	push @ISA, $backend;
	$self->{_PRIV}->{CONNID} = _create_random_id() ;
	$self->{_PRIV}->{ACTIONID} = (rand(100)+1) * (rand(100)+1);
	$self->{_PRIV}->{CACHE} = '';
	bless($self,$class);
	return $self;
}

=head1 CONSTRUCTOR

=head2 new

Do not require any parameter. You can optionnally give a backend option with a string :

	my $net = slackget10::Network->new(backend => 'slackget10::Network::Backend::XML');

The only included backend is the XML one for the moment. If the backend could not be loaded the constructor fall back to the XML backend.

=head1 FUNCTIONS

All methods return a slackget10::Network::Message (L<slackget10::Network::Message>) object, and if the remote slack-getd return some data they are accessibles via the data() accessor of the slackget10::Network::Message object.

=cut

=head2 decode

To do.

=cut

sub decode {
	my $self = shift;
	my $input = join '', @_;
	return $self->backend_decode($input);
}

=head2 encode

To do.

=cut

sub encode {
	my $self = shift;
	my $message = shift ;
	print "[slackget10::Network] [debug] encode() incoming message : $message, dump is :\n";
	use Data::Dumper; print Dumper($message),"\n";
	return $self->backend_encode($message);
}

=head2 interpret

To do.

=cut

sub interpret {
	my $self = shift;
	my $message = shift ;
	if(defined($message->action)){
		my $func = '__'.$message->action;
		if($self->can($func)){
			return $self->$func($message) ;
		}
	}
}

=head2 cache_data

To do.

=cut

sub cache_data {
	my ($self,@data)=@_;
	$self->{_PRIV}->{CACHE} .= join('',@data);
}

=head2 cached_data

To do.

=cut

sub cached_data {
	my $self = shift;
	return $self->{_PRIV}->{CACHE};
}

=head2 clear_cache

To do.

=cut

sub clear_cache {
	my $self = shift;
	$self->{_PRIV}->{CACHE} = '';
}

=head2 __get_connection_id

Set the id of the connection. The id is generate by the constructor and must not be modified. This method is automatically called by the constructor and is mostly private.

	$net->__get_connection_id ;

=cut

sub __get_connection_id
{
	my $self = shift;
	my $message = shift ;
	return slackget10::Network::Message->new(
				action => 'get_connection_id', 
				raw_data => {
					Enveloppe => {
						Action => {
							id => $message->{raw_data}->{Enveloppe}->{Action}->{id} ,
							content => 'get_connection_id',
						},
						Data => {
							content => $self->{_PRIV}->{CONNID},
						},
					}
				},
	);
}


=head2 __get_installed_list

get the list of installed packages on the remote daemon.

	my $installed_list = $net->get_installed_list ;

If an error occured call the appropriate handler.

In all case return a slackget10::Network::Message (L<slackget10::Network::Message>) object.

=cut

sub __get_installed_list {
	my $self = shift;
	my $socket = $self->{SOCKET} ;
	$self->send_data("get_installed_list:$self->{CONNID}\n") ;
	if($self->{handle_responses})
	{
		return $self->_handle_responses("get_installed_list") ;
	}
}

=head2 __get_packages_list

get the list of new avalaible packages on the remote daemon.

	my $status = $net->get_packages_list ;

If an error occured call the appropriate handler.

In all case return a slackget10::Network::Message (L<slackget10::Network::Message>) object.

=cut

sub __get_packages_list {
	my $self = shift;
	my $socket = $self->{SOCKET} ;
	$self->send_data("get_packages_list:$self->{CONNID}\n") ;
	if($self->{handle_responses})
	{
		return $self->_handle_responses("get_packages_list") ;
	}
}

=head2 __get_html_info

Get an HTML encoded string which give some general information on the remote slack-getd

	print $net->get_html_info ;

=cut

sub __get_html_info
{
	my $self = shift;
	my $socket = $self->{SOCKET} ;
	$self->send_data("get_html_info:$self->{CONNID}\n") ;
	if($self->{handle_responses})
	{
		return $self->_handle_responses("get_html_info") ;
	}
}

=head2 __build_packages_list

Said to the remote slack-getd to build the new packages cache.

	my $status = $net->build_packages_list ;

The returned status contains no significant data in case of success.

=cut

sub __build_packages_list
{
	my ($self) = @_ ;
	my $socket = $self->{SOCKET} ;
	$self->send_data("build_packages_list:$self->{CONNID}\n") ;
	if($self->{handle_responses})
	{
		return $self->_handle_responses("build_packages_list") ;
	}
}

=head2 __build_installed_list

Said to the remote slack-getd to build the installed packages cache.

	my $status = $net->build_installed_list ;

The returned status contains no significant data in case of success.

=cut

sub __build_installed_list
{
	my ($self) = @_ ;
	my $socket = $self->{SOCKET} ;
	$self->send_data("build_installed_list:$self->{CONNID}\n") ;
	if($self->{handle_responses})
	{
		return $self->_handle_responses("build_installed_list") ;
	}
}

=head2 __build_media_list

Said to the remote slack-getd to build the media list (medias.xml file).

	my $status = $net->build_media_list ;

The returned status contains no significant data in case of success.

=cut

sub __build_media_list
{
	my ($self) = @_ ;
	my $socket = $self->{SOCKET} ;
	$self->send_data("build_media_list:$self->{CONNID}\n") ;
	if($self->{handle_responses})
	{
		return $self->_handle_responses("build_media_list") ;
	}
}

=head2 __diskspace

Ask to the remote daemon for the state of the disk space on a specify partition.

	$net->handle_responses(1); # We want slackget10::Network handle the response and return the hashref.
	my $response = $net->diskspace( "/" ) ;
	$net->handle_responses(0);
	print "Free space on remote computer / directory is ",$response->data()->{avalaible_space}," KB\n";

Return a slackget10::Network::Message object which contains (in case of success) a HASHREF build like that :

	$space = {
		device => <NUMBER>,
		total_size => <NUMBER>,
		used_space => <NUMBER>,
		available_space => <NUMBER>,
		use_percentage => <NUMBER>,
		mount_point => <NUMBER>
	};

=cut

sub __diskspace
{
	my ($self,$dir) = @_ ;
	my $socket = $self->{SOCKET} ;
# 	print STDOUT "[DEBUG::Network.pm] sending command \"diskspace:$dir\" to remote daemon\n";
	$self->send_data("diskspace:$self->{CONNID}:$dir\n") ;
	if($self->{handle_responses})
	{
		my $str = '';
		my $ds = {};
		while(<$socket>)
		{
			chomp;
			if($_=~ /^wait:$self->{CONNID}:/)
			{
				sleep 1;
				next ;
			}
			if ($_=~ /auth_violation:$self->{CONNID}:\s*(.*)/)
			{
				return slackget10::Network::Message->new(
					is_success => undef,
					ERROR_MSG => $1,
					DATA => $_
				);
				last ;
			}
			if($_=~ /^diskspace:$self->{CONNID}:(device=[^;]+;total_size=[^;]+;used_space=[^;]+;available_space=[^;]+;use_percentage=[^;]+;mount_point=[^;]+)/)
			{
				my $tmp = $1;
				print STDOUT "[DEBUG::Network.pm] $tmp contient des info sur diskspace\n";
				foreach my $pair (split(/;/,$tmp))
				{
					my ($key,$value) = split(/=/,$pair);
					print STDOUT "[DEBUG::Network.pm] $key => $value\n";
					$ds->{$key} = $value;
				}
			}
			else
			{
				my $code = $self->_handle_protocol($_) ;
				last if($code==2);
				print STDOUT "[DEBUG::Network.pm] $_ ne contient pas d'info sur diskspace\n";
			}
			last if($_=~ /^end:$self->{CONNID}:\s*diskspace/);
		}
		return slackget10::Network::Message->new(
		is_success => 1,
		DATA => $ds
		);
	}
	
}

=head2 __search

take at least two parameters : the word you search for, and a field. Valid fields are those who describe a package entity in the packages.xml file.

	my $response = $net->search('gcc','name','description') ; # search for package containing 'gcc' in fields 'name' and 'description'

Return the remote slack-getd's response in the DATA section of the response (L<slackget10::Network::Message>).

=cut

sub __search
{
	my ($self,$word,@args) = @_ ;
	my $socket = $self->{SOCKET} ;
	my $fields = join(';',@args);
# 	chop $fields ;
	$self->send_data("search:$self->{CONNID}:$word:$fields\n") ;
	if($self->{handle_responses})
	{
		return $self->_handle_responses("search") ;
	}
}

=head2 __websearch

Take 2 parameters : a reference on an array which contains the words to search for, and another array reference which contains a list of fields (valid fields are thoses describe in the packages.xml file).


The DATA section of the response (L<slackget10::Network::Message>) will contain an ARRAYREF. Each cell of this array will contains a package in HTML
The returned data is HTML, each package are separed by a line wich only contain the string "__MARK__"

	my $response = $network->websearch([ 'burn', 'cd' ], [ 'name', 'description' ]) ;

=cut

sub __websearch
{
	my ($self,$requests,$args) = @_ ;
	my $socket = $self->{SOCKET} ;
	my $fields = join(';',@{$args});
	my $words = join(';',@{$requests}) ;
# 	chop $fields ;
	warn "[slackget10::Network] (debug::websearch) self=$self, words=$words, fields=$fields\n";
	$self->send_data("websearch:$self->{CONNID}:$words:$fields\n") ;
	if($self->{handle_responses})
	{
		my $str = [];
		my $idx = 0;
		while(<$socket>)
		{
			if($_=~ /^wait:$self->{CONNID}:/)
			{
				sleep 1;
				next ;
			}
			last if($_=~ /^end:$self->{CONNID}: websearch/);
			if ($_=~ /auth_violation:$self->{CONNID}:\s*(.*)/)
			{
				return slackget10::Network::Message->new(
					is_success => undef,
					ERROR_MSG => $1,
					DATA => $_
				);
				last ;
			}
			my $code = $self->_handle_protocol($_) ;
			if($_=~/__MARK__/)
			{
				$idx++;
			}
			else
			{
				$str->[$idx] .= $_;
			}
			last if($code==2);
		}
		return slackget10::Network::Message->new(
		is_success => 1,
		DATA => $str
		);
	}
	
}

=head2 __multisearch

Take 2 parameters : a reference on an array which contains the words to search for, and another array reference which contains a list of fields (valid fields are thoses describe in the packages.xml file).


The DATA section of the response (L<slackget10::Network::Message>) will contain the XML encoded response.

	my $response = $network->websearch([ 'burn', 'cd' ], [ 'name', 'description' ]) ;

=cut

sub __multisearch
{
	my ($self,$requests,$args) = @_ ;
	my $socket = $self->{SOCKET} ;
	my $fields = join(';',@{$args});
	my $words = join(';',@{$requests}) ;
# 	chop $fields ;
	$self->send_data("multisearch:$self->{CONNID}:$words:$fields\n") ;
	if($self->{handle_responses})
	{
		return $self->_handle_responses("search") ;
	}
	
}


=head2 __getfile

This method allow you to download one or more files from a slack-get daemon. This method of download is specific to slack-get and is based on the EBCS protocol.

Arguments are :

	files : pass a slackget10::PackageList to this option.
	
	destdir : a string wich is the directory where will be stored the downloaded files.

Here is a little code example :

	# $pkgl is a slackget10::PackageList object.
	$net->getfile(
		file => $pkgl,
		destdir => $sgo->config()->{common}->{'update-directory'}."/package-cache/"
	);

=cut

sub __getfile
{
	my $self = shift;
	my %args = @_ ;
# 	my $pkgl = $args{'file'};
	return slackget10::Network::Message->new(
				is_success => undef,
				ERROR_MSG => "An object of slackget10::PackageList type was waited, but another type of object has come.",
				DATA => undef
			) if(ref($args{'file'}) ne 'slackget10::PackageList') ;
# 	my $destdir = shift;
	my $socket = $self->{SOCKET} ;
	my $str = 'The following files have been successfully saved : ';
	my $file;
	my $write_in = 0;
	# TODO: termin�ici : envoy�le message de requete de fichiers, et finir le code de r�up�ation des fichiers (voir par ex si il n'y as pas d'erreur).
	my $requested_pkgs = '';
	$args{'file'}->index_list() ;
	foreach (@{$args{'file'}->get_all})
	{
		$requested_pkgs .= $_->get_id().';'
	}
	chop $requested_pkgs;
	$self->send_data("getfile:$self->{CONNID}:$requested_pkgs\n");
	if($self->{handle_responses})
	{
		my $current_file;
		while(<$socket>)
		{
			if($_=~ /^wait:$self->{CONNID}:/)
			{
				print "wait\n";
				sleep 2;
				next ;
			}
			last if($_=~ /^end:$self->{CONNID}:\s*getfile/);
			if ($_=~ /auth_violation:$self->{CONNID}:\s*(.*)/)
			{
				return slackget10::Network::Message->new(
					is_success => undef,
					ERROR_MSG => $1,
					DATA => $_
				);
				last ;
			}
			elsif($_ =~ /binaryfile:$self->{CONNID}:\s*(.+)/)
			{
				undef($file);
				$file = slackget10::File->new("$args{'destdir'}/$1",'no-auto-load' => 1, 'mode' => 'write','binary' => 1);
				$current_file=$1;
				$current_file=~ s/\.tgz//;
				$write_in = 1;
			}
			elsif($_ =~ /end:$self->{CONNID}:binaryfile/)
			{
				$file->Write_and_close ;
				$args{'file'}->get_indexed($current_file)->setValue('is-installable',1) ;
				$current_file = '';
				$str .= $file->filename().' ';
				$write_in = 0;
			}
			my $code = $self->_handle_protocol($_) ;
			last if($code==2);
			$file->Add($_) if($write_in && $code == 1);
		}
		return slackget10::Network::Message->new(
		is_success => 1,
		DATA => $str
		);
	}
	
}

=head2 __reboot

	This method ask the remote daemon to reboot the remote computer.

=cut

sub __reboot
{
	my $self = shift;
	$self->send_data("reboot:$self->{CONNID}\n");
}

=head2 __quit

Close the current connection.

	$net->__quit ;

=cut

sub __quit {
	my ($self,$mess) = @_ ;
	$mess = "end session" unless(defined($mess));
	chomp $mess;
# 	print "[debug slackget10::Network] sending \"quit:$self->{CONNID}:$mess\"\n";
	$self->send_data("quit:$self->{CONNID}:$mess\n") ;
# 	$self->{SOCKET}->close() ;
}

=head1 ACCESSORS

=head2 slackget (read only)

return the current slackget10 object.

=cut

sub slackget
{
	my $self = shift ;
	return $self->{SGO} ;
}

=head2 connection_id

Get or set the connection ID.

	$net->connection_id(1234);
	print "Connection ID : ", $net->connection_id , "\n";

=cut

sub connection_id
{
	return $_[1] ? $_[0]->{CONNID}=$_[1] : $_[0]->{CONNID};
}

=head2 handle_responses (read/write)

	Boolean accessor, get/set the value of the handle_responses option.

=cut

sub handle_responses
{
	return $_[1] ? $_[0]->{DATA}->{data}=$_[1] : $_[0]->{DATA}->{data};
}

=head1 PKGTOOLS BINDINGS

Methods in this section are the remote call procedure for pkgtools interactions. The slack-getd daemon use another class for direct call to the pkgtools (L<slackget10::PkgTools>).

The 3 methods have the same operating mode : 

1) Take a single slackget10::PackageList as argument

2) Do the job

3) If their is more than one choice for the package you try to install, the daemon ask for a choice of you.

3bis) Re-do the job

4) For each package in the slackget10::PackageList set a 'status' field which contain the status of the (install|upgrade|remove) process.

=head2 __installpkg

	$net->installpkg($packagelist) ;

=cut

sub __installpkg
{
	my ($self,$packagelist) = @_ ;
	return undef if(ref($packagelist) ne 'slackget10::PackageList') ;
	my $request;
	foreach (@{$packagelist->get_all})
	{
		$request .= $_->get_id().';';
	}
	chop $request;
	print "[DEBUG::Network::installpkg] request => $request\n";
	my $socket = $self->{SOCKET} ;
	$self->send_data("installpkg:$self->{CONNID}:$request\n") ;
	if($self->{handle_responses})
	{
		return $self->_handle_responses("installpkg","All packages marked for installation have been treated.") ;
	}
	return 1;
}

=head2 __upgradepkg

	$net->upgradepkg($packagelist) ;

=cut

sub __upgradepkg
{
	my ($self,$packagelist) = @_ ;
	return undef if(ref($packagelist) ne 'slackget10::PackageList') ;
	my $request;
	foreach (@{$packagelist->get_all})
	{
		$request .= $_->get_id().';';
	}
	chop $request;
	print "[DEBUG::Network::installpkg] request => $request\n";
	my $socket = $self->{SOCKET} ;
	$self->send_data("upgradepkg:$self->{CONNID}:$request\n") ;
	if($self->{handle_responses})
	{
		return $self->_handle_responses("upgradepkg","All packages marked for upgrade have been treated.") ;
	}
	return 1;
}

=head2 __removepkg

Send network commands to a slack-get daemon. This method (like other pkgtools network call), do nothing by herself, but sending a "removepkg:pkg1;pkg2;..;pkgN" to the slack-getd.

	$net->removepkg($packagelist) ;

=cut

sub __removepkg
{
	my ($self,$packagelist) = @_ ;
	print "[DEBUG::Network::removepkg] packagelist => $packagelist\n";
	return undef if(ref($packagelist) ne 'slackget10::PackageList') ;
	my $request;
	foreach (@{$packagelist->get_all})
	{
		$request .= $_->get_id().';';
	}
	chop $request;
	print "[DEBUG::Network::removepkg] request => $request\n";
	my $socket = $self->{SOCKET} ;
	$self->send_data("removepkg:$self->{CONNID}:$request\n") ;
	if($self->{handle_responses})
	{
		return $self->_handle_responses("removepkg","All packages marked for remove have been treated.") ;
	}
	return 1;
}

=head1 DEFAULT HANDLERS

Since the 0.12 release there is no more default handlers.

=cut


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

L<http://www.infinityperl.org>

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

=head1 SEE ALSO

L<slackget10::Network::Message>, L<slackget10::Status>, L<slackget10::Network::Connection>

=head1 COPYRIGHT & LICENSE

Copyright 2005 DUPUIS Arnaud, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of slackget10::Network