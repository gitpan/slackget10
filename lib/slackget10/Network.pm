package slackget10::Network;

use warnings;
use strict;
require slackget10::Network::Response ;

=head1 NAME

slackget10::Network - A class for network communication

=head1 VERSION

Version 0.7.3

=cut

our $VERSION = '0.7.3';

=head1 SYNOPSIS

This class' purpose is to make all network dialog transparent. Instead of sending 

    use slackget10::Network;

    my $net = slackget10::Network->new(
    	handle_responses => 1,
    	socket => IO::Socket::INET->new(
		PeerAddr => 192.168.0.10,
		PeerPort => 42000)
    );
    my $installed = $net->get_installed_list ;
    my $reponse = $net->install_packages("gcc-objc;gcc-g++;gcc");
    if($response->is_success)
    {
    	print "Packages successfully installed\n";
    }
    elsif($response->have_choice)
    {
    	print $response->data ;
    }
    elsif($response->is_error)
    {
    	print "An error occured during install. Remote daemon said : ",$response->data ,"\n";
    }

All methods from this module return a slackget10::Network::Response (L<slackget10::Network::Response>) object.

In the same way they all handle network exceptions from remote daemon.

=cut

sub new
{
	my ($class,%args) = @_ ;
	sub _create_random_id
	{
		srand (time ^ $$ ^ unpack "%L*", `ps axww | gzip`);
		my $newpass='';
		for (my $k=1;$k<=56;$k++)
		{
			my $lettre = ('a'...'z',1...9)[35*rand];
			$newpass.=$lettre;
		}
		return $newpass;
	}
	return undef unless(defined($args{'socket'})) ;
	return undef unless($args{'socket'});
	my $self={
		on_success => \&on_success ,
		on_error => \&on_error,
		on_unknow => \&on_unknow,
		on_choice => \&on_choice,
		on_info => \&on_info
	};
	$self->{handle_responses} = undef;
	$self->{handle_responses} = $args{handle_responses} if(exists($args{handle_responses}));
	$self->{'on_error'} = $args{'on_error'} if($args{'on_error'} && ref($args{'on_error'}) eq 'CODE') ;
	$self->{'on_success'} = $args{'on_success'} if($args{'on_success'} && ref($args{'on_success'}) eq 'CODE') ;
	$self->{'on_choice'} = $args{'on_choice'} if($args{'on_choice'} && ref($args{'on_choice'}) eq 'CODE') ;
	$self->{'on_info'} = $args{'on_info'} if($args{'on_info'} && ref($args{'on_info'}) eq 'CODE') ;
	$self->{'on_unknow'} = $args{'on_unknow'} if($args{'on_unknow'} && ref($args{'on_unknow'}) eq 'CODE') ;
	$self->{SGO} = $args{'slackget_object'} if($args{'slackget_object'} && ref($args{'slackget_object'}) eq 'slackget10');
	$self->{SOCKET} = $args{'socket'} ;
	$self->{TIMEOUT} = 3;
	$self->{TIMEOUT} = $args{'timeout'} if(defined($args{'timeout'})) ;
	$self->{CONNID} = _create_random_id() ;
	bless($self,$class);
	$self->_setconnectionid() if(!$args{'dont-set-connection-id'});
	return $self;
}

=head1 CONSTRUCTOR

=head2 new

Need a 'socket' argument :

    my $net = slackget10::Network->new(
    	socket => IO::Socket::INET->new(
		PeerAddr => 192.168.0.10,
		PeerPort => 42000)
    );

The constructor can take the followings arguments :

B<socket> : a IO::Socket::INET wich is connected to the remote slack-getd

B<handle_responses> : if this parameter is defined the slackget10::Network class instance will handle the network answer (default: undef). 

WARNING: if you use this class on a GUI you will prefer to handle protocol by yourself because this class freeze a GUI. The other possibility is to use the network tasks manager class of slack-get (this class has been recoded for this manager, you can read L<slackget10::GUI::Qt::operationsProcessor> for more informations).

WARNING 2 : For the moment, this class can only handle responses when you use an IO::Socket socket (no support for Qt::Socket yet).

B<slackget_object> : a reference to a valide slackget10 object.

