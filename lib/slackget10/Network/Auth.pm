package slackget10::Network::Auth;

use warnings;
use strict;

=head1 NAME

slackget10::Network::Auth - The authentification/authorization class for slack-getd network deamons.

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '0.8.7';

=head1 SYNOPSIS

This class is used by slack-get daemon's to verify the permission of an host.

    use slackget10::Network::Auth;

    my $auth = slackget10::Network::Auth->new($config);
    if(!$auth->can_connect($client->peerhost()))
    {
    	$client->close ;
    }
    

=cut

sub new
{
	my ($class,$config) = @_ ;
	return undef if(!defined($config) && ref($config) ne 'slackget10::Config') ;
	my $self={};
	$self->{CONF} = $config ;
	bless($self,$class);
	
	return $self;
}

=head1 CONSTRUCTOR

=head2 new

The constructor just take one argument: a slackget10::Config object :

	my $auth = new slackget10::Network::Auth ($config);

=head1 FUNCTIONS

All methods name are the same as configuration file directives, but you need to change '-' to '_'. 

=head2 RETURNED VALUES

All methods return TRUE (1) if directive is set to 'yes', FALSE (0) if set to 'no' and undef if the directive cannot be found in the slackget10::Config. For some secure reasons, all directives are in read-only access.
But in the real use the undef value must never been returned, because all method fall back to the <all> section on undefined value. So if a method return undef, this is because the <daemon> -> <connection-policy> -> <all> section is not complete, and that's really a very very bad idea !

=head2 can_connect

Take an host address and return the appropriate value.

	$auth->can_connect($client->peerhost) or die "client is not allow to connect\n";

=cut

sub can_connect {
	my ($self,$host) = @_ ;
	if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}))
	{
		if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-connect'}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-connect'}))
		{
			if($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-connect'}=~ /yes/i)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}
	}
	if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-connect'}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-connect'}))
	{
		if($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-connect'}=~ /yes/i)
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}
	else
	{
		return undef;
	}
}

=head2 can_build_packages_list

=cut

sub can_build_packages_list {
	my ($self,$host) = @_ ;
	if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}))
	{
		if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-build-packages-list'}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-build-packages-list'}))
		{
			if($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-build-packages-list'}=~ /yes/i)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}
	}
	if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-build-packages-list'}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-build-packages-list'}))
	{
		if($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-build-packages-list'}=~ /yes/i)
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}
	else
	{
		return undef;
	}
}

=head2 can_build_installed_list

=cut

sub can_build_installed_list {
	my ($self,$host) = @_ ;
	if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}))
	{
		if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-build-installed-list'}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-build-installed-list'}))
		{
			if($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-build-installed-list'}=~ /yes/i)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}
	}
	if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-build-installed-list'}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-build-installed-list'}))
	{
		if($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-build-installed-list'}=~ /yes/i)
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}
	else
	{
		return undef;
	}
}

=head2 can_install_packages

=cut

sub can_install_packages {
	my ($self,$host) = @_ ;
	if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}))
	{
		if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-install-packages'}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-install-packages'}))
		{
			if($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-install-packages'}=~ /yes/i)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}
	}
	if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-install-packages'}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-install-packages'}))
	{
		if($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-install-packages'}=~ /yes/i)
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}
	else
	{
		return undef;
	}
}

=head2 can_upgrade_packages

=cut

sub can_upgrade_packages {
	my ($self,$host) = @_ ;
	if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}))
	{
		if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-upgrade-packages'}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-upgrade-packages'}))
		{
			if($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-upgrade-packages'}=~ /yes/i)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}
	}
	if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-upgrade-packages'}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-upgrade-packages'}))
	{
		if($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-upgrade-packages'}=~ /yes/i)
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}
	else
	{
		return undef;
	}
}

=head2 can_remove_packages

=cut

sub can_remove_packages {
	my ($self,$host) = @_ ;
	if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}))
	{
		if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-remove-packages'}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-remove-packages'}))
		{
			if($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-remove-packages'}=~ /yes/i)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}
	}
	if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-remove-packages'}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-remove-packages'}))
	{
		if($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-remove-packages'}=~ /yes/i)
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}
	else
	{
		return undef;
	}
}

=head2 can_require_installed_list

=cut

sub can_require_installed_list {
	my ($self,$host) = @_ ;
	if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}))
	{
		if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-require-installed-list'}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-require-installed-list'}))
		{
			if($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-require-installed-list'}=~ /yes/i)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}
	}
	if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-require-installed-list'}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-require-installed-list'}))
	{
		if($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-require-installed-list'}=~ /yes/i)
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}
	else
	{
		return undef;
	}
}

=head2 can_require_servers_list

=cut

sub can_require_servers_list {
	my ($self,$host) = @_ ;
	if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}))
	{
		if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-require-servers-list'}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-require-servers-list'}))
		{
			if($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-require-servers-list'}=~ /yes/i)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}
	}
	if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-require-servers-list'}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-require-servers-list'}))
	{
		if($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-require-servers-list'}=~ /yes/i)
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}
	else
	{
		return undef;
	}
}

=head2 can_require_packages_list

=cut

sub can_require_packages_list {
	my ($self,$host) = @_ ;
	if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}))
	{
		if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-require-packages-list'}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-require-packages-list'}))
		{
			if($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-require-packages-list'}=~ /yes/i)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}
	}
	if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-require-packages-list'}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-require-packages-list'}))
	{
		if($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-require-packages-list'}=~ /yes/i)
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}
	else
	{
		return undef;
	}
}


=head2 can_search

=cut

sub can_search {
	my ($self,$host) = @_ ;
	if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}))
	{
		if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-search'}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-search'}))
		{
			if($self->{CONF}->{daemon}->{'connection-policy'}->{host}->{"$host"}->{'can-search'}=~ /yes/i)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}
	}
	if(exists($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-search'}) && defined($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-search'}))
	{
		if($self->{CONF}->{daemon}->{'connection-policy'}->{all}->{'can-search'}=~ /yes/i)
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}
	else
	{
		return undef;
	}
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

1; # End of slackget10::Network::Auth
