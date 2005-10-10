package slackget10::Network;

use warnings;
use strict;
require slackget10::Network::Response ;

=head1 NAME

slackget10::Network - A class for network communication

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '0.5.8';

=head1 SYNOPSIS

This class' purpose is to make all network dialog transparent. Instead of sending 

    use slackget10::Network;

    my $net = slackget10::Network->new(
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
	return undef unless(defined($args{'socket'})) ;
	return undef unless($args{'socket'});
	my $self={
		on_success => \&on_success ,
		on_error => \&on_error,
		on_unknow => \&on_unknow,
		on_choice => \&on_choice,
		on_info => \&on_info
	};
	$self->{'on_error'} = $args{'on_error'} if($args{'on_error'} && ref($args{'on_error'}) eq 'CODE') ;
	$self->{'on_success'} = $args{'on_success'} if($args{'on_success'} && ref($args{'on_success'}) eq 'CODE') ;
	$self->{'on_choice'} = $args{'on_choice'} if($args{'on_choice'} && ref($args{'on_choice'}) eq 'CODE') ;
	$self->{'on_info'} = $args{'on_info'} if($args{'on_info'} && ref($args{'on_info'}) eq 'CODE') ;
	$self->{'on_unknow'} = $args{'on_unknow'} if($args{'on_unknow'} && ref($args{'on_unknow'}) eq 'CODE') ;
	$self->{SGO} = $args{'slackget_object'} if($args{'slackget_object'} && ref($args{'slackget_object'}) eq 'slackget10');
	$self->{SOCKET} = $args{'socket'} ;
	$self->{TIMEOUT} = 3;
	$self->{TIMEOUT} = $args{'timeout'} if(defined($args{'timeout'})) ;
	bless($self,$class);
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

B<slackget_object> : a reference to a valide slackget10 object.

B<on_error> [handler] : a CODE reference to a sub which will be call on each error message returned by the server. This sub must take a string (the error message) as argument.

B<on_success> [handler] : a CODE reference to a sub which will be call on each success message returned by the server. This sub must take a string (the error message) as argument.

B<on_unknow> [handler] : a CODE reference to a sub which will be call on each unknown command message returned by the remote slack-getd. This sub must take a string (the error message) as argument.

B<on_choice> [handler] : a CODE reference to a sub wich will be call each time a choice is needed. This sub must take a reference to an array as first argument and the whole XML string which represent the choice as second argument. The arrayref is where the treatment method will put the result of the choice. Please look at the source code of the on_choice method for more informations.

There is also one special event : 'end' which is not hookable. It may be in the futur but this event is send when all treatment and data relative to the last command are terminate (but there is no information about the state in this event). It seems that this is usefull only to this module's methods.

Look at the L<DEFAULT HANDLERS> section for more informations one default handlers.

=head1 FUNCTIONS

All methods return a slackget10::Network::Response (L<slackget10::Network::Response>) object, and if the remote slack-getd return some data they are accessibles via the data() accessor of the slackget10::Network::Response object.

=cut

sub _handle_protocol
{
	my $self = shift ;
# 	my $mess = shift;
	if($_[0]=~/^error:\s*(.*)/)
	{
		print "Handling protocol : error msg calling $self->{'on_error'}\n";
		$self->{'on_error'}->("[".$self->{SOCKET}->peerhost()."] $1");
		$_[0] =~ s/.*//g;
	}
	elsif($_[0]=~/^success:\s*(.*)/)
	{
		print "Handling protocol : success msg calling $self->{'on_success'}\n";
		$self->{'on_success'}->("[".$self->{SOCKET}->peerhost()."] $1");
		$_[0] =~ s/.*//g;
	}
	elsif($_[0]=~/^unknown_said:\s*(.*)/)
	{
		print "Handling protocol : unknow msg calling $self->{'on_unknow'}\n";
		$self->{'on_unknow'}->("[".$self->{SOCKET}->peerhost()."] $1");
		$_[0] =~ s/.*//g;
	}
	elsif($_[0]=~/^choice:\s*(.*)/)
	{
		print "Handling protocol : choice msg calling $self->{'on_choice'}\n";
		$self->{'on_choice'}->("[".$self->{SOCKET}->peerhost()."] $1");
		$_[0] =~ s/.*//g;
	}
	elsif($_[0]=~ /^info:(\d+):\s*(.*)/)
	{
		print "Handling protocol : info msg calling $self->{'on_info'}\n";
		$self->{'on_info'}->($1,"[".$self->{SOCKET}->peerhost()."] $1");
		$_[0] =~ s/.*//g;
	}
	
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
	print $socket "get_installed_list\n";
	my $str = '';
	while(<$socket>)
	{
		if($_=~ /^wait:/)
		{
			sleep 1;
			next ;
		}
		last if($_=~ /^end: get_installed_list/);
		if ($_=~ /auth_violation:\s*(.*)/)
		{
			return slackget10::Network::Response->new(
				is_success => undef,
				ERROR_MSG => $1,
				DATA => $_
			);
			last ;
		}
		$self->_handle_protocol($_) ;
		$str .= $_;
	}
	return slackget10::Network::Response->new(
	is_success => 1,
	DATA => $str
	);
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
	print $socket "get_packages_list\n";
	my $str = '';
	while(<$socket>)
	{
		if($_=~ /^wait:/)
		{
			print "[DEBUG] daemon ask us to wait\n";
			sleep 1;
			next ;
		}
		last if($_=~ /^end: get_packages_list/);
		if ($_=~ /auth_violation:\s*(.*)/)
		{
			return slackget10::Network::Response->new(
				is_success => undef,
				ERROR_MSG => $1,
				DATA => $_
			);
			last ;
		}
		$self->_handle_protocol($_) ;
		$str .= $_ if($_);
	}
	return slackget10::Network::Response->new(
	is_success => 1,
	DATA => $str
	);
}

=head2 get_html_info

Get an HTML encoded string which give some general information on the remote slack-getd

	print $net->get_html_info ;

=cut

sub get_html_info
{
	my $self = shift;
	my $socket = $self->{SOCKET} ;
	print $socket "get_html_info\n";
	my $str = '';
	while(<$socket>)
	{
		if($_=~ /^wait:/)
		{
			sleep 1;
			next ;
		}
		last if($_=~ /^end: get_html_info/);
		if ($_=~ /auth_violation:\s*(.*)/)
		{
			return slackget10::Network::Response->new(
				is_success => undef,
				ERROR_MSG => $1,
				DATA => $_
			);
			last ;
		}
		$self->_handle_protocol($_) ;
		$str .= $_;
	}
	return $str;
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
	print $socket "build_packages_list\n";
	my $str = '';
	while(<$socket>)
	{
		if($_=~ /^wait:/)
		{
			sleep 1;
			next ;
		}
		last if($_=~ /^end: build_packages_list/);
		if ($_=~ /auth_violation:\s*(.*)/)
		{
			return slackget10::Network::Response->new(
				is_success => undef,
				ERROR_MSG => $1,
				DATA => $_
			);
			last ;
		}
		$self->_handle_protocol($_) ;
		$str .= $_;
	}
	return slackget10::Network::Response->new(
	is_success => 1,
	DATA => $str
	);
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
	print $socket "build_installed_list\n";
	my $str = '';
	while(<$socket>)
	{
		if($_=~ /^wait:/)
		{
			sleep 1;
			next ;
		}
		last if($_=~ /^end: build_installed_list/);
		if ($_=~ /auth_violation:\s*(.*)/)
		{
			return slackget10::Network::Response->new(
				is_success => undef,
				ERROR_MSG => $1,
				DATA => $_
			);
			last ;
		}
		$self->_handle_protocol($_) ;
		$str .= $_;
	}
	return slackget10::Network::Response->new(
	is_success => 1,
	DATA => $str
	);
}

=head2 build_server_list

Said to the remote slack-getd to build the server list (servers.xml file).

	my $status = $net->build_server_list ;

The returned status contains no significant data in case of success.

=cut

sub build_server_list
{
	my ($self) = @_ ;
	my $socket = $self->{SOCKET} ;
	print $socket "build_packages_list\n";
	my $str = '';
	while(<$socket>)
	{
		if($_=~ /^wait:/)
		{
			sleep 1;
			next ;
		}
		last if($_=~ /^end: build_server_list/);
		if ($_=~ /auth_violation:\s*(.*)/)
		{
			return slackget10::Network::Response->new(
				is_success => undef,
				ERROR_MSG => $1,
				DATA => $_
			);
			last ;
		}
		$self->_handle_protocol($_) ;
		$str .= $_;
	}
	return slackget10::Network::Response->new(
	is_success => 1,
	DATA => $str
	);
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
	print $socket "search:$word:$fields\n";
	my $str = '';
	while(<$socket>)
	{
		if($_=~ /^wait:/)
		{
			sleep 1;
			next ;
		}
		last if($_=~ /^end: search/);
		if ($_=~ /auth_violation:\s*(.*)/)
		{
			return slackget10::Network::Response->new(
				is_success => undef,
				ERROR_MSG => $1,
				DATA => $_
			);
			last ;
		}
		$self->_handle_protocol($_) ;
		$str .= $_;
	}
	return slackget10::Network::Response->new(
	is_success => 1,
	DATA => $str
	);
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
	print $socket "websearch:$words:$fields\n";
	my $str = [];
	my $idx = 0;
	while(<$socket>)
	{
		if($_=~ /^wait:/)
		{
			sleep 1;
			next ;
		}
		last if($_=~ /^end: websearch/);
		if ($_=~ /auth_violation:\s*(.*)/)
		{
			return slackget10::Network::Response->new(
				is_success => undef,
				ERROR_MSG => $1,
				DATA => $_
			);
			last ;
		}
		$self->_handle_protocol($_) ;
		if($_=~/__MARK__/)
		{
			$idx++;
		}
		else
		{
			$str->[$idx] .= $_;
		}
	}
	return slackget10::Network::Response->new(
	is_success => 1,
	DATA => $str
	);
}

=head2 Host

Call the peerhost() method of the current IO::Socket::INET object and return the result.

=cut

sub Host
{
	my $self = shift;
	return $self->{SOCKET}->peerhost() ;
}

=head1 ACCESSORS

=head2 Socket

return the current socket (IO::Socket::INET) object.

=cut

sub Socket
{
	my $self = shift;
	return $self->{SOCKET} ;
}

=head2 slackget

return the current slackget10 object.

=cut

sub slackget
{
	my $self = shift ;
	return $self->{SGO} ;
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
	foreach (@{$packagelist->get_all})
	{
		#TODO: finir d'écrire le traitement 
	}
	return 1;
}

=head2 upgradepkg

=cut

sub upgradepkg
{
	my ($self) = @_ ;
}

=head2 removepkg

=cut

sub removepkg
{
	my ($self) = @_ ;
}

=head2 quit

Close the current connection.

	$net->quit ;

=cut

sub quit {
	my ($self,$mess) = @_ ;
	my $socket = $self->{SOCKET} ;
	if(defined($mess))
	{
		print $socket "quit: $mess\n";
	}
	else
	{
		print $socket "quit: end session\n";
	}
	$self->{SOCKET}->close() ;
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
	my $arrayref = shift;
	my $xml = shift;
	die "[event::choice] the slackget10::Network::on_choice default handler cannot be called as an instance method.\n" if(ref($arrayref) eq 'slackget10::Network');
	# TODO: finir cette méthode (implémenter le choix).
}

=head2 on_info

Just print on standard output the info message wich have been receive.

THIS FUNCTION CANNOT BE CALL AS AN INSTANCE METHOD

=cut

sub on_info
{
	my $mess = shift;
	chomp $mess;
	die "[event::info] the slackget10::Network::on_unknow default handler cannot be called as an instance method.\n" if(ref($mess) eq 'slackget10::Network');
	print "[event::info] remote slack-getd send an information message \"$mess\"\n";
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