B<on_error> [handler] : a CODE reference to a sub which will be call on each error message returned by the server. This sub must take a string (the error message) as argument.

B<on_success> [handler] : a CODE reference to a sub which will be call on each success message returned by the server. This sub must take a string (the error message) as argument.

B<on_unknow> [handler] : a CODE reference to a sub which will be call on each unknown command message returned by the remote slack-getd. This sub must take a string (the error message) as argument.

B<on_choice> [handler] : a CODE reference to a sub wich will be call each time a choice is needed. This sub must take a whole XML string which represent the choice as argument. Please look at the source code of the on_choice method for more informations.

B<on_info> [handler] : a CODE reference to a sub wich will be call each time the daemon give us an information. This sub must take as argument : an IP adresse (string), an info level (integer) and a message (string). Please remember that this message is only half process : this class extract the IP adresse of the remote daemon, the info level and the message, but the message itself can contains other informations which are not yet process (like "progress" messages).

There is also one special event : 'end' which is not hookable. It may be in the futur but this event is send when all treatment and data relative to the last command are terminate (but there is no information about the state in this event). It seems that this is usefull only to this module's methods.

Look at the L<DEFAULT HANDLERS> section for more informations one default handlers.

=head1 FUNCTIONS

All methods return a slackget10::Network::Response (L<slackget10::Network::Response>) object, and if the remote slack-getd return some data they are accessibles via the data() accessor of the slackget10::Network::Response object.

=cut

=head2 _setconnectionid

Set the id of the connection. The id is generate by the constructor and must not be modified. This method is automatically called by the constructor and is mostly private.

	$net->_setconnectionid() ;

=cut

sub _setconnectionid
{
	my $self = shift;
	$self->send_data("setconnectionid:$self->{CONNID}\n") or die "FATAL: cannot set the connection ID\n";
}

=head2 send_data

send a given message to the remote daemon. This method is mostly for private use.

	$net->send_data("get_installed_list") or die "cannot send get_installed_list\n";

=cut

sub send_data
{
	my ($self,$message) = @_ ;
	# TODO : finir de coder cette fonction
	my $socket = $self->{SOCKET} ;
	chomp $message;
	if(ref($socket) =~ /IO::Socket/)
	{
		print $socket "$message\n" or return undef;
	}
	elsif(ref($socket) =~ /Qt::Socket/)
	{
		$socket->flush ;
		my $sent = $socket->writeBlock("$message\n", length("$message\n"));
# 		print "[slackget10::Network] sent $sent/".length("$message\n")." bytes through the QSocket message was \"$message\n\"\n";
		warn "Error while sending data through the QSocket.\n" if($sent == -1 ) ;
		return undef if($sent == -1 ) ;
	}
	else
	{
		return undef;
	}
	return 1;
}

sub _handle_protocol
{
	my $self = shift ;
	my $addr='0.0.0.0:0';
	if(ref($self->{SOCKET}) =~ /IO::Socket/)
	{
		$addr = $self->{SOCKET}->peerhost();
	}
	elsif(ref($self->{SOCKET}) =~ /Qt::Socket/)
	{
		$addr = $self->{SOCKET}->peerAddress()->toString() if($self->{SOCKET}->peerAddress());
	}
# 	my $mess = shift;
	if($_[0]=~/^error:$self->{CONNID}:\s*(.*)/)
	{
		print "[slackget10::Network DEBUG] Handling protocol : error msg calling $self->{'on_error'}\n";
		$self->{'on_error'}->("[$addr] $1");
		$_[0] =~ s/.*//g;
		return 2;
	}
	elsif($_[0]=~/^success:$self->{CONNID}:\s*(.*)/)
	{
		print "[slackget10::Network DEBUG] Handling protocol : success msg calling $self->{'on_success'}\n";
		$self->{'on_success'}->("[$addr] $1");
		$_[0] =~ s/.*//g;
		return 4;
	}
	elsif($_[0]=~/^unknown_said:$self->{CONNID}:\s*(.*)/)
	{
		print "[slackget10::Network DEBUG] Handling protocol : unknow msg calling $self->{'on_unknow'}\n";
		$self->{'on_unknow'}->("[$addr] $1");
		$_[0] =~ s/.*//g;
		return 2;
	}
	elsif($_[0]=~/^choice:$self->{CONNID}:\s*(.*)/)
	{
		print "[slackget10::Network DEBUG] Handling protocol : choice msg calling $self->{'on_choice'}\n";
		$self->{'on_choice'}->("$1"); #il manque l'adresse
		$_[0] =~ s/.*//g;
		return 3;
	}
	elsif($_[0]=~ /^info:$self->{CONNID}:(\d+):\s*(.*)/)
	{
		print "[slackget10::Network DEBUG] Handling protocol : info msg calling $self->{'on_info'}\n";
		$self->{'on_info'}->($addr,$1,$2);
		$_[0] =~ s/.*//g;
		return 4;
	}
# 	print "Canno't handle protocol for message \"$_[0]\"\n";
	return 1;
}

sub _handle_responses
{
	my ($self,$message,$success_message) = @_;
	my $socket = $self->{SOCKET} ;
	my $str = '';
	my $idx=8;
	while(<$socket>)
	{
# 		next if($_ =~ /^\s*$/);
# 		print "[slackget10::Network DEBUG] \"$_\"\n" if($idx<=10);
		if($_=~ /^wait:$self->{CONNID}:/)
		{
			print "waiting for daemon\n";
			sleep 2;
			next ;
		}
		last if($_=~ /^end:$self->{CONNID}:\s*$message/);
		if ($_=~ /auth_violation:$self->{CONNID}:\s*(.*)/)
		{
			return slackget10::Network::Response->new(
				is_success => undef,
				ERROR_MSG => $1,
				DATA => $_
			);
			last ;
		}
		my $code = $self->_handle_protocol($_) ;
		last if($code==2);
		$str .= $_;
	}
# 	my @tt = split(/\n/,$str);
# 	print "[DEBUG Network] ligne 0 \"",$tt[0],"\"\n";
# 	print "[DEBUG Network] ligne 1 \"",$tt[1],"\"\n";
	$str .= "$success_message" if(defined($success_message));
	return slackget10::Network::Response->new(
	is_success => 1,
	DATA => $str
	);
}

=head2 get_installed_list

get the list of installed packages on the remote daemon.

	my $installed_list = $net->get_installed_list ;

If an error occured call the appropriate handler.

In all case return a slackget10::Network::Response (L<slackget10::Network::Response>) object.

=cut

sub get_installed_list {
	my $self = shift;
	my $socket = $self->{SOCKET} ;
	$self->send_data("get_installed_list:$self->{CONNID}\n") ;
	if($self->{handle_responses})
	{
		return $self->_handle_responses("get_installed_list") ;
	}
}

=head2 get_packages_list

get the list of new avalaible packages on the remote daemon.

	my $status = $net->get_packages_list ;

If an error occured call the appropriate handler.

In all case return a slackget10::Network::Response (L<slackget10::Network::Response>) object.

=cut

sub get_packages_list {
	my $self = shift;
	my $socket = $self->{SOCKET} ;
	$self->send_data("get_packages_list:$self->{CONNID}\n") ;
	if($self->{handle_responses})
	{
		return $self->_handle_responses("get_packages_list") ;
	}
}

=head2 get_html_info

Get an HTML encoded string which give some general information on the remote slack-getd

	print $net->get_html_info ;

=cut

sub get_html_info
{
	my $self = shift;
	my $socket = $self->{SOCKET} ;
	$self->send_data("get_html_info:$self->{CONNID}\n") ;
	if($self->{handle_responses})
	{
		return $self->_handle_responses("get_html_info") ;
	}
}

=head2 build_packages_list

Said to the remote slack-getd to build the new packages cache.

	my $status = $net->build_packages_list ;

The returned status contains no significant data in case of success.

=cut

sub build_packages_list
{
	my ($self) = @_ ;
	my $socket = $self->{SOCKET} ;
	$self->send_data("build_packages_list:$self->{CONNID}\n") ;
	if($self->{handle_responses})
	{
		return $self->_handle_responses("build_packages_list") ;
	}
}

=head2 build_installed_list

Said to the remote slack-getd to build the installed packages cache.

	my $status = $net->build_installed_list ;

The returned status contains no significant data in case of success.

=cut

sub build_installed_list
{
	my ($self) = @_ ;
	my $socket = $self->{SOCKET} ;
	$self->send_data("build_installed_list:$self->{CONNID}\n") ;
	if($self->{handle_responses})
	{
		return $self->_handle_responses("build_installed_list") ;
	}
}

=head2 build_media_list

Said to the remote slack-getd to build the media list (medias.xml file).

	my $status = $net->build_media_list ;

The returned status contains no significant data in case of success.

=cut

sub build_media_list
{
	my ($self) = @_ ;
	my $socket = $self->{SOCKET} ;
	$self->send_data("build_media_list:$self->{CONNID}\n") ;
	if($self->{handle_responses})
	{
		return $self->_handle_responses("build_media_list") ;
	}
}

=head2 diskspace

Ask to the remote daemon for the state of the disk space on a specify partition.

	$net->handle_responses(1); # We want slackget10::Network handle the response and return the hashref.
	my $response = $net->diskspace( "/" ) ;
	$net->handle_responses(0);
	print "Free space on remote computer / directory is ",$response->data()->{avalaible_space}," KB\n";

Return a slackget10::Network::Response object which contains (in case of success) a HASHREF build like that :

	$space = {
		device => <NUMBER>,
		total_size => <NUMBER>,
		used_space => <NUMBER>,
		available_space => <NUMBER>,
		use_percentage => <NUMBER>,
		mount_point => <NUMBER>
	};

=cut

sub diskspace
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
				return slackget10::Network::Response->new(
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
		return slackget10::Network::Response->new(
		is_success => 1,
		DATA => $ds
		);
	}
	
}

=head2 search

take at least two parameters : the word you search for, and a field. Valid fields are those who describe a package entity in the packages.xml file.

	my $response = $net->search('gcc','name','description') ; # search for package containing 'gcc' in fields 'name' and 'description'

Return the remote slack-getd's response in the DATA section of the response (L<slackget10::Network::Response>).

=cut

sub search
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

=head2 websearch

Take 2 parameters : a reference on an array which contains the words to search for, and another array reference which contains a list of fields (valid fields are thoses describe in the packages.xml file).


The DATA section of the response (L<slackget10::Network::Response>) will contain an ARRAYREF. Each cell of this array will contains a package in HTML
The returned data is HTML, each package are separed by a line wich only contain the string "__MARK__"

	my $response = $network->websearch([ 'burn', 'cd' ], [ 'name', 'description' ]) ;

=cut

sub websearch
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
				return slackget10::Network::Response->new(
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
		return slackget10::Network::Response->new(
		is_success => 1,
		DATA => $str
		);
	}
	
}

=head2 multisearch

Take 2 parameters : a reference on an array which contains the words to search for, and another array reference which contains a list of fields (valid fields are thoses describe in the packages.xml file).


The DATA section of the response (L<slackget10::Network::Response>) will contain the XML encoded response.

	my $response = $network->websearch([ 'burn', 'cd' ], [ 'name', 'description' ]) ;

=cut

sub multisearch
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


=head2 getfile

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

sub getfile
{
	my $self = shift;
	my %args = @_ ;
# 	my $pkgl = $args{'file'};
	return slackget10::Network::Response->new(
				is_success => undef,
				ERROR_MSG => "An object of slackget10::PackageList type was waited, but another type of object has come.",
				DATA => undef
			) if(ref($args{'file'}) ne 'slackget10::PackageList') ;
# 	my $destdir = shift;
	my $socket = $self->{SOCKET} ;
	my $str = 'The following files have been successfully saved : ';
	my $file;
	my $write_in = 0;
	# TODO: terminé ici : envoyé le message de requete de fichiers, et finir le code de récupération des fichiers (voir par ex si il n'y as pas d'erreur).
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
				return slackget10::Network::Response->new(
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
		return slackget10::Network::Response->new(
		is_success => 1,
		DATA => $str
		);
	}
	
}

=head2 reboot

	This method ask the remote daemon to reboot the remote computer.

=cut

sub reboot
{
	my $self = shift;
	$self->send_data("reboot:$self->{CONNID}\n");
}

=head2 quit

Close the current connection.

	$net->quit ;

=cut

sub quit {
	my ($self,$mess) = @_ ;
	$mess = "end session" unless(defined($mess));
	chomp $mess;
# 	print "[debug slackget10::Network] sending \"quit:$self->{CONNID}:$mess\"\n";
	$self->send_data("quit:$self->{CONNID}:$mess\n") ;
# 	$self->{SOCKET}->close() ;
}

=head1 ACCESSORS

=head2 Socket (read only)

return the current socket (IO::Socket::INET) object.

=cut

=head2 Host

Call the peerhost() method of the current IO::Socket::INET object and return the result.

=cut

sub Host
{
	my $self = shift;
	return $self->{SOCKET}->peerhost() ;
}

sub Socket
{
	my $self = shift;
	return $self->{SOCKET} ;
}

=head2 slackget (read only)

return the current slackget10 object.

=cut

sub slackget
{
	my $self = shift ;
	return $self->{SGO} ;
}

=head2 get_connectionid

Return the (read-only) connection ID.

	$net->get_connectionid

=cut

sub get_connectionid
{
	return $_[0]->{CONNID};
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

=head2 installpkg

	$net->installpkg($packagelist) ;

=cut

sub installpkg
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

=head2 upgradepkg

	$net->upgradepkg($packagelist) ;

=cut

sub upgradepkg
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

=head2 removepkg

Send network commands to a slack-get daemon. This method (like other pkgtools network call), do nothing by herself, but sending a "removepkg:pkg1;pkg2;..;pkgN" to the slack-getd.

	$net->removepkg($packagelist) ;

=cut

sub removepkg
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

=head2 on_success

Just print on standard error output the success message.

THIS FUNCTION CANNOT BE CALL AS AN INSTANCE METHOD

=cut

sub on_success
{
	my $mess = shift;
	die "[event::success] the slackget10::Network::on_success default handler cannot be called as an instance method.\n" if(ref($mess) eq 'slackget10::Network');
	print STDERR "[event::success] $mess\n";
}

=head2 on_error

Just print on standard error output the error message.

THIS FUNCTION CANNOT BE CALL AS AN INSTANCE METHOD

=cut

sub on_error
{
	my $mess = shift;
	die "[event::error] the slackget10::Network::on_error default handler cannot be called as an instance method.\n" if(ref($mess) eq 'slackget10::Network');
	print STDERR "[event::error] $mess\n";
}

=head2 on_unknow

Just print on standard error output an error message with the unknown command.

THIS FUNCTION CANNOT BE CALL AS AN INSTANCE METHOD

=cut

sub on_unknow
{
	my $mess = shift;
	chomp $mess;
	die "[event::unknow] the slackget10::Network::on_unknow default handler cannot be called as an instance method.\n" if(ref($mess) eq 'slackget10::Network');
	print STDERR "[event::unknow] remote slack-getd report an unknow call from this client. the unknown command is '$mess'\n";
}

=head2 on_choice

Default handle for on_choice event. This handler is not really suitable because she automatically choose the first package of the list.

THIS FUNCTION CANNOT BE CALL AS AN INSTANCE METHOD

=cut

sub on_choice
{
	my $xml = shift;
	die "[event::choice] the slackget10::Network::on_choice default handler cannot be called as an instance method.\n" if(ref($xml) eq 'slackget10::Network');
	# TODO: finir cette méthode (implémenter le choix).
}

=head2 on_info

Just print on standard output the info message wich have been receive.

THIS FUNCTION CANNOT BE CALL AS AN INSTANCE METHOD

=cut

sub on_info
{
	my ($ip,$level,$mess)=@_;
	chomp $mess;
	die "[event::info] the slackget10::Network::on_unknow default handler cannot be called as an instance method.\n" if(ref($ip) eq 'slackget10::Network');
	print "[event::info] remote slack-getd ($ip) send an information message \"$mess\" at the importance level $level/3\n";
}

=head1 AUTHOR

DUPUIS Arnaud, C<< <a.dupuis@infinityperl.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-slackget10@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=slackget10>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SEE ALSO

L<slackget10::Network::Response>, L<slackget10::Status>, L<slackget10::Network::Connection>

=head1 COPYRIGHT & LICENSE

Copyright 2005 DUPUIS Arnaud, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of slackget10::Network